local addonName, ns = ...
local L = ns.L
local W = ns.Widgets

local DEBUG_MODE = false
local inCombat = false

local UNLOCK_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local MOVEMENT_ABILITIES = {
    DEATHKNIGHT = {[250] = {48265}, [251] = {48265}, [252] = {48265, 444010, 444347}},
    DEMONHUNTER = {
        [577] = {195072}, [581] = {189110}, [1480] = {1234796},
        filter = {
            [427640] = {198793, 370965, 195072},
            [427794] = {195072},
        },
    },
    DRUID = {[102] = {102401, 252216, 1850,102417}, [103] = {102401, 252216, 1850,102417}, [104] = {102401,252216, 106898,1850,102417}, [105] = {102401, 252216, 1850,102417}},
    EVOKER = {[1467] = {358267}, [1468] = {358267}, [1473] = {358267}},
    HUNTER = {[253] = {186257, 781}, [254] = {186257, 781}, [255] = {186257, 781}},
    MAGE = {[62] = {212653, 1953}, [63] = {212653, 1953}, [64] = {212653, 1953}},
    MONK = {[268] = {115008, 109132, 119085, 361138}, [269] = {109132, 119085, 361138}, [270] = {109132, 119085, 361138}},
    PALADIN = {[65] = {190784}, [66] = {190784}, [70] = {190784}},
    PRIEST = {[256] = {121536, 73325}, [257] = {121536, 73325}, [258] = {121536, 73325}},
    ROGUE = {[259] = {36554, 2983}, [260] = {195457, 2983}, [261] = {36554, 2983}},
    SHAMAN = {[262] = {79206, 90328, 192063, 58875}, [263] = {90328, 192063, 58875}, [264] = {79206, 90328, 192063, 58875}},
    WARLOCK = {
        [265] = {48020}, [266] = {48020}, [267] = {48020},
        filter = {[385899] = {385899}},
    },
    WARRIOR = {[71] = {6544}, [72] = {6544}, [73] = {6544}},
}

local allMobilitySpells = {}

local function RebuildMobilitySpellLookup()
    wipe(allMobilitySpells)
    for _, classData in pairs(MOVEMENT_ABILITIES) do
        for key, value in pairs(classData) do
            if type(key) == "number" and type(value) == "table" then
                for _, spellId in ipairs(value) do
                    allMobilitySpells[spellId] = true
                end
            end
        end
    end
    local db = NaowhQOL and NaowhQOL.movementAlert
    if db and db.spellOverrides then
        for spellId, override in pairs(db.spellOverrides) do
            if override.enabled ~= false then
                allMobilitySpells[spellId] = true
            end
        end
    end
end

RebuildMobilitySpellLookup()

local glowCooldown = 0
local procDebounce = 0
local castFilters = {}

local function RefreshCastFilters()
    wipe(castFilters)
    local classData = MOVEMENT_ABILITIES[select(2, UnitClass("player"))]
    if not classData or not classData.filter then return end
    for talentId, spells in pairs(classData.filter) do
        if C_SpellBook.IsSpellKnown(talentId) then
            for _, id in ipairs(spells) do
                castFilters[id] = true
            end
        end
    end
end

local function OnSpellCast(spellId)
    if castFilters[spellId] then
        glowCooldown = GetTime() + 1.5
    end
end

local function IsValidTimeSpiralProc(spellId)
    local now = GetTime()
    if not allMobilitySpells[spellId] then return false end
    if now < glowCooldown then return false end
    if (now - procDebounce) < 0.12 then return false end
    return true
end

local function RecordProc()
    procDebounce = GetTime()
end

local movementFrame = CreateFrame("Frame", "NaowhQOL_MovementAlert", UIParent, "BackdropTemplate")
movementFrame:SetSize(200, 40)
movementFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
movementFrame:Hide()

local movementText = movementFrame:CreateFontString(nil, "OVERLAY")
movementText:SetFont(ns.DefaultFontPath(), 24, "OUTLINE")
movementText:SetPoint("CENTER")

local displayPool = {}
local activeSlotCount = 0

local function CreateDisplaySlot()
    local slot = CreateFrame("Frame", nil, movementFrame)
    slot:SetSize(200, 40)

    slot.text = slot:CreateFontString(nil, "OVERLAY")
    slot.text:SetFont(ns.DefaultFontPath(), 24, "OUTLINE")
    slot.text:SetPoint("CENTER")

    slot.icon = CreateFrame("Frame", nil, slot)
    slot.icon:SetSize(40, 40)
    slot.icon:SetPoint("CENTER")
    slot.icon.border = slot.icon:CreateTexture(nil, "BACKGROUND")
    slot.icon.border:SetAllPoints()
    slot.icon.border:SetColorTexture(0, 0, 0, 1)
    slot.icon.tex = slot.icon:CreateTexture(nil, "ARTWORK")
    slot.icon.tex:SetPoint("TOPLEFT", 2, -2)
    slot.icon.tex:SetPoint("BOTTOMRIGHT", -2, 2)
    slot.icon.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    slot.icon.cooldown = CreateFrame("Cooldown", nil, slot.icon, "CooldownFrameTemplate")
    slot.icon.cooldown:SetAllPoints(slot.icon.tex)
    slot.icon.cooldown:SetDrawEdge(false)
    slot.icon:Hide()

    slot.bar = CreateFrame("StatusBar", nil, slot)
    slot.bar:SetSize(150, 20)
    slot.bar:SetPoint("CENTER")
    slot.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    slot.bar:SetMinMaxValues(0, 1)
    slot.bar:SetValue(0)
    slot.bar.bg = slot.bar:CreateTexture(nil, "BACKGROUND")
    slot.bar.bg:SetAllPoints()
    slot.bar.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    slot.bar.text = slot.bar:CreateFontString(nil, "OVERLAY")
    slot.bar.text:SetFont(ns.DefaultFontPath(), 12, "OUTLINE")
    slot.bar.text:SetPoint("CENTER")
    slot.bar.icon = slot.bar:CreateTexture(nil, "OVERLAY")
    slot.bar.icon:SetSize(20, 20)
    slot.bar.icon:SetPoint("RIGHT", slot.bar, "LEFT", -4, 0)
    slot.bar.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    slot.bar:Hide()

    return slot
end

local function GetDisplaySlot(index)
    if not displayPool[index] then
        displayPool[index] = CreateDisplaySlot()
    end
    return displayPool[index]
end

local function LayoutDisplaySlots(count)
    local frameW = movementFrame:GetWidth()
    local frameH = movementFrame:GetHeight()
    local spacing = 2
    for i = 1, count do
        local slot = displayPool[i]
        if slot then
            slot:ClearAllPoints()
            slot:SetSize(frameW, frameH)
            if i == 1 then
                slot:SetPoint("BOTTOM", movementFrame, "BOTTOM", 0, 0)
            else
                slot:SetPoint("BOTTOM", displayPool[i - 1], "TOP", 0, spacing)
            end
        end
    end
end

local movementResizeHandle
local cachedMovementSpells = {}
local cachedChargeCount = {}
local rechargeTimers = {}
local spellWasCast = {}
local spellCastTime = {}
local trackedSpellSet = {}
local cacheResetTime = 0
local movementCountdownTimer = nil
local timeSpiralCountdownTimer = nil
local CheckMovementCooldown
local UpdateEventRegistration

local timeSpiralFrame = CreateFrame("Frame", "NaowhQOL_TimeSpiral", UIParent, "BackdropTemplate")
timeSpiralFrame:SetSize(200, 40)
timeSpiralFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
timeSpiralFrame:Hide()

local timeSpiralText = timeSpiralFrame:CreateFontString(nil, "OVERLAY")
timeSpiralText:SetFont(ns.DefaultFontPath(), 24, "OUTLINE")
timeSpiralText:SetPoint("CENTER")

local timeSpiralResizeHandle
local timeSpiralActiveTime = nil

local GATEWAY_SHARD_ITEM_ID = 188152

local gatewayFrame = CreateFrame("Frame", "NaowhQOL_GatewayShard", UIParent, "BackdropTemplate")
gatewayFrame:SetSize(200, 40)
gatewayFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
gatewayFrame:Hide()

local gatewayText = gatewayFrame:CreateFontString(nil, "OVERLAY")
gatewayText:SetFont(ns.DefaultFontPath(), 24, "OUTLINE")
gatewayText:SetPoint("CENTER")

local gatewayResizeHandle
local lastGatewayUsable = false
local gatewayPollTicker = nil

local function SafeGetChargeInfo(spellId)
    local ok, isCharge, maxCh, rechDur = pcall(function()
        local chargeInfo = C_Spell.GetSpellCharges(spellId)
        if not chargeInfo then return false, 1, 0 end
        local m = tonumber(chargeInfo.maxCharges) or 1
        local r = tonumber(chargeInfo.cooldownDuration) or 0
        return m > 1, m, r
    end)
    if not ok then return false, 1, 0 end
    return isCharge, maxCh, rechDur
end

local function SafeGetBaseDuration(spellId)
    if C_Spell.GetSpellCooldownDuration then
        local ok, dur = pcall(C_Spell.GetSpellCooldownDuration, spellId)
        if ok and dur then
            local ok2, total = pcall(dur.GetTotalDuration, dur)
            total = tonumber(tostring(total or 0)) or 0
            if ok2 and total > 1.5 then
                return total
            end
        end
    end
    if C_Spell.GetSpellBaseCooldown then
        local ok, ms = pcall(C_Spell.GetSpellBaseCooldown, spellId)
        if ok and ms and ms > 1500 then
            return ms / 1000
        end
    end
    local ok, dur = pcall(function()
        local cdInfo = C_Spell.GetSpellCooldown(spellId)
        if cdInfo and cdInfo.duration then
            return tonumber(cdInfo.duration) or 0
        end
        return 0
    end)
    return (ok and dur and dur > 1.5) and dur or 0
end

local function GetPlayerMovementSpells()
    local class = select(2, UnitClass("player"))
    local spec = GetSpecialization()
    if not spec then return {} end
    local specId = select(1, GetSpecializationInfo(spec))

    local db = NaowhQOL and NaowhQOL.movementAlert
    local overrides = db and db.spellOverrides or {}

    local classAbilities = MOVEMENT_ABILITIES[class]
    if not classAbilities then return {} end

    local specAbilities = classAbilities[specId]
    if not specAbilities then return {} end

    local result = {}
    local seen = {}

    for _, spellId in ipairs(specAbilities) do
        if not seen[spellId] then
            local override = overrides[spellId]
            if not override or override.enabled ~= false then
                if ns.IsPlayerSpell(spellId) then
                    local displayId = spellId
                    if C_Spell.GetOverrideSpell then
                        local oid = C_Spell.GetOverrideSpell(spellId)
                        if oid and oid ~= spellId then displayId = oid end
                    end
                    if seen[displayId] then
                    else
                        seen[spellId] = true
                        seen[displayId] = true
                        local spellInfo = C_Spell.GetSpellInfo(displayId)
                        local isCharge, maxCh, rechDur = SafeGetChargeInfo(displayId)
                        if spellInfo then
                            table.insert(result, {
                                spellId = displayId,
                                spellName = spellInfo.name,
                                spellIcon = spellInfo.iconID,
                                customText = override and override.customText ~= "" and override.customText or nil,
                                isChargeSpell = isCharge,
                                maxCharges = maxCh,
                                rechargeDuration = rechDur,
                                baseDuration = isCharge and rechDur or SafeGetBaseDuration(displayId),
                            })
                        end
                    end
                end
            end
        end
    end

    for spellId, override in pairs(overrides) do
        if not seen[spellId] and override.class == class and override.enabled ~= false then
            if ns.IsPlayerSpell(spellId) then
                local displayId = spellId
                if C_Spell.GetOverrideSpell then
                    local oid = C_Spell.GetOverrideSpell(spellId)
                    if oid and oid ~= spellId then displayId = oid end
                end
                if not seen[displayId] then
                    seen[spellId] = true
                    seen[displayId] = true
                    local spellInfo = C_Spell.GetSpellInfo(displayId)
                    local isCharge, maxCh, rechDur = SafeGetChargeInfo(displayId)
                    if spellInfo then
                        table.insert(result, {
                            spellId = displayId,
                            spellName = spellInfo.name,
                            spellIcon = spellInfo.iconID,
                            customText = override.customText ~= "" and override.customText or nil,
                            isChargeSpell = isCharge,
                            maxCharges = maxCh,
                            rechargeDuration = rechDur,
                            baseDuration = isCharge and rechDur or SafeGetBaseDuration(displayId),
                        })
                    end
                end
            end
        end
    end

    return result
end

local function UpdateCachedCharges()
    if inCombat then return end
    for _, entry in ipairs(cachedMovementSpells) do
        if entry.isChargeSpell then
            local ok, charges = pcall(function()
                local chargeInfo = C_Spell.GetSpellCharges(entry.spellId)
                if chargeInfo then
                    return tonumber(tostring(chargeInfo.currentCharges)) or 0
                end
            end)
            if ok and charges then
                cachedChargeCount[entry.spellId] = charges
            end
        end
        if not entry.isChargeSpell then
            local ok, dur = pcall(function()
                local cdInfo = C_Spell.GetSpellCooldown(entry.spellId)
                if cdInfo and cdInfo.duration then
                    return tonumber(tostring(cdInfo.duration)) or 0
                end
                return 0
            end)
            if ok and dur and dur > 0 then
                entry.baseDuration = dur
            end
        end
    end
end

local function CacheMovementSpells(fullReset)
    local class = select(2, UnitClass("player"))
    local spec = GetSpecialization()
    local specId = spec and select(1, GetSpecializationInfo(spec)) or nil

    if DEBUG_MODE then
        print("[MovementAlert] CacheMovementSpells - Class:", class, "SpecID:", specId)
    end

    if fullReset then
        wipe(spellWasCast)
        wipe(spellCastTime)
        cacheResetTime = GetTime()
    end

    cachedMovementSpells = GetPlayerMovementSpells()
    wipe(trackedSpellSet)
    for _, entry in ipairs(cachedMovementSpells) do
        trackedSpellSet[entry.spellId] = entry.spellId
        if C_Spell.GetOverrideSpell then
            local oid = C_Spell.GetOverrideSpell(entry.spellId)
            if oid and oid ~= entry.spellId then
                trackedSpellSet[oid] = entry.spellId
            end
        end
    end

    local classAbilities = MOVEMENT_ABILITIES[class]
    local specAbilities = classAbilities and specId and classAbilities[specId]
    if specAbilities and C_Spell.GetOverrideSpell then
        for _, spellId in ipairs(specAbilities) do
            if not trackedSpellSet[spellId] then
                local oid = C_Spell.GetOverrideSpell(spellId)
                if oid and oid ~= spellId and trackedSpellSet[oid] then
                    trackedSpellSet[spellId] = trackedSpellSet[oid]
                end
            end
        end
    end

    UpdateCachedCharges()

    if DEBUG_MODE then
        print("[MovementAlert] Cached", #cachedMovementSpells, "spells")
        for _, entry in ipairs(cachedMovementSpells) do
            print("  -", entry.spellId, entry.spellName,
                entry.customText or "(default)",
                entry.isChargeSpell and ("charges:" .. (cachedChargeCount[entry.spellId] or "?")) or "")
        end
    end
end

local function CancelAllRechargeTimers()
    for _, timer in pairs(rechargeTimers) do
        timer:Cancel()
    end
    wipe(rechargeTimers)
end

local function StartRechargeTimer(entry)
    if rechargeTimers[entry.spellId] then return end
    local duration = entry.rechargeDuration or 0
    if duration <= 0 then return end
    rechargeTimers[entry.spellId] = C_Timer.NewTimer(duration, function()
        rechargeTimers[entry.spellId] = nil
        local rawCur = cachedChargeCount[entry.spellId]
        local cur = (rawCur ~= nil and tonumber(tostring(rawCur)) or 0)
        local max = entry.maxCharges or 1
        cachedChargeCount[entry.spellId] = math.min(cur + 1, max)
        if cachedChargeCount[entry.spellId] < max then
            StartRechargeTimer(entry)
        end
        if CheckMovementCooldown then CheckMovementCooldown() end
    end)
end

local function OnTrackedSpellCast(spellId)
    if (GetTime() - cacheResetTime) < 2 then return end
    local baseId = trackedSpellSet[spellId]
    if not baseId then return end
    spellWasCast[baseId] = true
    spellCastTime[baseId] = GetTime()

    if not inCombat then
        for _, entry in ipairs(cachedMovementSpells) do
            if entry.spellId == baseId and not entry.isChargeSpell then
                local dur = SafeGetBaseDuration(baseId)
                if dur > 0 then entry.baseDuration = dur end
                break
            end
        end
    end

    if not inCombat then return end
    for _, entry in ipairs(cachedMovementSpells) do
        if entry.spellId == baseId and entry.isChargeSpell then
            local rawCur = cachedChargeCount[baseId]
            local cur = rawCur ~= nil and tonumber(tostring(rawCur)) or nil
            if cur == nil then cur = entry.maxCharges or 1 end
            cachedChargeCount[baseId] = math.max(0, cur - 1)
            if not rechargeTimers[baseId] then
                StartRechargeTimer(entry)
            end
            return
        end
    end
end

local function PlayTimeSpiralAlert(db)
    if db.tsSoundEnabled and db.tsSoundID then
        ns.SoundList.Play(db.tsSoundID)
    elseif db.tsTtsEnabled and db.tsTtsMessage then
        C_VoiceChat.SpeakText(db.tsTtsVoiceID or 0, db.tsTtsMessage, 1, db.tsTtsVolume or 50, true)
    end
end

local function PlayGatewayAlert(db)
    if db.gwSoundEnabled and db.gwSoundID then
        ns.SoundList.Play(db.gwSoundID)
    elseif db.gwTtsEnabled and db.gwTtsMessage then
        C_VoiceChat.SpeakText(db.gwTtsVoiceID or 0, db.gwTtsMessage, 1, db.gwTtsVolume or 50, true)
    end
end

local function CancelMovementCountdown()
    if movementCountdownTimer then
        movementCountdownTimer:Cancel()
        movementCountdownTimer = nil
    end
end

local function CancelTimeSpiralCountdown()
    if timeSpiralCountdownTimer then
        timeSpiralCountdownTimer:Cancel()
        timeSpiralCountdownTimer = nil
    end
end

local function StyleSlot(slot, db)
    local fontPath = ns.Media.ResolveFont(db.font)
    local frameH = movementFrame:GetHeight()
    local frameW = movementFrame:GetWidth()
    local fontSize = math.max(10, math.min(72, math.floor(frameH * 0.55)))
    local tR, tG, tB = W.GetEffectiveColor(db, "textColorR", "textColorG", "textColorB", "textColorUseClassColor")

    local s = slot.text:SetFont(fontPath, fontSize, "OUTLINE")
    if not s then slot.text:SetFont(ns.DefaultFontPath(), fontSize, "OUTLINE") end
    slot.text:SetTextColor(tR, tG, tB)

    local barH = math.max(12, math.floor(frameH * 0.5))
    local barIconSize = barH
    local barW = frameW - (db.barShowIcon ~= false and (barIconSize + 8) or 0) - 10
    local barFontSize = math.max(8, math.min(24, math.floor(barH * 0.6)))
    slot.bar:SetSize(math.max(50, barW), barH)
    slot.bar.icon:SetSize(barIconSize, barIconSize)
    local bs = slot.bar.text:SetFont(fontPath, barFontSize, "OUTLINE")
    if not bs then slot.bar.text:SetFont(ns.DefaultFontPath(), barFontSize, "OUTLINE") end

    local iconSize = math.max(20, math.min(frameW, frameH) - 4)
    slot.icon:SetSize(iconSize, iconSize)
end

function movementFrame:UpdateDisplay()
    local db = NaowhQOL.movementAlert
    if not db then return end

    movementFrame:EnableMouse(db.unlock and db.enabled)
    if db.unlock and db.enabled then
        movementFrame:SetBackdrop(UNLOCK_BACKDROP)
        movementFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        movementFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        if movementResizeHandle then movementResizeHandle:Show() end
        movementText:SetText("MOVEMENT CD")
        movementText:Show()
        movementFrame:Show()
    else
        movementFrame:SetBackdrop(nil)
        if movementResizeHandle then movementResizeHandle:Hide() end
        movementText:SetText("")
        movementText:Hide()
    end

    if not movementFrame.initialized then
        movementFrame:ClearAllPoints()
        local point = db.point or "CENTER"
        local x = db.x or 0
        local y = db.y or 50
        movementFrame:SetPoint(point, UIParent, point, x, y)
        movementFrame:SetSize(db.width or 200, db.height or 40)
        movementFrame.initialized = true
    end

    local fontPath = ns.Media.ResolveFont(db.font)
    local frameW = movementFrame:GetWidth()
    local frameH = movementFrame:GetHeight()

    local fontSize = math.max(10, math.min(72, math.floor(frameH * 0.55)))
    local success = movementText:SetFont(fontPath, fontSize, "OUTLINE")
    if not success then
        movementText:SetFont(ns.DefaultFontPath(), fontSize, "OUTLINE")
    end
    local tR, tG, tB = W.GetEffectiveColor(db, "textColorR", "textColorG", "textColorB", "textColorUseClassColor")
    movementText:SetTextColor(tR, tG, tB)

    for _, slot in ipairs(displayPool) do
        StyleSlot(slot, db)
    end

    UpdateEventRegistration()
    if db.enabled and not db.unlock then
        CheckMovementCooldown()
    end
end

function timeSpiralFrame:UpdateDisplay()
    local db = NaowhQOL.movementAlert
    if not db then return end

    timeSpiralFrame:EnableMouse(db.tsUnlock)
    if db.tsUnlock and db.tsEnabled then
        timeSpiralFrame:SetBackdrop(UNLOCK_BACKDROP)
        timeSpiralFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        timeSpiralFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        if timeSpiralResizeHandle then timeSpiralResizeHandle:Show() end
        timeSpiralText:SetText("TIME SPIRAL")
        timeSpiralFrame:Show()
    elseif timeSpiralActiveTime then
        timeSpiralFrame:SetBackdrop(nil)
        if timeSpiralResizeHandle then timeSpiralResizeHandle:Hide() end
    else
        timeSpiralFrame:SetBackdrop(nil)
        if timeSpiralResizeHandle then timeSpiralResizeHandle:Hide() end
        timeSpiralText:SetText("")
        timeSpiralFrame:Hide()
    end

    if not timeSpiralFrame.initialized then
        timeSpiralFrame:ClearAllPoints()
        local point = db.tsPoint or "CENTER"
        local x = db.tsX or 0
        local y = db.tsY or 100
        timeSpiralFrame:SetPoint(point, UIParent, point, x, y)
        timeSpiralFrame:SetSize(db.tsWidth or 200, db.tsHeight or 40)
        timeSpiralFrame.initialized = true
    end

    local fontPath = ns.Media.ResolveFont(db.font)
    local fontSize = math.max(10, math.min(72, math.floor(timeSpiralFrame:GetHeight() * 0.55)))
    local success = timeSpiralText:SetFont(fontPath, fontSize, "OUTLINE")
    if not success then
        timeSpiralText:SetFont(ns.DefaultFontPath(), fontSize, "OUTLINE")
    end
    local tsR, tsG, tsB = W.GetEffectiveColor(db, "tsColorR", "tsColorG", "tsColorB", "tsColorUseClassColor")
    timeSpiralText:SetTextColor(tsR, tsG, tsB)
    UpdateEventRegistration()
end

function gatewayFrame:UpdateDisplay()
    local db = NaowhQOL.movementAlert
    if not db then return end

    gatewayFrame:EnableMouse(db.gwUnlock)
    if db.gwUnlock and db.gwEnabled then
        gatewayFrame:SetBackdrop(UNLOCK_BACKDROP)
        gatewayFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        gatewayFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        if gatewayResizeHandle then gatewayResizeHandle:Show() end
        gatewayText:SetText("GATEWAY")
        gatewayFrame:Show()
    else
        gatewayFrame:SetBackdrop(nil)
        if gatewayResizeHandle then gatewayResizeHandle:Hide() end
        gatewayText:SetText("")
        gatewayFrame:Hide()
    end

    if not gatewayFrame.initialized then
        gatewayFrame:ClearAllPoints()
        local point = db.gwPoint or "CENTER"
        local x = db.gwX or 0
        local y = db.gwY or 150
        gatewayFrame:SetPoint(point, UIParent, point, x, y)
        gatewayFrame:SetSize(db.gwWidth or 200, db.gwHeight or 40)
        gatewayFrame.initialized = true
    end

    local fontPath = ns.Media.ResolveFont(db.font)
    local fontSize = math.max(10, math.min(72, math.floor(gatewayFrame:GetHeight() * 0.55)))
    local success = gatewayText:SetFont(fontPath, fontSize, "OUTLINE")
    if not success then
        gatewayText:SetFont(ns.DefaultFontPath(), fontSize, "OUTLINE")
    end
    local gwR, gwG, gwB = W.GetEffectiveColor(db, "gwColorR", "gwColorG", "gwColorB", "gwColorUseClassColor")
    gatewayText:SetTextColor(gwR, gwG, gwB)
    UpdateEventRegistration()
end

local function HideMovementDisplay()
    local db = NaowhQOL.movementAlert
    if db and not db.unlock then
        movementFrame:Hide()
    end
    movementText:Hide()
    for _, slot in ipairs(displayPool) do
        slot.text:Hide()
        slot.icon:Hide()
        slot.icon.cooldown:Clear()
        slot.bar:Hide()
        slot:Hide()
    end
    activeSlotCount = 0
    CancelMovementCountdown()
end

local function ShowMovementSlot(index, cdInfo, spellEntry, duration)
    local db = NaowhQOL.movementAlert
    if not db then return end

    local cdRemaining, cdStart, cdDuration, cdModRate
    if duration then
        local okR, rem   = pcall(duration.GetRemainingDuration, duration)
        local okT, total = pcall(duration.GetTotalDuration, duration)
        local okS, start = pcall(duration.GetStartTime, duration)
        local okM, rate  = pcall(duration.GetModRate, duration)
        if okR and rem then
            cdRemaining = rem
            cdDuration  = (okT and total) or 0
            cdStart     = (okS and start) or 0
            cdModRate   = (okM and rate)  or 1
        end
    end

    if not cdRemaining then
        if inCombat then
            local castTime = spellCastTime[spellEntry.spellId] or GetTime()
            local baseDur = spellEntry.isChargeSpell
                and (spellEntry.rechargeDuration or 0)
                or  (spellEntry.baseDuration or 0)
            cdStart    = castTime
            cdDuration = baseDur
            cdRemaining = math.max(0, (castTime + baseDur) - GetTime())
            cdModRate  = 1
        else
            cdRemaining = tonumber(tostring(cdInfo.timeUntilEndOfStartRecovery)) or 0
            cdStart     = tonumber(tostring(cdInfo.startTime)) or 0
            cdDuration  = tonumber(tostring(cdInfo.duration)) or 0
            cdModRate   = tonumber(tostring(cdInfo.modRate or 1)) or 1
        end
    end

    local slot = GetDisplaySlot(index)
    StyleSlot(slot, db)
    local displayMode = db.displayMode or "text"
    local precision = db.precision or 1
    local spellName = spellEntry.customText or spellEntry.spellName or L["MOVEMENT_ALERT_FALLBACK"] or "Movement"
    local spellIcon = spellEntry.spellIcon

    slot.text:Hide()
    slot.icon:Hide()
    slot.bar:Hide()

    if displayMode == "text" then
        local textFormat = db.textFormat or "%ts\nNo %a"
        local precFmt = "%%." .. precision .. "f"
        local fmtStr = textFormat:gsub("\\n", "\n"):gsub("%%a", spellName):gsub("%%t", precFmt)
        slot.text:SetFormattedText(fmtStr, cdRemaining)
        slot.text:Show()
    elseif displayMode == "icon" then
        if spellIcon then
            slot.icon.tex:SetTexture(spellIcon)
            if duration and slot.icon.cooldown.SetCooldownFromDurationObject then
                slot.icon.cooldown:SetCooldownFromDurationObject(duration, true)
            else
                slot.icon.cooldown:SetCooldown(cdStart, cdDuration, cdModRate)
            end
            slot.icon.cooldown:SetHideCountdownNumbers(false)
            slot.icon:Show()
        else
            local textFormat = db.textFormat or "%ts\nNo %a"
            local precFmt = "%%." .. precision .. "f"
            local fmtStr = textFormat:gsub("\\n", "\n"):gsub("%%a", spellName):gsub("%%t", precFmt)
            slot.text:SetFormattedText(fmtStr, cdRemaining)
            slot.text:Show()
        end
    elseif displayMode == "bar" then
        slot.bar:SetMinMaxValues(0, cdDuration)
        slot.bar:SetValue(cdRemaining)
        local barR, barG, barB = W.GetEffectiveColor(db, "textColorR", "textColorG", "textColorB", "textColorUseClassColor")
        slot.bar:SetStatusBarColor(barR, barG, barB)

        slot.bar.text:SetFormattedText("%." .. precision .. "f", cdRemaining)

        if db.barShowIcon ~= false and spellIcon then
            slot.bar.icon:SetTexture(spellIcon)
            slot.bar.icon:Show()
        else
            slot.bar.icon:Hide()
        end

        slot.bar:Show()
    end

    slot:Show()
end

CheckMovementCooldown = function()
    local db = NaowhQOL.movementAlert
    if not db then return end

    if not db.enabled then
        if DEBUG_MODE then print("[MovementAlert] Module disabled") end
        HideMovementDisplay()
        return
    end

    if db.combatOnly and not inCombat and not db.unlock then
        if DEBUG_MODE then print("[MovementAlert] Combat-only mode, not in combat") end
        HideMovementDisplay()
        return
    end

    local playerClass = select(2, UnitClass("player"))
    if db.disabledClasses and db.disabledClasses[playerClass] then
        if DEBUG_MODE then print("[MovementAlert] Class disabled:", playerClass) end
        HideMovementDisplay()
        return
    end

    if #cachedMovementSpells == 0 then
        if DEBUG_MODE then print("[MovementAlert] No cached spells") end
        HideMovementDisplay()
        return
    end

    local count = 0

    for _, entry in ipairs(cachedMovementSpells) do
        local cdInfo = C_Spell.GetSpellCooldown(entry.spellId)

        if DEBUG_MODE then
            print("[MovementAlert] Checking:", entry.spellId, entry.spellName,
                  "cdInfo:", cdInfo and "exists" or "nil",
                  "charge:", entry.isChargeSpell and "yes" or "no")
        end

        if cdInfo and cdInfo.timeUntilEndOfStartRecovery then
            local showThis = false

            if entry.isChargeSpell then
                local currentCharges
                if inCombat then
                    local raw = cachedChargeCount[entry.spellId]
                    currentCharges = (raw ~= nil) and (tonumber(tostring(raw)) or 0) or 0
                else
                    local chargeInfo = C_Spell.GetSpellCharges(entry.spellId)
                    currentCharges = 0
                    if chargeInfo and chargeInfo.currentCharges ~= nil then
                        currentCharges = tonumber(tostring(chargeInfo.currentCharges)) or 0
                    end
                    cachedChargeCount[entry.spellId] = currentCharges
                end
                if currentCharges == 0 and spellWasCast[entry.spellId] then
                    if inCombat then
                        showThis = true
                    else
                        local remaining = tonumber(tostring(cdInfo.timeUntilEndOfStartRecovery)) or 0
                        if remaining > 1.5 then
                            showThis = true
                        end
                    end
                end
            elseif spellWasCast[entry.spellId] then
                if inCombat then
                    showThis = true
                else
                    local remaining = tonumber(tostring(cdInfo.timeUntilEndOfStartRecovery)) or 0
                    if remaining > 1.5 then
                        showThis = true
                    end
                end
            end

            if showThis then
                local duration
                if entry.isChargeSpell and C_Spell.GetSpellChargeDuration then
                    local ok, d = pcall(C_Spell.GetSpellChargeDuration, entry.spellId)
                    if ok then duration = d end
                elseif not entry.isChargeSpell and C_Spell.GetSpellCooldownDuration then
                    local ok, d = pcall(C_Spell.GetSpellCooldownDuration, entry.spellId)
                    if ok then duration = d end
                end
                count = count + 1
                ShowMovementSlot(count, cdInfo, entry, duration)
            end
        else
            spellWasCast[entry.spellId] = nil
            spellCastTime[entry.spellId] = nil
        end
    end

    for i = count + 1, activeSlotCount do
        local slot = displayPool[i]
        if slot then
            slot.text:Hide()
            slot.icon:Hide()
            slot.icon.cooldown:Clear()
            slot.bar:Hide()
            slot:Hide()
        end
    end

    if count > 0 then
        activeSlotCount = count
        LayoutDisplaySlots(count)
        movementFrame:Show()
        CancelMovementCountdown()
        local pollMs = math.max(50, db.pollRate or 100)
        movementCountdownTimer = C_Timer.NewTimer(pollMs / 1000, CheckMovementCooldown)
    else
        activeSlotCount = 0
        HideMovementDisplay()
    end
end

local function UpdateTimeSpiralCountdown()
    local db = NaowhQOL.movementAlert
    if not db or not db.tsEnabled or not timeSpiralActiveTime then
        if not (db and db.tsUnlock) then
            timeSpiralFrame:Hide()
        end
        CancelTimeSpiralCountdown()
        return
    end

    local remaining = 10 - (GetTime() - timeSpiralActiveTime)
    if remaining > 0 then
        local tsTextFormat = db.tsTextFormat or db.tsText or L["TIME_SPIRAL_TEXT_FORMAT_DEFAULT"] or "FREE MOVEMENT\n%ts"
        local fmtStr = tsTextFormat:gsub("\\n", "\n"):gsub("%%t", "%%s")
        timeSpiralText:SetFormattedText(fmtStr, string.format("%.1f", remaining))
        timeSpiralFrame:Show()
        timeSpiralCountdownTimer = C_Timer.NewTimer(0.1, UpdateTimeSpiralCountdown)
    else
        timeSpiralActiveTime = nil
        if not db.tsUnlock then
            timeSpiralFrame:Hide()
        end
        CancelTimeSpiralCountdown()
    end
end

local function StartTimeSpiralCountdown()
    CancelTimeSpiralCountdown()
    UpdateTimeSpiralCountdown()
end

local function StopGatewayPolling()
    if gatewayPollTicker then
        gatewayPollTicker:Cancel()
        gatewayPollTicker = nil
    end
end

local function CheckGatewayUsable()
    local db = NaowhQOL.movementAlert
    if not db or not db.gwEnabled then
        if not (db and db.gwUnlock) then
            gatewayFrame:Hide()
        end
        StopGatewayPolling()
        return
    end

    local itemCount = C_Item.GetItemCount(GATEWAY_SHARD_ITEM_ID)
    if itemCount == 0 then
        if not db.gwUnlock then
            gatewayFrame:Hide()
        end
        lastGatewayUsable = false
        return
    end

    if db.gwCombatOnly and not inCombat and not db.gwUnlock then
        gatewayFrame:Hide()
        lastGatewayUsable = false
        return
    end

    local isUsable = C_Item.IsUsableItem(GATEWAY_SHARD_ITEM_ID)

    if isUsable and not lastGatewayUsable then
        PlayGatewayAlert(db)
    end

    lastGatewayUsable = isUsable

    if isUsable then
        local gwText = db.gwText or "GATEWAY READY"
        gatewayText:SetText(gwText)
        gatewayFrame:Show()
    else
        if not db.gwUnlock then
            gatewayFrame:Hide()
        end
    end
end

local function StartGatewayPolling()
    StopGatewayPolling()
    local db = NaowhQOL.movementAlert
    if not db or not db.gwEnabled then return end

    CheckGatewayUsable()
    gatewayPollTicker = C_Timer.NewTicker(0.1, CheckGatewayUsable)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
loader:RegisterEvent("PLAYER_TALENT_UPDATE")
loader:RegisterEvent("TRAIT_CONFIG_UPDATED")
loader:RegisterEvent("PLAYER_REGEN_DISABLED")
loader:RegisterEvent("PLAYER_REGEN_ENABLED")
loader:RegisterEvent("PLAYER_LOGOUT")

local movementEventsRegistered = false
local timeSpiralEventsRegistered = false

UpdateEventRegistration = function()
    local db = NaowhQOL.movementAlert
    if not db then return end

    if db.enabled and not movementEventsRegistered then
        loader:RegisterEvent("SPELL_UPDATE_USABLE")
        loader:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        loader:RegisterEvent("SPELL_UPDATE_CHARGES")
        loader:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
        movementEventsRegistered = true
    elseif not db.enabled and movementEventsRegistered then
        loader:UnregisterEvent("SPELL_UPDATE_USABLE")
        loader:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
        loader:UnregisterEvent("SPELL_UPDATE_CHARGES")
        loader:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        movementEventsRegistered = false
        CancelMovementCountdown()
    end

    if db.tsEnabled and not timeSpiralEventsRegistered then
        loader:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
        loader:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
        loader:RegisterEvent("UNIT_SPELLCAST_SENT")
        loader:RegisterEvent("LOADING_SCREEN_DISABLED")
        timeSpiralEventsRegistered = true
        RefreshCastFilters()
    elseif not db.tsEnabled and timeSpiralEventsRegistered then
        loader:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
        loader:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
        loader:UnregisterEvent("UNIT_SPELLCAST_SENT")
        loader:UnregisterEvent("LOADING_SCREEN_DISABLED")
        timeSpiralEventsRegistered = false
        CancelTimeSpiralCountdown()
    end

    if db.gwEnabled then
        StartGatewayPolling()
    else
        StopGatewayPolling()
        if not db.gwUnlock then
            gatewayFrame:Hide()
        end
    end
end

loader:SetScript("OnEvent", ns.PerfMonitor:Wrap("Movement Alert", function(self, event, ...)
    local db = NaowhQOL.movementAlert
    if not db then return end

    if event == "PLAYER_LOGIN" then
        if DEBUG_MODE then print("[MovementAlert] PLAYER_LOGIN - initializing") end
        RebuildMobilitySpellLookup()
        CacheMovementSpells(true)
        inCombat = UnitAffectingCombat("player")

        db.width = db.width or 200
        db.height = db.height or 40
        db.point = db.point or "CENTER"
        db.x = db.x or 0
        db.y = db.y or 50

        W.MakeDraggable(movementFrame, { db = db })
        movementResizeHandle = W.CreateResizeHandle(movementFrame, {
            db = db,
            onResize = function() movementFrame:UpdateDisplay() end,
        })

        db.tsWidth = db.tsWidth or 200
        db.tsHeight = db.tsHeight or 40
        db.tsPoint = db.tsPoint or "CENTER"
        db.tsX = db.tsX or 0
        db.tsY = db.tsY or 100

        W.MakeDraggable(timeSpiralFrame, {
            db = db,
            unlockKey = "tsUnlock",
            pointKey = "tsPoint", xKey = "tsX", yKey = "tsY",
        })
        timeSpiralResizeHandle = W.CreateResizeHandle(timeSpiralFrame, {
            db = db,
            unlockKey = "tsUnlock",
            widthKey = "tsWidth", heightKey = "tsHeight",
            onResize = function() timeSpiralFrame:UpdateDisplay() end,
        })

        db.gwWidth = db.gwWidth or 200
        db.gwHeight = db.gwHeight or 40
        db.gwPoint = db.gwPoint or "CENTER"
        db.gwX = db.gwX or 0
        db.gwY = db.gwY or 150

        W.MakeDraggable(gatewayFrame, {
            db = db,
            unlockKey = "gwUnlock",
            pointKey = "gwPoint", xKey = "gwX", yKey = "gwY",
        })
        gatewayResizeHandle = W.CreateResizeHandle(gatewayFrame, {
            db = db,
            unlockKey = "gwUnlock",
            widthKey = "gwWidth", heightKey = "gwHeight",
            onResize = function() gatewayFrame:UpdateDisplay() end,
        })

        movementFrame.initialized = false
        timeSpiralFrame.initialized = false
        gatewayFrame.initialized = false
        movementFrame:UpdateDisplay()
        timeSpiralFrame:UpdateDisplay()
        gatewayFrame:UpdateDisplay()
        UpdateEventRegistration()

        ns.SpecUtil.RegisterCallback("MovementAlert", function()
            CacheMovementSpells(true)
            movementFrame:UpdateDisplay()
            timeSpiralFrame:UpdateDisplay()
            gatewayFrame:UpdateDisplay()
            CheckMovementCooldown()
        end)

        CheckMovementCooldown()
        StartGatewayPolling()

        C_Timer.After(0.2, function()
            UpdateEventRegistration()
        end)

        ns.SettingsIO:RegisterRefresh("movementAlert", function()
            RebuildMobilitySpellLookup()
            CacheMovementSpells(true)
            movementFrame:UpdateDisplay()
            timeSpiralFrame:UpdateDisplay()
            gatewayFrame:UpdateDisplay()
            UpdateEventRegistration()
        end)
        return
    end

    if event == "PLAYER_LOGOUT" then
        timeSpiralActiveTime = nil
        CancelMovementCountdown()
        CancelTimeSpiralCountdown()
        CancelAllRechargeTimers()
        StopGatewayPolling()
        return
    end

    if event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_TALENT_UPDATE" or event == "TRAIT_CONFIG_UPDATED" then
        if not InCombatLockdown() then
            CacheMovementSpells(true)
            CheckMovementCooldown()
            RefreshCastFilters()
        end
    elseif event == "LOADING_SCREEN_DISABLED" then
        RefreshCastFilters()
    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
        for _, entry in ipairs(cachedMovementSpells) do
            if entry.isChargeSpell then
                local rawCur = cachedChargeCount[entry.spellId]
                local cur = rawCur ~= nil and tonumber(tostring(rawCur)) or nil
                if cur and cur < (entry.maxCharges or 1) and not rechargeTimers[entry.spellId] then
                    StartRechargeTimer(entry)
                end
            end
        end
        CheckMovementCooldown()
        CheckGatewayUsable()
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
        CancelAllRechargeTimers()
        for spellId in pairs(spellWasCast) do
            local cdInfo = C_Spell.GetSpellCooldown(spellId)
            if not cdInfo or not cdInfo.timeUntilEndOfStartRecovery
               or (tonumber(tostring(cdInfo.timeUntilEndOfStartRecovery)) or 0) <= 0 then
                spellWasCast[spellId] = nil
                spellCastTime[spellId] = nil
            end
        end
        CacheMovementSpells()
        CheckMovementCooldown()
        CheckGatewayUsable()
    elseif event == "SPELL_UPDATE_COOLDOWN" or event == "SPELL_UPDATE_USABLE" or event == "SPELL_UPDATE_CHARGES" then
        if DEBUG_MODE then print("[MovementAlert] Event:", event) end
        UpdateCachedCharges()
        CheckMovementCooldown()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local _, _, spellId = ...
        OnTrackedSpellCast(spellId)
    elseif event == "UNIT_SPELLCAST_SENT" then
        local _, _, _, spellId = ...
        OnSpellCast(spellId)
    elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then
        local spellId = ...
        if db.tsEnabled and IsValidTimeSpiralProc(spellId) then
            RecordProc()
            timeSpiralActiveTime = GetTime()
            PlayTimeSpiralAlert(db)
            StartTimeSpiralCountdown()
        end
    end

    if event == "PLAYER_LOGIN"
        or event == "PLAYER_SPECIALIZATION_CHANGED"
        or event == "PLAYER_TALENT_UPDATE"
        or event == "TRAIT_CONFIG_UPDATED"
        or event == "LOADING_SCREEN_DISABLED" then
        movementFrame:UpdateDisplay()
        timeSpiralFrame:UpdateDisplay()
        gatewayFrame:UpdateDisplay()
        UpdateEventRegistration()
    end
end))

ns.MovementAlertDisplay = movementFrame
ns.TimeSpiralDisplay = timeSpiralFrame
ns.GatewayShardDisplay = gatewayFrame
ns.MOVEMENT_ABILITIES = MOVEMENT_ABILITIES
ns.RebuildMobilitySpellLookup = RebuildMobilitySpellLookup
ns.CacheMovementSpells = CacheMovementSpells
