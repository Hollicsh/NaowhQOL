local _, ns = ...

-- BuffWatcherV2 Core Module
-- Event handling, lifecycle, and slash commands

local Core = {}
ns.BWV2Core = Core

local BWV2 = ns.BWV2
local Categories = ns.BWV2Categories
local Watchers = ns.BWV2Watchers
local Scanner = ns.BWV2Scanner
local ReportCard = ns.BWV2ReportCard

-- Scan ticker (0.5s interval while report card visible)
local SCAN_INTERVAL = 0.5
local scanTicker = nil

-- Suppressed state (runtime only, resets on reload)
local suppressed = false

-- Event frame
local eventFrame = CreateFrame("Frame")

-- Stop the scan ticker
local function StopTicker()
    if scanTicker then
        scanTicker:Cancel()
        scanTicker = nil
    end
end

-- Start the scan ticker (runs while report card is visible)
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
        -- Perform scan and update display
        Scanner:PerformScan()
        ReportCard:Update()
    end)
end

-- Trigger a scan
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

    -- Perform synchronous scan
    Scanner:PerformScan()

    BWV2.scanInProgress = false
    BWV2.lastScanTime = GetTime()

    Core:PrintSummary()
    ReportCard:Show()
    StartTicker()
end

-- Print summary of missing buffs
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

    -- Group by category type for cleaner output
    local raidMissing = {}
    local classBuffMissing = {}
    local consumableMissing = {}
    local inventoryMissing = {}

    for key, data in pairs(missing) do
        local found = false

        -- Check raid buffs
        for _, buff in ipairs(Categories.RAID) do
            if buff.key == key then
                raidMissing[key] = data
                found = true
                break
            end
        end

        -- Check consumables
        if not found then
            for _, buff in ipairs(Categories.CONSUMABLE_GROUPS) do
                if buff.key == key then
                    consumableMissing[key] = data
                    found = true
                    break
                end
            end
        end

        -- Check inventory
        if not found then
            for _, group in ipairs(Categories.INVENTORY_GROUPS) do
                if group.key == key then
                    inventoryMissing[key] = data
                    found = true
                    break
                end
            end
        end

        -- Remaining are class buffs (user-defined)
        if not found then
            classBuffMissing[key] = data
        end
    end

    -- Print raid buffs
    if next(raidMissing) then
        print("  |cffffcc00Raid Buffs:|r")
        for key, data in pairs(raidMissing) do
            local coverage = data.missing and string.format(" (%d/%d covered)", data.total - data.missing, data.total) or ""
            print("    |cffffa900- " .. (data.name or key) .. coverage .. "|r")
        end
    end

    -- Print class buffs (grouped by check type)
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

    -- Print consumables
    if next(consumableMissing) then
        print("  |cffffcc00Consumables:|r")
        for key, data in pairs(consumableMissing) do
            print("    |cffffa900- " .. (data.name or key) .. "|r")
        end
    end

    -- Print inventory (missing only)
    if next(inventoryMissing) then
        print("  |cffffcc00Inventory:|r")
        for key, data in pairs(inventoryMissing) do
            print("    |cffffa900- " .. (data.name or key) .. ": Missing|r")
        end
    end
end

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "READY_CHECK" then
        TriggerScan()

    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Combat started - hide report card and stop ticker
        StopTicker()
        if ReportCard and ReportCard:IsShown() then
            ReportCard:Hide()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Combat ended - do nothing
        return

    elseif event == "CHALLENGE_MODE_START" then
        -- M+ started - hide report card and stop ticker
        StopTicker()
        if ReportCard and ReportCard:IsShown() then
            ReportCard:Hide()
        end

    elseif event == "PLAYER_LOGIN" then
        -- Initialize saved variables
        BWV2:InitSavedVars()

        -- Register for profile refresh
        ns.SettingsIO:RegisterRefresh("buffWatcherV2", function()
            -- Hide report card if showing (will re-read settings on next scan)
            StopTicker()
            if ReportCard and ReportCard:IsShown() then
                ReportCard:Hide()
            end
            -- Reset state so next scan uses new settings
            BWV2:ResetState()
        end)

        -- Scan on login if enabled (delayed to ensure everything is loaded)
        local db = BWV2:GetDB()
        if db.enabled and db.scanOnLogin then
            C_Timer.After(2, function()
                -- Skip if in combat or M+
                if InCombatLockdown() then return end
                if C_ChallengeMode and C_ChallengeMode.IsChallengeModeActive() then return end
                TriggerScan()
            end)
        end
    end
end)

-- Register events
eventFrame:RegisterEvent("READY_CHECK")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("CHALLENGE_MODE_START")
eventFrame:RegisterEvent("PLAYER_LOGIN")

-- Slash command for manual scan
SLASH_NSCAN1 = "/nscan"
SlashCmdList["NSCAN"] = function(msg)
    TriggerScan()
end

-- Slash command to suppress/unsuppress module
SLASH_NSUP1 = "/nsup"
SlashCmdList["NSUP"] = function(msg)
    suppressed = not suppressed
    if suppressed then
        -- Hide report card and stop ticker when suppressing
        StopTicker()
        if ReportCard and ReportCard:IsShown() then
            ReportCard:Hide()
        end
        print("|cffff6600[BuffWatcher]|r Suppressed until reload or /nsup")
    else
        print("|cff00ff00[BuffWatcher]|r No longer suppressed")
    end
end

-- Public API
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
