local _, ns = ...

local Core = {}
ns.BWV2Core = Core

local BWV2 = ns.BWV2
local Categories = ns.BWV2Categories
local Scanner = ns.BWV2Scanner
local ReportCard = ns.BWV2ReportCard
local BuffDropAlert = ns.BWV2BuffDropAlert

local SCAN_INTERVAL = 0.5
local REFRESH_INTERVAL = 1.0
local WEAPON_ENCHANT_POLL_INTERVAL = 1.0

local scanTicker = nil
local refreshTicker = nil
local weaponEnchantTicker = nil

local suppressed = false

local eventFrame = CreateFrame("Frame")

local function StopTicker()
    if scanTicker then
        scanTicker:Cancel()
        scanTicker = nil
    end
end

local function StopRefreshTicker()
    if refreshTicker then
        refreshTicker:Cancel()
        refreshTicker = nil
    end
end

local function StopWeaponEnchantPoller()
    if weaponEnchantTicker then
        weaponEnchantTicker:Cancel()
        weaponEnchantTicker = nil
    end
end

local function StopAllPollers()
    StopTicker()
    StopRefreshTicker()
    StopWeaponEnchantPoller()
end

local function HasWeaponEnchantAlert()
    local db = BWV2:GetDB()
    if not db.classBuffAlwaysCheck then return false end
    local _, playerClass = UnitClass("player")
    local classData = db.classBuffs and db.classBuffs[playerClass]
    if not classData or not classData.enabled then return false end
    for _, group in ipairs(classData.groups or {}) do
        if group.checkType == "weaponEnchant" then
            return true
        end
    end
    for _, grp in ipairs(Categories.CONSUMABLE_GROUPS or {}) do
        if grp.checkType == "weaponEnchant" and Categories:IsConsumableGroupEnabled(grp.key) then
            return true
        end
    end
    return false
end

local function StartWeaponEnchantPoller()
    StopWeaponEnchantPoller()
    if not HasWeaponEnchantAlert() then return end
    local db = BWV2:GetDB()
    if not db or not db.enabled or not db.buffDropReminder then return end

    weaponEnchantTicker = C_Timer.NewTicker(WEAPON_ENCHANT_POLL_INTERVAL, function()
        local cdb = BWV2:GetDB()
        if not cdb or not cdb.enabled or not cdb.buffDropReminder then
            StopWeaponEnchantPoller()
            return
        end
        if suppressed then
            StopWeaponEnchantPoller()
            return
        end
        BWV2:SetDirty()
    end)
end

local function DoRefresh()
    if not BWV2:IsEnabled() then return end
    if suppressed then return end
    BWV2:RefreshAlerts()
    if BuffDropAlert then
        BuffDropAlert:SyncFromState()
    end
end

local function StartRefreshTicker()
    StopRefreshTicker()
    local db = BWV2:GetDB()
    if not db or not db.enabled or not db.buffDropReminder then return end
    local hasAnyAlwaysOn = db.raidBuffAlwaysCheck or db.classBuffAlwaysCheck or db.consumableAlwaysCheck or db.inventoryAlwaysCheck
    if not hasAnyAlwaysOn then return end

    refreshTicker = C_Timer.NewTicker(REFRESH_INTERVAL, function()
        local cdb = BWV2:GetDB()
        if not cdb or not cdb.enabled or not cdb.buffDropReminder then
            StopRefreshTicker()
            return
        end
        if suppressed then
            StopRefreshTicker()
            return
        end
        if BWV2.dirty then
            DoRefresh()
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

        Scanner:PerformScan()
        ReportCard:Update()
    end)
end

local function TriggerScan()
    if not BWV2:IsEnabled() then return end
    if suppressed then return end
    if BWV2.scanInProgress then return end

    if InCombatLockdown() then return end
    if ns.ZoneUtil.IsInPvP() then return end

    BWV2.scanInProgress = true
    Scanner:PerformScan()
    BWV2.scanInProgress = false
    BWV2.lastScanTime = GetTime()

    Core:PrintSummary()
    ReportCard:Show()
    StartTicker()

    BWV2:SetDirty()
    DoRefresh()
    StartWeaponEnchantPoller()
    StartRefreshTicker()
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

local AURA_THROTTLE = 0.5
local lastAuraRefresh = 0

local function OnPlayerAuraChanged()
    local db = BWV2:GetDB()
    if not db.enabled then return end
    if suppressed then return end
    if not db.buffDropReminder then return end

    local now = GetTime()
    if now - lastAuraRefresh < AURA_THROTTLE then
        BWV2:SetDirty()
        return
    end
    lastAuraRefresh = now

    DoRefresh()
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
            OnPlayerAuraChanged()
        end

    elseif event == "UNIT_INVENTORY_CHANGED" then
        local unit = ...
        if unit == "player" then
            C_Timer.After(0, function()
                BWV2:SetDirty()
                DoRefresh()
            end)
        end

    elseif event == "BAG_UPDATE_DELAYED" then
        local db = BWV2:GetDB()
        if db and db.enabled and db.buffDropReminder and db.inventoryAlwaysCheck and not InCombatLockdown() then
            BWV2:SetDirty()
            DoRefresh()
        end

    elseif event == "PLAYER_REGEN_DISABLED" then
        BWV2:SetCombatState(true)
        StopTicker()
        if ReportCard and ReportCard:IsShown() then
            ReportCard:Hide()
        end
        if BuffDropAlert then
            BuffDropAlert:DismissNonCombatSafe()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        BWV2:SetCombatState(BWV2.inEncounter)
        C_Timer.After(0.5, function()
            if not InCombatLockdown() then
                DoRefresh()
                StartRefreshTicker()
                StartWeaponEnchantPoller()
            end
        end)

    elseif event == "ENCOUNTER_START" then
        BWV2:SetEncounterState(true)

    elseif event == "ENCOUNTER_END" then
        BWV2.inEncounter = false
        BWV2:SetCombatState(InCombatLockdown())

    elseif event == "CHALLENGE_MODE_START" then
        BWV2.inMythicPlus = true
        StopAllPollers()
        if ReportCard and ReportCard:IsShown() then
            ReportCard:Hide()
        end
        if BuffDropAlert then BuffDropAlert:DismissAll() end
        BWV2:ClearAlerts()
        BWV2:ClearDismissals()

    elseif event == "PLAYER_DEAD" then
        BWV2:SetDeadState(true)

    elseif event == "PLAYER_UNGHOST" or event == "PLAYER_ALIVE" then
        if not UnitIsDead("player") then
            BWV2:SetDeadState(false)
            C_Timer.After(0.5, function()
                DoRefresh()
            end)
        end

    elseif event == "PLAYER_LOGIN" then
        Categories:LocalizeSpecNames()
        BWV2:InitSavedVars()

        if ns.ZoneUtil then
            ns.ZoneUtil.RegisterCallback("BWV2_AlertFilter", function()
                local cdb = BWV2:GetDB()
                if cdb and cdb.enabled and BWV2:ShouldSuppressAlerts() then
                    if BuffDropAlert then BuffDropAlert:DismissAll() end
                    BWV2:ClearAlerts()
                    BWV2:ClearDismissals()
                end
            end)
        end

        ns.SettingsIO:RegisterRefresh("buffWatcherV2", function()
            StopAllPollers()
            if ReportCard and ReportCard:IsShown() then
                ReportCard:Hide()
            end
            BWV2:ResetState()
            BWV2:ClearAlerts()
            BWV2:ClearDismissals()
        end)

        local db = BWV2:GetDB()
        if db.enabled and db.scanOnLogin then
            C_Timer.After(2, function()
                if InCombatLockdown() then return end
                if C_ChallengeMode and C_ChallengeMode.IsChallengeModeActive() then return end
                TriggerScan()
            end)
        end

        if db.enabled and db.buffDropReminder then
            C_Timer.After(3, function()
                DoRefresh()
                StartRefreshTicker()
                StartWeaponEnchantPoller()
            end)
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        BWV2.inMythicPlus = false
        local db = BWV2:GetDB()
        if db and db.enabled and db.buffDropReminder then
            C_Timer.After(1.5, function()
                BWV2:ClearDismissals()
                DoRefresh()
                StartRefreshTicker()
                StartWeaponEnchantPoller()
            end)
        end

    elseif event == "PLAYER_UPDATE_RESTING" then
        local db = BWV2:GetDB()
        if db and db.enabled and db.buffDropAlertDisableRested and IsResting() then
            if BuffDropAlert then BuffDropAlert:DismissAll() end
            BWV2:ClearAlerts()
            BWV2:ClearDismissals()
        end

    elseif event == "GROUP_ROSTER_UPDATE" then
        BWV2:SetDirty()
        if BWV2:GetDB().buffDropReminder and BWV2:GetDB().raidBuffAlwaysCheck then
            C_Timer.After(0.5, function()
                DoRefresh()
            end)
        end
    end
end)

eventFrame:RegisterEvent("READY_CHECK")
eventFrame:RegisterEvent("READY_CHECK_CONFIRM")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("ENCOUNTER_START")
eventFrame:RegisterEvent("ENCOUNTER_END")
eventFrame:RegisterEvent("CHALLENGE_MODE_START")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
eventFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
eventFrame:RegisterEvent("PLAYER_DEAD")
eventFrame:RegisterEvent("PLAYER_UNGHOST")
eventFrame:RegisterEvent("PLAYER_ALIVE")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

SLASH_NSCAN1 = "/nscan"
SlashCmdList["NSCAN"] = function(msg)
    TriggerScan()
end

SLASH_NSUP1 = "/nsup"
SlashCmdList["NSUP"] = function(msg)
    suppressed = not suppressed
    if suppressed then
        StopAllPollers()
        if ReportCard and ReportCard:IsShown() then
            ReportCard:Hide()
        end
        if BuffDropAlert then BuffDropAlert:DismissAll() end
        BWV2:ClearAlerts()
        BWV2:ClearDismissals()
        print("|cffff6600[BuffWatcher]|r Suppressed until reload or /nsup")
    else
        print("|cff00ff00[BuffWatcher]|r No longer suppressed")
        DoRefresh()
        StartRefreshTicker()
        StartWeaponEnchantPoller()
    end
end

function Core:TriggerScan()
    TriggerScan()
end

function Core:StopTicker()
    StopTicker()
end

function Core:StopAllPollers()
    StopAllPollers()
end

function Core:GetLastScanTime()
    return BWV2.lastScanTime
end

function Core:GetMissingBuffs()
    return BWV2.missingByCategory
end

function Core:ForceRefresh()
    DoRefresh()
end

SLASH_NBWDEBUG1 = "/nbwdebug"
SlashCmdList["NBWDEBUG"] = function()
    local db = BWV2:GetDB()
    local contentType = BWV2:GetCurrentContentType()
    local threshold = BWV2:GetThreshold()
    print("|cff00ccff[BWDebug]|r contentType=" .. contentType .. " threshold=" .. threshold .. "s (" .. math.floor(threshold/60) .. "min)")
    print("|cff00ccff[BWDebug]|r buffDropReminder=" .. tostring(db.buffDropReminder) .. " raidAlways=" .. tostring(db.raidBuffAlwaysCheck) .. " classAlways=" .. tostring(db.classBuffAlwaysCheck) .. " consumableAlways=" .. tostring(db.consumableAlwaysCheck))
    print("|cff00ccff[BWDebug]|r inCombat=" .. tostring(BWV2.inCombat) .. " inEncounter=" .. tostring(BWV2.inEncounter) .. " inReadyCheck=" .. tostring(BWV2.inReadyCheck) .. " isDead=" .. tostring(BWV2.isDead))
    print("|cff00ccff[BWDebug]|r activeAlerts:")
    for k, v in pairs(BWV2.activeAlerts) do
        print("|cff00ccff[BWDebug]|r   [" .. k .. "] cat=" .. (v.category or "?") .. " dismissed=" .. tostring(BWV2:IsAlertDismissed(k)))
    end
end
