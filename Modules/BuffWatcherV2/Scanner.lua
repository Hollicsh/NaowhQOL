local _, ns = ...

local Scanner = {}
ns.BWV2Scanner = Scanner

local BWV2 = ns.BWV2
local Categories = ns.BWV2Categories

function Scanner:GetPlayerBuffs()
    if BWV2.raidResults["player"] then
        return BWV2.raidResults["player"].buffs or {}
    end

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local unit = "raid" .. i
            if UnitIsUnit(unit, "player") and BWV2.raidResults[unit] then
                return BWV2.raidResults[unit].buffs or {}
            end
        end
    end
    local buffs = {}
    local idx = 1
    local auraData = C_UnitAuras.GetAuraDataByIndex("player", idx, "HELPFUL")
    while auraData do
        buffs[auraData.spellId] = {
            expiry = auraData.expirationTime,
            icon = tonumber(auraData.icon),
            name = auraData.name,
            sourceUnit = auraData.sourceUnit,
        }
        idx = idx + 1
        auraData = C_UnitAuras.GetAuraDataByIndex("player", idx, "HELPFUL")
    end
    return buffs
end

local textureCache = {}

local function GetCachedSpellTexture(spellID)
    if not spellID then return nil end
    local key = "spell_" .. spellID
    if not textureCache[key] then
        textureCache[key] = C_Spell.GetSpellTexture(spellID)
    end
    return textureCache[key]
end

local function GetCachedItemIcon(itemID)
    if not itemID then return nil end
    local key = "item_" .. itemID
    if not textureCache[key] then
        local _, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID)
        textureCache[key] = icon
    end
    return textureCache[key]
end

local function GetSpellIcon(spellID)
    local icon = C_Spell.GetSpellTexture(spellID)
    if not icon then
        local info = C_Spell.GetSpellInfo(spellID)
        icon = info and (info.iconID or info.originalIconID)
    end
    return icon
end

local function GetCachedEnchantIcon(enchantID)
    if not enchantID then return 463543 end
    local key = "enchant_" .. enchantID
    if textureCache[key] ~= nil then
        return textureCache[key]
    end
    local icon = 463543
    local map = Categories and Categories.ENCHANT_ICON_MAP
    local spellID = map and map[enchantID]
    if spellID then
        icon = GetSpellIcon(spellID) or 463543
    else
        icon = GetSpellIcon(enchantID) or 463543
    end
    textureCache[key] = icon
    return icon
end

function Scanner:GetEnchantIcon(enchantID)
    return GetCachedEnchantIcon(enchantID)
end

local function FindFirstAvailableItem(itemIDString)
    if not itemIDString then return nil end
    for id in tostring(itemIDString):gmatch("%d+") do
        local itemID = tonumber(id)
        if itemID and C_Item.GetItemCount(itemID) > 0 then
            return itemID
        end
    end
    return nil
end

function Scanner:GetRaidUnits()
    local units = {}
    local inRaid = IsInRaid()
    local groupSize = GetNumGroupMembers()

    if groupSize == 0 then
        units[1] = "player"
        return units
    end

    for i = 1, groupSize do
        local unit
        if inRaid then
            unit = "raid" .. i
        else
            unit = (i == 1) and "player" or ("party" .. (i - 1))
        end

        if UnitExists(unit) and not UnitIsDeadOrGhost(unit)
           and UnitIsConnected(unit) and UnitIsVisible(unit) then
            units[#units + 1] = unit
        end
    end

    return units
end

function Scanner:ScanUnitBuffs(unit)
    local buffs = {}
    local i = 1
    local auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")

    while auraData do
        buffs[auraData.spellId] = {
            expiry = auraData.expirationTime,
            icon = tonumber(auraData.icon),
            name = auraData.name,
            sourceUnit = auraData.sourceUnit,
        }
        i = i + 1
        auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
    end

    return buffs
end

function Scanner:ScanRaidBuffs()
    local missing = {}
    local threshold = BWV2:GetThreshold()

    wipe(BWV2.scanResults.raidBuffs)

    for _, buff in ipairs(Categories.RAID) do
        local primaryID = type(buff.spellID) == "table" and buff.spellID[1] or buff.spellID

        if not Categories:IsCategoryEnabled(buff.key) then
        elseif primaryID and Categories:IsDefaultDisabled("raidBuffs", primaryID) then
        elseif not BWV2:HasClassInGroup(buff.class) then
        else
            local covered = 0
            local total = 0
            local inRaid = IsInRaid()

            for unit, data in pairs(BWV2.raidResults) do
                if inRaid and unit == "player" then
                else
                    total = total + 1
                    local spellIDs = type(buff.spellID) == "table" and buff.spellID or {buff.spellID}

                    for _, spellID in ipairs(spellIDs) do
                        if data.buffs[spellID] then
                            local remaining = (data.buffs[spellID].expiry or 0) - GetTime()
                            if data.buffs[spellID].expiry == 0 or remaining > threshold then
                                covered = covered + 1
                                break
                            end
                        end
                    end
                end
            end

            local icon = GetCachedSpellTexture(primaryID)
            local pass = (covered >= total)

            BWV2.scanResults.raidBuffs[#BWV2.scanResults.raidBuffs + 1] = {
                key = buff.key,
                name = buff.name,
                spellID = primaryID,
                icon = icon,
                pass = pass,
                covered = covered,
                total = total,
                class = buff.class,
            }

            if not pass then
                missing[buff.key] = {
                    name = buff.name,
                    missing = total - covered,
                    total = total,
                    class = buff.class,
                }
            end
        end
    end

    return missing
end

function Scanner:CheckSelfBuffSpells(spellIDs, minRequired)
    local playerBuffs = self:GetPlayerBuffs()

    local count = 0
    for _, spellID in ipairs(spellIDs) do
        if playerBuffs[spellID] then
            count = count + 1
        end
    end

    local needed = (minRequired == 0) and #spellIDs or minRequired
    return count >= needed
end

function Scanner:CheckTargetedBuffSpells(spellIDs)
    for unit, data in pairs(BWV2.raidResults) do
        for _, spellID in ipairs(spellIDs) do
            local buffData = data.buffs[spellID]
            if buffData and buffData.sourceUnit and UnitIsUnit(buffData.sourceUnit, "player") then
                return true
            end
        end
    end
    return false
end

function Scanner:CheckWeaponEnchantIDs(enchantIDs, minRequired)
    local hasMain, _, _, mainID, hasOff, _, _, offID = GetWeaponEnchantInfo()

    local count = 0
    for _, enchantID in ipairs(enchantIDs) do
        if (hasMain and mainID == enchantID) or (hasOff and offID == enchantID) then
            count = count + 1
        end
    end

    local needed = (minRequired == 0) and #enchantIDs or minRequired
    return count >= needed
end

function Scanner:ScanClassBuffs()
    local missing = {}
    local _, playerClass = UnitClass("player")
    local playerSpecID = BWV2:GetPlayerSpecID()
    local db = BWV2:GetDB()

    wipe(BWV2.scanResults.classBuffs)

    local classData = db.classBuffs and db.classBuffs[playerClass]
    if not classData or not classData.enabled then
        return missing
    end

    local playerBuffs = self:GetPlayerBuffs()

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
            if not specMatch then
                shouldCheck = false
            end
        end

        if shouldCheck and group.talentCondition then
            local hasTalent = BWV2:PlayerHasTalent(group.talentCondition.talentID)
            if group.talentCondition.mode == "activate" then
                if not hasTalent then
                    shouldCheck = false
                end
            elseif group.talentCondition.mode == "skip" then
                if hasTalent then
                    shouldCheck = false
                end
            end
        end

        if shouldCheck then
            local hasBuff = false
            local foundSpellID = nil
            local foundIcon = nil

            if group.checkType == "self" then
                local spellIDs = group.spellIDs or {}
                if #spellIDs > 0 then
                    hasBuff = self:CheckSelfBuffSpells(spellIDs, group.minRequired or 1)
                    for _, spellID in ipairs(spellIDs) do
                        if playerBuffs[spellID] then
                            foundSpellID = spellID
                            foundIcon = playerBuffs[spellID].icon or GetCachedSpellTexture(spellID)
                            break
                        end
                    end
                    if not foundIcon and spellIDs[1] then
                        foundSpellID = spellIDs[1]
                        foundIcon = GetCachedSpellTexture(spellIDs[1])
                    end
                end
            elseif group.checkType == "targeted" then
                local spellIDs = group.spellIDs or {}
                if #spellIDs > 0 then
                    hasBuff = self:CheckTargetedBuffSpells(spellIDs)
                    for unit, data in pairs(BWV2.raidResults) do
                        for _, spellID in ipairs(spellIDs) do
                            local buffData = data.buffs[spellID]
                            if buffData and buffData.sourceUnit and UnitIsUnit(buffData.sourceUnit, "player") then
                                foundSpellID = spellID
                                foundIcon = buffData.icon or GetCachedSpellTexture(spellID)
                                break
                            end
                        end
                        if foundIcon then break end
                    end
                    if not foundIcon and spellIDs[1] then
                        foundSpellID = spellIDs[1]
                        foundIcon = GetCachedSpellTexture(spellIDs[1])
                    end
                end
            elseif group.checkType == "weaponEnchant" then
                local enchantIDs = group.enchantIDs or {}
                if #enchantIDs > 0 then
                    hasBuff = self:CheckWeaponEnchantIDs(enchantIDs, group.minRequired or 1)
                    local hasMain, _, _, mainID, hasOff, _, _, offID = GetWeaponEnchantInfo()
                    for _, eid in ipairs(enchantIDs) do
                        if (hasMain and mainID == eid) or (hasOff and offID == eid) then
                            foundIcon = GetCachedEnchantIcon(eid)
                            break
                        end
                    end
                    if not foundIcon then
                        foundIcon = GetCachedEnchantIcon(enchantIDs[1])
                    end
                end
            end

            local remaining = nil
            if hasBuff and group.thresholds and group.checkType ~= "weaponEnchant" and foundSpellID then
                local contentType = BWV2:GetCurrentContentType()
                local threshold = group.thresholds[contentType] or 0
                if threshold > 0 then
                    local buffData = playerBuffs[foundSpellID]
                    if buffData and buffData.expiry and buffData.expiry > 0 then
                        remaining = buffData.expiry - GetTime()
                        if remaining < threshold then
                            hasBuff = false
                        end
                    end
                end
            end

            BWV2.scanResults.classBuffs[#BWV2.scanResults.classBuffs + 1] = {
                key = group.key,
                name = group.name,
                spellID = foundSpellID,
                icon = foundIcon,
                pass = hasBuff,
                checkType = group.checkType,
                remaining = (not hasBuff and remaining and remaining > 0) and remaining or nil,
            }

            if not hasBuff then
                missing[group.key] = {
                    name = group.name,
                    checkType = group.checkType,
                    className = playerClass,
                }
            end
        end
    end

    return missing
end

function Scanner:ScanConsumables()
    local missing = {}
    local threshold = BWV2:GetThreshold()
    local playerBuffs = self:GetPlayerBuffs()
    local db = BWV2:GetDB()

    wipe(BWV2.scanResults.consumables)

    for _, buff in ipairs(Categories.CONSUMABLE_GROUPS) do
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

        local primaryID = nil
        if #spellIDs > 0 then
            primaryID = spellIDs[1]
        end

        local hasCheckMethod = primaryID or buff.buffIconID or buff.checkType == "weaponEnchant" or buff.itemIDs
        if not hasCheckMethod then
            BWV2.scanResults.consumables[#BWV2.scanResults.consumables + 1] = {
                key = buff.key,
                name = buff.name,
                icon = buff.fallbackIcon,
                pass = false,
                unconfigured = true,
            }
        elseif not Categories:IsConsumableGroupEnabled(buff.key) then
        elseif not Categories:IsCategoryEnabled(buff.key) then
        elseif primaryID and Categories:IsDefaultDisabled("consumable_" .. buff.key, primaryID) then
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
                local hasBuff = false
                local foundSpellID = nil
                local foundIcon = nil
                local remaining = 0

                if buff.checkType == "icon" and buff.buffIconID then
                    for spellID, data in pairs(playerBuffs) do
                        if data.icon == buff.buffIconID then
                            remaining = (data.expiry or 0) - GetTime()
                            if data.expiry == 0 or remaining > threshold then
                                hasBuff = true
                                foundSpellID = spellID
                                foundIcon = data.icon
                                break
                            elseif data.expiry ~= 0 then
                                foundSpellID = spellID
                                foundIcon = data.icon
                            end
                        end
                    end
                elseif buff.checkType == "weaponEnchant" then
                    local success, errorCode = Categories:CheckWeaponBuffStatus()
                    if not success then
                        local errorNames = {
                            NO_WEAPON = "No Weapon Equipped",
                            MISSING_MAIN = "Mainhand Missing Enchant",
                            MISSING_OFF = "Offhand Missing Enchant",
                        }
                        missing[buff.key] = {
                            name = errorNames[errorCode] or buff.name,
                            readyCheckOnly = buff.readyCheckOnly,
                            errorCode = errorCode,
                        }
                    end
                    hasBuff = success
                    foundIcon = buff.fallbackIcon or 463543
                elseif buff.itemIDs and #buff.itemIDs > 0 then
                    hasBuff = Categories:HasInventoryItem(buff.itemIDs)
                    foundIcon = GetCachedItemIcon(buff.itemIDs[1])
                elseif #spellIDs > 0 then
                    for _, spellID in ipairs(spellIDs) do
                        if playerBuffs[spellID] then
                            remaining = (playerBuffs[spellID].expiry or 0) - GetTime()
                            if playerBuffs[spellID].expiry == 0 or remaining > threshold then
                                hasBuff = true
                                foundSpellID = spellID
                                foundIcon = playerBuffs[spellID].icon or GetCachedSpellTexture(spellID)
                                break
                            elseif playerBuffs[spellID].expiry ~= 0 then
                                foundSpellID = spellID
                                foundIcon = playerBuffs[spellID].icon or GetCachedSpellTexture(spellID)
                            end
                        end
                    end
                    if not foundIcon and spellIDs[1] then
                        foundIcon = GetCachedSpellTexture(spellIDs[1])
                    end
                end

                local autoUseItemID = FindFirstAvailableItem(db.consumableAutoUse and db.consumableAutoUse[buff.key])
                BWV2.scanResults.consumables[#BWV2.scanResults.consumables + 1] = {
                    key = buff.key,
                    name = buff.name,
                    spellID = foundSpellID or primaryID,
                    itemID = autoUseItemID,
                    icon = foundIcon or GetCachedSpellTexture(primaryID) or buff.fallbackIcon,
                    pass = hasBuff,
                    remaining = (not hasBuff and remaining > 0) and remaining or nil,
                }

                if not hasBuff and not missing[buff.key] then
                    missing[buff.key] = {
                        name = buff.name,
                        readyCheckOnly = buff.readyCheckOnly,
                    }
                end
            end
        end
    end

    return missing
end

function Scanner:ScanInventory()
    local missing = {}
    local inventory = {}
    local db = BWV2:GetDB()

    wipe(BWV2.scanResults.inventory)

    for _, group in ipairs(Categories.INVENTORY_GROUPS) do
        local groupKey = "inventory_" .. group.key

        if not Categories:IsInventoryGroupEnabled(group.key) then
        elseif group.requireClass and not BWV2:HasClassInGroup(group.requireClass) then
        else
            local itemIDs = {}
            local disabledDefaults = db.disabledDefaults and db.disabledDefaults[groupKey] or {}

            for _, itemID in ipairs(group.itemIDs or {}) do
                if not disabledDefaults[itemID] then
                    itemIDs[#itemIDs + 1] = itemID
                end
            end

            local userEntries = db.userEntries and db.userEntries[groupKey]
            if userEntries and userEntries.itemIDs then
                for _, itemID in ipairs(userEntries.itemIDs) do
                    itemIDs[#itemIDs + 1] = itemID
                end
            end

            local count = Categories:GetInventoryItemCount(itemIDs)
            local pass = count > 0

            local icon = GetCachedItemIcon(itemIDs[1]) or group.fallbackIcon

            BWV2.scanResults.inventory[#BWV2.scanResults.inventory + 1] = {
                key = group.key,
                name = group.name,
                itemID = itemIDs[1],
                icon = icon,
                pass = pass,
                count = count,
                requireClass = group.requireClass,
            }

            if pass then
                inventory[group.key] = {
                    name = group.name,
                    count = count,
                    pass = true,
                }
            else
                missing[group.key] = {
                    name = group.name,
                    requireClass = group.requireClass,
                }
            end
        end
    end

    return missing, inventory
end

function Scanner:ScanAndCompareUnit(unit)
    local buffs = self:ScanUnitBuffs(unit)
    BWV2.raidResults[unit] = { buffs = buffs }
end

function Scanner:RunCategoryScans()
    local allMissing = {}

    local raidMissing = self:ScanRaidBuffs()
    for key, data in pairs(raidMissing) do
        allMissing[key] = data
    end

    local classBuffMissing = self:ScanClassBuffs()
    for key, data in pairs(classBuffMissing) do
        allMissing[key] = data
    end

    local consumableMissing = self:ScanConsumables()
    for key, data in pairs(consumableMissing) do
        allMissing[key] = data
    end

    local inventoryMissing, inventoryStatus = self:ScanInventory()
    for key, data in pairs(inventoryMissing) do
        allMissing[key] = data
    end

    BWV2.missingByCategory = allMissing
    BWV2.inventoryStatus = inventoryStatus
end

function Scanner:PerformScan()
    local units = self:GetRaidUnits()

    BWV2:ResetState()

    for _, unit in ipairs(units) do
        self:ScanAndCompareUnit(unit)
    end

    self:RunCategoryScans()
end
