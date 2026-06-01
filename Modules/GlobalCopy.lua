local addonName, ns = ...

local W = ns.Widgets
local C = ns.COLORS

local function IsSecret(value)
    return issecretvalue and issecretvalue(value) or false
end

local function CanAccess(value)
    return not canaccessvalue or canaccessvalue(value)
end

local function CanAccessAll(...)
    return not canaccessallvalues or canaccessallvalues(...)
end

local copyFrame
local keyboardFrame

local function ShowCopyBox(title, text)
    if not text or text == "" then
        print(W.Colorize("NaowhQOL:", C.BLUE) .. " " .. W.Colorize("No copyable text found.", C.ERROR))
        return
    end

    if not copyFrame then
        local f = CreateFrame("Frame", "NaowhQOL_GlobalCopyFrame", UIParent, "BackdropTemplate")
        f:SetSize(520, 260)
        f:SetPoint("CENTER")
        f:SetFrameStrata("DIALOG")
        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)
        f:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]],
            edgeFile = [[Interface\Buttons\WHITE8x8]],
            edgeSize = 1,
        })
        f:SetBackdropColor(0.02, 0.02, 0.02, 0.98)
        f:SetBackdropBorderColor(0.01, 0.56, 0.91, 0.8)

        f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        f.title:SetPoint("TOPLEFT", 14, -12)

        local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -2, -2)

        local hint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hint:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -8)
        hint:SetText(W.Colorize("Ctrl+A, Ctrl+C to copy", C.GRAY))

        local box = CreateFrame("EditBox", nil, f, "BackdropTemplate")
        box:SetMultiLine(true)
        box:SetAutoFocus(false)
        box:SetFontObject("ChatFontNormal")
        box:SetTextInsets(8, 8, 8, 8)
        box:SetPoint("TOPLEFT", 14, -58)
        box:SetPoint("BOTTOMRIGHT", -14, 14)
        box:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]],
            edgeFile = [[Interface\Buttons\WHITE8x8]],
            edgeSize = 1,
        })
        box:SetBackdropColor(0, 0, 0, 0.9)
        box:SetBackdropBorderColor(0.01, 0.56, 0.91, 0.5)
        box:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
            f:Hide()
        end)
        box:SetScript("OnEditFocusGained", function(self)
            self:HighlightText()
        end)
        f.box = box
        copyFrame = f
    end

    copyFrame.title:SetText(W.Colorize(title or "Copy", C.ORANGE))
    copyFrame.box:SetText(text)
    copyFrame:Show()
    copyFrame.box:SetFocus()
    copyFrame.box:HighlightText()
end

local function FontStringsToText(iter)
    local lines = {}
    for fs in iter do
        local ok, shown = pcall(fs.IsVisible, fs)
        if ok and CanAccess(shown) and shown then
            local textOk, text = pcall(fs.GetText, fs)
            if textOk and CanAccess(text) and text and text ~= "" then
                lines[#lines + 1] = text
            end
        end
    end
    return lines[1] and table.concat(lines, "\n") or nil
end

local function ChildFrames(frame)
    return coroutine.wrap(function()
        local children = { frame:GetChildren() }
        for i = 1, #children do
            local child = children[i]
            coroutine.yield(child)
            for subChild in ChildFrames(child) do
                coroutine.yield(subChild)
            end
        end
    end)
end

local function FrameFontStrings(frame)
    return coroutine.wrap(function()
        local function YieldRegions(target)
            local regions = { target:GetRegions() }
            for i = 1, #regions do
                local region = regions[i]
                if region and region.GetText then
                    coroutine.yield(region)
                end
            end
        end
        YieldRegions(frame)
        for child in ChildFrames(frame) do
            YieldRegions(child)
        end
    end)
end

local function GetSpecificFrameText(frame)
    if not frame or not frame.GetRegions then return nil end
    local ok, text = pcall(function()
        return FontStringsToText(FrameFontStrings(frame))
    end)
    return ok and text or nil
end

local function IterateFrames()
    local frame
    return function()
        frame = EnumerateFrames(frame)
        return frame
    end
end

local function GetMouseoverText()
    local lines = {}
    for frame in IterateFrames() do
        if frame and frame.IsVisible and frame.GetRegions then
            local ok, useFrame = pcall(function()
                local shown = frame:IsVisible()
                local over = MouseIsOver(frame)
                local name = frame:GetName()
                if not CanAccessAll(shown, over, name) then return false end
                return shown and over and name ~= "WorldFrame"
            end)
            if ok and useFrame then
                local text = GetSpecificFrameText(frame)
                if text and text ~= "" then
                    lines[#lines + 1] = text
                end
            end
        end
    end
    return lines[1] and table.concat(lines, "\n") or nil
end

local function GetMouseFocusText()
    local frames = GetMouseFoci and GetMouseFoci() or { GetMouseFocus and GetMouseFocus() }
    local lines = {}
    for _, frame in ipairs(frames) do
        if frame and frame ~= WorldFrame then
            local text = GetSpecificFrameText(frame)
            if text and text ~= "" then
                lines[#lines + 1] = text
            end
        end
    end
    return lines[1] and table.concat(lines, "\n") or nil
end

local function CopySlash(msg)
    local db = NaowhQOL and NaowhQOL.globalCopy
    if not db or not db.enabled then return end
    if InCombatLockdown and InCombatLockdown() then return end
    msg = strtrim(msg or "")
    local text
    if msg ~= "" and _G[msg] then
        text = GetSpecificFrameText(_G[msg])
    else
        text = GetMouseFocusText() or GetMouseoverText()
    end
    ShowCopyBox(msg ~= "" and msg or "Global Copy", text)
end

local function ModifiersMatch(mod)
    mod = mod or "CTRL"
    if mod == "NONE" then return true end
    if mod == "CTRL" and IsControlKeyDown() then return true end
    if mod == "SHIFT" and IsShiftKeyDown() then return true end
    if mod == "ALT" and IsAltKeyDown() then return true end
    return false
end

local function IDFromGUID(guid)
    if not guid then return nil end
    return select(6, strsplit("-", guid))
end

local function ResolveSpellTooltip()
    local okSpell, spellName, spellID = pcall(GameTooltip.GetSpell, GameTooltip)
    if okSpell and CanAccessAll(spellName, spellID) and not IsSecret(spellID) and spellID then
        return spellName or "Spell", tostring(spellID)
    end
end

local function ResolveItemTooltip()
    local okItem, itemName, itemLink = pcall(GameTooltip.GetItem, GameTooltip)
    if okItem and CanAccessAll(itemName, itemLink) and itemLink and not IsSecret(itemLink) then
        local itemID = itemLink:match("item:(%d+)")
        if itemID then
            return itemName or "Item", itemID
        end
    end
end

local function ResolveUnitTooltip()
    local okUnit, unitName, unitToken = pcall(GameTooltip.GetUnit, GameTooltip)
    if okUnit and CanAccessAll(unitName, unitToken) then
        local unitGUID = unitToken and UnitGUID(unitToken)
        local npcID = IDFromGUID(unitGUID)
        if npcID then
            return unitName or "NPC", tostring(npcID)
        elseif unitName then
            return "Unit", unitName
        end
    end
end

local function ResolveTooltipData()
    if not GameTooltip.GetTooltipData then return nil end
    local okData, data = pcall(GameTooltip.GetTooltipData, GameTooltip)
    if not okData or not CanAccess(data) or not data or IsSecret(data) then return nil end
    if data.id and not IsSecret(data.id) then
        return data.type or "Tooltip", tostring(data.id)
    end
    if data.hyperlink and CanAccess(data.hyperlink) and not IsSecret(data.hyperlink) then
        local hyperlink = tostring(data.hyperlink)
        local id = hyperlink:match("spell:(%d+)") or hyperlink:match("item:(%d+)")
        if id then
            return "Tooltip", id
        end
    end
end

local tooltipResolvers = {
    ResolveSpellTooltip,
    ResolveItemTooltip,
    ResolveUnitTooltip,
    ResolveTooltipData,
}

local function TryTooltipID()
    if not GameTooltip or not GameTooltip:IsShown() then return nil end
    for _, resolver in ipairs(tooltipResolvers) do
        local title, text = resolver()
        if text then
            return title, text
        end
    end

    return nil
end

local function OnKeyDown(_, key)
    local db = NaowhQOL and NaowhQOL.globalCopy
    if not db or not db.enabled or not db.tooltipIds then return end
    if InCombatLockdown and InCombatLockdown() then return end
    if not ModifiersMatch(db.modifier) then return end
    if strupper(key or "") ~= strupper(db.key or "C") then return end
    local title, text = TryTooltipID()
    if text then
        ShowCopyBox(title, text)
    end
end

local function Refresh()
    local db = NaowhQOL and NaowhQOL.globalCopy
    if not db or not db.enabled then
        if keyboardFrame then keyboardFrame:EnableKeyboard(false) end
        return
    end

    if not keyboardFrame then
        keyboardFrame = CreateFrame("Frame", "NaowhQOL_GlobalCopyKeyboard")
        keyboardFrame:SetPropagateKeyboardInput(true)
        keyboardFrame:SetScript("OnKeyDown", OnKeyDown)
    end
    keyboardFrame:EnableKeyboard(true)
end

SLASH_NAOWHQOLCOPY1 = "/ncopy"
SLASH_NAOWHQOLCOPY2 = "/naocopy"
SLASH_NAOWHQOLCOPY3 = "/copy"
SlashCmdList["NAOWHQOLCOPY"] = CopySlash

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", Refresh)

ns.GlobalCopy = {
    Refresh = Refresh,
    ShowCopyBox = ShowCopyBox,
    CopySlash = CopySlash,
}
