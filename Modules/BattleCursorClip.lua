local addonName, ns = ...

local CLIP_CVAR = "ClipCursor"

local clippedByUs = false
local savedClipValue = nil

local function IsEnabled()
    return NaowhQOL.misc and NaowhQOL.misc.combatCursorClip
end

local function GetClipValue()
    local ok, val = pcall(GetCVar, CLIP_CVAR)
    return ok and val or "0"
end

local function SetClipValue(val)
    pcall(SetCVar, CLIP_CVAR, tostring(val))
end

local function ClipForCombat()
    if not IsEnabled() or clippedByUs then return end
    savedClipValue = GetClipValue()
    SetClipValue("1")
    clippedByUs = true
end

local function RestoreClip()
    if not clippedByUs then return end
    SetClipValue(savedClipValue or "0")
    clippedByUs = false
    savedClipValue = nil
end

ns.BattleCursorClip = {
    Restore = RestoreClip,
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        if InCombatLockdown() and IsEnabled() then
            ClipForCombat()
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        ClipForCombat()
    elseif event == "PLAYER_REGEN_ENABLED" then
        RestoreClip()
    elseif event == "PLAYER_LOGOUT" then
        RestoreClip()
    end
end)
