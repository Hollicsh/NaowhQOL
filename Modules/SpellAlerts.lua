local addonName, ns = ...

local frame = CreateFrame("Frame")
local lastAppliedOverlay

local function GetDB()
    return NaowhQOL and NaowhQOL.spellAlerts
end

local function GetSpecID()
    local specIndex = GetSpecialization and GetSpecialization()
    if not specIndex then return nil end
    return GetSpecializationInfo(specIndex)
end

local function IsAddOnLoadedSafe(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded(name)
    end
    local legacy = _G.IsAddOnLoaded
    if legacy then
        return legacy(name)
    end
    return false
end

local function IsProcGlowsLoaded()
    return IsAddOnLoadedSafe("ProcGlows")
end

local function SetOverlayCVar(enabled)
    local setter = SetCVar or (C_CVar and C_CVar.SetCVar)
    if setter then
        pcall(setter, "displaySpellActivationOverlays", enabled and "1" or "0")
    end
end

local function GetOverlayLive()
    local getter = GetCVar or (C_CVar and C_CVar.GetCVar)
    if not getter then return nil end
    local ok, live = pcall(getter, "displaySpellActivationOverlays")
    if ok and live ~= nil then
        return tostring(live)
    end
end

local function Apply(force)
    local desired

    -- ProcGlows hooks ActionButtonSpellAlertManager; overlays must stay on.
    if IsProcGlowsLoaded() then
        desired = "1"
    else
        local db = GetDB()
        if not db or not db.enabled then
            desired = "1"
        else
            db.enabledSpecs = db.enabledSpecs or {}
            local specID = GetSpecID()
            local enabled = specID and db.enabledSpecs[specID] == true
            desired = enabled and "1" or "0"
        end
    end

    if not force and ns.CVarSync and ns.CVarSync:IsExternal("displaySpellActivationOverlays") then
        return
    end

    local live = GetOverlayLive()
    if live then
        if not force and lastAppliedOverlay and live ~= lastAppliedOverlay and live ~= desired then
            return
        end
        if live == desired then
            lastAppliedOverlay = live
            return
        end
    end

    SetOverlayCVar(desired == "1")
    lastAppliedOverlay = desired
    if ns.CVarSync then
        ns.CVarSync:RecordApplied("displaySpellActivationOverlays", desired)
    end
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, event, loadedAddon)
    if event == "ADDON_LOADED" and loadedAddon ~= "ProcGlows" then
        return
    end
    C_Timer.After(0, Apply)
end)

ns.SpellAlerts = {
    Apply = Apply,
    GetSpecID = GetSpecID,
    IsProcGlowsLoaded = IsProcGlowsLoaded,
}
