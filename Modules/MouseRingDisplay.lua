local addonName, ns = ...
local L = ns.L
local W = ns.Widgets

local function IsSecret(value)
    return issecretvalue and issecretvalue(value) or false
end

local ASSET_PATH = "Interface\\AddOns\\NaowhQOL\\Assets\\"
local RING_TEXEL = 0.5 / 256
local TRAIL_TEXEL = 0.5 / 128
local TRAIL_MAX = 60
local TRAIL_SHAPES = {
    glow     = "trail_glow.tga",
    circle   = "nq_circle.tga",
    ring     = "nq_ring_soft1.tga",
    star     = "nq_star.tga",
    sparkle  = "sparkle.tga",
}
local SPARKLE_COUNT = 40
local sparkleColors = {}
for i = 1, SPARKLE_COUNT do
    sparkleColors[i] = {
        r = math.random(30, 90) / 100,
        g = math.random(30, 90) / 100,
        b = math.random(30, 90) / 100,
    }
end
local GCD_SPELL = 61304
local SWIPE_DELAY_DEFAULT = 0.08
local floor, max = math.floor, math.max

local function GetDB()
    NaowhQOL = NaowhQOL or {}
    NaowhQOL.mouseRing = NaowhQOL.mouseRing or {}
    return NaowhQOL.mouseRing
end

local state = {
    inCombat = false,
    inInstance = false,
    isRightMouseDown = false,
    isAfk = false,
    isCasting = false,
    isChanneling = false,
    castStart = 0,
    castEnd = 0,
    channelStart = 0,
    channelEnd = 0,
    gcdReady = true,
    gcdInfo = nil,
    gcdSwipeAllowed = true,
    gcdDelayTimer = nil,
    castSwipeAllowed = false,
    castDelayTimer = nil,
    isOutOfMelee = false,
    meleeLastInRange = nil,
    lastMoveTime = 0,
    idleAlpha = 1,
}

local HPAL_ITEM_ID = 129055
local MELEE_TICK_RATE = 0.05
local meleeSpellId = nil
local meleeSupported = false
local meleeHpalEnabled = false

local function HasAttackableTarget()
    if not UnitExists("target") then return false end
    if not UnitCanAttack("player", "target") then return false end
    if UnitIsDeadOrGhost("target") then return false end
    return true
end

local container, ring, borderRing, readyRing, centerDot
local gcdSweep = {}
local trailContainer, trailPoints = nil, {}

local TWO_PI = math.pi * 2
local PI     = math.pi

local UpdateRender

local gcdSweepState = {
    active    = false,
    startTime = 0,
    duration  = 1,
    modRate   = 1,
    r = 1, g = 1, b = 1, a = 1,
}

local function UpdateGCDSweep()
    if not gcdSweep.frame then return end
    local s = gcdSweepState
    if not s.active then return end

    local elapsed = GetTime() - s.startTime
    local total   = s.duration / (s.modRate or 1)
    local frac    = math.min(elapsed / total, 1)

    if frac >= 1 then
        s.active = false
        gcdSweep.rightRing:Show()
        gcdSweep.rightRing:SetVertexColor(s.r, s.g, s.b, s.a)
        gcdSweep.rightProg:SetRotation(0)
        gcdSweep.leftRing:Show()
        gcdSweep.leftRing:SetVertexColor(s.r, s.g, s.b, s.a)
        gcdSweep.leftProg:SetRotation(-PI)
        return
    end

    local angle = frac * TWO_PI
    local r, g, b, a = s.r, s.g, s.b, s.a

    if angle > 0 then
        gcdSweep.rightRing:Show()
        gcdSweep.rightRing:SetVertexColor(r, g, b, a)
        gcdSweep.rightProg:SetRotation(PI - math.min(angle, PI))
    else
        gcdSweep.rightRing:Hide()
    end

    if angle > PI then
        gcdSweep.leftRing:Show()
        gcdSweep.leftRing:SetVertexColor(r, g, b, a)
        gcdSweep.leftProg:SetRotation(-(angle - PI))
    else
        gcdSweep.leftRing:Hide()
    end
end

local UpdateMouseWatcher

local function ShouldBeVisible()
    local db = GetDB()
    if not db.enabled then return false end
    if db.hideOnMouseClick and state.isRightMouseDown then return false end
    if state.inCombat then return true end
    if db.hideWhenUnfocused and state.isAfk then return false end
    return db.showOutOfCombat ~= false
end

local function GetOpacity()
    local db = GetDB()
    local base
    if state.inCombat or state.inInstance then
        base = db.opacityInCombat or 1.0
    else
        base = db.opacityOutOfCombat or 1.0
    end
    return base * state.idleAlpha
end

local function GetRingColor()
    local db = GetDB()
    return W.GetEffectiveColor(db, "colorR", "colorG", "colorB", "useClassColor")
end

local function SetupTexture(tex, shape)
    tex:SetTexture(ASSET_PATH .. shape, "CLAMP", "CLAMP", "TRILINEAR")
    tex:SetTexCoord(RING_TEXEL, 1 - RING_TEXEL, RING_TEXEL, 1 - RING_TEXEL)
    if tex.SetSnapToPixelGrid then
        tex:SetSnapToPixelGrid(false)
        tex:SetTexelSnappingBias(0)
    end
end

UpdateRender = function()
    if not container then return end
    local db = GetDB()
    local alpha = GetOpacity()

    UpdateMouseWatcher()

    if not ShouldBeVisible() then
        container:Hide()
        if trailContainer then trailContainer:Hide() end
        return
    end

    container:Show()

    if borderRing then
        local meleeOut = db.meleeRecolor and state.isOutOfMelee
        local showBorder = db.borderEnabled
        if meleeOut and db.meleeRecolorBorder ~= false then
            showBorder = true
        end

        if showBorder then
            local bw = db.borderWeight or 2
            local size = db.size or 48
            if size % 2 == 1 then size = size + 1 end
            borderRing:SetSize(size + bw * 2, size + bw * 2)
            borderRing:ClearAllPoints()
            borderRing:SetPoint("CENTER", container, "CENTER", 0, 0)

            local br, bg, bb = W.GetEffectiveColor(db, "borderR", "borderG", "borderB", "borderUseClassColor")
            if meleeOut and db.meleeRecolorBorder ~= false then
                br, bg, bb = 1, 0, 0
            end
            borderRing:SetVertexColor(br, bg, bb, 1)
            borderRing:SetAlpha(alpha)
            borderRing:Show()
        else
            borderRing:Hide()
        end
    end

    if ring then
        if db.gcdEnabled and db.hideBackground then
            ring:Hide()
        else
            local r, g, b = GetRingColor()
            if db.meleeRecolor and state.isOutOfMelee then
                r, g, b = 1, 0, 0
            end
            ring:SetVertexColor(r, g, b, 1)
            ring:SetAlpha(alpha)
            ring:Show()
        end
    end

    if gcdSweep.frame then
        local swipeAlpha = alpha * (db.gcdAlpha or 1)
        local wantSweep  = false

        if db.gcdEnabled and db.castSwipeEnabled and state.isCasting and state.castStart > 0 and state.castSwipeAllowed then
            local r, g, b = W.GetEffectiveColor(db, "castSwipeR", "castSwipeG", "castSwipeB", "castSwipeUseClassColor")
            gcdSweepState.startTime = state.castStart
            gcdSweepState.duration  = state.castEnd - state.castStart
            gcdSweepState.modRate   = 1
            gcdSweepState.r, gcdSweepState.g, gcdSweepState.b, gcdSweepState.a = r, g, b, swipeAlpha
            gcdSweepState.active = true
            wantSweep = true
        elseif db.gcdEnabled and db.castSwipeEnabled and state.isChanneling and state.channelStart > 0 and state.castSwipeAllowed then
            local r, g, b = W.GetEffectiveColor(db, "castSwipeR", "castSwipeG", "castSwipeB", "castSwipeUseClassColor")
            gcdSweepState.startTime = state.channelStart
            gcdSweepState.duration  = state.channelEnd - state.channelStart
            gcdSweepState.modRate   = 1
            gcdSweepState.r, gcdSweepState.g, gcdSweepState.b, gcdSweepState.a = r, g, b, swipeAlpha
            gcdSweepState.active = true
            wantSweep = true
        elseif db.gcdEnabled and not state.gcdReady and state.gcdInfo and state.gcdSwipeAllowed then
            local r, g, b = W.GetEffectiveColor(db, "gcdR", "gcdG", "gcdB", "gcdUseClassColor")
            gcdSweepState.startTime = state.gcdInfo.startTime
            gcdSweepState.duration  = state.gcdInfo.duration
            gcdSweepState.modRate   = state.gcdInfo.modRate or 1
            gcdSweepState.r, gcdSweepState.g, gcdSweepState.b, gcdSweepState.a = r, g, b, swipeAlpha
            gcdSweepState.active = true
            wantSweep = true
        end

        if wantSweep then
            gcdSweep.frame:Show()
            UpdateGCDSweep()
        else
            gcdSweepState.active = false
            gcdSweep.frame:Hide()
        end
    end

    if readyRing then
        local showReady = db.gcdEnabled and state.gcdReady
                          and not state.isCasting and not state.isChanneling

        if showReady then
            local readyR, readyG, readyB
            if db.gcdReadyMatchSwipe then
                readyR, readyG, readyB = W.GetEffectiveColor(db, "gcdR", "gcdG", "gcdB", "gcdUseClassColor")
            elseif db.gcdReadyUseClassColor then
                readyR, readyG, readyB = W.GetEffectiveColor(db, "gcdReadyR", "gcdReadyG", "gcdReadyB", "gcdReadyUseClassColor")
            else
                readyR, readyG, readyB = db.gcdReadyR or 0, db.gcdReadyG or 0.8, db.gcdReadyB or 0.3
            end
            if db.meleeRecolor and state.isOutOfMelee and db.meleeRecolorRing then
                readyR, readyG, readyB = 1, 0, 0
            end
            readyRing:SetVertexColor(readyR, readyG, readyB, 1)
            readyRing:SetAlpha(alpha)
            readyRing:Show()
        else
            readyRing:Hide()
        end
    end

    if trailContainer then
        if db.trailEnabled then
            trailContainer:Show()
        else
            trailContainer:Hide()
        end
    end

    if centerDot then
        if db.dotEnabled then
            local ds = db.dotSize or 6
            centerDot:SetSize(ds, ds)
            local dr, dg, db2 = W.GetEffectiveColor(db, "dotR", "dotG", "dotB", "dotUseClassColor")
            centerDot:SetVertexColor(dr, dg, db2, 1)
            centerDot:SetAlpha(alpha)
            centerDot:Show()
        else
            centerDot:Hide()
        end
    end
end

local meleeSoundTicker = nil
local lastMeleeSoundTime = 0
local MELEE_SOUND_COOLDOWN = 0.9

local function StopMeleeSound()
    if meleeSoundTicker then
        meleeSoundTicker:Cancel()
        meleeSoundTicker = nil
    end
end

local function PlayMeleeSoundOnce(soundID)
    local now = GetTime()
    if now - lastMeleeSoundTime < MELEE_SOUND_COOLDOWN then return end
    lastMeleeSoundTime = now
    ns.SoundList.Play(soundID or ns.Media.DEFAULT_SOUND)
end

local function StartMeleeSound(db)
    StopMeleeSound()
    local interval = db.meleeSoundInterval or 3
    local soundID = db.meleeSoundID or ns.Media.DEFAULT_SOUND
    PlayMeleeSoundOnce(soundID)
    if interval > 0 then
        meleeSoundTicker = C_Timer.NewTicker(interval, function()
            PlayMeleeSoundOnce(soundID)
        end)
    end
end

local meleeTick = CreateFrame("Frame")
local meleeTickAcc = 0

local function ShouldMeleeTickRun()
    local db = GetDB()
    if not db.enabled then return false end
    if not db.meleeRecolor then return false end
    if not meleeSupported then return false end
    if not HasAttackableTarget() then return false end
    return true
end

local function TickMeleeRange()
    local db = GetDB()
    if not db.meleeRecolor or not meleeSupported then
        if state.isOutOfMelee then
            state.isOutOfMelee = false
            UpdateRender()
        end
        StopMeleeSound()
        state.meleeLastInRange = nil
        return
    end

    local wasOut = state.isOutOfMelee

    if not HasAttackableTarget() then
        state.isOutOfMelee = false
        StopMeleeSound()
        state.meleeLastInRange = nil
    else
        local inMelee
        if meleeHpalEnabled then
            inMelee = C_Item.IsItemInRange(HPAL_ITEM_ID, "target")
        elseif meleeSpellId then
            inMelee = C_Spell.IsSpellInRange(meleeSpellId, "target")
        end
        if inMelee == nil then return end
        state.isOutOfMelee = not inMelee

        if state.isOutOfMelee then
            if db.meleeSoundEnabled and state.meleeLastInRange == true then
                StartMeleeSound(db)
            end
        else
            StopMeleeSound()
        end
        state.meleeLastInRange = inMelee
    end

    if state.isOutOfMelee ~= wasOut then
        UpdateRender()
    end
end

local meleeTickOnUpdate = ns.PerfMonitor:Wrap("MouseRing Range", function(self, elapsed)
    meleeTickAcc = meleeTickAcc + elapsed
    if meleeTickAcc < MELEE_TICK_RATE then return end
    meleeTickAcc = 0
    TickMeleeRange()
end)

local function StartMeleeTick()
    if not meleeTick:GetScript("OnUpdate") then
        meleeTick:SetScript("OnUpdate", meleeTickOnUpdate)
    end
end

local function StopMeleeTick()
    meleeTick:SetScript("OnUpdate", nil)
    meleeTickAcc = 0
    if state.isOutOfMelee then
        state.isOutOfMelee = false
        UpdateRender()
    end
    StopMeleeSound()
    state.meleeLastInRange = nil
end

local function EvaluateMeleeTick()
    if ShouldMeleeTickRun() then
        StartMeleeTick()
    else
        StopMeleeTick()
    end
end

local function CacheMeleeSpell()
    if meleeHpalEnabled then return end
    local info = ns.MeleeRangeInfo
    if not info then return end
    meleeSpellId = info.GetCurrentSpell()
    meleeSupported = (meleeSpellId ~= nil)
end

local function EvaluateHpalMode()
    local db = GetDB()
    local classFile = ns.SpecUtil.GetClassName()
    local specIndex = ns.SpecUtil.GetSpecIndex()

    local shouldEnable = classFile == "PALADIN"
        and specIndex == 1
        and db.enabled and db.meleeRecolor

    if shouldEnable then
        meleeHpalEnabled = true
        meleeSupported = true
    else
        meleeHpalEnabled = false
    end
end

local function CreateRing()
    if container then return end
    local db = GetDB()
    local size = db.size or 48
    if size % 2 == 1 then size = size + 1 end

    container = CreateFrame("Frame", nil, UIParent)
    container:SetSize(size, size)
    container:SetFrameStrata("TOOLTIP")
    container:EnableMouse(false)

    local shape = db.shape or "ring.tga"
    borderRing = container:CreateTexture(nil, "BACKGROUND")
    SetupTexture(borderRing, shape)
    borderRing:Hide()

    ring = container:CreateTexture(nil, "BORDER")
    ring:SetAllPoints()
    SetupTexture(ring, shape)
    local r, g, b = GetRingColor()
    ring:SetVertexColor(r, g, b, 1)

    readyRing = container:CreateTexture(nil, "ARTWORK")
    readyRing:SetAllPoints()
    SetupTexture(readyRing, shape)
    readyRing:Hide()

    local maskPath = ASSET_PATH .. "half_disk.tga"
    local clipPath = ASSET_PATH .. "half_disk_clip.tga"

    local sweepFrame = CreateFrame("Frame", nil, container)
    sweepFrame:SetAllPoints()
    sweepFrame:SetFrameLevel(container:GetFrameLevel() + 5)
    sweepFrame:Hide()
    gcdSweep.frame = sweepFrame

    local rightRing = sweepFrame:CreateTexture(nil, "ARTWORK")
    SetupTexture(rightRing, shape)
    rightRing:SetAllPoints()
    rightRing:Hide()
    local rightClip = sweepFrame:CreateMaskTexture()
    rightClip:SetTexture(clipPath, "CLAMP", "CLAMP", "TRILINEAR")
    rightClip:SetAllPoints()
    rightClip:SetRotation(0)
    rightRing:AddMaskTexture(rightClip)
    local rightProg = sweepFrame:CreateMaskTexture()
    rightProg:SetTexture(maskPath, "CLAMP", "CLAMP", "TRILINEAR")
    rightProg:SetAllPoints()
    rightProg:SetRotation(PI)
    rightRing:AddMaskTexture(rightProg)
    gcdSweep.rightRing = rightRing
    gcdSweep.rightProg = rightProg

    local leftRing = sweepFrame:CreateTexture(nil, "ARTWORK")
    SetupTexture(leftRing, shape)
    leftRing:SetAllPoints()
    leftRing:Hide()
    local leftClip = sweepFrame:CreateMaskTexture()
    leftClip:SetTexture(clipPath, "CLAMP", "CLAMP", "TRILINEAR")
    leftClip:SetAllPoints()
    leftClip:SetRotation(PI)
    leftRing:AddMaskTexture(leftClip)
    local leftProg = sweepFrame:CreateMaskTexture()
    leftProg:SetTexture(maskPath, "CLAMP", "CLAMP", "TRILINEAR")
    leftProg:SetAllPoints()
    leftProg:SetRotation(0)
    leftRing:AddMaskTexture(leftProg)
    gcdSweep.leftRing = leftRing
    gcdSweep.leftProg = leftProg

    sweepFrame:SetScript("OnUpdate", function()
        if gcdSweepState.active then UpdateGCDSweep() end
    end)

    centerDot = container:CreateTexture(nil, "OVERLAY")
    centerDot:SetTexture([[Interface\Buttons\WHITE8x8]])
    centerDot:SetPoint("CENTER", container, "CENTER", 0, 0)
    centerDot:Hide()

    local lastX, lastY = 0, 0
    container:SetScript("OnUpdate", function(self, elapsed)
        if not ShouldBeVisible() then return end

        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        x, y = floor(x / scale + 0.5), floor(y / scale + 0.5)

        if x ~= lastX or y ~= lastY then
            lastX, lastY = x, y
            state.lastMoveTime = GetTime()
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
        end

        local db = GetDB()
        if db.fadeOnIdle then
            local idleDelay = (db.fadeIdleDelay or 2000) / 1000
            local elapsed2 = GetTime() - state.lastMoveTime
            if elapsed2 > idleDelay then
                local targetAlpha = db.fadeIdleOpacity or 0
                local fadeDur = 0.5
                local fadeElapsed = elapsed2 - idleDelay
                state.idleAlpha = max(targetAlpha, 1 - (fadeElapsed / fadeDur) * (1 - targetAlpha))
            else
                state.idleAlpha = 1
            end
            local currentAlpha = GetOpacity()
            self:SetAlpha(currentAlpha)
            if trailContainer then trailContainer:SetAlpha(currentAlpha) end
        else
            state.idleAlpha = 1
        end
    end)

    UpdateRender()
end

local function GetTrailTexture()
    local db = GetDB()
    local key = db.trailShape or "glow"
    return ASSET_PATH .. (TRAIL_SHAPES[key] or TRAIL_SHAPES.glow)
end

local function CreateTrail()
    if trailContainer then return end

    trailContainer = CreateFrame("Frame", nil, UIParent)
    trailContainer:SetFrameStrata("TOOLTIP")
    trailContainer:SetFrameLevel(1)
    trailContainer:SetPoint("BOTTOMLEFT")
    trailContainer:SetSize(1, 1)
    trailContainer:Hide()

    local texPath = GetTrailTexture()
    for i = 1, TRAIL_MAX do
        local tex = trailContainer:CreateTexture(nil, "BACKGROUND")
        tex:SetTexture(texPath, "CLAMP", "CLAMP", "TRILINEAR")
        tex:SetTexCoord(TRAIL_TEXEL, 1 - TRAIL_TEXEL, TRAIL_TEXEL, 1 - TRAIL_TEXEL)
        tex:SetBlendMode("ADD")
        tex:SetSize(24, 24)
        tex:Hide()
        trailPoints[i] = { tex = tex, x = 0, y = 0, time = 0, active = false }
    end

    local head, lastX, lastY = 0, 0, 0
    local updateTimer = 0
    local activeCount = 0
    local trailUpdateFunc

    trailUpdateFunc = function(self, elapsed)
        local db = GetDB()
        local shouldTrack = db.trailEnabled and ShouldBeVisible()

        updateTimer = updateTimer + elapsed
        if updateTimer < 0.025 then return end
        updateTimer = 0

        local now = GetTime()

        if shouldTrack then
            local x, y = GetCursorPosition()
            local scale = UIParent:GetEffectiveScale()
            x, y = floor(x / scale + 0.5), floor(y / scale + 0.5)

            local dx, dy = x - lastX, y - lastY
            local spacing = max(2, (db.trailSize or 24) * 0.1)

            if dx * dx + dy * dy >= spacing * spacing then
                lastX, lastY = x, y
                local trailLen = db.trailLength or 20
                head = (head % trailLen) + 1
                local pt = trailPoints[head]
                if not pt.active then
                    activeCount = activeCount + 1
                end
                pt.x, pt.y, pt.time, pt.active = x, y, now, true
            end
        end

        if activeCount > 0 then
            local duration = max(db.trailDuration or 0.6, 0.1)
            local tr, tg, tb = W.GetEffectiveColor(db, "trailR", "trailG", "trailB", "trailUseClassColor")
            local opacity = GetOpacity()
            local baseSize = db.trailSize or 24
            local useSparkle = db.trailSparkle
            local brightness = db.trailBrightness or 0.8

            for i = 1, TRAIL_MAX do
                local pt = trailPoints[i]
                if pt.active then
                    local fade = 1 - (now - pt.time) / duration
                    if fade <= 0 then
                        pt.active = false
                        pt.tex:Hide()
                        activeCount = activeCount - 1
                    else
                        pt.tex:ClearAllPoints()
                        pt.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pt.x, pt.y)
                        local cr, cg, cb = tr, tg, tb
                        if useSparkle then
                            local sc = sparkleColors[((i - 1) % SPARKLE_COUNT) + 1]
                            cr, cg, cb = sc.r, sc.g, sc.b
                        end
                        pt.tex:SetVertexColor(cr, cg, cb, fade * opacity * brightness)
                        pt.tex:SetSize(baseSize * fade, baseSize * fade)
                        pt.tex:Show()
                    end
                end
            end
        end

        if not shouldTrack and activeCount == 0 then
            self:SetScript("OnUpdate", nil)
        end
    end

    trailContainer:SetScript("OnShow", function(self)
        self:SetScript("OnUpdate", trailUpdateFunc)
    end)
    trailContainer:SetScript("OnHide", function(self)
        if activeCount == 0 then
            self:SetScript("OnUpdate", nil)
        end
    end)
end

local function RefreshCombatState()
    state.inCombat = InCombatLockdown() or UnitAffectingCombat("player")
    local inInst, instType = IsInInstance()
    state.inInstance = inInst and (instType == "party" or instType == "raid" or instType == "pvp" or instType == "arena")
end

local mouseWatcher = CreateFrame("Frame")
local mouseWatcherActive = false

local function MouseWatcherOnUpdate()
    local wasDown = state.isRightMouseDown
    state.isRightMouseDown = IsMouseButtonDown("RightButton")

    if wasDown ~= state.isRightMouseDown then
        UpdateRender()
    end
end

UpdateMouseWatcher = function()
    local db = GetDB()
    local shouldRun = db.enabled and db.hideOnMouseClick

    if shouldRun and not mouseWatcherActive then
        mouseWatcher:SetScript("OnUpdate", MouseWatcherOnUpdate)
        mouseWatcherActive = true
    elseif not shouldRun and mouseWatcherActive then
        mouseWatcher:SetScript("OnUpdate", nil)
        state.isRightMouseDown = false
        mouseWatcherActive = false
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("SPELL_UPDATE_COOLDOWN")
events:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
events:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
events:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
events:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
events:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
events:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
events:RegisterEvent("PLAYER_TARGET_CHANGED")
events:RegisterEvent("PLAYER_LEAVING_WORLD")
events:RegisterUnitEvent("PLAYER_FLAGS_CHANGED", "player")

events:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        RefreshCombatState()
        if not state.inInstance then
            state.isAfk = UnitIsAFK("player") and true or false
        else
            state.isAfk = false
        end
        state.isCasting = UnitCastingInfo("player") ~= nil
        state.isChanneling = UnitChannelInfo("player") ~= nil
        state.castStart = 0
        state.castEnd = 0
        state.channelStart = 0
        state.channelEnd = 0
        state.lastMoveTime = GetTime()
        state.idleAlpha = 1
        CreateRing()
        CreateTrail()
        EvaluateHpalMode()
        CacheMeleeSpell()
        UpdateRender()
        EvaluateMeleeTick()

        ns.SettingsIO:RegisterRefresh("mouseRing", function()
            CreateRing()
            CreateTrail()
            EvaluateHpalMode()
            CacheMeleeSpell()
            UpdateRender()
            EvaluateMeleeTick()
        end)

    elseif event == "PLAYER_FLAGS_CHANGED" then
        if not state.inCombat and not state.inInstance then
            local wasAfk = state.isAfk
            if UnitIsAFK("player") then
                state.isAfk = true
            else
                state.isAfk = false
            end
            if wasAfk ~= state.isAfk then UpdateRender() end
        end

    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        RefreshCombatState()
        UpdateRender()

    elseif event == "PLAYER_TARGET_CHANGED" then
        state.isOutOfMelee = false
        state.meleeLastInRange = nil
        StopMeleeSound()
        UpdateRender()
        EvaluateMeleeTick()

    elseif event == "PLAYER_LEAVING_WORLD" then
        StopMeleeTick()

    elseif event == "UNIT_SPELLCAST_START" then
        local _, _, _, startTime, endTime = UnitCastingInfo("player")
        if startTime and endTime and not IsSecret(startTime) and not IsSecret(endTime) then
            state.isCasting = true
            state.castStart = startTime / 1000
            state.castEnd = endTime / 1000
            state.castSwipeAllowed = false
            if state.castDelayTimer then
                state.castDelayTimer:Cancel()
            end
            local swipeDelay = GetDB().swipeDelay or SWIPE_DELAY_DEFAULT
            state.castDelayTimer = C_Timer.NewTimer(swipeDelay, function()
                state.castSwipeAllowed = true
                state.castDelayTimer = nil
                UpdateRender()
            end)
        end
        UpdateRender()

    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        local _, _, _, startTime, endTime = UnitChannelInfo("player")
        if startTime and endTime and not IsSecret(startTime) and not IsSecret(endTime) then
            state.isChanneling = true
            state.channelStart = startTime / 1000
            state.channelEnd = endTime / 1000
            state.castSwipeAllowed = false
            if state.castDelayTimer then
                state.castDelayTimer:Cancel()
            end
            local swipeDelay = GetDB().swipeDelay or SWIPE_DELAY_DEFAULT
            state.castDelayTimer = C_Timer.NewTimer(swipeDelay, function()
                state.castSwipeAllowed = true
                state.castDelayTimer = nil
                UpdateRender()
            end)
        end
        UpdateRender()

    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
        if state.isCasting then
            state.isCasting = false
            state.castStart = 0
            state.castEnd = 0
            if state.castDelayTimer then
                state.castDelayTimer:Cancel()
                state.castDelayTimer = nil
            end
            state.castSwipeAllowed = false
        end
        local _, _, _, startTime, endTime = UnitChannelInfo("player")
        if startTime and endTime and not IsSecret(startTime) and not IsSecret(endTime) then
            state.isChanneling = true
            state.channelStart = startTime / 1000
            state.channelEnd = endTime / 1000
        end
        UpdateRender()

    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        state.isChanneling = false
        state.channelStart = 0
        state.channelEnd = 0
        if state.castDelayTimer then
            state.castDelayTimer:Cancel()
            state.castDelayTimer = nil
        end
        state.castSwipeAllowed = false
        UpdateRender()

    elseif event == "SPELL_UPDATE_COOLDOWN" then
        local db = GetDB()
        if not db.gcdEnabled then return end

        local info = C_Spell.GetSpellCooldown(GCD_SPELL)
        local dur = info and info.duration
        if info and dur and not IsSecret(dur) and dur > 0
           and not IsSecret(info.startTime) and not IsSecret(info.modRate or 1) then
            local wasReady = state.gcdReady
            state.gcdInfo = info
            state.gcdReady = false

            if wasReady then
                state.gcdSwipeAllowed = false
                if state.gcdDelayTimer then
                    state.gcdDelayTimer:Cancel()
                end
                local swipeDelay = db.swipeDelay or SWIPE_DELAY_DEFAULT
                state.gcdDelayTimer = C_Timer.NewTimer(swipeDelay, function()
                    state.gcdSwipeAllowed = true
                    state.gcdDelayTimer = nil
                    UpdateRender()
                end)
            end
        else
            state.gcdReady = true
            state.gcdInfo = nil
            state.gcdSwipeAllowed = true
            if state.gcdDelayTimer then
                state.gcdDelayTimer:Cancel()
                state.gcdDelayTimer = nil
            end
        end
        UpdateRender()
    end
end)

ns.SpecUtil.RegisterCallback("MouseRingDisplay", function()
    EvaluateHpalMode()
    CacheMeleeSpell()
    EvaluateMeleeTick()
end)

local MouseRingDisplay = {}

function MouseRingDisplay:UpdateDisplay()
    CreateRing()
    CreateTrail()

    local db = GetDB()
    local shape = db.shape or "ring.tga"
    local size = db.size or 48
    if size % 2 == 1 then size = size + 1 end

    if container then container:SetSize(size, size) end
    if borderRing then SetupTexture(borderRing, shape) end
    if ring then
        SetupTexture(ring, shape)
        local r, g, b = GetRingColor()
        ring:SetVertexColor(r, g, b, 1)
    end
    if readyRing then SetupTexture(readyRing, shape) end
    if gcdCooldown then gcdCooldown:SetSwipeTexture(ASSET_PATH .. shape) end

    self:RefreshTrailTextures()

    EvaluateHpalMode()
    CacheMeleeSpell()
    UpdateRender()
    EvaluateMeleeTick()
end

function MouseRingDisplay:UpdateSize(size)
    GetDB().size = size
    if size % 2 == 1 then size = size + 1 end
    if container then container:SetSize(size, size) end
    UpdateRender()
end

function MouseRingDisplay:UpdateColor(r, g, b)
    local db = GetDB()
    db.colorR, db.colorG, db.colorB = r, g, b
    if ring then ring:SetVertexColor(r, g, b, 1) end
end

function MouseRingDisplay:UpdateShape(shape)
    GetDB().shape = shape
    if borderRing then SetupTexture(borderRing, shape) end
    if ring then SetupTexture(ring, shape) end
    if readyRing then SetupTexture(readyRing, shape) end
    if gcdCooldown then gcdCooldown:SetSwipeTexture(ASSET_PATH .. shape) end
end

function MouseRingDisplay:RefreshTrailTextures()
    if not trailContainer then return end
    local texPath = GetTrailTexture()
    for i = 1, TRAIL_MAX do
        local pt = trailPoints[i]
        if pt and pt.tex then
            pt.tex:SetTexture(texPath, "CLAMP", "CLAMP", "TRILINEAR")
            pt.tex:SetTexCoord(TRAIL_TEXEL, 1 - TRAIL_TEXEL, TRAIL_TEXEL, 1 - TRAIL_TEXEL)
        end
    end
end

function MouseRingDisplay:RefreshGCD()
    UpdateRender()
end

function MouseRingDisplay:RefreshVisibility()
    RefreshCombatState()
    UpdateRender()
end

MouseRingDisplay.StopMeleeSound = StopMeleeSound
ns.MouseRingDisplay = MouseRingDisplay
