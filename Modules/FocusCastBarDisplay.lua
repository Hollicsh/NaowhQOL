local addonName, ns = ...
local L = ns.L
local W = ns.Widgets

local INTERRUPT_SPELLS = {
    DEATHKNIGHT = {[250] = 47528, [251] = 47528, [252] = 47528},
    DEMONHUNTER = {[577] = 183752, [581] = 183752, [1480] = 183752},
    DRUID = {[102] = 78675, [103] = 106839, [104] = 106839, [105] = nil},
    EVOKER = {[1467] = 351338, [1468] = 351338, [1473] = 351338},
    HUNTER = {[253] = 147362, [254] = 147362, [255] = 187707},
    MAGE = {[62] = 2139, [63] = 2139, [64] = 2139},
    MONK = {[268] = 116705, [269] = 116705, [270] = nil},
    PALADIN = {[65] = nil, [66] = 96231, [70] = 96231},
    PRIEST = {[256] = nil, [257] = nil, [258] = 15487},
    ROGUE = {[259] = 1766, [260] = 1766, [261] = 1766},
    SHAMAN = {[262] = 57994, [263] = 57994, [264] = 57994},
    WARLOCK = {[265] = 19647, [266] = 119914, [267] = 19647},
    WARRIOR = {[71] = 6552, [72] = 6552, [73] = 6552},
}

local castBarFrame = CreateFrame("Frame", "NaowhQOL_FocusCastBar", UIParent, "BackdropTemplate")
castBarFrame:SetSize(250, 24)
castBarFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
castBarFrame:Hide()

local borderFrame = CreateFrame("Frame", nil, castBarFrame, "BackdropTemplate")
borderFrame:SetPoint("TOPLEFT", -1, 1)
borderFrame:SetPoint("BOTTOMRIGHT", 1, -1)
borderFrame:SetBackdrop({
    edgeFile = [[Interface\Buttons\WHITE8X8]],
    edgeSize = 1,
})
borderFrame:SetBackdropBorderColor(0, 0, 0, 1)

local bgTexture = castBarFrame:CreateTexture(nil, "BACKGROUND")
bgTexture:SetAllPoints()
bgTexture:SetTexture([[Interface\Buttons\WHITE8X8]])

local progressBar = CreateFrame("StatusBar", nil, castBarFrame)
progressBar:SetStatusBarTexture([[Interface\Buttons\WHITE8X8]])
progressBar:SetMinMaxValues(0, 1)
progressBar:SetValue(0)

local interruptBar = CreateFrame("StatusBar", nil, castBarFrame)
interruptBar:SetStatusBarTexture([[Interface\Buttons\WHITE8X8]])
interruptBar:SetStatusBarColor(0, 0, 0, 0)
interruptBar:SetAllPoints(progressBar)
interruptBar:SetMinMaxValues(0, 1)
interruptBar:SetValue(0)
interruptBar:Hide()

local interruptTick = interruptBar:CreateTexture(nil, "OVERLAY")
interruptTick:SetTexture([[Interface\Buttons\WHITE8X8]])
interruptTick:SetVertexColor(1, 1, 1, 0.9)
interruptTick:SetSize(2, 24)

local nonIntOverlay = progressBar:CreateTexture(nil, "OVERLAY")
nonIntOverlay:SetAllPoints(progressBar:GetStatusBarTexture())
nonIntOverlay:SetTexture([[Interface\Buttons\WHITE8X8]])
nonIntOverlay:SetAlpha(0)

local iconFrame = CreateFrame("Frame", nil, castBarFrame)
iconFrame:SetSize(24, 24)
iconFrame:SetPoint("LEFT", castBarFrame, "LEFT", 0, 0)

local iconBorder = CreateFrame("Frame", nil, iconFrame, "BackdropTemplate")
iconBorder:SetPoint("TOPLEFT", -1, 1)
iconBorder:SetPoint("BOTTOMRIGHT", 1, -1)
iconBorder:SetBackdrop({
    edgeFile = [[Interface\Buttons\WHITE8X8]],
    edgeSize = 1,
})
iconBorder:SetBackdropBorderColor(0, 0, 0, 1)

local iconTexture = iconFrame:CreateTexture(nil, "ARTWORK")
iconTexture:SetAllPoints()
iconTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93)

local shieldIcon = castBarFrame:CreateTexture(nil, "OVERLAY")
shieldIcon:SetAtlas("ui-castingbar-shield")
shieldIcon:SetSize(29, 33)
shieldIcon:SetPoint("TOP", castBarFrame, "BOTTOM", 0, 4)
shieldIcon:Hide()

local textFrame = CreateFrame("Frame", nil, castBarFrame)
textFrame:SetAllPoints(progressBar)
textFrame:SetFrameLevel(castBarFrame:GetFrameLevel() + 5)

local spellNameText = textFrame:CreateFontString(nil, "OVERLAY")
spellNameText:SetFont(ns.DefaultFontPath(), 12, "OUTLINE")
spellNameText:SetPoint("LEFT", textFrame, "LEFT", 4, 0)
spellNameText:SetJustifyH("LEFT")

local castTimeText = textFrame:CreateFontString(nil, "OVERLAY")
castTimeText:SetFont(ns.DefaultFontPath(), 12, "OUTLINE")
castTimeText:SetPoint("RIGHT", textFrame, "RIGHT", -4, 0)
castTimeText:SetJustifyH("RIGHT")

local empowerMarkers = {}

local resizeHandle
local isCasting = false
local isChanneling = false
local cachedInterruptSpellId = nil

local function GetInterruptSpellId()
    if cachedInterruptSpellId then
        return cachedInterruptSpellId
    end

    local _, class = UnitClass("player")
    local classSpells = INTERRUPT_SPELLS[class]
    if not classSpells then return nil end

    local spec = GetSpecialization()
    if not spec then return nil end

    local specId = GetSpecializationInfo(spec)
    if not specId then return nil end

    cachedInterruptSpellId = classSpells[specId]
    return cachedInterruptSpellId
end

local function UpdateBarColor()
    local db = NaowhQOL.focusCastBar
    if not db then return end

    local spellId = GetInterruptSpellId()
    if not spellId then
        progressBar:SetStatusBarColor(db.barColorCdR, db.barColorCdG, db.barColorCdB)
        return
    end

    local cooldownDuration = C_Spell.GetSpellCooldownDuration(spellId)
    if not cooldownDuration then
        progressBar:SetStatusBarColor(db.barColorCdR, db.barColorCdG, db.barColorCdB)
        return
    end

    local isReady = cooldownDuration:IsZero()
    local barTexture = progressBar:GetStatusBarTexture()

    local bcR, bcG, bcB = W.GetEffectiveColor(db, "barColorR", "barColorG", "barColorB", "barColorUseClassColor")
    local readyColor = CreateColor(bcR, bcG, bcB, 1)
    local cdcR, cdcG, cdcB = W.GetEffectiveColor(db, "barColorCdR", "barColorCdG", "barColorCdB", "barColorCdUseClassColor")
    local cdColor = CreateColor(cdcR, cdcG, cdcB, 1)

    barTexture:SetVertexColorFromBoolean(isReady, readyColor, cdColor)

    if db.hideOnCooldown then
        castBarFrame:SetAlphaFromBoolean(isReady)
    end
end

local function UpdateInterruptTick()
    local db = NaowhQOL.focusCastBar
    if not db or not db.showInterruptTick then
        interruptBar:Hide()
        return
    end

    if not isCasting and not isChanneling then
        interruptBar:Hide()
        return
    end

    local spellId = GetInterruptSpellId()
    if not spellId then
        interruptBar:Hide()
        return
    end

    local castDuration
    if isCasting then
        castDuration = UnitCastingDuration("focus")
    else
        castDuration = UnitChannelDuration("focus")
    end

    if not castDuration then
        interruptBar:Hide()
        return
    end

    local interruptCooldown = C_Spell.GetSpellCooldownDuration(spellId)
    if not interruptCooldown then
        interruptBar:Hide()
        return
    end

    local totalDuration = castDuration:GetTotalDuration()
    interruptBar:SetMinMaxValues(0, totalDuration)
    interruptBar:SetReverseFill(isChanneling)
    interruptBar:SetValue(interruptCooldown:GetRemainingDuration())

    interruptTick:ClearAllPoints()
    local barTexture = interruptBar:GetStatusBarTexture()
    if isChanneling then
        interruptTick:SetPoint("RIGHT", barTexture, "LEFT")
    else
        interruptTick:SetPoint("LEFT", barTexture, "RIGHT")
    end

    interruptTick:SetHeight(db.height or 24)
    local tickR, tickG, tickB = W.GetEffectiveColor(db, "tickColorR", "tickColorG", "tickColorB", "tickColorUseClassColor")
    interruptTick:SetVertexColor(tickR, tickG, tickB, 0.9)
    interruptBar:Show()

    local isReady = interruptCooldown:IsZero()
    interruptBar:SetAlphaFromBoolean(isReady, 0, 1)
end

local function UpdateInterruptibleDisplay()
    local db = NaowhQOL.focusCastBar
    if not db then return end

    local notInterruptible
    if isCasting then
        local _, _, _, _, _, _, _, notInt = UnitCastingInfo("focus")
        notInterruptible = notInt
    elseif isChanneling then
        local _, _, _, _, _, _, notInt = UnitChannelInfo("focus")
        notInterruptible = notInt
    else
        shieldIcon:Hide()
        nonIntOverlay:SetAlpha(0)
        return
    end

    if notInterruptible == nil then
        shieldIcon:Hide()
        nonIntOverlay:SetAlpha(0)
        return
    end

    if db.showShieldIcon then
        shieldIcon:Show()
        shieldIcon:SetAlphaFromBoolean(notInterruptible, 1, 0)
    else
        shieldIcon:Hide()
    end

    if db.colorNonInterrupt then
        local niR, niG, niB = W.GetEffectiveColor(db, "nonIntColorR", "nonIntColorG", "nonIntColorB", "nonIntColorUseClassColor")
        nonIntOverlay:SetVertexColor(niR, niG, niB, 1)
        nonIntOverlay:SetAlphaFromBoolean(notInterruptible, 1, 0)
    else
        nonIntOverlay:SetAlpha(0)
    end
end

local function UpdateLayout()
    local db = NaowhQOL.focusCastBar
    if not db then return end

    local showIcon = db.showIcon
    local iconPos = db.iconPosition or "LEFT"

    local iconW, iconH
    if db.autoSizeIcon then
        local barH = castBarFrame:GetHeight()
        if iconPos == "LEFT" or iconPos == "RIGHT" then
            iconH = barH
            iconW = barH
        else
            iconW = barH
            iconH = barH
        end
    else
        local s = db.iconSize or 24
        iconW = s
        iconH = s
    end

    iconFrame:SetSize(iconW, iconH)

    progressBar:ClearAllPoints()
    progressBar:SetAllPoints(castBarFrame)

    if showIcon then
        iconFrame:Show()
        iconFrame:ClearAllPoints()

        if db.autoSizeIcon then
            if iconPos == "LEFT" then
                iconFrame:SetPoint("TOPRIGHT", castBarFrame, "TOPLEFT", -1, 0)
                iconFrame:SetPoint("BOTTOMRIGHT", castBarFrame, "BOTTOMLEFT", -1, 0)
                iconFrame:SetWidth(iconW)
            elseif iconPos == "RIGHT" then
                iconFrame:SetPoint("TOPLEFT", castBarFrame, "TOPRIGHT", 1, 0)
                iconFrame:SetPoint("BOTTOMLEFT", castBarFrame, "BOTTOMRIGHT", 1, 0)
                iconFrame:SetWidth(iconW)
            elseif iconPos == "TOP" then
                iconFrame:SetPoint("BOTTOMLEFT", castBarFrame, "TOPLEFT", 0, 1)
                iconFrame:SetPoint("BOTTOMRIGHT", castBarFrame, "TOPRIGHT", 0, 1)
                iconFrame:SetHeight(iconH)
            elseif iconPos == "BOTTOM" then
                iconFrame:SetPoint("TOPLEFT", castBarFrame, "BOTTOMLEFT", 0, -1)
                iconFrame:SetPoint("TOPRIGHT", castBarFrame, "BOTTOMRIGHT", 0, -1)
                iconFrame:SetHeight(iconH)
            else
                iconFrame:SetPoint("TOPRIGHT", castBarFrame, "TOPLEFT", -1, 0)
                iconFrame:SetPoint("BOTTOMRIGHT", castBarFrame, "BOTTOMLEFT", -1, 0)
                iconFrame:SetWidth(iconW)
            end
        else
            iconFrame:SetSize(iconW, iconH)
            if iconPos == "LEFT" then
                iconFrame:SetPoint("RIGHT", castBarFrame, "LEFT", -1, 0)
            elseif iconPos == "RIGHT" then
                iconFrame:SetPoint("LEFT", castBarFrame, "RIGHT", 1, 0)
            elseif iconPos == "TOP" then
                iconFrame:SetPoint("BOTTOM", castBarFrame, "TOP", 0, 1)
            elseif iconPos == "BOTTOM" then
                iconFrame:SetPoint("TOP", castBarFrame, "BOTTOM", 0, -1)
            else
                iconFrame:SetPoint("RIGHT", castBarFrame, "LEFT", -1, 0)
            end
        end
    else
        iconFrame:Hide()
    end

    local bgR, bgG, bgB = W.GetEffectiveColor(db, "bgColorR", "bgColorG", "bgColorB", "bgColorUseClassColor")
    bgTexture:SetVertexColor(bgR, bgG, bgB, db.bgAlpha)

    local barStyle = ns.Media.ResolveBar(db.barStyle)
    progressBar:SetStatusBarTexture(barStyle)
    bgTexture:SetTexture(barStyle)

    textFrame:ClearAllPoints()
    textFrame:SetAllPoints(progressBar)

    interruptBar:ClearAllPoints()
    interruptBar:SetAllPoints(progressBar)

    local fontPath = ns.Media.ResolveFont(db.font)
    local fontSize = db.fontSize or 12
    spellNameText:SetFont(fontPath, fontSize, "OUTLINE")
    castTimeText:SetFont(fontPath, fontSize, "OUTLINE")
    local tcR, tcG, tcB = W.GetEffectiveColor(db, "textColorR", "textColorG", "textColorB", "textColorUseClassColor")
    spellNameText:SetTextColor(tcR, tcG, tcB)
    castTimeText:SetTextColor(tcR, tcG, tcB)

    spellNameText:SetWordWrap(false)
    local truncateLimit = db.spellNameTruncate or 0
    if truncateLimit > 0 then
        local charWidth = fontSize * 0.6
        spellNameText:SetWidth(truncateLimit * charWidth)
    else
        spellNameText:SetWidth(0)
    end

    if db.showSpellName then
        spellNameText:Show()
    else
        spellNameText:Hide()
    end

    if db.showTimeRemaining then
        castTimeText:Show()
    else
        castTimeText:Hide()
    end
end

local function HideEmpowerStages()
    for i, marker in ipairs(empowerMarkers) do
        marker:Hide()
    end
end

local function UpdateEmpowerStages(numStages)
    local db = NaowhQOL.focusCastBar
    if not db or not db.showEmpowerStages then
        HideEmpowerStages()
        return
    end

    local barWidth = progressBar:GetWidth()

    for i = 1, numStages - 1 do
        local marker = empowerMarkers[i]
        if not marker then
            marker = progressBar:CreateTexture(nil, "OVERLAY")
            marker:SetTexture([[Interface\Buttons\WHITE8X8]])
            marker:SetVertexColor(1, 1, 1, 0.8)
            marker:SetWidth(2)
            empowerMarkers[i] = marker
        end

        local xOffset = (barWidth / numStages) * i
        marker:ClearAllPoints()
        marker:SetPoint("TOP", progressBar, "TOPLEFT", xOffset, 0)
        marker:SetPoint("BOTTOM", progressBar, "BOTTOMLEFT", xOffset, 0)
        marker:Show()
    end

    for i = numStages, #empowerMarkers do
        if empowerMarkers[i] then
            empowerMarkers[i]:Hide()
        end
    end
end

local function PlayAudioAlert()
    local db = NaowhQOL.focusCastBar
    if not db then return end

    if db.soundEnabled and db.sound then
        ns.SoundList.Play(db.sound)
    elseif db.ttsEnabled and db.ttsMessage and db.ttsMessage ~= "" then
        local voiceID = db.ttsVoiceID or 0
        local rate = db.ttsRate or 0
        local volume = db.ttsVolume or 50
        C_VoiceChat.SpeakText(voiceID, db.ttsMessage, rate, volume, true)
    end
end

local currentNotInterruptible = nil
local hasSecretInterruptible = false

local function IsFocusFriendly()
    return UnitExists("focus") and UnitIsFriend("player", "focus")
end

local function StartCast(notInterruptible, texture, text, startTime, endTime)
    local db = NaowhQOL.focusCastBar
    if not db or not db.enabled then return end

    if db.hideFriendlyCasts and IsFocusFriendly() then return end

    isCasting = true
    isChanneling = false
    currentNotInterruptible = notInterruptible
    hasSecretInterruptible = true

    if db.showIcon then
        iconTexture:SetTexture(texture)
    end

    if db.showSpellName and text then
        spellNameText:SetText(text)
    end

    HideEmpowerStages()

    if not db.colorNonInterrupt then
        UpdateBarColor()
    end

    local duration = UnitCastingDuration("focus")
    if duration then
        progressBar:SetMinMaxValues(0, 1)
        progressBar:SetTimerDuration(duration, Enum.StatusBarInterpolation.Immediate, Enum.StatusBarTimerDirection.ElapsedTime)
        if db.showTimeRemaining then
            local remain = duration:GetRemainingDuration()
            castTimeText:SetFormattedText('%.1f', remain)
        end
    end

    castBarFrame:Show()
    UpdateInterruptibleDisplay()
    UpdateInterruptTick()

    PlayAudioAlert()
end

local function StartChannel(notInterruptible, numEmpowerStages, texture, text, startTime, endTime)
    local db = NaowhQOL.focusCastBar
    if not db or not db.enabled then return end

    if db.hideFriendlyCasts and IsFocusFriendly() then return end

    isCasting = false
    isChanneling = true
    currentNotInterruptible = notInterruptible
    hasSecretInterruptible = true

    if db.showIcon then
        iconTexture:SetTexture(texture)
    end

    if db.showSpellName and text then
        spellNameText:SetText(text)
    end

    HideEmpowerStages()
    if numEmpowerStages then
        pcall(function()
            if numEmpowerStages > 0 then
                UpdateEmpowerStages(numEmpowerStages)
            end
        end)
    end

    if not db.colorNonInterrupt then
        UpdateBarColor()
    end

    local duration = UnitChannelDuration("focus")
    if duration then
        progressBar:SetMinMaxValues(0, 1)
        progressBar:SetTimerDuration(duration, Enum.StatusBarInterpolation.Immediate, Enum.StatusBarTimerDirection.RemainingTime)
        if db.showTimeRemaining then
            local remain = duration:GetRemainingDuration()
            castTimeText:SetFormattedText('%.1f', remain)
        end
    end

    castBarFrame:Show()
    UpdateInterruptibleDisplay()
    UpdateInterruptTick()

    PlayAudioAlert()
end

local function StopCast()
    isCasting = false
    isChanneling = false
    currentNotInterruptible = nil
    hasSecretInterruptible = false
    HideEmpowerStages()
    shieldIcon:SetAlpha(0)
    nonIntOverlay:SetAlpha(0)
    interruptBar:Hide()
    local db = NaowhQOL.focusCastBar
    if not db or not db.unlock then
        castBarFrame:Hide()
    end
end

local function CheckFocusCast()
    if not UnitExists("focus") then
        StopCast()
        return
    end

    local castDuration = UnitCastingDuration("focus")
    if castDuration then
        local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("focus")
        StartCast(notInterruptible, texture, text, startTime, endTime)
        return
    end

    local channelDuration = UnitChannelDuration("focus")
    if channelDuration then
        local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages = UnitChannelInfo("focus")
        StartChannel(notInterruptible, numStages, texture, text, startTime, endTime)
        return
    end

    StopCast()
end

function castBarFrame:UpdateDisplay()
    local db = NaowhQOL.focusCastBar
    if not db then return end

    if not db.enabled then
        castBarFrame:SetBackdrop(nil)
        if resizeHandle then resizeHandle:Hide() end
        castBarFrame:Hide()
        return
    end

    castBarFrame:EnableMouse(db.unlock)
    if db.unlock then
        castBarFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        })
        castBarFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        if resizeHandle then resizeHandle:Show() end

        spellNameText:SetText(L["FOCUS_PREVIEW_CAST"])
        castTimeText:SetText(L["FOCUS_PREVIEW_TIME"])
        progressBar:SetValue(0.5)
        iconTexture:SetTexture(136243)
        castBarFrame:Show()
    else
        castBarFrame:SetBackdrop(nil)
        if resizeHandle then resizeHandle:Hide() end

        if not isCasting and not isChanneling then
            castBarFrame:Hide()
        end
    end

    local width = db.width or 250
    local height = db.height or 24
    castBarFrame:SetSize(width, height)

    castBarFrame:ClearAllPoints()
    local point = db.point or "CENTER"
    local anchorTo = db.anchorTo or point
    local x = db.x or 0
    local y = db.y or 100
    castBarFrame:SetPoint(point, UIParent, anchorTo, x, y)

    UpdateLayout()
    UpdateBarColor()
end

local THROTTLE = 0.033
local updateElapsed = 0

castBarFrame:SetScript("OnUpdate", ns.PerfMonitor:Wrap("Focus Cast Bar", function(self, dt)
    updateElapsed = updateElapsed + dt
    if updateElapsed < THROTTLE then return end

    local db = NaowhQOL.focusCastBar
    if not db or not db.enabled then return end

    UpdateBarColor()

    if db.showTimeRemaining then
        local duration
        if isCasting then
            duration = UnitCastingDuration("focus")
        elseif isChanneling then
            duration = UnitChannelDuration("focus")
        end
        if duration then
            local remain = duration:GetRemainingDuration()
            castTimeText:SetFormattedText('%.1f', remain)
        end
    end

    updateElapsed = 0
end))

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
loader:RegisterEvent("PLAYER_FOCUS_CHANGED")
loader:RegisterUnitEvent("UNIT_SPELLCAST_START", "focus")
loader:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "focus")
loader:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "focus")
loader:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "focus")
loader:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "focus")
loader:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "focus")
loader:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "focus")
loader:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "focus")
loader:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", "focus")
loader:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "focus")

loader:SetScript("OnEvent", function(self, event, unit, ...)
    local db = NaowhQOL.focusCastBar

    if event == "PLAYER_LOGIN" then
        if not db then return end

        db.width = db.width or 250
        db.height = db.height or 24
        db.point = db.point or "CENTER"
        db.x = db.x or 0
        db.y = db.y or 100

        W.MakeDraggable(castBarFrame, {
            db = db, userPlaced = false, anchorToKey = "anchorTo",
            onDragStop = function()
                if ns.SettingsIO then ns.SettingsIO:MarkDirty() end
            end,
        })
        resizeHandle = W.CreateResizeHandle(castBarFrame, {
            db = db,
            onResize = function()
                UpdateLayout()
                UpdateEmpowerStages(#empowerMarkers + 1)
                if ns.SettingsIO then ns.SettingsIO:MarkDirty() end
            end,
        })

        castBarFrame:UpdateDisplay()

        GetInterruptSpellId()

        ns.SettingsIO:RegisterRefresh("focusCastBar", function()
            castBarFrame:UpdateDisplay()
        end)
        return
    end

    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        cachedInterruptSpellId = nil
        GetInterruptSpellId()
        return
    end

    if not db or not db.enabled then return end

    if db.unlock then return end

    if event == "PLAYER_FOCUS_CHANGED" then
        CheckFocusCast()
        return
    end

    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
        local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("focus")
        StartCast(notInterruptible, texture, text, startTime, endTime)

    elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages = UnitChannelInfo("focus")
        StartChannel(notInterruptible, numStages, texture, text, startTime, endTime)

    elseif event == "UNIT_SPELLCAST_STOP"
        or event == "UNIT_SPELLCAST_CHANNEL_STOP"
        or event == "UNIT_SPELLCAST_FAILED"
        or event == "UNIT_SPELLCAST_INTERRUPTED" then
        StopCast()

    elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
        currentNotInterruptible = false
        hasSecretInterruptible = true
        if isCasting or isChanneling then
            UpdateInterruptibleDisplay()
        end

    elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
        currentNotInterruptible = true
        hasSecretInterruptible = true
        if isCasting or isChanneling then
            UpdateInterruptibleDisplay()
        end
    end
end)

ns.FocusCastBarDisplay = castBarFrame
