local _, ns = ...

local function IsSecret(v)
    return issecretvalue and issecretvalue(v) or false
end

local BWV2 = {}
ns.BWV2 = BWV2

BWV2.scanInProgress = false
BWV2.lastScanTime = 0
BWV2.dirty = false
BWV2.inCombat = false
BWV2.inEncounter = false
BWV2.inReadyCheck = false
BWV2.inMythicPlus = false
BWV2.isDead = false

BWV2.scanResults = {
    raidBuffs = {},
    consumables = {},
    inventory = {},
    classBuffs = {},
}

BWV2.raidResults = {}
BWV2.missingByPlayer = {}
BWV2.inventoryStatus = {}
BWV2.missingByCategory = {}

BWV2.activeAlerts = {}
BWV2.dismissedAlerts = {}

BWV2.classBuffSelfCache = {}
BWV2.classBuffInstanceIDs = {}

function BWV2:SetDirty()
    self.dirty = true
end

function BWV2:IsRestricted()
    return self.inCombat or self.inMythicPlus
end

function BWV2:ResetState()
    wipe(self.raidResults)
    wipe(self.missingByPlayer)
    wipe(self.inventoryStatus)
    if not self.scanResults then
        self.scanResults = {}
    end
    self.scanResults.raidBuffs = self.scanResults.raidBuffs or {}
    self.scanResults.consumables = self.scanResults.consumables or {}
    self.scanResults.inventory = self.scanResults.inventory or {}
    self.scanResults.classBuffs = self.scanResults.classBuffs or {}
    wipe(self.scanResults.raidBuffs)
    wipe(self.scanResults.consumables)
    wipe(self.scanResults.inventory)
    wipe(self.scanResults.classBuffs)
    self.scanInProgress = false
end

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

function BWV2:HasClassInGroup(className)
    local inRaid = IsInRaid()
    local groupSize = GetNumGroupMembers()

    if groupSize == 0 then
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

function BWV2:GetPlayerSpecID()
    local specIndex = GetSpecialization()
    if specIndex then
        return GetSpecializationInfo(specIndex)
    end
    return nil
end

function BWV2:PlayerHasTalent(spellID)
    if not spellID then return false end
    return ns.IsPlayerSpell(spellID)
end

function BWV2:IsSpellCombatSafe(spellID)
    return ns.CombatSafeSpells and ns.CombatSafeSpells[spellID] == true
end

function BWV2:HasCombatSafeSpell(spellIDs)
    if not spellIDs then return false end
    for _, id in ipairs(spellIDs) do
        if self:IsSpellCombatSafe(id) then
            return true
        end
    end
    return false
end

function BWV2:GetCombatSafeSpellIDs(spellIDs)
    if not spellIDs then return {} end
    local safe = {}
    for _, id in ipairs(spellIDs) do
        if self:IsSpellCombatSafe(id) then
            safe[#safe + 1] = id
        end
    end
    return safe
end

function BWV2:IsAuraTrackable(spellIDs, checkType)
    if checkType == "weaponEnchant" then return true end
    if checkType == "inventory" then return true end
    if checkType == "icon" then return false end
    if not self:IsRestricted() then return true end
    if not spellIDs then return true end
    if type(spellIDs) == "number" then
        return self:IsSpellCombatSafe(spellIDs)
    end
    for _, id in ipairs(spellIDs) do
        if not self:IsSpellCombatSafe(id) then
            return false
        end
    end
    return true
end

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
                dungeon = 2400,
                raid = 900,
                other = 300,
            },
            talentMods = {
                roguePoisons = {
                    { type = "requireCount", talentID = 381802, count = 4 },
                },
            },
            disabledDefaults = {},
            consumableGroupEnabled = {
                flask = true,
                food = true,
                rune = true,
                weaponBuff = true,
            },
            consumableAutoUse = {
                flask = nil,
                food = nil,
                rune = nil,
                weaponBuff = nil,
            },
            inventoryGroupEnabled = {
                dpsPotion = true,
                healthPotion = true,
                healthstone = true,
                gatewayControl = true,
                manaBun = false,
            },
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
            reportCardPosition = nil,
            buffDropPosition = nil,
            reportCardIconSize = 32,
            reportCardUnlock = false,
            reportCardScale = 1.0,
            reportCardAutoCloseDelay = 5,
            scanOnLogin = false,
            lastSection = "classBuffs",
            chatReportEnabled = false,
            buffDropReminder = true,
            buffDropIconSize = 32,
            buffDropScale = 1.0,
            buffDropUnlock = false,
            buffDropGlowType = 4,
            buffDropGlowR = 0.95,
            buffDropGlowG = 0.95,
            buffDropGlowB = 0.32,
            buffDropGlowUseClassColor = false,
            buffDropGlowPixelLines = 8,
            buffDropGlowPixelFrequency = 0.25,
            buffDropGlowPixelLength = 4,
            buffDropGlowAutocastParticles = 4,
            buffDropGlowAutocastFrequency = 0.125,
            buffDropGlowAutocastScale = 1.0,
            buffDropGlowBorderFrequency = 0.125,
            buffDropGlowProcDuration = 1,
            buffDropGlowProcStartAnim = false,
            buffDropAlertInstanceOnly = false,
            buffDropAlertDisableRested = false,
            buffDropTextFontSize = 11,
            raidBuffAlwaysCheck = false,
            classBuffAlwaysCheck = false,
            consumableAlwaysCheck = false,
            inventoryAlwaysCheck = false,
        }
    end

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
    if NaowhQOL.buffWatcherV2.raidBuffAlwaysCheck == nil then
        NaowhQOL.buffWatcherV2.raidBuffAlwaysCheck = false
    end
    if NaowhQOL.buffWatcherV2.classBuffAlwaysCheck == nil then
        NaowhQOL.buffWatcherV2.classBuffAlwaysCheck = false
    end
    if NaowhQOL.buffWatcherV2.consumableAlwaysCheck == nil then
        NaowhQOL.buffWatcherV2.consumableAlwaysCheck = false
    end
    if NaowhQOL.buffWatcherV2.inventoryAlwaysCheck == nil then
        NaowhQOL.buffWatcherV2.inventoryAlwaysCheck = false
    end
    if NaowhQOL.buffWatcherV2.buffDropIconSize == nil then
        NaowhQOL.buffWatcherV2.buffDropIconSize = 32
    end
    if NaowhQOL.buffWatcherV2.buffDropScale == nil then
        NaowhQOL.buffWatcherV2.buffDropScale = 1.0
    end
    if NaowhQOL.buffWatcherV2.buffDropUnlock == nil then
        NaowhQOL.buffWatcherV2.buffDropUnlock = false
    end
    if NaowhQOL.buffWatcherV2.buffDropGlowType == nil then
        NaowhQOL.buffWatcherV2.buffDropGlowType = 4
    end
    if NaowhQOL.buffWatcherV2.buffDropGlowR == nil then
        NaowhQOL.buffWatcherV2.buffDropGlowR = 0.95
    end
    if NaowhQOL.buffWatcherV2.buffDropGlowG == nil then
        NaowhQOL.buffWatcherV2.buffDropGlowG = 0.95
    end
    if NaowhQOL.buffWatcherV2.buffDropGlowB == nil then
        NaowhQOL.buffWatcherV2.buffDropGlowB = 0.32
    end
    if NaowhQOL.buffWatcherV2.buffDropGlowUseClassColor == nil then
        NaowhQOL.buffWatcherV2.buffDropGlowUseClassColor = false
    end
    if NaowhQOL.buffWatcherV2.buffDropGlowPixelLines == nil then
        NaowhQOL.buffWatcherV2.buffDropGlowPixelLines = 8
    end
    if NaowhQOL.buffWatcherV2.buffDropGlowPixelFrequency == nil then
        NaowhQOL.buffWatcherV2.buffDropGlowPixelFrequency = 0.25
    end
    if NaowhQOL.buffWatcherV2.buffDropGlowPixelLength == nil then
        NaowhQOL.buffWatcherV2.buffDropGlowPixelLength = 4
    end
    if NaowhQOL.buffWatcherV2.buffDropGlowAutocastParticles == nil then
        NaowhQOL.buffWatcherV2.buffDropGlowAutocastParticles = 4
    end
    if NaowhQOL.buffWatcherV2.buffDropGlowAutocastFrequency == nil then
        NaowhQOL.buffWatcherV2.buffDropGlowAutocastFrequency = 0.125
    end
    if NaowhQOL.buffWatcherV2.buffDropGlowAutocastScale == nil then
        NaowhQOL.buffWatcherV2.buffDropGlowAutocastScale = 1.0
    end
    if NaowhQOL.buffWatcherV2.buffDropGlowBorderFrequency == nil then
        NaowhQOL.buffWatcherV2.buffDropGlowBorderFrequency = 0.125
    end
    if NaowhQOL.buffWatcherV2.buffDropGlowProcDuration == nil then
        NaowhQOL.buffWatcherV2.buffDropGlowProcDuration = 1
    end
    if NaowhQOL.buffWatcherV2.buffDropGlowProcStartAnim == nil then
        NaowhQOL.buffWatcherV2.buffDropGlowProcStartAnim = false
    end
    if NaowhQOL.buffWatcherV2.buffDropAlertInstanceOnly == nil then
        NaowhQOL.buffWatcherV2.buffDropAlertInstanceOnly = false
    end
    if NaowhQOL.buffWatcherV2.buffDropAlertDisableRested == nil then
        NaowhQOL.buffWatcherV2.buffDropAlertDisableRested = false
    end
    if NaowhQOL.buffWatcherV2.buffDropTextFontSize == nil then
        NaowhQOL.buffWatcherV2.buffDropTextFontSize = 11
    end

    if not NaowhQOL.buffWatcherV2._classBuffDefaultsVersion then
        local Categories = ns.BWV2Categories
        local defaults = Categories and Categories.DEFAULT_CLASS_BUFFS
        if defaults and NaowhQOL.buffWatcherV2.classBuffs then
            for className, classData in pairs(NaowhQOL.buffWatcherV2.classBuffs) do
                if classData.groups and #classData.groups == 0 and defaults[className] then
                    for _, group in ipairs(defaults[className]) do
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

    if (NaowhQOL.buffWatcherV2._classBuffDefaultsVersion or 0) < 4 then
        local Categories = ns.BWV2Categories
        local defaults = Categories and Categories.DEFAULT_CLASS_BUFFS
        if defaults and NaowhQOL.buffWatcherV2.classBuffs and NaowhQOL.buffWatcherV2.classBuffs["SHAMAN"] then
            local shamanData = NaowhQOL.buffWatcherV2.classBuffs["SHAMAN"]
            local newGroups = {}
            for _, group in ipairs(defaults["SHAMAN"]) do
                local copy = {}
                for k, v in pairs(group) do
                    if type(v) == "table" then
                        local t = {}
                        for k2, v2 in pairs(v) do t[k2] = v2 end
                        copy[k] = t
                    else
                        copy[k] = v
                    end
                end
                newGroups[#newGroups + 1] = copy
            end
            shamanData.groups = newGroups
        end
        NaowhQOL.buffWatcherV2._classBuffDefaultsVersion = 4
    end

    if (NaowhQOL.buffWatcherV2._classBuffDefaultsVersion or 0) < 5 then
        local Categories = ns.BWV2Categories
        local defaults = Categories and Categories.DEFAULT_CLASS_BUFFS
        if defaults and NaowhQOL.buffWatcherV2.classBuffs and NaowhQOL.buffWatcherV2.classBuffs["ROGUE"] then
            local rogueData = NaowhQOL.buffWatcherV2.classBuffs["ROGUE"]
            local newGroups = {}
            for _, group in ipairs(defaults["ROGUE"]) do
                local copy = {}
                for k, v in pairs(group) do
                    if type(v) == "table" then
                        local t = {}
                        for k2, v2 in pairs(v) do t[k2] = v2 end
                        copy[k] = t
                    else
                        copy[k] = v
                    end
                end
                newGroups[#newGroups + 1] = copy
            end
            rogueData.groups = newGroups
        end
        NaowhQOL.buffWatcherV2._classBuffDefaultsVersion = 5
    end

    if (NaowhQOL.buffWatcherV2._classBuffDefaultsVersion or 0) < 6 then
        local Categories = ns.BWV2Categories
        local defaults = Categories and Categories.DEFAULT_CLASS_BUFFS
        if defaults and NaowhQOL.buffWatcherV2.classBuffs and NaowhQOL.buffWatcherV2.classBuffs["EVOKER"] then
            local evokerData = NaowhQOL.buffWatcherV2.classBuffs["EVOKER"]
            local newGroups = {}
            for _, group in ipairs(defaults["EVOKER"]) do
                local copy = {}
                for k, v in pairs(group) do
                    if type(v) == "table" then
                        local t = {}
                        for k2, v2 in pairs(v) do t[k2] = v2 end
                        copy[k] = t
                    else
                        copy[k] = v
                    end
                end
                newGroups[#newGroups + 1] = copy
            end
            evokerData.groups = newGroups
        end
        NaowhQOL.buffWatcherV2._classBuffDefaultsVersion = 6
    end

    if (NaowhQOL.buffWatcherV2._classBuffDefaultsVersion or 0) < 7 then
        local Categories = ns.BWV2Categories
        local defaults = Categories and Categories.DEFAULT_CLASS_BUFFS
        if defaults and NaowhQOL.buffWatcherV2.classBuffs and NaowhQOL.buffWatcherV2.classBuffs["SHAMAN"] then
            local shamData = NaowhQOL.buffWatcherV2.classBuffs["SHAMAN"]
            local exclusiveKeys = { shamanShield = true, earth_shield = true, water_shield = true }
            for _, group in ipairs(shamData.groups or {}) do
                if exclusiveKeys[group.key] then
                    group.exclusiveGroup = "shamanShields"
                end
            end
        end
        NaowhQOL.buffWatcherV2._classBuffDefaultsVersion = 7
    end

    if (NaowhQOL.buffWatcherV2._classBuffDefaultsVersion or 0) < 8 then
        if NaowhQOL.buffWatcherV2.classBuffs and NaowhQOL.buffWatcherV2.classBuffs["SHAMAN"] then
            local shamData = NaowhQOL.buffWatcherV2.classBuffs["SHAMAN"]
            for _, group in ipairs(shamData.groups or {}) do
                if group.key == "earth_shield" and group.checkType == "self" then
                    group.checkType = "targeted"
                end
            end
        end
        NaowhQOL.buffWatcherV2._classBuffDefaultsVersion = 8
    end

    if (NaowhQOL.buffWatcherV2._classBuffDefaultsVersion or 0) < 9 then
        if NaowhQOL.buffWatcherV2.classBuffs and NaowhQOL.buffWatcherV2.classBuffs["SHAMAN"] then
            local shamData = NaowhQOL.buffWatcherV2.classBuffs["SHAMAN"]
            for _, group in ipairs(shamData.groups or {}) do
                if group.key == "earth_shield" then
                    group.spellIDs = {974}
                    if group.talentCondition then
                        group.talentCondition.talentID = 974
                    end
                end
            end

            local hasTidecaller = false
            for _, group in ipairs(shamData.groups or {}) do
                if group.key == "tidecallersGuard" then
                    hasTidecaller = true
                    break
                end
            end
            if not hasTidecaller then
                shamData.groups[#shamData.groups + 1] = {
                    key = "tidecallersGuard",
                    name = "Tidecaller's Guard",
                    checkType = "weaponEnchant",
                    enchantIDs = {7528},
                    specFilter = {264},
                    minRequired = 1,
                    thresholds = { dungeon = 0, raid = 0, other = 0 },
                    talentCondition = { talentID = 457481, mode = "activate" },
                }
            end
        end
        NaowhQOL.buffWatcherV2._classBuffDefaultsVersion = 9
    end

    if (NaowhQOL.buffWatcherV2._classBuffDefaultsVersion or 0) < 10 then
        local Categories = ns.BWV2Categories
        local defaults = Categories and Categories.DEFAULT_CLASS_BUFFS
        if defaults and NaowhQOL.buffWatcherV2.classBuffs and NaowhQOL.buffWatcherV2.classBuffs["SHAMAN"] then
            local shamData = NaowhQOL.buffWatcherV2.classBuffs["SHAMAN"]
            local newGroups = {}
            for _, group in ipairs(defaults["SHAMAN"]) do
                local copy = {}
                for k, v in pairs(group) do
                    if type(v) == "table" then
                        local t = {}
                        for k2, v2 in pairs(v) do t[k2] = v2 end
                        copy[k] = t
                    else
                        copy[k] = v
                    end
                end
                newGroups[#newGroups + 1] = copy
            end
            shamData.groups = newGroups
        end
        NaowhQOL.buffWatcherV2._classBuffDefaultsVersion = 10
    end

    if (NaowhQOL.buffWatcherV2._classBuffDefaultsVersion or 0) < 11 then
        local Categories = ns.BWV2Categories
        local defaults = Categories and Categories.DEFAULT_CLASS_BUFFS
        if defaults and NaowhQOL.buffWatcherV2.classBuffs and NaowhQOL.buffWatcherV2.classBuffs["SHAMAN"] then
            local shamData = NaowhQOL.buffWatcherV2.classBuffs["SHAMAN"]
            local newGroups = {}
            for _, group in ipairs(defaults["SHAMAN"]) do
                local copy = {}
                for k, v in pairs(group) do
                    if type(v) == "table" then
                        local t = {}
                        for k2, v2 in pairs(v) do t[k2] = v2 end
                        copy[k] = t
                    else
                        copy[k] = v
                    end
                end
                newGroups[#newGroups + 1] = copy
            end
            shamData.groups = newGroups
        end
        NaowhQOL.buffWatcherV2._classBuffDefaultsVersion = 11
    end

    if (NaowhQOL.buffWatcherV2._classBuffDefaultsVersion or 0) < 12 then
        local Categories = ns.BWV2Categories
        local defaults = Categories and Categories.DEFAULT_CLASS_BUFFS
        if defaults and NaowhQOL.buffWatcherV2.classBuffs and NaowhQOL.buffWatcherV2.classBuffs["SHAMAN"] then
            local shamData = NaowhQOL.buffWatcherV2.classBuffs["SHAMAN"]
            local newGroups = {}
            for _, group in ipairs(defaults["SHAMAN"]) do
                local copy = {}
                for k, v in pairs(group) do
                    if type(v) == "table" then
                        local t = {}
                        for k2, v2 in pairs(v) do t[k2] = v2 end
                        copy[k] = t
                    else
                        copy[k] = v
                    end
                end
                newGroups[#newGroups + 1] = copy
            end
            shamData.groups = newGroups
        end
        NaowhQOL.buffWatcherV2._classBuffDefaultsVersion = 12
    end
end

function BWV2:GetDB()
    self:InitSavedVars()
    return NaowhQOL.buffWatcherV2
end

function BWV2:GetBuffDropFont()
    local db = self:GetDB()
    if db.buffDropTextFont then
        return ns.Media.ResolveFont(db.buffDropTextFont)
    end
    return ns.DefaultFontPath()
end

function BWV2:IsEnabled()
    local db = self:GetDB()
    return db.enabled
end

function BWV2:GetThreshold()
    local db = self:GetDB()
    local contentType = self:GetCurrentContentType()
    return db.thresholds[contentType] or 300
end

function BWV2:ShouldSuppressAlerts()
    local db = self:GetDB()
    if ns.ZoneUtil.IsInPvP() then return true end
    if db.buffDropAlertInstanceOnly and not ns.ZoneUtil.IsInInstance() then return true end
    if db.buffDropAlertDisableRested and IsResting() then return true end
    return false
end

function BWV2:SetCombatState(combat)
    local changed = self.inCombat ~= combat
    self.inCombat = combat
    if changed then
        self:SetDirty()
    end
end

function BWV2:SetEncounterState(encounter)
    self.inEncounter = encounter
    if encounter then
        self.inCombat = true
        self:SetDirty()
    end
end

function BWV2:SetReadyCheckState(active)
    local changed = self.inReadyCheck ~= active
    self.inReadyCheck = active
    if changed then
        self:SetDirty()
    end
end

function BWV2:SetDeadState(dead)
    local changed = self.isDead ~= dead
    self.isDead = dead
    if changed then
        self:SetDirty()
    end
end

function BWV2:OnClassBuffAuraEvent(updateInfo)
    if not InCombatLockdown() or not updateInfo then return end

    if updateInfo.removedAuraInstanceIDs then
        for _, instanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            local ok, groupKey = pcall(function() return self.classBuffInstanceIDs[instanceID] end)
            if ok and groupKey then
                self.classBuffSelfCache[groupKey] = false
                self.classBuffInstanceIDs[instanceID] = nil
                self:SetDirty()
            end
        end
    end
end

function BWV2:CacheClassBuffState(groupKey, hasBuff, spellIDs)
    if InCombatLockdown() then return end
    self.classBuffSelfCache[groupKey] = hasBuff
    if hasBuff and spellIDs then
        for _, spellID in ipairs(spellIDs) do
            local auraData = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
            if auraData and auraData.auraInstanceID then
                self.classBuffInstanceIDs[auraData.auraInstanceID] = groupKey
            end
        end
    end
end

function BWV2:GetCachedClassBuffState(groupKey)
    if not InCombatLockdown() then return nil end
    return self.classBuffSelfCache[groupKey]
end

function BWV2:DismissAlert(key)
    self.dismissedAlerts[key] = true
end

function BWV2:IsAlertDismissed(key)
    return self.dismissedAlerts[key] == true
end

function BWV2:ClearDismissals()
    wipe(self.dismissedAlerts)
end

function BWV2:ClearAlerts()
    wipe(self.activeAlerts)
end

function BWV2:RefreshAlerts()
    local db = self:GetDB()
    if not db.buffDropReminder then
        wipe(self.activeAlerts)
        return
    end

    if self:ShouldSuppressAlerts() then
        wipe(self.activeAlerts)
        return
    end

    if self.isDead then
        wipe(self.activeAlerts)
        return
    end

    local isRestricted = self:IsRestricted()
    local Categories = ns.BWV2Categories
    if not Categories then return end

    local threshold = self:GetThreshold()
    local _, playerClass = UnitClass("player")
    local playerSpecID = self:GetPlayerSpecID()

    local currentAlertKeys = {}

    if db.raidBuffAlwaysCheck then
        self:RefreshRaidBuffAlerts(Categories, threshold, isRestricted, currentAlertKeys)
    end

    if db.classBuffAlwaysCheck then
        self:RefreshClassBuffAlerts(db, playerClass, playerSpecID, threshold, isRestricted, currentAlertKeys)
    end

    if db.consumableAlwaysCheck and not isRestricted then
        self:RefreshConsumableAlerts(db, Categories, threshold, currentAlertKeys)
    end

    if db.inventoryAlwaysCheck and not isRestricted then
        self:RefreshInventoryAlerts(db, Categories, currentAlertKeys)
    end

    for key in pairs(self.activeAlerts) do
        if not currentAlertKeys[key] then
            self.activeAlerts[key] = nil
        end
    end

    for key in pairs(self.dismissedAlerts) do
        if not self.activeAlerts[key] then
            self.dismissedAlerts[key] = nil
        end
    end

    self.dirty = false
end

function BWV2:RefreshRaidBuffAlerts(Categories, threshold, isRestricted, currentAlertKeys)
    if not isRestricted and not ns.DisplayUtils.CanReadGroupAuras() then return end

    local units = {}
    local inRaid = IsInRaid()
    local groupSize = GetNumGroupMembers()
    if groupSize == 0 then
        local _, playerClass = UnitClass("player")
        units[1] = { unit = "player", class = playerClass }
    else
        for i = 1, groupSize do
            local unit
            if inRaid then
                unit = "raid" .. i
            else
                unit = (i == 1) and "player" or ("party" .. (i - 1))
            end
            if UnitExists(unit) and not UnitIsDeadOrGhost(unit) and UnitIsConnected(unit) and UnitIsVisible(unit) then
                local _, unitClass = UnitClass(unit)
                units[#units + 1] = { unit = unit, class = unitClass }
            end
        end
    end

    if #units == 0 then return end

    for _, buff in ipairs(Categories.RAID) do
        local primaryID = type(buff.spellID) == "table" and buff.spellID[1] or buff.spellID
        if primaryID and not Categories:IsDefaultDisabled("raidBuffs", primaryID)
           and Categories:IsCategoryEnabled(buff.key) then
            local playerKnows = false
            local spellIDs = type(buff.spellID) == "table" and buff.spellID or {buff.spellID}
            for _, spellID in ipairs(spellIDs) do
                if ns.IsPlayerSpell(spellID) then
                    playerKnows = true
                    break
                end
            end

            if playerKnows then
                local idsToQuery = spellIDs
                local canCheck = true

                if isRestricted then
                    local safeIDs = self:GetCombatSafeSpellIDs(spellIDs)
                    if #safeIDs == 0 then
                        local alertKey = "raidAlways_" .. buff.key
                        if self.activeAlerts[alertKey] then
                            currentAlertKeys[alertKey] = true
                        end
                        canCheck = false
                    else
                        idsToQuery = safeIDs
                    end
                end

                if canCheck then
                    local covered = 0
                    local total = 0
                    for _, unitData in ipairs(units) do
                        if Categories:UnitBenefitsFromBuff(buff.key, unitData.class, nil) then
                            total = total + 1
                            local hasBuff = false
                            for _, spellID in ipairs(idsToQuery) do
                                local aura = C_UnitAuras.GetUnitAuraBySpellID(unitData.unit, spellID)
                                if aura then
                                    local expTime = aura.expirationTime
                                    if IsSecret(expTime) then
                                        hasBuff = true
                                    elseif expTime == 0 or (expTime - GetTime()) > threshold then
                                        hasBuff = true
                                    end
                                    break
                                end
                            end
                            if hasBuff then covered = covered + 1 end
                        end
                    end

                    local alertKey = "raidAlways_" .. buff.key
                    if covered < total then
                        local icon = C_Spell.GetSpellTexture(primaryID)
                        if not self.activeAlerts[alertKey] then
                            self.activeAlerts[alertKey] = {
                                key = alertKey,
                                name = buff.name,
                                spellIDs = spellIDs,
                                icon = icon,
                                category = "raidBuff",
                                covered = covered,
                                total = total,
                                isGroupCoverage = true,
                            }
                        else
                            self.activeAlerts[alertKey].covered = covered
                            self.activeAlerts[alertKey].total = total
                        end
                        currentAlertKeys[alertKey] = true
                    end
                end
            end
        end
    end
end

function BWV2:RefreshClassBuffAlerts(db, playerClass, playerSpecID, threshold, isRestricted, currentAlertKeys)
    local classData = db.classBuffs and db.classBuffs[playerClass]
    if not classData or not classData.enabled then return end

    local consumableSpellIDs = {}
    local Categories = ns.BWV2Categories
    if Categories and db.consumableAlwaysCheck then
        for _, buff in ipairs(Categories.CONSUMABLE_GROUPS) do
            for _, id in ipairs(buff.spellIDs or {}) do
                consumableSpellIDs[id] = true
            end
        end
    end

    local exclusiveGroupPassed = {}

    for _, group in ipairs(classData.groups or {}) do
        local shouldCheck = true

        if shouldCheck and group.spellIDs and group.checkType == "self" then
            local allOverlap = true
            for _, spellID in ipairs(group.spellIDs) do
                if not consumableSpellIDs[spellID] then
                    allOverlap = false
                    break
                end
            end
            if allOverlap and #group.spellIDs > 0 then
                shouldCheck = false
            end
        end

        if group.specFilter and #group.specFilter > 0 then
            local specMatch = false
            for _, specID in ipairs(group.specFilter) do
                if specID == playerSpecID then
                    specMatch = true
                    break
                end
            end
            if not specMatch then shouldCheck = false end
        end

        if shouldCheck and group.talentCondition then
            local hasTalent = self:PlayerHasTalent(group.talentCondition.talentID)
            if group.talentCondition.mode == "activate" and not hasTalent then
                shouldCheck = false
            elseif group.talentCondition.mode == "skip" and hasTalent then
                shouldCheck = false
            end
        end

        if shouldCheck then
            local hasBuff = false
            local icon = nil

            if group.checkType == "self" then
                local spellIDs = group.spellIDs or {}
                if isRestricted then
                    local cached = self:GetCachedClassBuffState(group.key)
                    if cached ~= nil then
                        hasBuff = cached
                    else
                        local safeIDs = self:GetCombatSafeSpellIDs(spellIDs)
                        if #safeIDs > 0 then
                            local contentType = self:GetCurrentContentType()
                            local groupThreshold = (group.thresholds and group.thresholds[contentType]) or threshold
                            local needed = (group.minRequired == 0) and #spellIDs or (group.minRequired or 1)
                            local count = 0
                            for _, spellID in ipairs(safeIDs) do
                                local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                                if aura then
                                    local expTime = aura.expirationTime
                                    if IsSecret(expTime) then
                                        count = count + 1
                                    elseif expTime == 0 or (expTime - GetTime()) > groupThreshold then
                                        count = count + 1
                                    end
                                end
                            end
                            hasBuff = count >= needed
                        else
                            hasBuff = true
                        end
                    end
                else
                    if not ns.DisplayUtils.CanReadAuras() then
                        hasBuff = true
                    else
                        local contentType = self:GetCurrentContentType()
                        local groupThreshold = (group.thresholds and group.thresholds[contentType]) or threshold
                        local needed = (group.minRequired == 0) and #spellIDs or (group.minRequired or 1)
                        local count = 0
                        for _, spellID in ipairs(spellIDs) do
                            local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                            if aura then
                                local expTime = aura.expirationTime
                                if IsSecret(expTime) then
                                    count = count + 1
                                elseif expTime == 0 or (expTime - GetTime()) > groupThreshold then
                                    count = count + 1
                                end
                            end
                        end
                        hasBuff = count >= needed
                        self:CacheClassBuffState(group.key, hasBuff, spellIDs)
                    end
                end
                if spellIDs[1] then
                    if group.iconByRole then
                        local role = select(5, GetSpecializationInfo(GetSpecialization() or 0)) or "DAMAGER"
                        local roleSpellID = group.iconByRole[role] or group.iconByRole["DAMAGER"] or spellIDs[1]
                        icon = C_Spell.GetSpellTexture(roleSpellID)
                    else
                        icon = C_Spell.GetSpellTexture(spellIDs[1])
                    end
                end

            elseif group.checkType == "targeted" then
                if GetNumGroupMembers() == 0 then
                    hasBuff = true
                elseif isRestricted then
                    local spellIDs = group.spellIDs or {}
                    local safeIDs = self:GetCombatSafeSpellIDs(spellIDs)
                    if #safeIDs > 0 then
                        local inRaid = IsInRaid()
                        local groupSize = GetNumGroupMembers()
                        if groupSize == 0 then groupSize = 1 end
                        for i = 1, groupSize do
                            local unit
                            if inRaid then
                                unit = "raid" .. i
                            else
                                unit = (i == 1) and "player" or ("party" .. (i - 1))
                            end
                            if UnitExists(unit) then
                                for _, spellID in ipairs(safeIDs) do
                                    local aura = C_UnitAuras.GetUnitAuraBySpellID(unit, spellID)
                                    if aura then
                                        if aura.sourceUnit and ns.DisplayUtils.SafeIsPlayer(aura.sourceUnit) then
                                            local expTime = aura.expirationTime
                                            if IsSecret(expTime) then
                                                hasBuff = true
                                            elseif expTime == 0 or (expTime - GetTime()) > threshold then
                                                hasBuff = true
                                            end
                                        end
                                    end
                                end
                            end
                            if hasBuff then break end
                        end
                    else
                        hasBuff = true
                    end
                    if group.spellIDs and group.spellIDs[1] then
                        icon = C_Spell.GetSpellTexture(group.spellIDs[1])
                    end
                elseif not ns.DisplayUtils.CanReadGroupAuras() then
                    hasBuff = true
                else
                    local spellIDs = group.spellIDs or {}
                    if #spellIDs > 0 then
                        local inRaid = IsInRaid()
                        local groupSize = GetNumGroupMembers()
                        if groupSize == 0 then groupSize = 1 end
                        for i = 1, groupSize do
                            local unit
                            if inRaid then
                                unit = "raid" .. i
                            else
                                unit = (i == 1) and "player" or ("party" .. (i - 1))
                            end
                            if UnitExists(unit) then
                                local idx = 1
                                local auraData = C_UnitAuras.GetAuraDataByIndex(unit, idx, "HELPFUL")
                                while auraData do
                                    if IsSecret(auraData.spellId) then
                                        hasBuff = true
                                        break
                                    end
                                    for _, spellID in ipairs(spellIDs) do
                                        if auraData.spellId == spellID
                                           and auraData.sourceUnit
                                           and ns.DisplayUtils.SafeIsPlayer(auraData.sourceUnit) then
                                            local expTime = auraData.expirationTime
                                            if IsSecret(expTime) then
                                                hasBuff = true
                                            elseif expTime == 0 or (expTime - GetTime()) > threshold then
                                                hasBuff = true
                                            end
                                            break
                                        end
                                    end
                                    if hasBuff then break end
                                    idx = idx + 1
                                    auraData = C_UnitAuras.GetAuraDataByIndex(unit, idx, "HELPFUL")
                                end
                            end
                            if hasBuff then break end
                        end
                    end
                    if group.spellIDs and group.spellIDs[1] then
                        icon = C_Spell.GetSpellTexture(group.spellIDs[1])
                    end
                end

            elseif group.checkType == "weaponEnchant" then
                local enchantIDs = group.enchantIDs or {}
                if #enchantIDs > 0 then
                    local wOk, hasMain, _, _, mainID, hasOff, _, _, offID = pcall(GetWeaponEnchantInfo)
                    if wOk then
                        local count = 0
                        for _, eid in ipairs(enchantIDs) do
                            if (hasMain and mainID == eid) or (hasOff and offID == eid) then
                                count = count + 1
                            end
                        end
                        local needed = (group.minRequired == 0) and #enchantIDs or (group.minRequired or 1)
                        hasBuff = count >= needed
                    end
                end
                local scanner = ns.BWV2Scanner
                icon = (scanner and #(group.enchantIDs or {}) > 0 and scanner:GetEnchantIcon(group.enchantIDs[1])) or 463543
            end

            if hasBuff and group.exclusiveGroup then
                exclusiveGroupPassed[group.exclusiveGroup] = true
            end

            local alertKey = "classAlways_" .. group.key
            if not hasBuff then
                self.activeAlerts[alertKey] = {
                    key = alertKey,
                    name = group.name,
                    icon = icon or 134400,
                    category = "classBuff",
                    checkType = group.checkType,
                    exclusiveGroup = group.exclusiveGroup,
                    spellIDs = group.spellIDs,
                    enchantIDs = group.enchantIDs,
                    minRequired = group.minRequired,
                    overlayText = group.overlayText,
                }
                currentAlertKeys[alertKey] = true
            end
        end
    end

    if next(exclusiveGroupPassed) then
        for key, data in pairs(self.activeAlerts) do
            if data.exclusiveGroup and exclusiveGroupPassed[data.exclusiveGroup] then
                self.activeAlerts[key] = nil
                currentAlertKeys[key] = nil
            end
        end
    end
end

function BWV2:RefreshConsumableAlerts(db, Categories, threshold, currentAlertKeys)
    if not ns.DisplayUtils.CanReadAuras() then return end

    for _, buff in ipairs(Categories.CONSUMABLE_GROUPS) do
        if not Categories:IsConsumableGroupEnabled(buff.key) then
        elseif not Categories:IsCategoryEnabled(buff.key) then
        else
            local skip = false
            if buff.excludeIfSpellKnown then
                for _, spellID in ipairs(buff.excludeIfSpellKnown) do
                    if ns.IsPlayerSpell(spellID) then
                        skip = true
                        break
                    end
                end
            end

            if not skip then
                local spellIDs = {}
                for _, id in ipairs(buff.spellIDs or {}) do
                    spellIDs[#spellIDs + 1] = id
                end
                local userEntries = db.userEntries and db.userEntries["consumable_" .. buff.key]
                if userEntries and userEntries.spellIDs then
                    for _, id in ipairs(userEntries.spellIDs) do
                        spellIDs[#spellIDs + 1] = id
                    end
                end

                local hasBuff = false
                local icon = nil
                local foundExpiry = nil

                if buff.checkType == "icon" and buff.buffIconID then
                    local idx = 1
                    local auraData = C_UnitAuras.GetAuraDataByIndex("player", idx, "HELPFUL")
                    while auraData do
                        if not IsSecret(auraData.icon) and auraData.icon == buff.buffIconID then
                            local expTime = auraData.expirationTime
                            if IsSecret(expTime) then
                                hasBuff = true
                                icon = auraData.icon
                                break
                            end
                            local remaining = (expTime or 0) - GetTime()
                            if expTime == 0 or remaining > threshold then
                                hasBuff = true
                                icon = auraData.icon
                                break
                            elseif expTime ~= 0 then
                                foundExpiry = expTime
                            end
                        end
                        idx = idx + 1
                        auraData = C_UnitAuras.GetAuraDataByIndex("player", idx, "HELPFUL")
                    end
                elseif buff.checkType == "weaponEnchant" then
                    if UnitIsDead("player") then
                        hasBuff = true
                    else
                        local success = Categories:CheckWeaponBuffStatus()
                        hasBuff = success
                    end
                    icon = buff.fallbackIcon or 463543
                elseif buff.itemIDs and #buff.itemIDs > 0 then
                    hasBuff = Categories:HasInventoryItem(buff.itemIDs)
                elseif #spellIDs > 0 then
                    for _, spellID in ipairs(spellIDs) do
                        local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                        if aura then
                            local expTime = aura.expirationTime
                            if IsSecret(expTime) then
                                hasBuff = true
                                icon = aura.icon or C_Spell.GetSpellTexture(spellID) or buff.fallbackIcon
                                break
                            end
                            local remaining = (expTime or 0) - GetTime()
                            if expTime == 0 or remaining > threshold then
                                hasBuff = true
                                icon = aura.icon or C_Spell.GetSpellTexture(spellID) or buff.fallbackIcon
                                break
                            elseif expTime ~= 0 then
                                foundExpiry = expTime
                                icon = aura.icon or C_Spell.GetSpellTexture(spellID) or buff.fallbackIcon
                            end
                        end
                    end
                    if not icon and spellIDs[1] then
                        icon = C_Spell.GetSpellTexture(spellIDs[1]) or buff.fallbackIcon
                    end
                end

                local alertKey = "consumableAlways_" .. buff.key
                if not hasBuff then
                    self.activeAlerts[alertKey] = {
                        key = alertKey,
                        name = buff.name,
                        icon = icon or buff.fallbackIcon,
                        category = "consumable",
                        spellIDs = (buff.checkType ~= "icon" and buff.checkType ~= "weaponEnchant" and #spellIDs > 0) and spellIDs or nil,
                        iconCheck = (buff.checkType == "icon" and buff.buffIconID) or nil,
                        expiryTime = foundExpiry,
                        checkType = buff.checkType,
                    }
                    currentAlertKeys[alertKey] = true
                end
            end
        end
    end
end

function BWV2:RefreshInventoryAlerts(db, Categories, currentAlertKeys)
    for _, group in ipairs(Categories.INVENTORY_GROUPS) do
        if not Categories:IsInventoryGroupEnabled(group.key) then
        elseif group.requireClass and not self:HasClassInGroup(group.requireClass) then
        else
            local itemIDs = {}
            local disabledDefaults = db.disabledDefaults and db.disabledDefaults["inventory_" .. group.key] or {}
            for _, itemID in ipairs(group.itemIDs or {}) do
                if not disabledDefaults[itemID] then
                    itemIDs[#itemIDs + 1] = itemID
                end
            end
            local userEntries = db.userEntries and db.userEntries["inventory_" .. group.key]
            if userEntries and userEntries.itemIDs then
                for _, itemID in ipairs(userEntries.itemIDs) do
                    itemIDs[#itemIDs + 1] = itemID
                end
            end
            local alertKey = "inventoryAlways_" .. group.key
            if #itemIDs > 0 and Categories:GetInventoryItemCount(itemIDs) == 0 then
                local _, _, _, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(itemIDs[1])
                self.activeAlerts[alertKey] = {
                    key = alertKey,
                    name = group.name,
                    icon = itemIcon or group.fallbackIcon or 134400,
                    category = "inventory",
                    checkType = "inventory",
                }
                currentAlertKeys[alertKey] = true
            end
        end
    end
end
