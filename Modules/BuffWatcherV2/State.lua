local _, ns = ...

local BWV2 = {}
ns.BWV2 = BWV2

BWV2.raidResults = {}
BWV2.missingByPlayer = {}
BWV2.activeWatchers = {}
BWV2.inventoryStatus = {}
BWV2.scanInProgress = false
BWV2.lastScanTime = 0

BWV2.buffSnapshot = {}
BWV2.buffDropReminded = {}
BWV2.classBuffSelfCache = {}
BWV2.classBuffInstanceIDs = {}

BWV2.scanResults = {
    raidBuffs = {},
    presenceBuffs = {},
    consumables = {},
    inventory = {},
    classBuffs = {},
}

function BWV2:ResetState()
    wipe(self.raidResults)
    wipe(self.missingByPlayer)
    wipe(self.inventoryStatus)
    if not self.scanResults then
        self.scanResults = {}
    end
    self.scanResults.raidBuffs = self.scanResults.raidBuffs or {}
    self.scanResults.presenceBuffs = self.scanResults.presenceBuffs or {}
    self.scanResults.consumables = self.scanResults.consumables or {}
    self.scanResults.inventory = self.scanResults.inventory or {}
    self.scanResults.classBuffs = self.scanResults.classBuffs or {}
    wipe(self.scanResults.raidBuffs)
    wipe(self.scanResults.presenceBuffs)
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
            buffDropGlowR = 0.95,
            buffDropGlowG = 0.95,
            buffDropGlowB = 0.32,
            buffDropGlowUseClassColor = false,
            raidBuffAlwaysCheck = false,
            classBuffAlwaysCheck = false,
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
    if NaowhQOL.buffWatcherV2.buffDropIconSize == nil then
        NaowhQOL.buffWatcherV2.buffDropIconSize = 32
    end
    if NaowhQOL.buffWatcherV2.buffDropScale == nil then
        NaowhQOL.buffWatcherV2.buffDropScale = 1.0
    end
    if NaowhQOL.buffWatcherV2.buffDropUnlock == nil then
        NaowhQOL.buffWatcherV2.buffDropUnlock = false
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
end

function BWV2:GetDB()
    self:InitSavedVars()
    return NaowhQOL.buffWatcherV2
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

function BWV2:BuildBuffSnapshot()
    wipe(self.buffSnapshot)
    wipe(self.buffDropReminded)

    local results = self.scanResults
    local Categories = ns.BWV2Categories
    if not results or not Categories then return end

    for _, entry in ipairs(results.raidBuffs or {}) do
        if entry.pass then
            for _, buff in ipairs(Categories.RAID) do
                if buff.key == entry.key then
                    local ids = type(buff.spellID) == "table" and buff.spellID or {buff.spellID}
                    local playerKnows = false
                    for _, spellID in ipairs(ids) do
                        if ns.IsPlayerSpell(spellID) then
                            playerKnows = true
                            break
                        end
                    end
                    if playerKnows then
                        self.buffSnapshot[entry.key] = {
                            name = entry.name,
                            spellIDs = ids,
                            icon = entry.icon,
                            category = "raidBuff",
                        }
                    end
                    break
                end
            end
        end
    end

    for _, entry in ipairs(results.consumables or {}) do
        if entry.pass and not entry.unconfigured then
            local ids = {}
            local iconCheck = nil
            for _, grp in ipairs(Categories.CONSUMABLE_GROUPS) do
                if grp.key == entry.key then
                    if grp.checkType == "icon" and grp.buffIconID then
                        iconCheck = grp.buffIconID
                    elseif grp.checkType == "weaponEnchant" then
                        self.buffSnapshot[entry.key] = {
                            name = entry.name,
                            icon = entry.icon,
                            category = "consumable",
                            checkType = "weaponEnchant",
                        }
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

    for _, entry in ipairs(results.classBuffs or {}) do
        if entry.pass then
            local _, playerClass = UnitClass("player")
            local db = self:GetDB()
            local classData = db.classBuffs and db.classBuffs[playerClass]
            if classData then
                for _, group in ipairs(classData.groups or {}) do
                    if group.key == entry.key then
                        if entry.checkType == "self" and group.spellIDs then
                            self.buffSnapshot[entry.key] = {
                                name = entry.name,
                                spellIDs = group.spellIDs,
                                icon = entry.icon,
                                category = "classBuff",
                                thresholds = group.thresholds,
                            }
                        elseif entry.checkType == "weaponEnchant" and group.enchantIDs then
                            self.buffSnapshot[entry.key] = {
                                name = entry.name,
                                icon = entry.icon,
                                category = "classBuff",
                                checkType = "weaponEnchant",
                                enchantIDs = group.enchantIDs,
                                minRequired = group.minRequired or 1,
                            }
                        end
                        break
                    end
                end
            end
        end
    end
end

function BWV2:CheckBuffDrops()
    if not self.buffSnapshot or not next(self.buffSnapshot) then
        return nil
    end

    local dropped = {}

    for key, data in pairs(self.buffSnapshot) do
        if not self.buffDropReminded[key] then
            local stillPresent = false

            if data.spellIDs and #data.spellIDs > 0 then
                local contentType = self:GetCurrentContentType()
                local threshold
                if data.category == "classBuff" and data.thresholds then
                    threshold = data.thresholds[contentType] or 0
                else
                    threshold = self:GetThreshold()
                end
                for _, spellID in ipairs(data.spellIDs) do
                    local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                    if aura then
                        local remaining = (aura.expirationTime or 0) - GetTime()
                        if aura.expirationTime == 0 or remaining > threshold then
                            stillPresent = true
                            break
                        end
                    end
                end
            end

            if not stillPresent and data.iconCheck then
                local threshold = self:GetThreshold()
                local idx = 1
                local auraData = C_UnitAuras.GetAuraDataByIndex("player", idx, "HELPFUL")
                while auraData do
                    if tostring(auraData.icon) == tostring(data.iconCheck) then
                        local remaining = (auraData.expirationTime or 0) - GetTime()
                        if auraData.expirationTime == 0 or remaining > threshold then
                            stillPresent = true
                        end
                        break
                    end
                    idx = idx + 1
                    auraData = C_UnitAuras.GetAuraDataByIndex("player", idx, "HELPFUL")
                end
            end

            if not stillPresent and data.checkType == "weaponEnchant" then
                local hasMain, _, _, mainID, hasOff, _, _, offID = GetWeaponEnchantInfo()
                if data.enchantIDs and #data.enchantIDs > 0 then
                    local count = 0
                    for _, eid in ipairs(data.enchantIDs) do
                        if (hasMain and mainID == eid) or (hasOff and offID == eid) then
                            count = count + 1
                        end
                    end
                    local needed = (data.minRequired == 0) and #data.enchantIDs or (data.minRequired or 1)
                    stillPresent = count >= needed
                else
                    stillPresent = hasMain and true or false
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

function BWV2:AddToBuffSnapshot(item, categoryKey)
    if not item or not item.key then return end
    local Categories = ns.BWV2Categories
    if not Categories then return end

    if categoryKey == "raidBuffs" then
        for _, buff in ipairs(Categories.RAID) do
            if buff.key == item.key then
                local ids = type(buff.spellID) == "table" and buff.spellID or {buff.spellID}
                local playerKnows = false
                for _, spellID in ipairs(ids) do
                    if ns.IsPlayerSpell(spellID) then
                        playerKnows = true
                        break
                    end
                end
                if playerKnows then
                    self.buffSnapshot[item.key] = {
                        name = item.name,
                        spellIDs = ids,
                        icon = item.icon,
                        category = "raidBuff",
                    }
                end
                return
            end
        end
    elseif categoryKey == "consumables" then
        for _, grp in ipairs(Categories.CONSUMABLE_GROUPS) do
            if grp.key == item.key then
                local ids = {}
                local iconCheck = nil
                if grp.checkType == "icon" and grp.buffIconID then
                    iconCheck = grp.buffIconID
                elseif grp.checkType == "weaponEnchant" then
                    self.buffSnapshot[item.key] = {
                        name = item.name,
                        icon = item.icon,
                        category = "consumable",
                        checkType = "weaponEnchant",
                    }
                    return
                elseif grp.spellIDs then
                    for _, id in ipairs(grp.spellIDs) do
                        ids[#ids + 1] = id
                    end
                end
                if #ids > 0 or iconCheck then
                    self.buffSnapshot[item.key] = {
                        name = item.name,
                        spellIDs = ids,
                        icon = item.icon,
                        category = "consumable",
                        iconCheck = iconCheck,
                    }
                end
                return
            end
        end
    elseif categoryKey == "classBuffs" then
        local _, playerClass = UnitClass("player")
        local db = self:GetDB()
        local classData = db.classBuffs and db.classBuffs[playerClass]
        if classData then
            for _, group in ipairs(classData.groups or {}) do
                if group.key == item.key then
                    if item.checkType == "self" and group.spellIDs then
                        self.buffSnapshot[item.key] = {
                            name = item.name,
                            spellIDs = group.spellIDs,
                            icon = item.icon,
                            category = "classBuff",
                            thresholds = group.thresholds,
                        }
                    elseif item.checkType == "weaponEnchant" and group.enchantIDs then
                        self.buffSnapshot[item.key] = {
                            name = item.name,
                            icon = item.icon,
                            category = "classBuff",
                            checkType = "weaponEnchant",
                            enchantIDs = group.enchantIDs,
                            minRequired = group.minRequired or 1,
                        }
                    end
                    return
                end
            end
        end
    end
end

function BWV2:CheckAlwaysOnRaidBuffs()
    local db = self:GetDB()
    if not db or not db.raidBuffAlwaysCheck then return nil end

    local Categories = ns.BWV2Categories
    if not Categories then return nil end

    local missing = {}

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
                local hasBuff = false
                local threshold = self:GetThreshold()
                for _, spellID in ipairs(spellIDs) do
                    local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                    if aura then
                        local remaining = (aura.expirationTime or 0) - GetTime()
                        if aura.expirationTime == 0 or remaining > threshold then
                            hasBuff = true
                            break
                        end
                    end
                end

                if not hasBuff then
                    local icon = C_Spell.GetSpellTexture(primaryID)
                    missing[#missing + 1] = {
                        key = "raidAlways_" .. buff.key,
                        name = buff.name,
                        spellIDs = spellIDs,
                        icon = icon,
                        category = "raidBuff",
                    }
                end
            end
        end
    end

    return (#missing > 0) and missing or nil
end

function BWV2:CheckAlwaysOnClassBuffs()
    local db = self:GetDB()
    if not db or not db.classBuffAlwaysCheck then return nil end

    local _, playerClass = UnitClass("player")
    local classData = db.classBuffs and db.classBuffs[playerClass]
    if not classData or not classData.enabled then return nil end

    local playerSpecID = self:GetPlayerSpecID()
    local missing = {}

    for _, group in ipairs(classData.groups or {}) do
        local shouldCheck = true

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
                local threshold = self:GetThreshold()
                local needed = (group.minRequired == 0) and #spellIDs or (group.minRequired or 1)
                local count = 0
                for _, spellID in ipairs(spellIDs) do
                    local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                    if aura then
                        local remaining = (aura.expirationTime or 0) - GetTime()
                        if aura.expirationTime == 0 or remaining > threshold then
                            count = count + 1
                        end
                    end
                end
                hasBuff = count >= needed
                -- Out of combat: cache state and auraInstanceID for combat tracking.
                -- In combat: aura APIs return tainted/nil, so trust the cache
                -- (cache is invalidated by OnClassBuffAuraEvent when removals are detected)
                if not InCombatLockdown() then
                    self.classBuffSelfCache[group.key] = hasBuff
                    if hasBuff then
                        for _, spellID in ipairs(spellIDs) do
                            local auraData = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                            if auraData and auraData.auraInstanceID then
                                self.classBuffInstanceIDs[auraData.auraInstanceID] = group.key
                            end
                        end
                    end
                elseif not hasBuff and self.classBuffSelfCache[group.key] then
                    hasBuff = true
                end
                if spellIDs[1] then
                    icon = C_Spell.GetSpellTexture(spellIDs[1])
                end
            elseif group.checkType == "targeted" then
                local spellIDs = group.spellIDs or {}
                local threshold = self:GetThreshold()
                if InCombatLockdown() then
                    hasBuff = true -- aura data is tainted in combat; skip check
                elseif #spellIDs > 0 then
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
                                for _, spellID in ipairs(spellIDs) do
                                    if auraData.spellId == spellID
                                       and auraData.sourceUnit
                                       and UnitIsUnit(auraData.sourceUnit, "player") then
                                        local remaining = (auraData.expirationTime or 0) - GetTime()
                                        if auraData.expirationTime == 0 or remaining > threshold then
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
                if spellIDs[1] then
                    icon = C_Spell.GetSpellTexture(spellIDs[1])
                end
            elseif group.checkType == "weaponEnchant" then
                local enchantIDs = group.enchantIDs or {}
                if #enchantIDs > 0 then
                    local hasMain, _, _, mainID, hasOff, _, _, offID = GetWeaponEnchantInfo()
                    local count = 0
                    for _, eid in ipairs(enchantIDs) do
                        if (hasMain and mainID == eid) or (hasOff and offID == eid) then
                            count = count + 1
                        end
                    end
                    local needed = (group.minRequired == 0) and #enchantIDs or (group.minRequired or 1)
                    hasBuff = count >= needed
                end
                icon = 463543
            end

            if not hasBuff then
                missing[#missing + 1] = {
                    key = "classAlways_" .. group.key,
                    name = group.name,
                    icon = icon or 134400,
                    category = "classBuff",
                    checkType = group.checkType,
                    spellIDs = group.spellIDs,
                    enchantIDs = group.enchantIDs,
                    minRequired = group.minRequired,
                }
            end
        end
    end

    return (#missing > 0) and missing or nil
end

function BWV2:OnClassBuffAuraEvent(updateInfo)
    if not InCombatLockdown() or not updateInfo then return end

    -- Track removals: if a tracked auraInstanceID was removed, invalidate cache
    if updateInfo.removedAuraInstanceIDs then
        for _, instanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            local ok, groupKey = pcall(function() return self.classBuffInstanceIDs[instanceID] end)
            if ok and groupKey then
                self.classBuffSelfCache[groupKey] = false
                self.classBuffInstanceIDs[instanceID] = nil
            end
        end
    end

    -- Note: addedAuras fields are fully tainted in combat, so we cannot detect
    -- re-application here. The cache will be corrected on PLAYER_REGEN_ENABLED
    -- when aura APIs become readable again.
end

function BWV2:ClearBuffSnapshot()
    wipe(self.buffSnapshot)
    wipe(self.buffDropReminded)
end
