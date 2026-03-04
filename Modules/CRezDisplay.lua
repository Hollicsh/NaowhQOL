local addonName, ns = ...
local L = ns.L
local W = ns.Widgets
local MakeSlot = ns.DisplayUtils.MakeSlot
local REBIRTH_SPELL_ID = 20484

local inMythicPlus = false
local encounterActive = false

local rezFrame = CreateFrame("Frame", "NaowhQOL_CRezTimer", UIParent, "BackdropTemplate")
rezFrame:SetSize(40, 40)
rezFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
rezFrame:Hide()

local rezSlot = MakeSlot(rezFrame)
rezSlot:SetAllPoints()
rezSlot.lbl:Hide()

rezSlot.count = rezSlot:CreateFontString(nil, "OVERLAY")
rezSlot.count:SetPoint("BOTTOMRIGHT", -2, 2)
rezSlot.count:SetFont(ns.DefaultFontPath(), 11, "OUTLINE")

local rezUpdateElapsed = 0
local REZ_UPDATE_INTERVAL = 0.1

local function ShouldShowRezTimer()
    local db = NaowhQOL.cRez
    if not db or not db.enabled then return false end
    if db.unlock then return true end
    return inMythicPlus or encounterActive
end

local function UpdateRezDisplay()
    local db = NaowhQOL.cRez
    if not db then return end

    local fontPath = ns.Media.ResolveFont(db.font)
    rezSlot.timer:SetFont(fontPath, db.timerFontSize or 11, "OUTLINE")
    local tcR, tcG, tcB = W.GetEffectiveColor(db, "timerColorR", "timerColorG", "timerColorB", "timerColorUseClassColor")
    rezSlot.timer:SetTextColor(tcR, tcG, tcB, db.timerAlpha or 1)
    rezSlot.count:SetFont(fontPath, db.countFontSize or 11, "OUTLINE")
    local ccR, ccG, ccB = W.GetEffectiveColor(db, "countColorR", "countColorG", "countColorB", "countColorUseClassColor")
    rezSlot.count:SetTextColor(ccR, ccG, ccB, db.countAlpha or 1)

    local charges = C_Spell.GetSpellCharges(REBIRTH_SPELL_ID)
    if not charges then
        rezSlot.tex:SetTexture("Interface\\Icons\\Spell_Nature_Reincarnation")
        rezSlot.timer:SetText("--:--")
        rezSlot.count:SetText("0")
        return
    end

    local icon = C_Spell.GetSpellTexture(REBIRTH_SPELL_ID)
    rezSlot.tex:SetTexture(icon or "Interface\\Icons\\Spell_Nature_Reincarnation")
    rezSlot.count:SetText(tostring(charges.currentCharges))

    if charges.currentCharges >= charges.maxCharges then
        rezSlot.timer:SetText("")
        rezSlot.tex:SetDesaturated(false)
    else
        local remaining = charges.cooldownDuration - (GetTime() - charges.cooldownStartTime)
        if remaining > 0 then
            rezSlot.timer:SetText(format("%d:%02d", remaining / 60, remaining % 60))
        else
            rezSlot.timer:SetText("")
        end
        rezSlot.tex:SetDesaturated(charges.currentCharges == 0)
    end
end

rezFrame:SetScript("OnUpdate", function(self, elapsed)
    rezUpdateElapsed = rezUpdateElapsed + elapsed
    if rezUpdateElapsed < REZ_UPDATE_INTERVAL then return end
    rezUpdateElapsed = 0
    UpdateRezDisplay()
end)

function rezFrame:Refresh()
    local db = NaowhQOL.cRez
    if not db then self:Hide() return end

    self:EnableMouse(db.unlock)
    ns.DisplayUtils.SetFrameUnlocked(self, db.unlock, L["CREZ_UNLOCK_LABEL"] or "Rez Timer")

    local sz = db.iconSize or 40
    self:SetSize(sz, sz)

    if not self.posInitialized then
        self:ClearAllPoints()
        self:SetPoint(db.point or "CENTER", UIParent, db.point or "CENTER", db.x or 0, db.y or 150)
        self.posInitialized = true
    end

    if ShouldShowRezTimer() then
        self:Show()
        UpdateRezDisplay()
    else
        self:Hide()
    end
end

local function OnUnitDied(unitGUID)
    local db = NaowhQOL.cRez
    if not db or not db.enabled or not db.deathWarning then return end

    if issecretvalue and issecretvalue(unitGUID) then return end
    if not unitGUID then return end

    local unit = UnitTokenFromGUID(unitGUID)
    if not unit then return end

    local inGroup = IsGUIDInGroup and IsGUIDInGroup(unitGUID)
    local isPlayer = UnitIsUnit(unit, "player")
    if not inGroup and not isPlayer then return end

    PlaySound(SOUNDKIT.RAID_WARNING or 8959, "Master")

    local name = UnitNameUnmodified(unit) or UnitName(unit) or "Unknown"
    local msg = name .. " " .. (L["CREZ_DIED"] or "died")
    RaidNotice_AddMessage(RaidWarningFrame, msg, ChatTypeInfo["RAID_WARNING"])
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ENCOUNTER_START")
eventFrame:RegisterEvent("ENCOUNTER_END")
eventFrame:RegisterEvent("CHALLENGE_MODE_START")
eventFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
eventFrame:RegisterEvent("UNIT_DIED")

eventFrame:SetScript("OnEvent", ns.PerfMonitor:Wrap("CRez", function(self, event, arg1)
    if event == "PLAYER_LOGIN" then
        local db = NaowhQOL.cRez
        if not db then return end

        inMythicPlus = ns.ZoneUtil.IsInMythicPlus()
        encounterActive = C_InstanceEncounter and C_InstanceEncounter.IsEncounterInProgress() or false

        W.MakeDraggable(rezFrame, { db = db })

        ns.ZoneUtil.RegisterCallback("CRez", function()
            inMythicPlus = ns.ZoneUtil.IsInMythicPlus()
            encounterActive = C_InstanceEncounter and C_InstanceEncounter.IsEncounterInProgress() or false
            rezFrame:Refresh()
        end)

        rezFrame:Refresh()

        ns.SettingsIO:RegisterRefresh("cRez", function()
            rezFrame:Refresh()
        end)
        return
    end

    if event == "ENCOUNTER_START" then
        encounterActive = true
        rezFrame:Refresh()
        return
    end

    if event == "ENCOUNTER_END" then
        encounterActive = false
        rezFrame:Refresh()
        return
    end

    if event == "CHALLENGE_MODE_START" then
        inMythicPlus = true
        rezFrame:Refresh()
        return
    end

    if event == "CHALLENGE_MODE_COMPLETED" then
        inMythicPlus = false
        rezFrame:Refresh()
        return
    end

    if event == "UNIT_DIED" then
        OnUnitDied(arg1)
        return
    end
end))

ns.CRezTimerDisplay = rezFrame
