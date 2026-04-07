local addonName, ns = ...
if not ns then return end
local L = ns.L

ns.DisplayUtils = {}

local MAX_CACHE_SIZE = 100
local textureCache = {}
local cacheCount = 0

function ns.DisplayUtils.GetCachedTexture(spellId)
    if not spellId then return nil end
    local tex = textureCache[spellId]
    if tex then
        return tex
    end

    tex = C_Spell.GetSpellTexture(spellId)
    if tex then
        if cacheCount >= MAX_CACHE_SIZE then
            local cleared = 0
            for k in pairs(textureCache) do
                textureCache[k] = nil
                cleared = cleared + 1
                if cleared >= MAX_CACHE_SIZE / 2 then break end
            end
            cacheCount = cacheCount - cleared
        end
        textureCache[spellId] = tex
        cacheCount = cacheCount + 1
    end
    return tex
end

function ns.DisplayUtils.CanReadAuras()
    local aura = C_UnitAuras.GetAuraDataByIndex("player", 1, "HELPFUL")
    if not aura then return true end
    if issecretvalue and issecretvalue(aura.spellId) then return false end
    local ok = pcall(function() return aura.spellId == 0 end)
    return ok
end

function ns.DisplayUtils.CanReadGroupAuras()
    if not ns.DisplayUtils.CanReadAuras() then return false end
    local groupSize = GetNumGroupMembers()
    if groupSize <= 1 then return true end
    local inRaid = IsInRaid()
    for i = 1, groupSize do
        local unit
        if inRaid then
            unit = "raid" .. i
        else
            unit = (i == 1) and "player" or ("party" .. (i - 1))
        end
        if unit ~= "player" and UnitExists(unit) then
            local aura = C_UnitAuras.GetAuraDataByIndex(unit, 1, "HELPFUL")
            if aura then
                if issecretvalue and issecretvalue(aura.spellId) then return false end
                local ok = pcall(function() return aura.spellId == 0 end)
                if not ok then return false end
            end
            return true
        end
    end
    return true
end

local playerGUID
function ns.DisplayUtils.SafeIsPlayer(unit)
    if not unit then return false end
    local result = UnitIsUnit(unit, "player")
    if issecretvalue and issecretvalue(result) then
        if not playerGUID then
            playerGUID = UnitGUID("player")
        end
        return UnitGUID(unit) == playerGUID
    end
    return result
end

ns.DisplayUtils.FRAME_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

function ns.DisplayUtils.MakeSlot(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(40, 40)
    f.border = f:CreateTexture(nil, "BACKGROUND")
    f.border:SetAllPoints()
    f.border:SetColorTexture(0, 0, 0, 1)
    f.tex = f:CreateTexture(nil, "ARTWORK")
    f.tex:SetPoint("TOPLEFT", 2, -2)
    f.tex:SetPoint("BOTTOMRIGHT", -2, 2)
    f.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.timer = f:CreateFontString(nil, "OVERLAY")
    f.timer:SetPoint("BOTTOM", 0, -14)
    f.timer:SetFont(ns.DefaultFontPath(), 11, "OUTLINE")
    f.lbl = f:CreateFontString(nil, "OVERLAY")
    f.lbl:SetPoint("TOP", 0, 12)
    f.lbl:SetFont(ns.DefaultFontPath(), 9, "OUTLINE")
    f.lbl:SetTextColor(0.7, 0.7, 0.7)
    return f
end

function ns.DisplayUtils.SetSlot(slot, label, data, fallbackIcon)
    slot.lbl:SetText(label)
    if not data then
        slot.tex:SetTexture(fallbackIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
        slot.tex:SetDesaturated(fallbackIcon ~= nil)
        slot.timer:SetText(L["COMMON_MISSING"])
        slot.timer:SetTextColor(1, 0.3, 0.3)
    elseif data.expiry == 0 then
        slot.tex:SetTexture(data.icon)
        slot.tex:SetDesaturated(false)
        slot.timer:SetText("")
        slot.timer:SetTextColor(1, 1, 1)
    else
        slot.tex:SetTexture(data.icon)
        slot.tex:SetDesaturated(false)
        local rem = data.expiry - GetTime()
        if rem > 0 then
            slot.timer:SetText(format("%d:%02d", rem / 60, rem % 60))
            slot.timer:SetTextColor(1, 1, 1)
        else
            slot.timer:SetText(L["COMMON_EXPIRED"])
            slot.timer:SetTextColor(1, 0.3, 0.3)
        end
    end
end

function ns.DisplayUtils.DisableEditModeSnap()
    if C_EditMode and C_EditMode.SetAccountSetting then
        C_EditMode.SetAccountSetting(22, 0)
    end
    if EditModeManagerFrame then
        local snapCheck = EditModeManagerFrame.EnableSnapCheckButton
        if snapCheck and snapCheck.Button and snapCheck.Button.SetChecked then
            snapCheck.Button:SetChecked(false)
        end
    end
end

function ns.DisplayUtils.SetFrameUnlocked(frame, unlocked, label)
    if unlocked then
        ns.DisplayUtils.DisableEditModeSnap()
        frame:SetBackdrop(ns.DisplayUtils.FRAME_BACKDROP)
        frame:SetBackdropColor(0, 0, 0, 0.5)
        frame:SetBackdropBorderColor(1, 0.66, 0, 0.8)
        if label and not frame.unlockLabel then
            frame.unlockLabel = frame:CreateFontString(nil, "OVERLAY")
            frame.unlockLabel:SetFont(ns.DefaultFontPath(), 10, "OUTLINE")
            frame.unlockLabel:SetPoint("CENTER")
            frame.unlockLabel:SetTextColor(1, 0.66, 0)
        end
        if frame.unlockLabel then
            local text = label or L["COMMON_DRAG_TO_MOVE"]
            text = text .. "\n" .. L["COMMON_RIGHT_CLICK_SETTINGS"]
            frame.unlockLabel:SetText(text)
            frame.unlockLabel:Show()
        end
    else
        frame:SetBackdrop(nil)
        if frame.unlockLabel then
            frame.unlockLabel:Hide()
        end
    end
end
