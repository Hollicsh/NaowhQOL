local addonName, ns = ...

local LCG = LibStub and LibStub("LibCustomGlow-1.0", true)

local frameMap = {}
local observed = {}
local scanFrame = CreateFrame("Frame")

local STATIC_COLORS = {
    Magic = { 0.2, 0.6, 1.0, 1 },
    Curse = { 0.6, 0.2, 1.0, 1 },
    Disease = { 0.6, 0.4, 0.0, 1 },
    Poison = { 0.0, 0.6, 0.0, 1 },
    Bleed = { 0.8, 0.0, 0.0, 1 },
}

local function IsFrame(frame)
    local objectType = type(frame)
    if objectType ~= "table" and objectType ~= "userdata" then return false end
    if type(frame.GetObjectType) ~= "function" then return false end
    if type(frame.SetPoint) ~= "function" then return false end
    if type(frame.CreateTexture) ~= "function" then return false end
    local ok = pcall(frame.GetObjectType, frame)
    return ok
end

local function IsSecret(value)
    return issecretvalue and issecretvalue(value) or false
end

local function GetDB()
    return NaowhQOL and NaowhQOL.dispelGlow
end

local function GetFrameUnit(frame)
    if not IsFrame(frame) then return nil end
    if frame.unit then return frame.unit end
    if frame.GetAttribute then
        local ok, unit = pcall(frame.GetAttribute, frame, "unit")
        if ok then return unit end
    end
    return nil
end

local function AddTypes(types, ...)
    for i = 1, select("#", ...) do
        types[select(i, ...)] = true
    end
end

local function GetDispelTypes()
    local types = {}
    local _, class = UnitClass("player")
    local specIndex = GetSpecialization and GetSpecialization()
    local specID = specIndex and GetSpecializationInfo(specIndex)

    if class == "DRUID" then
        AddTypes(types, "Curse", "Poison")
        if specID == 105 then types.Magic = true end
    elseif class == "EVOKER" then
        AddTypes(types, "Bleed", "Curse", "Disease", "Poison")
        if specID == 1468 then types.Magic = true end
    elseif class == "MAGE" then
        types.Curse = true
    elseif class == "MONK" then
        AddTypes(types, "Disease", "Poison")
        if specID == 270 then types.Magic = true end
    elseif class == "PALADIN" then
        AddTypes(types, "Disease", "Poison")
        if specID == 65 then types.Magic = true end
    elseif class == "PRIEST" then
        types.Disease = true
        if specID == 256 or specID == 257 then types.Magic = true end
    elseif class == "SHAMAN" then
        types.Curse = true
        if specID == 264 then types.Magic = true end
    end

    return types
end

local dispelTypes = {}

local function RefreshDispelTypes()
    dispelTypes = GetDispelTypes()
end

local function CreateVisual(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetAllPoints(parent)
    f:SetFrameLevel((parent:GetFrameLevel() or 1) + 10)
    f:EnableMouse(false)

    f.top = f:CreateTexture(nil, "OVERLAY")
    f.top:SetColorTexture(1, 1, 1, 1)
    f.top:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    f.top:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    f.top:SetHeight(3)

    f.bottom = f:CreateTexture(nil, "OVERLAY")
    f.bottom:SetColorTexture(1, 1, 1, 1)
    f.bottom:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
    f.bottom:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    f.bottom:SetHeight(3)

    f.left = f:CreateTexture(nil, "OVERLAY")
    f.left:SetColorTexture(1, 1, 1, 1)
    f.left:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    f.left:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
    f.left:SetWidth(3)

    f.right = f:CreateTexture(nil, "OVERLAY")
    f.right:SetColorTexture(1, 1, 1, 1)
    f.right:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    f.right:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    f.right:SetWidth(3)

    f:Hide()
    return f
end

local function SetVisualColor(visual, color)
    local db = GetDB()
    local r, g, b, a
    if db and db.useDispelColor ~= false and color then
        r, g, b, a = color[1], color[2], color[3], color[4]
    else
        r = db and db.colorR or 0.0
        g = db and db.colorG or 1.0
        b = db and db.colorB or 0.0
        a = db and db.alpha or 1.0
    end
    a = a or 1
    visual.top:SetVertexColor(r, g, b, a)
    visual.bottom:SetVertexColor(r, g, b, a)
    visual.left:SetVertexColor(r, g, b, a)
    visual.right:SetVertexColor(r, g, b, a)
end

local function StopGlow(visual)
    if not LCG or not visual then return end
    LCG.PixelGlow_Stop(visual)
    LCG.AutoCastGlow_Stop(visual)
    LCG.ButtonGlow_Stop(visual)
    LCG.ProcGlow_Stop(visual)
end

local function StartGlow(visual, color)
    local db = GetDB()
    if not LCG or not visual or not db or not db.glowEnabled then return end
    local glowColor = color or { db.colorR or 0, db.colorG or 1, db.colorB or 0, db.alpha or 1 }
    local glowType = db.glowType or "pixel"
    StopGlow(visual)
    if glowType == "autocast" then
        LCG.AutoCastGlow_Start(visual, glowColor, db.glowLines or 8, db.glowFrequency or 0.25, db.glowScale or 1, 1, 1, nil)
    elseif glowType == "button" then
        LCG.ButtonGlow_Start(visual, glowColor, db.glowFrequency or 0.25)
    elseif glowType == "proc" then
        LCG.ProcGlow_Start(visual, { color = glowColor, duration = db.glowDuration or 1 })
    else
        LCG.PixelGlow_Start(visual, glowColor, db.glowLines or 8, db.glowFrequency or 0.25, db.glowLength or 6, db.glowThickness or 2, 0, 0, true, nil)
    end
end

local function FindDispellableAura(unit)
    if not unit or not UnitExists(unit) then return nil end
    for i = 1, 40 do
        local aura = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex and C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
        if not aura then return nil end
        local dispelName = aura.dispelName or aura.dispelType
        if dispelName and not IsSecret(dispelName) and dispelTypes[dispelName] then
            local color = STATIC_COLORS[dispelName]
            if C_UnitAuras.GetAuraDispelTypeColor and aura.auraInstanceID and not IsSecret(aura.auraInstanceID) then
                local ok, c = pcall(C_UnitAuras.GetAuraDispelTypeColor, unit, aura.auraInstanceID)
                if ok and c then
                    color = { c.r or color[1], c.g or color[2], c.b or color[3], c.a or 1 }
                end
            end
            return color
        end
    end
    return nil
end

local function UpdateFrame(frame)
    local db = GetDB()
    local entry = frameMap[frame]
    if not entry then return end
    if not db or not db.enabled then
        StopGlow(entry.visual)
        entry.visual:Hide()
        return
    end
    local unit = GetFrameUnit(frame)
    local color = FindDispellableAura(unit)
    if color then
        SetVisualColor(entry.visual, color)
        entry.visual:Show()
        StartGlow(entry.visual, color)
    else
        StopGlow(entry.visual)
        entry.visual:Hide()
    end
end

local function Observe(frame)
    if not IsFrame(frame) or observed[frame] then return end
    observed[frame] = true
    frameMap[frame] = frameMap[frame] or { visual = CreateVisual(frame) }
    if frame.HookScript then
        frame:HookScript("OnAttributeChanged", function(self, name)
            if name == "unit" then UpdateFrame(self) end
        end)
    end
end

local function Discover()
    if InCombatLockdown and InCombatLockdown() then
        C_Timer.After(1, Discover)
        return
    end

    if CompactRaidFrameContainer and CompactRaidFrameContainer.flowFrames then
        for _, frame in pairs(CompactRaidFrameContainer.flowFrames) do
            Observe(frame)
        end
    end

    for i = 1, 40 do
        Observe(_G["CompactRaidFrame" .. i])
    end
    for i = 1, 5 do
        Observe(_G["CompactPartyFrameMember" .. i])
    end
    for g = 1, 8 do
        for b = 1, 5 do
            Observe(_G["ElvUF_PartyGroup" .. g .. "UnitButton" .. b])
            Observe(_G["ElvUF_RaidGroup" .. g .. "UnitButton" .. b])
        end
    end
    for i = 1, 8 do
        Observe(_G["ElvUF_TankUnitButton" .. i])
        Observe(_G["ElvUF_AssistUnitButton" .. i])
    end

    for frame in pairs(frameMap) do
        UpdateFrame(frame)
    end
end

local function Refresh()
    RefreshDispelTypes()
    Discover()
end

scanFrame:RegisterEvent("PLAYER_LOGIN")
scanFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
scanFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
scanFrame:RegisterEvent("UNIT_AURA")
scanFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
scanFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
scanFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
scanFrame:SetScript("OnEvent", function(_, event, unit)
    if event == "UNIT_AURA" then
        for frame in pairs(frameMap) do
            if GetFrameUnit(frame) == unit then
                UpdateFrame(frame)
            end
        end
    else
        Refresh()
        if event == "PLAYER_ENTERING_WORLD" then
            C_Timer.After(2, Refresh)
        end
    end
end)

ns.DispelGlow = {
    Refresh = Refresh,
}
