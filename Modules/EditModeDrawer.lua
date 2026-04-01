local addonName, ns = ...

local LibEditModeDrawer = LibStub("LibEditModeDrawer", true)
if not LibEditModeDrawer then return end

local settingsDrawer, unlockDrawer
local hooked = false

local function AreAllUnlocked()
    local registry = ns.MODULE_REGISTRY
    if not registry then return false end
    for _, entry in ipairs(registry) do
        if #entry.unlockKeys > 0 then
            local modDb = NaowhQOL[entry.db]
            if modDb then
                for _, key in ipairs(entry.unlockKeys) do
                    if not modDb[key] then return false end
                end
            end
        end
    end
    return true
end

local function GetUnlockableEntries()
    local entries = {}
    local registry = ns.MODULE_REGISTRY
    local displayNames = ns.MODULE_DISPLAY_NAMES
    if not registry then return entries end
    local seen = {}
    for _, entry in ipairs(registry) do
        if #entry.unlockKeys > 0 and not seen[entry.db] then
            seen[entry.db] = true
            entries[#entries + 1] = displayNames and displayNames[entry.db] or entry.db
        end
    end
    return entries
end

local function SetAllUnlocks(state)
    local registry = ns.MODULE_REGISTRY
    if not registry then return end
    for _, entry in ipairs(registry) do
        local modDb = NaowhQOL[entry.db]
        if modDb then
            for _, key in ipairs(entry.unlockKeys) do
                modDb[key] = state
            end
        end
    end
    if ns.SettingsIO then ns.SettingsIO:MarkDirty() end
    if ns.RefreshAllModuleDisplays then ns.RefreshAllModuleDisplays() end
    if state and ns.DisplayUtils then
        ns.DisplayUtils.DisableEditModeSnap()
    end
    if ns.BWV2ReportCard then
        if state then
            pcall(ns.BWV2ReportCard.ApplySettings, ns.BWV2ReportCard)
            pcall(ns.BWV2ReportCard.ShowPreview, ns.BWV2ReportCard)
        else
            pcall(ns.BWV2ReportCard.Hide, ns.BWV2ReportCard)
        end
    end
    if ns.BWV2BuffDropAlert then
        if state then
            pcall(ns.BWV2BuffDropAlert.ShowPreview, ns.BWV2BuffDropAlert)
        else
            pcall(ns.BWV2BuffDropAlert.HidePreview, ns.BWV2BuffDropAlert)
        end
    end
end

local function OnEnterEditMode()
    if settingsDrawer then settingsDrawer:EnterEditMode() end
    if unlockDrawer then unlockDrawer:EnterEditMode() end
end

local function OnExitEditMode()
    if settingsDrawer then settingsDrawer:ExitEditMode() end
    if unlockDrawer then unlockDrawer:ExitEditMode() end
end

local function InitDrawers()
    settingsDrawer = LibEditModeDrawer:CreateDrawer({
        id = "NaowhQOLSettings",
        label = "|cff0091edNaowh|r|cffffa300QOL|r\nSettings",
        getEntries = function() return {"Settings Panel"} end,
        getValue = function()
            return ns.MainFrame and ns.MainFrame:IsShown()
        end,
        setValue = function(checked)
            if not ns.MainFrame then return end
            if checked and not ns.MainFrame:IsShown() then
                SlashCmdList["NAOWHQOL"]()
            elseif not checked and ns.MainFrame:IsShown() then
                ns.MainFrame:Hide()
            end
        end,
        tooltipHeader = "NaowhQOL Settings",
        tooltipDescriptionTemplate = "Open the %s configuration panel.\n\n%s",
        tooltipProductName = "NaowhQOL",
    })

    unlockDrawer = LibEditModeDrawer:CreateDrawer({
        id = "NaowhQOLUnlock",
        label = "|cff0091edNaowh|r|cffffa300QOL|r\nUnlock All",
        getEntries = GetUnlockableEntries,
        getValue = AreAllUnlocked,
        setValue = function(checked) SetAllUnlocks(checked) end,
        tooltipHeader = "NaowhQOL Unlock / Lock All",
        tooltipDescriptionTemplate = "Toggle all %s movable frames:\n\n%s",
        tooltipProductName = "NaowhQOL",
    })
end

local function TryHook()
    if hooked then return true end
    if not EditModeManagerFrame then return false end
    if not EditModeManagerFrame.EnterEditMode then return false end

    hooksecurefunc(EditModeManagerFrame, "EnterEditMode", OnEnterEditMode)
    hooksecurefunc(EditModeManagerFrame, "ExitEditMode", OnExitEditMode)

    hooked = true
    return true
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        InitDrawers()
        if TryHook() then
            self:UnregisterAllEvents()
        end
    elseif event == "ADDON_LOADED" then
        if settingsDrawer and TryHook() then
            self:UnregisterAllEvents()
        end
    end
end)
