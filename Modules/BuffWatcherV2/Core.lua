local _, ns = ...

local Core = {}
ns.BWV2Core = Core

local BWV2 = ns.BWV2
local Categories = ns.BWV2Categories
local Watchers = ns.BWV2Watchers
local Scanner = ns.BWV2Scanner
local ReportCard = ns.BWV2ReportCard
local BuffDropAlert = ns.BWV2BuffDropAlert

local SCAN_INTERVAL = 0.5
local scanTicker = nil

local suppressed = false

local eventFrame = CreateFrame("Frame")

local function StopTicker()
    if scanTicker then
        scanTicker:Cancel()
        scanTicker = nil
    end
end

local WEAPON_ENCHANT_POLL_INTERVAL = 1.0
local weaponEnchantTicker = nil

local function StopWeaponEnchantPoller()
    if weaponEnchantTicker then
        weaponEnchantTicker:Cancel()
        weaponEnchantTicker = nil
    end
end

local function StartWeaponEnchantPoller()
    StopWeaponEnchantPoller()

    local hasWeaponEnchant = false
    for _, data in pairs(BWV2.buffSnapshot) do
        if data.checkType == "weaponEnchant" then
            hasWeaponEnchant = true
            break
        end
    end
    if not hasWeaponEnchant then return end

    weaponEnchantTicker = C_Timer.NewTicker(WEAPON_ENCHANT_POLL_INTERVAL, function()
        local db = BWV2:GetDB()
        if not db or not db.enabled or not db.buffDropReminder then
            StopWeaponEnchantPoller()
            return
        end
        if suppressed or BWV2.lastScanTime == 0 then
            StopWeaponEnchantPoller()
            return
        end

        if BuffDropAlert and BuffDropAlert:HasAlerts() then
            BuffDropAlert:CheckRebuffs()
        end

        local dropped = BWV2:CheckBuffDrops()
        if dropped and BuffDropAlert then
            BuffDropAlert:AddAlerts(dropped)
        end
    end)
end

local classBuffEnchantTicker = nil

local function StopClassBuffEnchantPoller()
    if classBuffEnchantTicker then
        classBuffEnchantTicker:Cancel()
        classBuffEnchantTicker = nil
    end
end

local function StartClassBuffEnchantPoller()
    StopClassBuffEnchantPoller()

    local db = BWV2:GetDB()
    if not db or not db.classBuffAlwaysCheck then return end

    local _, playerClass = UnitClass("player")
    local classData = db.classBuffs and db.classBuffs[playerClass]
    if not classData or not classData.enabled then return end

    local hasWeaponEnchant = false
    for _, group in ipairs(classData.groups or {}) do
        if group.checkType == "weaponEnchant" then
            hasWeaponEnchant = true
            break
        end
    end
    if not hasWeaponEnchant then return end

    classBuffEnchantTicker = C_Timer.NewTicker(WEAPON_ENCHANT_POLL_INTERVAL, function()
        local cdb = BWV2:GetDB()
        if not cdb or not cdb.enabled or not cdb.classBuffAlwaysCheck then
            StopClassBuffEnchantPoller()
            return
        end
        if suppressed then
            StopClassBuffEnchantPoller()
            return
        end

        if BuffDropAlert then
            if BuffDropAlert:HasAlerts() then
                BuffDropAlert:CheckRebuffsForPrefix("classAlways_")
            end

            local missing = BWV2:CheckAlwaysOnClassBuffs()
            if missing then
                BuffDropAlert:AddAlerts(missing)
            else
                BuffDropAlert:DismissByPrefix("classAlways_")
            end
        end
    end)
end

local function StartTicker()
    StopTicker()
    scanTicker = C_Timer.NewTicker(SCAN_INTERVAL, function()
        if not BWV2:IsEnabled() then
            StopTicker()
            return
        end
        if InCombatLockdown() then
            return
        end
        if not ReportCard:IsShown() then
            StopTicker()
            return
        end

        local db = BWV2:GetDB()
        local prevPassState = {}
        if db.buffDropReminder then
            local results = BWV2.scanResults
            if results then
                for _, cat in ipairs({"raidBuffs", "consumables", "classBuffs"}) do
                    local items = results[cat]
                    if items then
                        for _, item in ipairs(items) do
                            if item.key then
                                prevPassState[item.key] = item.pass
                            end
                        end
                    end
                end
            end
        end

        Scanner:PerformScan()
        ReportCard:Update()

        if db.buffDropReminder then
            local results = BWV2.scanResults
            if results then
                for _, cat in ipairs({"raidBuffs", "consumables", "classBuffs"}) do
                    local items = results[cat]
                    if items then
                        for _, item in ipairs(items) do
                            if item.key and item.pass and prevPassState[item.key] == false then
                                BWV2:AddToBuffSnapshot(item, cat)
                                if BuffDropAlert then
                                    BuffDropAlert:DismissAlert(item.key)
                                end
                                BWV2.buffDropReminded[item.key] = nil
                                if item.checkType == "weaponEnchant" then
                                    StartWeaponEnchantPoller()
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function TriggerScan()
    if not BWV2:IsEnabled() then
        return
    end

    if suppressed then
        return
    end

    if BWV2.scanInProgress then
        return
    end

    if InCombatLockdown() then
        print("|cffff6600[BuffWatcher]|r Cannot scan during combat.")
        return
    end

    if ns.ZoneUtil.IsInMythicPlus() then
        print("|cffff6600[BuffWatcher]|r Disabled in M+.")
        return
    end

    BWV2.scanInProgress = true

    Scanner:PerformScan()

    BWV2.scanInProgress = false
    BWV2.lastScanTime = GetTime()

    local db = BWV2:GetDB()
    if db.buffDropReminder then
        if BuffDropAlert then BuffDropAlert:DismissAll() end
        BWV2:BuildBuffSnapshot()
        StartWeaponEnchantPoller()
    end

    Core:PrintSummary()
    ReportCard:Show()
    StartTicker()
end

function Core:PrintSummary()
    local db = BWV2:GetDB()
    if not db.chatReportEnabled then return end

    local missing = BWV2.missingByCategory
    local inventoryStatus = BWV2.inventoryStatus or {}

    if not missing or not next(missing) then
        print("|cff00ff00[BuffWatcher]|r All players have required buffs!")
        return
    end

    print("|cffff6600[BuffWatcher]|r Missing buffs:")

    local raidMissing = {}
    local presenceMissing = {}
    local classBuffMissing = {}
    local consumableMissing = {}
    local inventoryMissing = {}

    for key, data in pairs(missing) do
        local found = false

        for _, buff in ipairs(Categories.RAID) do
            if buff.key == key then
                raidMissing[key] = data
                found = true
                break
            end
        end

        if not found and Categories.PRESENCE then
            for _, buff in ipairs(Categories.PRESENCE) do
                if buff.key == key then
                    presenceMissing[key] = data
                    found = true
                    break
                end
            end
        end

        if not found then
            for _, buff in ipairs(Categories.CONSUMABLE_GROUPS) do
                if buff.key == key then
                    consumableMissing[key] = data
                    found = true
                    break
                end
            end
        end

        if not found then
            for _, group in ipairs(Categories.INVENTORY_GROUPS) do
                if group.key == key then
                    inventoryMissing[key] = data
                    found = true
                    break
                end
            end
        end

        if not found then
            classBuffMissing[key] = data
        end
    end

    if next(raidMissing) then
        print("  |cffffcc00Raid Buffs:|r")
        for key, data in pairs(raidMissing) do
            local coverage = data.missing and string.format(" (%d/%d covered)", data.total - data.missing, data.total) or ""
            print("    |cffffa900- " .. (data.name or key) .. coverage .. "|r")
        end
    end

    if next(presenceMissing) then
        print("  |cffffcc00Presence Buffs:|r")
        for key, data in pairs(presenceMissing) do
            print("    |cffffa900- " .. (data.name or key) .. "|r")
        end
    end

    if next(classBuffMissing) then
        print("  |cffffcc00Class Buffs:|r")
        for key, data in pairs(classBuffMissing) do
            local typeTag = ""
            if data.checkType == "targeted" then
                typeTag = " (targeted)"
            elseif data.checkType == "weaponEnchant" then
                typeTag = " (weapon)"
            end
            print("    |cffffa900- " .. (data.name or key) .. typeTag .. "|r")
        end
    end

    if next(consumableMissing) then
        print("  |cffffcc00Consumables:|r")
        for key, data in pairs(consumableMissing) do
            print("    |cffffa900- " .. (data.name or key) .. "|r")
        end
    end

    if next(inventoryMissing) then
        print("  |cffffcc00Inventory:|r")
        for key, data in pairs(inventoryMissing) do
            print("    |cffffa900- " .. (data.name or key) .. ": Missing|r")
        end
    end
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "READY_CHECK" then
        TriggerScan()
    elseif event == "READY_CHECK_CONFIRM" then
        local unit = ...
        if unit and UnitIsUnit(unit, "player") then
            StopTicker()
            if ReportCard and ReportCard:IsShown() then
                ReportCard:Hide()
            end
        end
    elseif event == "UNIT_AURA" then
        local unit, updateInfo = ...
        if unit == "player" then
            BWV2:OnClassBuffAuraEvent(updateInfo)
            Core:OnPlayerAuraChanged()
        end
    elseif event == "UNIT_INVENTORY_CHANGED" then
        local unit = ...
        if unit == "player" then
            Core:OnPlayerAuraChanged()
        end

    elseif event == "PLAYER_REGEN_DISABLED" then
        StopTicker()
        if ReportCard and ReportCard:IsShown() then
            ReportCard:Hide()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        Core:OnPlayerAuraChanged()
        return

    elseif event == "CHALLENGE_MODE_START" then
        StopTicker()
        StopWeaponEnchantPoller()
        StopClassBuffEnchantPoller()
        if ReportCard and ReportCard:IsShown() then
            ReportCard:Hide()
        end
        if BuffDropAlert then BuffDropAlert:DismissAll() end
        BWV2:ClearBuffSnapshot()

    elseif event == "PLAYER_LOGIN" then
        Categories:LocalizeSpecNames()

        BWV2:InitSavedVars()

        ns.SettingsIO:RegisterRefresh("buffWatcherV2", function()
            StopTicker()
            if ReportCard and ReportCard:IsShown() then
                ReportCard:Hide()
            end
            BWV2:ResetState()
        end)

        local db = BWV2:GetDB()
        if db.enabled and db.scanOnLogin then
            C_Timer.After(2, function()
                if InCombatLockdown() then return end
                if C_ChallengeMode and C_ChallengeMode.IsChallengeModeActive() then return end
                TriggerScan()
            end)
        end

        if db.enabled and db.raidBuffAlwaysCheck and BuffDropAlert then
            C_Timer.After(3, function()
                local missing = BWV2:CheckAlwaysOnRaidBuffs()
                if missing then
                    BuffDropAlert:AddAlerts(missing)
                end
            end)
        end

        if db.enabled and db.classBuffAlwaysCheck and BuffDropAlert then
            C_Timer.After(3, function()
                local missing = BWV2:CheckAlwaysOnClassBuffs()
                if missing then
                    BuffDropAlert:AddAlerts(missing)
                end
                StartClassBuffEnchantPoller()
            end)
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        local db = BWV2:GetDB()
        if db and db.enabled and db.raidBuffAlwaysCheck and BuffDropAlert then
            C_Timer.After(1.5, function()
                BuffDropAlert:DismissByPrefix("raidAlways_")
                local missing = BWV2:CheckAlwaysOnRaidBuffs()
                if missing then
                    BuffDropAlert:AddAlerts(missing)
                end
            end)
        end
        if db and db.enabled and db.classBuffAlwaysCheck and BuffDropAlert then
            C_Timer.After(1.5, function()
                BuffDropAlert:DismissByPrefix("classAlways_")
                local missing = BWV2:CheckAlwaysOnClassBuffs()
                if missing then
                    BuffDropAlert:AddAlerts(missing)
                end
                StartClassBuffEnchantPoller()
            end)
        end
    end
end)

eventFrame:RegisterEvent("READY_CHECK")
eventFrame:RegisterEvent("READY_CHECK_CONFIRM")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("CHALLENGE_MODE_START")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")

SLASH_NSCAN1 = "/nscan"
SlashCmdList["NSCAN"] = function(msg)
    TriggerScan()
end

SLASH_NSUP1 = "/nsup"
SlashCmdList["NSUP"] = function(msg)
    suppressed = not suppressed
    if suppressed then
        StopTicker()
        StopWeaponEnchantPoller()
        StopClassBuffEnchantPoller()
        if ReportCard and ReportCard:IsShown() then
            ReportCard:Hide()
        end
        if BuffDropAlert then BuffDropAlert:DismissAll() end
        BWV2:ClearBuffSnapshot()
        print("|cffff6600[BuffWatcher]|r Suppressed until reload or /nsup")
    else
        print("|cff00ff00[BuffWatcher]|r No longer suppressed")
    end
end

local BUFF_DROP_THROTTLE = 0.5
local lastBuffDropCheck = 0
local RAID_BUFF_THROTTLE = 1.0
local lastRaidBuffCheck = 0
local lastClassBuffCheck = 0

function Core:OnPlayerAuraChanged()
    local db = BWV2:GetDB()
    if not db.enabled then return end
    if suppressed then return end

    local now = GetTime()

    if db.raidBuffAlwaysCheck and BuffDropAlert then
        if BuffDropAlert:HasAlerts() then
            BuffDropAlert:CheckRebuffsForPrefix("raidAlways_")
        end

        if now - lastRaidBuffCheck >= RAID_BUFF_THROTTLE then
            lastRaidBuffCheck = now
            local missing = BWV2:CheckAlwaysOnRaidBuffs()
            if missing then
                BuffDropAlert:AddAlerts(missing)
            else
                BuffDropAlert:DismissByPrefix("raidAlways_")
            end
        end
    end

    if db.classBuffAlwaysCheck and BuffDropAlert then
        if BuffDropAlert:HasAlerts() then
            BuffDropAlert:CheckRebuffsForPrefix("classAlways_")
        end

        if now - lastClassBuffCheck >= RAID_BUFF_THROTTLE then
            lastClassBuffCheck = now
            local missing = BWV2:CheckAlwaysOnClassBuffs()
            if missing then
                BuffDropAlert:AddAlerts(missing)
            else
                BuffDropAlert:DismissByPrefix("classAlways_")
            end
        end
    end

    if not db.buffDropReminder then return end
    if BWV2.lastScanTime == 0 then return end

    if BuffDropAlert and BuffDropAlert:HasAlerts() then
        BuffDropAlert:CheckRebuffs()
    end

    if now - lastBuffDropCheck < BUFF_DROP_THROTTLE then return end
    lastBuffDropCheck = now

    local dropped = BWV2:CheckBuffDrops()
    if dropped and BuffDropAlert then
        BuffDropAlert:AddAlerts(dropped)
    end
end

function Core:TriggerScan()
    TriggerScan()
end

function Core:StopTicker()
    StopTicker()
end

function Core:GetLastScanTime()
    return BWV2.lastScanTime
end

function Core:GetMissingBuffs()
    return BWV2.missingByCategory
end
