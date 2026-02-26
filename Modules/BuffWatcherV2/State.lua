local _, ns = ...

-- BuffWatcherV2 State Module
-- Central state tables and utility functions

local BWV2 = {}
ns.BWV2 = BWV2

-- State tables
BWV2.raidResults = {}       -- unit -> { buffs = {spellID = auraData}, spec = id }
BWV2.missingByPlayer = {}   -- unit -> { categoryKey = true, ... }
BWV2.activeWatchers = {}    -- unit -> frame (one per unit with missing buffs)
BWV2.inventoryStatus = {}   -- key -> { name, count, pass = true }
BWV2.scanInProgress = false
BWV2.lastScanTime = 0

-- Buff-drop monitoring: tracks buffs that were present at last scan
BWV2.buffSnapshot = {}        -- key -> { name, spellIDs, icon, category, iconCheck }
BWV2.buffDropReminded = {}    -- key -> true (already reminded, won't re-remind)

-- Report card results (full pass/fail data with icons)
BWV2.scanResults = {
    raidBuffs = {},      -- { key, name, spellID, icon, pass, covered, total }
    presenceBuffs = {},  -- { key, name, spellID, icon, pass, class }
    consumables = {},    -- { key, name, spellID, icon, pass, remaining }
    inventory = {},      -- { key, name, itemID, icon, pass, count }
    classBuffs = {},     -- { key, name, spellID, icon, pass }
}

-- Reset all state tables
function BWV2:ResetState()
    wipe(self.raidResults)
    wipe(self.missingByPlayer)
    wipe(self.inventoryStatus)
    -- Ensure scanResults sub-tables exist before wiping
    if not self.scanResults then
        self.scanResults = {}
    end
    self.scanResults.raidBuffs = self.scanResults.raidBuffs or {}
    self.scanResults.presenceBuffs = self.scanResults.presenceBuffs or {}
    self.scanResults.consumables = self.scanResults.consumables or {}
    self.scanResults.inventory = self.scanResults.inventory or {}
    self.scanResults.classBuffs = self.scanResults.classBuffs or {}
    -- Reset scan results for report card
    wipe(self.scanResults.raidBuffs)
    wipe(self.scanResults.presenceBuffs)
    wipe(self.scanResults.consumables)
    wipe(self.scanResults.inventory)
    wipe(self.scanResults.classBuffs)
    -- Note: watchers should be cleaned up via Watchers.RemoveAllWatchers() before reset
    self.scanInProgress = false
end

-- Detect current content type for threshold selection
function BWV2:GetCurrentContentType()
    local inInstance, instanceType = IsInInstance()
    if not inInstance then
        return "other"
    elseif instanceType == "raid" then
        return "raid"
    else
        return "dungeon"
    end
end

-- Check if a class is present in the current group
function BWV2:HasClassInGroup(className)
    local inRaid = IsInRaid()
    local groupSize = GetNumGroupMembers()

    if groupSize == 0 then
        -- Solo player
        local _, playerClass = UnitClass("player")
        return playerClass == className
    end

    for i = 1, groupSize do
        local unit
        if inRaid then
            unit = "raid" .. i
        else
            unit = (i == 1) and "player" or ("party" .. (i - 1))
        end

        if UnitExists(unit) then
            local _, unitClass = UnitClass(unit)
            if unitClass == className then
                return true
            end
        end
    end

    return false
end

-- Get player's current specialization ID
function BWV2:GetPlayerSpecID()
    local specIndex = GetSpecialization()
    if specIndex then
        return GetSpecializationInfo(specIndex)
    end
    return nil
end

-- Check if player has a specific talent/spell known
function BWV2:PlayerHasTalent(spellID)
    return ns.IsPlayerSpell(spellID)
end

-- Initialize default saved variables if needed
function BWV2:InitSavedVars()
    if not NaowhQOL then NaowhQOL = {} end
    if not NaowhQOL.buffWatcherV2 then
        NaowhQOL.buffWatcherV2 = {
            enabled = true,
            userEntries = {
                raidBuffs = { spellIDs = {} },
                consumables = { spellIDs = {} },
                shamanImbues = { enchantIDs = {} },
                roguePoisons = { enchantIDs = {} },
                shamanShields = { spellIDs = {} },
            },
            categoryEnabled = {
                raidBuffs = true,
                consumables = true,
                shamanImbues = true,
                roguePoisons = true,
                shamanShields = true,
            },
            thresholds = {
                dungeon = 2400,  -- 40 min in seconds
                raid = 900,      -- 15 min
                other = 300,     -- 5 min
            },
            talentMods = {
                -- Default example: Dragon-Tempered Blades for rogue poisons
                roguePoisons = {
                    { type = "requireCount", talentID = 381802, count = 4 },
                },
            },
            -- Track which default spells user has disabled per category
            disabledDefaults = {},
            -- Per-consumable group enable/disable
            consumableGroupEnabled = {
                flask = true,
                food = true,
                rune = true,
                weaponBuff = true,
            },
            -- Auto-use item IDs for consumables (click-to-use on report card)
            consumableAutoUse = {
                flask = nil,
                food = nil,
                rune = nil,
                weaponBuff = nil,
            },
            -- Per-inventory group enable/disable
            inventoryGroupEnabled = {
                dpsPotion = true,
                healthPotion = true,
                healthstone = true,
                gatewayControl = true,
                manaBun = false,
            },
            -- Class-specific buff groups (user-defined)
            classBuffs = {
                WARRIOR     = { enabled = true, groups = {} },
                PALADIN     = { enabled = true, groups = {} },
                HUNTER      = { enabled = true, groups = {} },
                ROGUE       = { enabled = true, groups = {} },
                PRIEST      = { enabled = true, groups = {} },
                DEATHKNIGHT = { enabled = true, groups = {} },
                SHAMAN      = { enabled = true, groups = {} },
                MAGE        = { enabled = true, groups = {} },
                WARLOCK     = { enabled = true, groups = {} },
                MONK        = { enabled = true, groups = {} },
                DRUID       = { enabled = true, groups = {} },
                DEMONHUNTER = { enabled = true, groups = {} },
                EVOKER      = { enabled = true, groups = {} },
            },
            -- Report card frame position
            reportCardPosition = nil,  -- { point, x, y }
            -- Buff drop alert position
            buffDropPosition = nil,    -- { point, x, y }
            -- Report card display settings
            reportCardIconSize = 32,
            reportCardUnlock = false,
            reportCardScale = 1.0,
            reportCardAutoCloseDelay = 5,
            scanOnLogin = false,
            -- Last expanded config section (for tab memory)
            lastSection = "classBuffs",
            -- Chat output toggle
            chatReportEnabled = false,
            -- Buff-drop reminder (notify when a previously-present buff expires)
            buffDropReminder = true,
        }
    end

    -- Migration: ensure tables exist for existing users
    if not NaowhQOL.buffWatcherV2.disabledDefaults then
        NaowhQOL.buffWatcherV2.disabledDefaults = {}
    end
    if not NaowhQOL.buffWatcherV2.consumableGroupEnabled then
        NaowhQOL.buffWatcherV2.consumableGroupEnabled = {
            flask = true,
            food = true,
            rune = true,
            weaponBuff = true,
        }
    end
    if not NaowhQOL.buffWatcherV2.inventoryGroupEnabled then
        NaowhQOL.buffWatcherV2.inventoryGroupEnabled = {
            healthPotion = true,
            healthstone = true,
            gatewayControl = true,
            manaBun = false,
        }
    end
    if not NaowhQOL.buffWatcherV2.consumableAutoUse then
        NaowhQOL.buffWatcherV2.consumableAutoUse = {}
    end
    if not NaowhQOL.buffWatcherV2.classBuffs then
        NaowhQOL.buffWatcherV2.classBuffs = {
            WARRIOR     = { enabled = true, groups = {} },
            PALADIN     = { enabled = true, groups = {} },
            HUNTER      = { enabled = true, groups = {} },
            ROGUE       = { enabled = true, groups = {} },
            PRIEST      = { enabled = true, groups = {} },
            DEATHKNIGHT = { enabled = true, groups = {} },
            SHAMAN      = { enabled = true, groups = {} },
            MAGE        = { enabled = true, groups = {} },
            WARLOCK     = { enabled = true, groups = {} },
            MONK        = { enabled = true, groups = {} },
            DRUID       = { enabled = true, groups = {} },
            DEMONHUNTER = { enabled = true, groups = {} },
            EVOKER      = { enabled = true, groups = {} },
        }
    end
    if NaowhQOL.buffWatcherV2.chatReportEnabled == nil then
        NaowhQOL.buffWatcherV2.chatReportEnabled = false
    end
    -- Report card display settings migration
    if NaowhQOL.buffWatcherV2.reportCardIconSize == nil then
        NaowhQOL.buffWatcherV2.reportCardIconSize = 32
    end
    if NaowhQOL.buffWatcherV2.reportCardUnlock == nil then
        NaowhQOL.buffWatcherV2.reportCardUnlock = false
    end
    if NaowhQOL.buffWatcherV2.reportCardScale == nil then
        NaowhQOL.buffWatcherV2.reportCardScale = 1.0
    end
    if NaowhQOL.buffWatcherV2.reportCardAutoCloseDelay == nil then
        NaowhQOL.buffWatcherV2.reportCardAutoCloseDelay = 5
    end
    if NaowhQOL.buffWatcherV2.scanOnLogin == nil then
        NaowhQOL.buffWatcherV2.scanOnLogin = false
    end
    if NaowhQOL.buffWatcherV2.buffDropReminder == nil then
        NaowhQOL.buffWatcherV2.buffDropReminder = true
    end

    -- Apply default class buff groups for classes with empty groups (one-time migration)
    if not NaowhQOL.buffWatcherV2._classBuffDefaultsVersion then
        local Categories = ns.BWV2Categories
        local defaults = Categories and Categories.DEFAULT_CLASS_BUFFS
        if defaults and NaowhQOL.buffWatcherV2.classBuffs then
            for className, classData in pairs(NaowhQOL.buffWatcherV2.classBuffs) do
                if classData.groups and #classData.groups == 0 and defaults[className] then
                    for _, group in ipairs(defaults[className]) do
                        -- Shallow+1 copy to avoid reference issues
                        local copy = {}
                        for k, v in pairs(group) do
                            if type(v) == "table" then
                                local t = {}
                                for k2, v2 in pairs(v) do
                                    t[k2] = v2
                                end
                                copy[k] = t
                            else
                                copy[k] = v
                            end
                        end
                        classData.groups[#classData.groups + 1] = copy
                    end
                end
            end
        end
        NaowhQOL.buffWatcherV2._classBuffDefaultsVersion = 1
    end
end

-- Get saved variables table
function BWV2:GetDB()
    self:InitSavedVars()
    return NaowhQOL.buffWatcherV2
end

-- Check if module is enabled
function BWV2:IsEnabled()
    local db = self:GetDB()
    return db.enabled
end

-- Get threshold for current content type
function BWV2:GetThreshold()
    local db = self:GetDB()
    local contentType = self:GetCurrentContentType()
    return db.thresholds[contentType] or 300
end

---------------------------------------------------------------------------
-- BUFF-DROP MONITORING
-- After a scan, snapshot which tracked buffs the player currently has.
-- Then on UNIT_AURA we check if any snapshot buff disappeared.
-- Only reminds once per buff until the next full scan or /nscan.
---------------------------------------------------------------------------

-- Build a snapshot of all passing buffs on the player after a scan.
function BWV2:BuildBuffSnapshot()
    wipe(self.buffSnapshot)
    wipe(self.buffDropReminded)

    local results = self.scanResults
    local Categories = ns.BWV2Categories
    if not results or not Categories then return end

    -- Raid buffs that passed — store all variant spellIDs so we detect any variant
    for _, entry in ipairs(results.raidBuffs or {}) do
        if entry.pass then
            for _, buff in ipairs(Categories.RAID) do
                if buff.key == entry.key then
                    local ids = type(buff.spellID) == "table" and buff.spellID or {buff.spellID}
                    self.buffSnapshot[entry.key] = {
                        name = entry.name,
                        spellIDs = ids,
                        icon = entry.icon,
                        category = "raidBuff",
                    }
                    break
                end
            end
        end
    end

    -- Consumables that passed (spell-based only; skip icon-only / weapon / inventory)
    for _, entry in ipairs(results.consumables or {}) do
        if entry.pass and not entry.unconfigured then
            local ids = {}
            local iconCheck = nil
            for _, grp in ipairs(Categories.CONSUMABLE_GROUPS) do
                if grp.key == entry.key then
                    if grp.checkType == "icon" and grp.buffIconID then
                        -- Icon-based (e.g. food) — store iconID for matching
                        iconCheck = grp.buffIconID
                    elseif grp.checkType == "weaponEnchant" then
                        -- skip weapon enchants (not aura-based)
                        break
                    elseif grp.spellIDs then
                        for _, id in ipairs(grp.spellIDs) do
                            ids[#ids + 1] = id
                        end
                    end
                    break
                end
            end
            if #ids > 0 or iconCheck then
                self.buffSnapshot[entry.key] = {
                    name = entry.name,
                    spellIDs = ids,
                    icon = entry.icon,
                    category = "consumable",
                    iconCheck = iconCheck,
                }
            end
        end
    end

    -- Class buffs that passed (self-buff type only — those are auras on player)
    for _, entry in ipairs(results.classBuffs or {}) do
        if entry.pass and entry.checkType == "self" then
            local _, playerClass = UnitClass("player")
            local db = self:GetDB()
            local classData = db.classBuffs and db.classBuffs[playerClass]
            if classData then
                for _, group in ipairs(classData.groups or {}) do
                    if group.key == entry.key and group.spellIDs then
                        self.buffSnapshot[entry.key] = {
                            name = entry.name,
                            spellIDs = group.spellIDs,
                            icon = entry.icon,
                            category = "classBuff",
                        }
                        break
                    end
                end
            end
        end
    end
end

-- Check if any snapshot buffs have dropped from the player.
-- Returns a list of dropped buff entries (empty if nothing dropped).
function BWV2:CheckBuffDrops()
    if not self.buffSnapshot or not next(self.buffSnapshot) then
        return nil
    end

    local dropped = {}

    for key, data in pairs(self.buffSnapshot) do
        if not self.buffDropReminded[key] then
            local stillPresent = false

            -- Spell-ID based check
            if data.spellIDs and #data.spellIDs > 0 then
                for _, spellID in ipairs(data.spellIDs) do
                    local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                    if aura then
                        stillPresent = true
                        break
                    end
                end
            end

            -- Icon-based check (e.g. food buff)
            if not stillPresent and data.iconCheck then
                local idx = 1
                local auraData = C_UnitAuras.GetAuraDataByIndex("player", idx, "HELPFUL")
                while auraData do
                    if auraData.icon == data.iconCheck then
                        stillPresent = true
                        break
                    end
                    idx = idx + 1
                    auraData = C_UnitAuras.GetAuraDataByIndex("player", idx, "HELPFUL")
                end
            end

            if not stillPresent then
                local entry = {}
                for k, v in pairs(data) do entry[k] = v end
                entry.key = key
                dropped[#dropped + 1] = entry
                self.buffDropReminded[key] = true
            end
        end
    end

    return (#dropped > 0) and dropped or nil
end

-- Clear the snapshot (called on scan reset or disable)
function BWV2:ClearBuffSnapshot()
    wipe(self.buffSnapshot)
    wipe(self.buffDropReminded)
end
