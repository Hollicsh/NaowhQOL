local _, ns = ...

local ReportCard = {}
ns.BWV2ReportCard = ReportCard

local L = ns.L
local BWV2 = ns.BWV2
local Watchers = ns.BWV2Watchers

if not BWV2 then
    error("BuffWatcherV2: State module not loaded before ReportCard")
end
if not Watchers then
    error("BuffWatcherV2: Watchers module not loaded before ReportCard")
end

local DEFAULT_ICON_SIZE = 32
local ICON_SPACING = 14
local SECTION_SPACING = 12
local HEADER_HEIGHT = 24

local function GetIconSize()
    local db = BWV2:GetDB()
    return db.reportCardIconSize or DEFAULT_ICON_SIZE
end

local function GetRowHeight()
    return GetIconSize() + 18
end

local cellCounter = 0
local inCombat = InCombatLockdown()

local autoCloseTimer = nil
local FADE_DURATION = 1

local function GetAutoCloseDelay()
    local db = BWV2:GetDB()
    return db.reportCardAutoCloseDelay or 5
end

local function CancelAutoClose(frame)
    if autoCloseTimer then
        autoCloseTimer:Cancel()
        autoCloseTimer = nil
    end
    if frame then
        UIFrameFadeRemoveFrame(frame)
        frame:SetAlpha(1)
    end
end

local function AllChecksPassed()
    local results = BWV2.scanResults
    if not results then return true end

    for _, category in ipairs({"raidBuffs", "consumables", "inventory", "classBuffs"}) do
        local items = results[category]
        if items then
            for _, item in ipairs(items) do
                if not item.pass then
                    return false
                end
            end
        end
    end
    return true
end

local BACKDROP_COLOR = {0.08, 0.08, 0.08, 0.95}
local BACKDROP_BORDER_COLOR = {0.3, 0.3, 0.3, 1}
local PASS_BORDER_COLOR = {0.3, 0.8, 0.3, 1}
local FAIL_BORDER_COLOR = {0.8, 0.2, 0.2, 1}
local UNCONFIGURED_BORDER_COLOR = {0.9, 0.8, 0.2, 1}
local FAIL_ICON_TINT = {1, 0.3, 0.3}
local UNCONFIGURED_ICON_TINT = {1, 0.9, 0.4}
local PASS_TEXT_COLOR = {0.3, 1, 0.3}
local FAIL_TEXT_COLOR = {1, 0.3, 0.3}
local UNCONFIGURED_TEXT_COLOR = {0.9, 0.8, 0.2}
local EXPIRING_TEXT_COLOR = {1, 0.6, 0.2}
local HEADER_TEXT_COLOR = {1, 0.82, 0}

local cellPool = {}
local rowPool = {}
local headerPool = {}

ReportCard.activeCells = {}
ReportCard.activeRows = {}
ReportCard.activeHeaders = {}

local function GetCellWidth()
    return GetIconSize() + ICON_SPACING
end

local function AcquireCell(parent)
    local cell = table.remove(cellPool, #cellPool)
    local iconSize = GetIconSize()
    local rowHeight = GetRowHeight()
    local cellWidth = GetCellWidth()

    if cell then
        cell:SetParent(parent)
        cell:SetSize(cellWidth, rowHeight)
        cell.iconFrame:SetSize(iconSize, iconSize)
        cell.icon:SetSize(iconSize - 2, iconSize - 2)
        cell.text:SetWidth(cellWidth)
        cell:Show()
    else
        cellCounter = cellCounter + 1
        cell = CreateFrame("Button", "NaowhQOL_BWV2Cell" .. cellCounter, parent, "SecureActionButtonTemplate")
        cell:SetSize(cellWidth, rowHeight)
        cell:RegisterForClicks("AnyUp", "AnyDown")

        local iconFrame = CreateFrame("Frame", nil, cell, "BackdropTemplate")
        iconFrame:SetSize(iconSize, iconSize)
        iconFrame:SetPoint("TOP", (cellWidth - iconSize) / 2, 0)
        iconFrame:SetBackdrop({
            edgeFile = [[Interface\Buttons\WHITE8x8]],
            edgeSize = 1,
        })
        cell.iconFrame = iconFrame

        local icon = iconFrame:CreateTexture(nil, "ARTWORK")
        icon:SetSize(iconSize - 2, iconSize - 2)
        icon:SetPoint("CENTER")
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        cell.icon = icon

        local text = cell:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("TOP", iconFrame, "BOTTOM", 0, -2)
        text:SetWidth(cellWidth)
        text:SetJustifyH("CENTER")
        text:SetWordWrap(false)
        cell.text = text

        cell:EnableMouse(true)
    end
    return cell
end

local function ReleaseCell(cell)
    cell:Hide()
    cell:ClearAllPoints()
    cell:SetParent(nil)
    cell:SetScript("OnEnter", nil)
    cell:SetScript("OnLeave", nil)
    pcall(function()
        cell:SetAttribute("type", nil)
        cell:SetAttribute("spell", nil)
        cell:SetAttribute("unit", nil)
        cell:SetAttribute("macrotext1", nil)
    end)
    cell.cellData = nil
    cell.cellType = nil
    table.insert(cellPool, cell)
end

local function AcquireRow(parent)
    local row = table.remove(rowPool, #rowPool)
    if row then
        row:SetParent(parent)
        row:Show()
    else
        row = CreateFrame("Frame", nil, parent)
    end
    return row
end

local function ReleaseRow(row)
    row:Hide()
    row:ClearAllPoints()
    row:SetParent(nil)
    table.insert(rowPool, row)
end

local function AcquireHeader(parent)
    local header = table.remove(headerPool, #headerPool)
    if header then
        header:SetParent(parent)
        header:Show()
    else
        header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    end
    return header
end

local function ReleaseHeader(header)
    header:Hide()
    header:ClearAllPoints()
    table.insert(headerPool, header)
end

local function FormatDuration(seconds)
    if not seconds or seconds <= 0 then return "" end
    seconds = math.floor(seconds)
    if seconds >= 3600 then
        return string.format("%d:%02d", math.floor(seconds/3600), math.floor((seconds%3600)/60))
    else
        return string.format("%d:%02d", math.floor(seconds/60), seconds % 60)
    end
end

local function ConfigureClickAction(cell, data, cellType)
    if InCombatLockdown() then return end

    pcall(function()
        cell:SetAttribute("type", nil)
        cell:SetAttribute("spell", nil)
        cell:SetAttribute("unit", nil)
        cell:SetAttribute("macrotext1", nil)

        if cellType == "raid" and data.spellID then
            if ns.IsPlayerSpell(data.spellID) then
                cell:SetAttribute("type", "spell")
                cell:SetAttribute("spell", data.spellID)
                cell:SetAttribute("unit", "player")
            end
        elseif cellType == "consumable" and data.itemID then
            local itemName = C_Item.GetItemInfo(data.itemID)
            if itemName and C_Item.GetItemCount(data.itemID) > 0 then
                cell:SetAttribute("type", "macro")
                cell:SetAttribute("macrotext1", "/use " .. itemName)
            end
        elseif cellType == "classBuff" and data.spellID then
            if ns.IsPlayerSpell(data.spellID) then
                cell:SetAttribute("type", "spell")
                cell:SetAttribute("spell", data.spellID)
                cell:SetAttribute("unit", "player")
            end
        end
    end)
end

function ReportCard:RefreshClickActions()
    if InCombatLockdown() then return end
    for _, cell in ipairs(self.activeCells) do
        if cell.cellData and cell.cellType then
            ConfigureClickAction(cell, cell.cellData, cell.cellType)
        end
    end
end

local combatFrame = CreateFrame("Frame")
combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
        C_Timer.After(0.1, function()
            ReportCard:RefreshClickActions()
        end)
    end
end)

function ReportCard:CreateFrame()
    if self.frame then return self.frame end

    local db = BWV2:GetDB()

    local frame = CreateFrame("Frame", "NaowhQOL_BuffReportCard", UIParent, "BackdropTemplate")
    frame:SetSize(300, 250)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]],
        edgeFile = [[Interface\Buttons\WHITE8x8]],
        edgeSize = 2,
    })
    frame:SetBackdropColor(unpack(BACKDROP_COLOR))
    frame:SetBackdropBorderColor(unpack(BACKDROP_BORDER_COLOR))
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        local currentDB = BWV2:GetDB()
        if not currentDB.reportCardUnlock then return end
        CancelAutoClose(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        if point then
            local currentDB = BWV2:GetDB()
            currentDB.reportCardPosition = { point = point, x = x, y = y }
        end
        ReportCard:CheckAutoClose()
    end)
    frame:SetScript("OnEnter", function(self)
        CancelAutoClose(self)
    end)
    frame:SetScript("OnLeave", function()
        ReportCard:CheckAutoClose()
    end)
    frame:SetClampedToScreen(true)
    frame:Hide()

    frame:SetScale(db.reportCardScale or 1.0)

    local unlockText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    unlockText:SetPoint("BOTTOM", frame, "TOP", 0, 2)
    unlockText:SetText(L["COMMON_UNLOCK"] or "Unlock")
    unlockText:SetTextColor(1, 0.66, 0)
    unlockText:Hide()
    frame.unlockText = unlockText

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -8)
    title:SetText(L["BWV2_REPORT_TITLE"])
    frame.title = title

    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(16, 16)
    closeBtn:SetPoint("TOPRIGHT", -1, -1)
    local closeTex = closeBtn:CreateTexture(nil, "ARTWORK")
    closeTex:SetAllPoints()
    closeTex:SetTexture("Interface\\Buttons\\UI-StopButton")
    closeTex:SetVertexColor(1, 0.3, 0.3)
    closeBtn:SetScript("OnEnter", function(self)
        closeTex:SetVertexColor(1, 0.6, 0.6)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        closeTex:SetVertexColor(1, 0.3, 0.3)
    end)
    closeBtn:SetScript("OnClick", function()
        ReportCard:Hide()
    end)
    frame.closeBtn = closeBtn

    local dragOverlay = CreateFrame("Frame", nil, frame)
    dragOverlay:SetAllPoints()
    dragOverlay:SetFrameLevel(frame:GetFrameLevel() + 100)
    dragOverlay:EnableMouse(true)
    dragOverlay:RegisterForDrag("LeftButton")
    dragOverlay:SetScript("OnDragStart", function()
        CancelAutoClose(frame)
        frame:StartMoving()
    end)
    dragOverlay:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        local point, _, _, x, y = frame:GetPoint()
        if point then
            local currentDB = BWV2:GetDB()
            currentDB.reportCardPosition = { point = point, x = x, y = y }
        end
        ReportCard:CheckAutoClose()
    end)
    dragOverlay:SetScript("OnEnter", function()
        CancelAutoClose(frame)
    end)
    dragOverlay:SetScript("OnLeave", function()
        ReportCard:CheckAutoClose()
    end)
    dragOverlay:Hide()
    frame.dragOverlay = dragOverlay

    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 10, -32)
    content:SetPoint("BOTTOMRIGHT", -10, 10)
    frame.content = content

    if db.reportCardPosition then
        frame:ClearAllPoints()
        frame:SetPoint(db.reportCardPosition.point, UIParent, db.reportCardPosition.point,
            db.reportCardPosition.x, db.reportCardPosition.y)
    end

    self.frame = frame
    return frame
end

function ReportCard:ApplySettings()
    if not self.frame then return end

    local db = BWV2:GetDB()

    self.frame:SetScale(db.reportCardScale or 1.0)

    if db.reportCardUnlock then
        self.frame:SetBackdropBorderColor(1, 0.66, 0, 1)
        if self.frame.unlockText then
            self.frame.unlockText:Show()
        end
        if self.frame.dragOverlay then
            self.frame.dragOverlay:Show()
            self.frame.closeBtn:SetFrameLevel(self.frame.dragOverlay:GetFrameLevel() + 1)
        end
    else
        self.frame:SetBackdropBorderColor(unpack(BACKDROP_BORDER_COLOR))
        if self.frame.unlockText then
            self.frame.unlockText:Hide()
        end
        if self.frame.dragOverlay then
            self.frame.dragOverlay:Hide()
        end
    end
end

local function ConfigureCell(cell, data, cellType)
    local icon = cell.icon
    local iconFrame = cell.iconFrame
    local text = cell.text

    if data.icon then
        icon:SetTexture(data.icon)
    else
        icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end

    if data.unconfigured then
        icon:SetVertexColor(unpack(UNCONFIGURED_ICON_TINT))
        iconFrame:SetBackdropBorderColor(unpack(UNCONFIGURED_BORDER_COLOR))
    elseif not data.pass then
        icon:SetVertexColor(unpack(FAIL_ICON_TINT))
        iconFrame:SetBackdropBorderColor(unpack(FAIL_BORDER_COLOR))
    else
        icon:SetVertexColor(1, 1, 1)
        iconFrame:SetBackdropBorderColor(unpack(PASS_BORDER_COLOR))
    end

    if cellType == "raid" then
        text:SetText(data.covered .. "/" .. data.total)
        if not data.pass then
            text:SetTextColor(unpack(FAIL_TEXT_COLOR))
        else
            text:SetTextColor(unpack(PASS_TEXT_COLOR))
        end
    elseif cellType == "inventory" then
        text:SetText("x" .. data.count)
        if not data.pass then
            text:SetTextColor(unpack(FAIL_TEXT_COLOR))
        else
            text:SetTextColor(unpack(PASS_TEXT_COLOR))
        end
    elseif cellType == "consumable" then
        if data.unconfigured then
            text:SetText(L["BWV2_NO_ID"] or "No ID")
            text:SetTextColor(unpack(UNCONFIGURED_TEXT_COLOR))
        elseif not data.pass and data.remaining and data.remaining > 0 then
            text:SetText(FormatDuration(data.remaining))
            text:SetTextColor(unpack(EXPIRING_TEXT_COLOR))
        elseif data.pass then
            text:SetText("")
        else
            text:SetText(L["COMMON_MISSING"])
            text:SetTextColor(unpack(FAIL_TEXT_COLOR))
        end
    elseif cellType == "classBuff" then
        if data.pass then
            text:SetText("")
        else
            text:SetText(L["COMMON_MISSING"])
            text:SetTextColor(unpack(FAIL_TEXT_COLOR))
        end
    end

    cell:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(data.name, 1, 1, 1)
        if cellType == "raid" then
            GameTooltip:AddLine(data.covered .. " of " .. data.total .. " players covered", 0.8, 0.8, 0.8)
        elseif cellType == "inventory" then
            GameTooltip:AddLine("Count: " .. data.count, 0.8, 0.8, 0.8)
        elseif cellType == "consumable" and data.remaining and data.remaining > 0 then
            GameTooltip:AddLine("Expires in: " .. FormatDuration(data.remaining), unpack(EXPIRING_TEXT_COLOR))
        end
        if data.unconfigured then
            GameTooltip:AddLine(L["BWV2_NO_SPELL_ID_ADDED"] or "No spell ID added", unpack(UNCONFIGURED_TEXT_COLOR))
        elseif not data.pass then
            GameTooltip:AddLine("Missing!", unpack(FAIL_TEXT_COLOR))
        end
        GameTooltip:Show()
    end)
    cell:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function CreateSectionHeader(parent, text, yOffset, activeHeaders)
    local header = AcquireHeader(parent)
    header:SetPoint("TOPLEFT", 0, yOffset)
    header:SetText(text)
    header:SetTextColor(unpack(HEADER_TEXT_COLOR))
    activeHeaders[#activeHeaders + 1] = header
    return header
end

local function CreateIconRow(parent, items, cellType, yOffset, activeCells, activeRows)
    local row = AcquireRow(parent)
    row:SetPoint("TOPLEFT", 0, yOffset)
    row:SetSize(parent:GetWidth(), GetRowHeight())
    activeRows[#activeRows + 1] = row

    local xOffset = 0
    local cellWidth = GetCellWidth()
    for _, data in ipairs(items) do
        local cell = AcquireCell(row)
        ConfigureCell(cell, data, cellType)
        ConfigureClickAction(cell, data, cellType)
        cell.cellData = data
        cell.cellType = cellType
        cell:SetPoint("TOPLEFT", xOffset, 0)
        xOffset = xOffset + cellWidth
        activeCells[#activeCells + 1] = cell
    end

    return row, xOffset
end

function ReportCard:ClearContent()
    for _, cell in ipairs(self.activeCells) do
        ReleaseCell(cell)
    end
    wipe(self.activeCells)

    for _, row in ipairs(self.activeRows) do
        ReleaseRow(row)
    end
    wipe(self.activeRows)

    for _, header in ipairs(self.activeHeaders) do
        ReleaseHeader(header)
    end
    wipe(self.activeHeaders)
end

function ReportCard:Update()
    if not self.frame then
        self:CreateFrame()
    end

    self:ClearContent()

    local content = self.frame.content
    local yOffset = 0
    local maxWidth = 0

    local results = BWV2.scanResults
    if not results then
        self.frame.title:SetText(L["BWV2_REPORT_NO_DATA"])
        return
    end

    local db = BWV2:GetDB()
    local classicMode = db.classicDisplay

    if classicMode then
        self.frame:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]],
        })
        self.frame:SetBackdropColor(0, 0, 0, 0)
        self.frame.title:SetText("")
        if self.frame.closeBtn then
            self.frame.closeBtn:SetSize(16, 16)
            self.frame.closeBtn:ClearAllPoints()
            self.frame.closeBtn:SetPoint("TOPRIGHT", -1, -1)
            self.frame.closeBtn:Show()
        end

        content:ClearAllPoints()
        content:SetPoint("TOPLEFT", 5, -5)
        content:SetPoint("BOTTOMRIGHT", -5, 5)

        local failingItems = {}
        local cellTypes = {}

        local function AddFailing(items, cellType)
            if not items then return end
            for _, item in ipairs(items) do
                if not item.pass then
                    failingItems[#failingItems + 1] = item
                    cellTypes[#cellTypes + 1] = cellType
                end
            end
        end

        AddFailing(results.raidBuffs, "raid")
        AddFailing(results.consumables, "consumable")
        AddFailing(results.inventory, "inventory")
        AddFailing(results.classBuffs, "classBuff")

        if #failingItems > 0 then
            local row = AcquireRow(content)
            row:SetPoint("TOPLEFT", 0, 0)
            row:SetSize(content:GetWidth(), GetRowHeight())
            self.activeRows[#self.activeRows + 1] = row

            local xOffset = 0
            local cellWidth = GetCellWidth()
            for i, data in ipairs(failingItems) do
                local cell = AcquireCell(row)
                ConfigureCell(cell, data, cellTypes[i])
                ConfigureClickAction(cell, data, cellTypes[i])
                cell.cellData = data
                cell.cellType = cellTypes[i]
                cell:SetPoint("TOPLEFT", xOffset, 0)
                xOffset = xOffset + cellWidth
                self.activeCells[#self.activeCells + 1] = cell
            end
            maxWidth = xOffset
        end

        local frameWidth = math.max(50, maxWidth + 10 + 18)
        local frameHeight = GetRowHeight() + 10
        self.frame:SetSize(frameWidth, frameHeight)
    else
        self.frame:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]],
            edgeFile = [[Interface\Buttons\WHITE8x8]],
            edgeSize = 2,
        })
        self.frame:SetBackdropColor(unpack(BACKDROP_COLOR))
        self.frame:SetBackdropBorderColor(unpack(BACKDROP_BORDER_COLOR))
        self.frame.title:SetText(L["BWV2_REPORT_TITLE"])
        if self.frame.closeBtn then
            self.frame.closeBtn:SetSize(16, 16)
            self.frame.closeBtn:ClearAllPoints()
            self.frame.closeBtn:SetPoint("TOPRIGHT", -4, -4)
            self.frame.closeBtn:Show()
        end

        content:ClearAllPoints()
        content:SetPoint("TOPLEFT", 10, -32)
        content:SetPoint("BOTTOMRIGHT", -10, 10)

        local rowHeight = GetRowHeight()

        if results.raidBuffs and #results.raidBuffs > 0 then
            CreateSectionHeader(content, L["BWV2_SECTION_RAID"], yOffset, self.activeHeaders)
            yOffset = yOffset - HEADER_HEIGHT

            local row, rowWidth = CreateIconRow(content, results.raidBuffs, "raid", yOffset, self.activeCells, self.activeRows)
            maxWidth = math.max(maxWidth, rowWidth)
            yOffset = yOffset - rowHeight - SECTION_SPACING
        end

        if results.consumables and #results.consumables > 0 then
            CreateSectionHeader(content, L["BWV2_SECTION_CONSUMABLES"], yOffset, self.activeHeaders)
            yOffset = yOffset - HEADER_HEIGHT

            local row, rowWidth = CreateIconRow(content, results.consumables, "consumable", yOffset, self.activeCells, self.activeRows)
            maxWidth = math.max(maxWidth, rowWidth)
            yOffset = yOffset - rowHeight - SECTION_SPACING
        end

        if results.inventory and #results.inventory > 0 then
            CreateSectionHeader(content, L["BWV2_SECTION_INVENTORY"], yOffset, self.activeHeaders)
            yOffset = yOffset - HEADER_HEIGHT

            local row, rowWidth = CreateIconRow(content, results.inventory, "inventory", yOffset, self.activeCells, self.activeRows)
            maxWidth = math.max(maxWidth, rowWidth)
            yOffset = yOffset - rowHeight - SECTION_SPACING
        end

        if results.classBuffs and #results.classBuffs > 0 then
            CreateSectionHeader(content, L["BWV2_SECTION_CLASS"], yOffset, self.activeHeaders)
            yOffset = yOffset - HEADER_HEIGHT

            local row, rowWidth = CreateIconRow(content, results.classBuffs, "classBuff", yOffset, self.activeCells, self.activeRows)
            maxWidth = math.max(maxWidth, rowWidth)
            yOffset = yOffset - rowHeight - SECTION_SPACING
        end

        local contentHeight = math.abs(yOffset) + SECTION_SPACING
        local frameWidth = math.max(200, maxWidth + 30)
        local frameHeight = contentHeight + 45

        self.frame:SetSize(frameWidth, frameHeight)
    end

    self:CheckAutoClose()
end

function ReportCard:CheckAutoClose()
    if not self.frame or not self.frame:IsShown() then return end

    local db = BWV2:GetDB()
    if db and db.reportCardUnlock then
        CancelAutoClose(self.frame)
        return
    end

    local autoCloseDelay = GetAutoCloseDelay()

    if autoCloseDelay > 0 then
        if not autoCloseTimer then
            autoCloseTimer = C_Timer.NewTimer(autoCloseDelay, function()
                if self.frame and self.frame:IsShown() then
                    UIFrameFadeOut(self.frame, FADE_DURATION, 1, 0)
                    C_Timer.After(FADE_DURATION, function()
                        if self.frame and self.frame:GetAlpha() < 0.1 then
                            self:Hide()
                            self.frame:SetAlpha(1)
                        end
                    end)
                end
                autoCloseTimer = nil
            end)
        end
    else
        CancelAutoClose(self.frame)
    end
end

function ReportCard:Show()
    if not self.frame then
        self:CreateFrame()
    end
    self:ApplySettings()
    self:Update()
    self.frame:SetAlpha(1)
    self.frame:Show()

    self:CheckAutoClose()
end

function ReportCard:Hide()
    CancelAutoClose(self.frame)
    if self.frame then
        self.frame:Hide()
    end
    Watchers:RemoveAllWatchers()
end

function ReportCard:Toggle()
    if self.frame and self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

function ReportCard:IsShown()
    return self.frame and self.frame:IsShown()
end

function ReportCard:ShowPreview()
    BWV2.scanResults = {
        raidBuffs = {
            { key = "_preview_intellect", name = "Arcane Intellect", icon = 135932, pass = true, covered = 5, total = 5 },
            { key = "_preview_stamina", name = "Power Word: Fortitude", icon = 135987, pass = false, covered = 3, total = 5 },
        },
        consumables = {
            { key = "_preview_flask", name = "Flask", icon = 134830, pass = true },
            { key = "_preview_food", name = "Food", icon = 133565, pass = false, remaining = 0 },
        },
        inventory = {
            { key = "_preview_potion", name = "Health Potion", icon = 134830, pass = true, count = 5 },
        },
        classBuffs = {},
    }
    self:Show()
end
