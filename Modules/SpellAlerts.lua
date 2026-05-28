local addonName, ns = ...

local frame = CreateFrame("Frame")
local currentApplied

local function GetDB()
    return NaowhQOL and NaowhQOL.spellAlerts
end

local function GetSpecID()
    local specIndex = GetSpecialization and GetSpecialization()
    if not specIndex then return nil end
    return GetSpecializationInfo(specIndex)
end

local function SetOverlayCVar(enabled)
    local setter = SetCVar or (C_CVar and C_CVar.SetCVar)
    if setter then
        pcall(setter, "displaySpellActivationOverlays", enabled and "1" or "0")
    end
end

local function Apply()
    local db = GetDB()
    if not db or not db.enabled then
        if currentApplied ~= true then
            SetOverlayCVar(true)
            currentApplied = true
        end
        return
    end

    db.enabledSpecs = db.enabledSpecs or {}
    local specID = GetSpecID()
    local enabled = specID and db.enabledSpecs[specID] == true
    SetOverlayCVar(enabled)
    currentApplied = enabled
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")
frame:SetScript("OnEvent", function()
    C_Timer.After(0, Apply)
end)

ns.SpellAlerts = {
    Apply = Apply,
    GetSpecID = GetSpecID,
}
