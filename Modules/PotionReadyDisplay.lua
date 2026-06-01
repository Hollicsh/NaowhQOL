local addonName, ns = ...

local W = ns.Widgets
local LCG = LibStub and LibStub("LibCustomGlow-1.0", true)

local POTION_IDS = {
    241288, 241289, 241292, 241293, 241300,
    241301, 241308, 241309, 245898, 245903,
    1230859,
}

local frame = CreateFrame("Frame", "NaowhQOL_PotionReadyDisplay", UIParent, "BackdropTemplate")
frame:SetSize(240, 60)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 180)
frame:Hide()

local text = frame:CreateFontString(nil, "OVERLAY")
text:SetPoint("CENTER")
text:SetFont(ns.DefaultFontPath(), 24, "OUTLINE")
text:SetText("Potion ready")

local resizeHandle
local inCombat = false
local wasReady = false
local glowActive = false

local function GetDB()
    return NaowhQOL and NaowhQOL.potionReady
end

local function IsHealer()
    local specIndex = GetSpecialization and GetSpecialization()
    if not specIndex then return false end
    local role = select(5, GetSpecializationInfo(specIndex))
    return role == "HEALER"
end

local function ZoneAllowed(db)
    if not db.instanceOnly then return true end
    local inInstance, instanceType = IsInInstance()
    return inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "scenario")
end

local function HasReadyPotion()
    for _, itemID in ipairs(POTION_IDS) do
        local count = C_Item.GetItemCount(itemID, false, false, true) or 0
        if count > 0 then
            local start, duration, enabled = C_Container.GetItemCooldown(itemID)
            if enabled ~= 0 and (not duration or duration == 0 or not start or start == 0) then
                return true, itemID
            end
        end
    end
    return false, nil
end

local function StopGlow()
    if not LCG or not glowActive then return end
    LCG.PixelGlow_Stop(frame)
    LCG.AutoCastGlow_Stop(frame)
    LCG.ButtonGlow_Stop(frame)
    LCG.ProcGlow_Stop(frame)
    glowActive = false
end

local function StartGlow()
    local db = GetDB()
    if not db or not db.glowEnabled or not LCG then return end
    local color = { db.glowR or db.colorR or 0, db.glowG or db.colorG or 1, db.glowB or db.colorB or 0, db.alpha or 1 }
    StopGlow()
    if db.glowType == "autocast" then
        LCG.AutoCastGlow_Start(frame, color, db.glowLines or 8, db.glowFrequency or 0.25, db.glowScale or 1, 1, 1, nil)
    elseif db.glowType == "button" then
        LCG.ButtonGlow_Start(frame, color, db.glowFrequency or 0.25)
    elseif db.glowType == "proc" then
        LCG.ProcGlow_Start(frame, { color = color, duration = db.glowDuration or 1 })
    else
        LCG.PixelGlow_Start(frame, color, db.glowLines or 8, db.glowFrequency or 0.25, db.glowLength or 8, db.glowThickness or 2, 0, 0, true, nil)
    end
    glowActive = true
end

local function ApplyStyle()
    local db = GetDB()
    if not db then return end

    if not frame.initialized then
        frame:ClearAllPoints()
        local point = db.point or "CENTER"
        frame:SetPoint(point, UIParent, point, db.x or 0, db.y or 180)
        frame:SetSize(db.width or 240, db.height or 60)
        frame.initialized = true
    end

    local fontPath = ns.Media.ResolveFont(db.font)
    local fontSize = db.fontSize or 24
    local ok = text:SetFont(fontPath, fontSize, "OUTLINE")
    if not ok then text:SetFont(ns.DefaultFontPath(), fontSize, "OUTLINE") end
    text:SetText(db.text or "Potion ready")
    text:SetTextColor(db.colorR or 0, db.colorG or 1, db.colorB or 0, db.alpha or 1)

    frame:EnableMouse(db.unlock)
    if db.unlock then
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        if resizeHandle then resizeHandle:Show() end
        frame:Show()
    else
        frame:SetBackdrop(nil)
        if resizeHandle then resizeHandle:Hide() end
    end
end

local function ShouldShow(db)
    if not db or not db.enabled then return false end
    if db.combatOnly and not inCombat and not db.unlock then return false end
    if db.disableOnHealer and IsHealer() then return false end
    if not ZoneAllowed(db) then return false end
    return true
end

local function Update()
    local db = GetDB()
    ApplyStyle()

    if not ShouldShow(db) then
        wasReady = false
        StopGlow()
        if not (db and db.unlock) then frame:Hide() end
        return
    end

    local ready = HasReadyPotion()
    if ready then
        if not wasReady then
            if db.soundEnabled and db.soundID then ns.SoundList.Play(db.soundID) end
            StartGlow()
        elseif db.glowEnabled and not glowActive then
            StartGlow()
        end
        wasReady = true
        frame:Show()
    else
        wasReady = false
        StopGlow()
        if not db.unlock then frame:Hide() end
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("BAG_UPDATE_DELAYED")
events:RegisterEvent("SPELL_UPDATE_COOLDOWN")
events:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        local db = GetDB()
        if db then
            W.MakeDraggable(frame, { db = db })
            resizeHandle = W.CreateResizeHandle(frame, {
                db = db,
                minW = 120,
                minH = 24,
                maxW = 600,
                maxH = 160,
                onResize = ApplyStyle,
            })
            ns.SettingsIO:RegisterRefresh("potionReady", Update)
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
    elseif event == "PLAYER_ENTERING_WORLD" then
        inCombat = UnitAffectingCombat("player")
    end
    C_Timer.After(0.05, Update)
end)

ns.PotionReadyDisplay = {
    Update = Update,
    Frame = frame,
}
