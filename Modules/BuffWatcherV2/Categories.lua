local _, ns = ...

local Categories = {}
ns.BWV2Categories = Categories

local BWV2 = ns.BWV2

Categories.RAID = {
    { spellID = {1459, 432778}, key = "intellect", name = "Arcane Intellect", class = "MAGE" },
    { spellID = 6673, key = "attackPower", name = "Battle Shout", class = "WARRIOR" },
    { spellID = {1126, 432661}, key = "versatility", name = "Mark of the Wild", class = "DRUID" },
    { spellID = 21562, key = "stamina", name = "Power Word: Fortitude", class = "PRIEST" },
    { spellID = 462854, key = "skyfury", name = "Skyfury", class = "SHAMAN" },
    { spellID = {381732, 381741, 381746, 381748, 381749, 381750, 381751, 381752, 381753, 381754, 381756, 381757, 381758},
      key = "bronze", name = "Blessing of the Bronze", class = "EVOKER" },
}

Categories.BUFF_BENEFICIARIES = {
    intellect = {
        MAGE = true,
        WARLOCK = true,
        PRIEST = true,
        DRUID = true,
        SHAMAN = true,
        MONK = true,
        EVOKER = true,
        PALADIN = true,
    },
    attackPower = {
        WARRIOR = true,
        ROGUE = true,
        HUNTER = true,
        DEATHKNIGHT = true,
        PALADIN = true,
        MONK = true,
        DRUID = true,
        DEMONHUNTER = true,
        SHAMAN = true,
    },
}

Categories.SPEC_BENEFICIARIES = {
    intellect = {
        [62] = true, [63] = true, [64] = true,
        [256] = true, [257] = true, [258] = true,
        [265] = true, [266] = true, [267] = true,
        [102] = true, [105] = true,
        [262] = true, [264] = true,
        [270] = true,
        [65] = true,
        [1467] = true, [1468] = true, [1473] = true,
    },
    attackPower = {
        [71] = true, [72] = true, [73] = true,
        [259] = true, [260] = true, [261] = true,
        [253] = true, [254] = true, [255] = true,
        [250] = true, [251] = true, [252] = true,
        [577] = true, [581] = true,
        [103] = true, [104] = true,
        [263] = true,
        [268] = true, [269] = true,
        [66] = true, [70] = true,
    },
}

function Categories:UnitBenefitsFromBuff(buffKey, unitClass, specID)
    local specBeneficiaries = self.SPEC_BENEFICIARIES[buffKey]
    local classBeneficiaries = self.BUFF_BENEFICIARIES[buffKey]
    if specBeneficiaries and specID then
        return specBeneficiaries[specID] or false
    end
    if classBeneficiaries then
        return classBeneficiaries[unitClass] or false
    end
    return true
end

Categories.CLASS_INFO = {
    WARRIOR     = { name = LOCALIZED_CLASS_NAMES_MALE["WARRIOR"]     or "Warrior",      specs = {{71, "Arms"}, {72, "Fury"}, {73, "Protection"}} },
    PALADIN     = { name = LOCALIZED_CLASS_NAMES_MALE["PALADIN"]     or "Paladin",      specs = {{65, "Holy"}, {66, "Protection"}, {70, "Retribution"}} },
    HUNTER      = { name = LOCALIZED_CLASS_NAMES_MALE["HUNTER"]      or "Hunter",       specs = {{253, "Beast Mastery"}, {254, "Marksmanship"}, {255, "Survival"}} },
    ROGUE       = { name = LOCALIZED_CLASS_NAMES_MALE["ROGUE"]       or "Rogue",        specs = {{259, "Assassination"}, {260, "Outlaw"}, {261, "Subtlety"}} },
    PRIEST      = { name = LOCALIZED_CLASS_NAMES_MALE["PRIEST"]      or "Priest",       specs = {{256, "Discipline"}, {257, "Holy"}, {258, "Shadow"}} },
    DEATHKNIGHT = { name = LOCALIZED_CLASS_NAMES_MALE["DEATHKNIGHT"] or "Death Knight", specs = {{250, "Blood"}, {251, "Frost"}, {252, "Unholy"}} },
    SHAMAN      = { name = LOCALIZED_CLASS_NAMES_MALE["SHAMAN"]      or "Shaman",       specs = {{262, "Elemental"}, {263, "Enhancement"}, {264, "Restoration"}} },
    MAGE        = { name = LOCALIZED_CLASS_NAMES_MALE["MAGE"]        or "Mage",         specs = {{62, "Arcane"}, {63, "Fire"}, {64, "Frost"}} },
    WARLOCK     = { name = LOCALIZED_CLASS_NAMES_MALE["WARLOCK"]     or "Warlock",      specs = {{265, "Affliction"}, {266, "Demonology"}, {267, "Destruction"}} },
    MONK        = { name = LOCALIZED_CLASS_NAMES_MALE["MONK"]        or "Monk",         specs = {{268, "Brewmaster"}, {269, "Windwalker"}, {270, "Mistweaver"}} },
    DRUID       = { name = LOCALIZED_CLASS_NAMES_MALE["DRUID"]       or "Druid",        specs = {{102, "Balance"}, {103, "Feral"}, {104, "Guardian"}, {105, "Restoration"}} },
    DEMONHUNTER = { name = LOCALIZED_CLASS_NAMES_MALE["DEMONHUNTER"] or "Demon Hunter", specs = {{577, "Havoc"}, {581, "Vengeance"}} },
    EVOKER      = { name = LOCALIZED_CLASS_NAMES_MALE["EVOKER"]      or "Evoker",       specs = {{1467, "Devastation"}, {1468, "Preservation"}, {1473, "Augmentation"}} },
}

function Categories:LocalizeSpecNames()
    for _, classInfo in pairs(self.CLASS_INFO) do
        for _, specData in ipairs(classInfo.specs) do
            local specID = specData[1]
            local localizedName = select(2, GetSpecializationInfoByID(specID))
            if localizedName then
                specData[2] = localizedName
            end
        end
    end
end

Categories.CLASS_ORDER = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT",
    "SHAMAN", "MAGE", "WARLOCK", "MONK", "DRUID", "DEMONHUNTER", "EVOKER"
}

Categories.DEFAULT_CLASS_BUFFS = {
    PALADIN = {
        {
            key = "riteOfAdjuration",
            name = "Rite of Adjuration",
            checkType = "weaponEnchant",
            enchantIDs = {7144},
            specFilter = {},
            talentCondition = { talentID = 433583, mode = "activate" },
        },
        {
            key = "riteOfSanctification",
            name = "Rite of Sanctification",
            checkType = "weaponEnchant",
            enchantIDs = {7143},
            specFilter = {},
            talentCondition = { talentID = 433568, mode = "activate" },
        },
        {
            key = "beaconOfLight",
            name = "Beacon of Light",
            checkType = "targeted",
            spellIDs = {53563},
            specFilter = {65},
        },
        {
            key = "beaconOfFaith",
            name = "Beacon of Faith",
            checkType = "targeted",
            spellIDs = {156910},
            specFilter = {65},
            talentCondition = { talentID = 156910, mode = "activate" },
        },
    },
    ROGUE = {
        {
            key = "roguePoisons",
            name = "Poisons",
            checkType = "self",
            spellIDs = {2823, 3408, 5761, 8679, 381637,315584, 381664},
            minRequired = 2,
            thresholds = { dungeon = 25, raid = 25, other = 5 },
            specFilter = {},
        },
    },
    SHAMAN = {
        {
            key = "shamanImbue",
            name = "Flametongue",
            checkType = "weaponEnchant",
            enchantIDs = {5400},
            specFilter = {262, 263},
            minRequired = 1,
            thresholds = { dungeon = 0, raid = 0, other = 0 },
            talentCondition = { talentID = 318038, mode = "activate" },
        },
        {
            key = "windfury",
            name = "Windfury",
            checkType = "weaponEnchant",
            enchantIDs = {5401},
            specFilter = {263},
            minRequired = 1,
            thresholds = { dungeon = 0, raid = 0, other = 0 },
            talentCondition = { talentID = 33757, mode = "activate" },
        },
        {
            key = "earthliving",
            name = "Earthliving",
            checkType = "weaponEnchant",
            enchantIDs = {6498},
            specFilter = {264},
            minRequired = 1,
            thresholds = { dungeon = 0, raid = 0, other = 0 },
            talentCondition = { talentID = 382021, mode = "activate" },
        },
        {
            key = "tidecallersGuard",
            name = "Tidecaller's Guard",
            checkType = "weaponEnchant",
            enchantIDs = {7528},
            specFilter = {264},
            minRequired = 1,
            thresholds = { dungeon = 0, raid = 0, other = 0 },
            talentCondition = { talentID = 457481, mode = "activate" },
        },
        {
            key = "earthShieldSelf",
            name = "Earth Shield (Self)",
            overlayText = "NO\nSELF ES",
            checkType = "self",
            spellIDs = {383648},
            specFilter = {},
            minRequired = 1,
            thresholds = { dungeon = 0, raid = 0, other = 0 },
            talentCondition = { talentID = 383010, mode = "activate" },
        },
        {
            key = "shamanShield",
            name = "Water/Lightning Shield",
            overlayText = "NO\nSHIELD",
            checkType = "self",
            spellIDs = {192106, 52127},
            specFilter = {},
            minRequired = 1,
            thresholds = { dungeon = 0, raid = 0, other = 0 },
            talentCondition = { talentID = 383010, mode = "activate" },
            iconByRole = { HEALER = 52127, DAMAGER = 192106, TANK = 192106 },
        },
        {
            key = "shamanShieldBasic",
            name = "Shield",
            overlayText = "NO\nSHIELD",
            checkType = "self",
            spellIDs = {974, 192106, 52127},
            specFilter = {},
            minRequired = 1,
            thresholds = { dungeon = 0, raid = 0, other = 0 },
            talentCondition = { talentID = 383010, mode = "skip" },
            iconByRole = { HEALER = 52127, DAMAGER = 192106, TANK = 192106 },
        },
        {
            key = "earth_shield",
            name = "Earth Shield",
            overlayText = "NO\nES",
            checkType = "targeted",
            spellIDs = {974},
            specFilter = {},
            minRequired = 1,
            thresholds = { dungeon = 0, raid = 0, other = 0 },
            talentCondition = { talentID = 974, mode = "activate" },
        },
    },
    PRIEST = {
        {
            key = "shadowform",
            name = "Shadowform",
            checkType = "self",
            spellIDs = {232698, 194249},
            specFilter = {258},
        },
    },
    MAGE = {
        {
            key = "arcaneFamiliar",
            name = "Arcane Familiar",
            checkType = "self",
            spellIDs = {210126},
            specFilter = {},
            talentCondition = { talentID = 205022, mode = "activate" },
        },
    },
    WARLOCK = {
        {
            key = "grimoireOfSacrifice",
            name = "Grimoire of Sacrifice",
            checkType = "self",
            spellIDs = {196099},
            specFilter = {},
            talentCondition = { talentID = 108503, mode = "activate" },
        },
    },
    EVOKER = {
        {
            key = "sourceOfMagic",
            name = "Source of Magic",
            checkType = "targeted",
            spellIDs = {369459},
            specFilter = {},
            talentCondition = { talentID = 369459, mode = "activate" },
        },
        {
            key = "blisteringScales",
            name = "Blistering Scales",
            checkType = "targeted",
            spellIDs = {360827},
            specFilter = {1473},
            talentCondition = { talentID = 360827, mode = "activate" },
        },
    },
    DRUID = {
        {
            key = "symbioticRelationship",
            name = "Symbiotic Relationship",
            checkType = "targeted",
            spellIDs = {474750},
            specFilter = {},
            talentCondition = { talentID = 474750, mode = "activate" },
        },
    },
}

Categories.CONSUMABLE_GROUPS = {
    {
        key = "flask",
        name = "Flask",
        exclusive = true,
        spellIDs = {
            432021,
            431971,
            431972,
            431973,
            431974,
            432473,
            1235057,
            1235108,
            1235110,
            1235111,
            1239355,
        },
        fallbackIcon = 241320,
    },
    {
        key = "food",
        name = "Food",
        exclusive = true,
        checkType = "icon",
        buffIconID = 136000,
        spellIDs = {},
        fallbackIcon = 136000,
    },
    {
        key = "rune",
        name = "Augment Rune",
        exclusive = true,
        spellIDs = {
            1234969,
            1242347,
            453250,
            393438,
            1264426,
            347901,
        },
        fallbackIcon = 259085,
    },
    {
        key = "weaponBuff",
        name = "Weapon Buff",
        exclusive = true,
        checkType = "weaponEnchant",
        spellIDs = {},
        excludeIfSpellKnown = {
            382021,
            318038,
            33757,
            433583,
            433568,
        },
        fallbackIcon = 7548987,
    },
}

Categories.INVENTORY_GROUPS = {
    {
        key = "dpsPotion",
        name = "DPS Potion",
        itemIDs = {241308},
        fallbackIcon = 7548911,
    },
    {
        key = "healthPotion",
        name = "Health Potion",
        itemIDs = {241305},
        fallbackIcon = 7548909,
    },
    {
        key = "healthstone",
        name = "Healthstone",
        itemIDs = {5512, 224464},
        requireClass = "WARLOCK",
    },
    {
        key = "gatewayControl",
        name = "Gateway Control Shard",
        itemIDs = {188152},
        requireClass = "WARLOCK",
    },
    {
        key = "manaBun",
        name = "Mana Bun",
        itemIDs = {113509},
    },
}

Categories.EXCLUSIVE_GROUPS = {
    shamanImbues = true,
    shamanShields = true,
    beacons = true,
}

Categories.ROGUE_LETHAL_POISONS = {315584, 8679, 2823, 381664}
Categories.ROGUE_NONLETHAL_POISONS = {5761, 381637, 3408}

Categories.ENCHANT_ICON_MAP = {
    [5400] = 318038,
    [5401] = 33757,
    [6498] = 382021,
    [7143] = 433568,
    [7144] = 433583,
    [7528] = 457481,
}

function Categories:ApplyTalentMods(categoryKey, baseRequirements)
    local db = BWV2:GetDB()
    local mods = db.talentMods and db.talentMods[categoryKey]
    if not mods then return baseRequirements end

    local requirements = {}
    for k, v in pairs(baseRequirements) do
        requirements[k] = v
    end

    for _, rule in ipairs(mods) do
        local hasTalent = BWV2:PlayerHasTalent(rule.talentID)

        if hasTalent then
            if rule.type == "requireCount" then
                requirements.count = rule.count
            elseif rule.type == "requireSpellID" then
                requirements.spellID = rule.spellID
            elseif rule.type == "skipIfTalent" then
                requirements.skip = true
            end
        end
    end

    return requirements
end

function Categories:GetSpellIDs(categoryKey)
    local db = BWV2:GetDB()
    local userEntries = db.userEntries and db.userEntries[categoryKey]
    local userSpellIDs = userEntries and userEntries.spellIDs or {}

    local allCategories = {self.RAID, self.TARGETED, self.SELF, self.CONSUMABLE_GROUPS}
    for _, catList in ipairs(allCategories) do
        if catList then
            for _, buff in ipairs(catList) do
                if buff.key == categoryKey then
                    local baseIDs = buff.spellIDs or (type(buff.spellID) == "table" and buff.spellID or {buff.spellID})
                    local merged = {}
                    for _, id in ipairs(baseIDs or {}) do
                        merged[#merged + 1] = id
                    end
                    for _, id in ipairs(userSpellIDs) do
                        merged[#merged + 1] = id
                    end
                    return merged
                end
            end
        end
    end

    return userSpellIDs
end

function Categories:AddUserSpellID(categoryKey, spellID)
    local db = BWV2:GetDB()
    if not db.userEntries[categoryKey] then
        db.userEntries[categoryKey] = { spellIDs = {} }
    end
    table.insert(db.userEntries[categoryKey].spellIDs, spellID)
end

function Categories:RemoveUserSpellID(categoryKey, spellID)
    local db = BWV2:GetDB()
    local entries = db.userEntries[categoryKey]
    if not entries or not entries.spellIDs then return end

    for i, id in ipairs(entries.spellIDs) do
        if id == spellID then
            table.remove(entries.spellIDs, i)
            return
        end
    end
end

function Categories:IsCategoryEnabled(categoryKey)
    local db = BWV2:GetDB()
    if db.categoryEnabled[categoryKey] == nil then
        return true
    end
    return db.categoryEnabled[categoryKey]
end

function Categories:IsConsumableGroupEnabled(groupKey)
    local db = BWV2:GetDB()
    if not db.consumableGroupEnabled then return true end
    if db.consumableGroupEnabled[groupKey] == nil then
        return true
    end
    return db.consumableGroupEnabled[groupKey]
end

function Categories:IsDefaultDisabled(categoryKey, spellID)
    local db = BWV2:GetDB()
    if not db.disabledDefaults then return false end
    if not db.disabledDefaults[categoryKey] then return false end
    return db.disabledDefaults[categoryKey][spellID] == true
end

function Categories:GetActiveBuffs(categoryType, categoryKey)
    local sourceList = self[categoryType]
    if not sourceList then return {} end

    local active = {}
    for _, buff in ipairs(sourceList) do
        local primaryID = type(buff.spellID) == "table" and buff.spellID[1] or buff.spellID

        local checkKey = categoryKey or buff.key
        if not primaryID or not self:IsDefaultDisabled(checkKey, primaryID) then
            active[#active + 1] = buff
        end
    end

    return active
end

function Categories:UnitHasBuffFromList(unit, spellIDs, threshold)
    if type(spellIDs) ~= "table" then
        spellIDs = {spellIDs}
    end

    if not ns.DisplayUtils.CanReadAuras() then return false, 0, nil end

    local now = GetTime()
    threshold = threshold or 0

    for _, spellID in ipairs(spellIDs) do
        local auraData = C_UnitAuras.GetAuraDataBySpellName(unit, spellID, "HELPFUL")
        if not auraData then
            auraData = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
        end

        if auraData then
            local remaining = (auraData.expirationTime or 0) - now
            if auraData.expirationTime == 0 or remaining > threshold then
                return true, remaining, auraData.sourceUnit
            end
        end
    end

    return false, 0, nil
end

function Categories:UnitHasBuffByIcon(unit, iconID, threshold)
    if not ns.DisplayUtils.CanReadAuras() then return false, 0 end

    local now = GetTime()
    threshold = threshold or 0

    local i = 1
    local auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
    while auraData do
        if auraData.icon == iconID then
            local remaining = (auraData.expirationTime or 0) - now
            if auraData.expirationTime == 0 or remaining > threshold then
                return true, remaining
            end
        end
        i = i + 1
        auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
    end

    return false, 0
end

function Categories:HasWeaponEnchant(enchantID)
    local ok, hasMain, _, _, mainID, hasOff, _, _, offID = pcall(GetWeaponEnchantInfo)
    if not ok then return false end
    if hasMain and mainID == enchantID then
        return true
    end
    if hasOff and offID == enchantID then
        return true
    end
    return false
end

function Categories:IsOffhandEnchantable()
    local offhandID = GetInventoryItemID("player", 17)
    if not offhandID then
        return false
    end

    local _, _, _, _, _, itemType = C_Item.GetItemInfo(offhandID)
    return itemType == "Weapon"
end

function Categories:CheckWeaponBuffStatus()
    local mainhandID = GetInventoryItemID("player", 16)

    if not mainhandID then
        return false, "NO_WEAPON"
    end

    local ok, hasMain, _, _, _, hasOff, _, _, _ = pcall(GetWeaponEnchantInfo)
    if not ok then return false, "TAINTED" end

    if not hasMain then
        return false, "MISSING_MAIN"
    end

    if self:IsOffhandEnchantable() and not hasOff then
        return false, "MISSING_OFF"
    end

    return true, nil
end

function Categories:HasInventoryItem(itemIDs)
    if type(itemIDs) ~= "table" then
        itemIDs = {itemIDs}
    end

    for _, itemID in ipairs(itemIDs) do
        if C_Item.GetItemCount(itemID, false, true) > 0 then
            return true
        end
    end
    return false
end

function Categories:GetInventoryItemCount(itemIDs)
    if type(itemIDs) ~= "table" then
        itemIDs = {itemIDs}
    end

    local total = 0
    for _, itemID in ipairs(itemIDs) do
        total = total + C_Item.GetItemCount(itemID, false, true)
    end
    return total
end

function Categories:IsInventoryGroupEnabled(groupKey)
    local db = BWV2:GetDB()
    if not db.inventoryGroupEnabled then return true end
    if db.inventoryGroupEnabled[groupKey] == nil then
        return true
    end
    return db.inventoryGroupEnabled[groupKey]
end
