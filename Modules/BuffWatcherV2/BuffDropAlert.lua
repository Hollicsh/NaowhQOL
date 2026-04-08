local _, ns = ...

local function IsSecret(v)
    return issecretvalue and issecretvalue(v) or false
end

local BuffDropAlert = {}
ns.BWV2BuffDropAlert = BuffDropAlert

local BWV2 = ns.BWV2
local L = ns.L

local ICON_SPACING = 6

local LCG = LibStub("LibCustomGlow-1.0")
local GLOW_KEY = "NaowhQOL_BuffDrop"

local function GetMissingTintColor()
    local db = BWV2:GetDB()
    if db.buffDropNoTint then
        return 1, 1, 1
    end
    return 1, 0.4, 0.3
end

local function FormatDuration(seconds)
    if not seconds or seconds <= 0 then return "" end
    seconds = math.floor(seconds)
    if seconds >= 3600 then
        return string.format("%dh%02dm", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60))
    else
        return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
    end
end

local function GetIconSize()
    local db = BWV2:GetDB()
    return db.buffDropIconSize or 32
end

local function GetDurationFontPath()
    return BWV2:GetBuffDropFont()
end

local function GetDurationFontSize()
    local db = BWV2:GetDB()
    return db.buffDropTextFontSize or 11
end

local function GetOverlayFontSize()
    local db = BWV2:GetDB()
    local base = db.buffDropTextFontSize or 11
    return math.max(8, base - 1)
end

BuffDropAlert.activeCells = {}
BuffDropAlert.frame = nil

local GLOW_TYPE_PIXEL = 1
local GLOW_TYPE_AUTOCAST = 2
local GLOW_TYPE_BORDER = 3
local GLOW_TYPE_PROC = 4

local function GetGlowColor()
    local db = BWV2:GetDB()
    if db.buffDropGlowUseClassColor then
        local classColor = ns.Widgets.GetPlayerClassColor()
        return {classColor.r, classColor.g, classColor.b, 1}
    end
    return {db.buffDropGlowR or 0.95, db.buffDropGlowG or 0.95, db.buffDropGlowB or 0.32, 1}
end

local function StartGlow(cell)
    if cell._hasGlow then return end
    cell._hasGlow = true
    local db = BWV2:GetDB()
    local glowType = db.buffDropGlowType or GLOW_TYPE_PROC
    local color = GetGlowColor()

    if glowType == GLOW_TYPE_PIXEL then
        LCG.PixelGlow_Start(cell, color,
            db.buffDropGlowPixelLines or 8,
            db.buffDropGlowPixelFrequency or 0.25,
            db.buffDropGlowPixelLength or 4,
            nil, 0, 0, nil, GLOW_KEY)
    elseif glowType == GLOW_TYPE_AUTOCAST then
        LCG.AutoCastGlow_Start(cell, color,
            db.buffDropGlowAutocastParticles or 4,
            db.buffDropGlowAutocastFrequency or 0.125,
            db.buffDropGlowAutocastScale or 1.0,
            0, 0, GLOW_KEY)
    elseif glowType == GLOW_TYPE_BORDER then
        LCG.ButtonGlow_Start(cell, color,
            db.buffDropGlowBorderFrequency or 0.125)
    else
        LCG.ProcGlow_Start(cell, {
            color = color,
            key = GLOW_KEY,
            duration = db.buffDropGlowProcDuration or 1,
            startAnim = db.buffDropGlowProcStartAnim or false,
        })
    end
end

local function StopGlow(cell)
    if not cell._hasGlow then return end
    cell._hasGlow = false
    LCG.PixelGlow_Stop(cell, GLOW_KEY)
    LCG.AutoCastGlow_Stop(cell, GLOW_KEY)
    pcall(LCG.ButtonGlow_Stop, cell)
    LCG.ProcGlow_Stop(cell, GLOW_KEY)
end

local cellPool = {}

local raidTextFrame = nil
local raidTextLabels = {}
local RAID_TEXT_PADDING = 6
local RAID_TEXT_LINE_SPACING = 3

local function AcquireCell(parent)
    local iconSize = GetIconSize()
    local cell = table.remove(cellPool)
    if cell then
        cell:SetParent(parent)
        cell:SetSize(iconSize, iconSize)
        cell.icon:ClearAllPoints()
        cell.icon:SetAllPoints()
        if cell.durationText then
            cell.durationText:SetFont(GetDurationFontPath(), GetDurationFontSize(), "OUTLINE")
            cell.durationText:Hide()
            cell.durationText:SetText("")
        end
        if cell.overlayText then
            cell.overlayText:SetFont(GetDurationFontPath(), GetOverlayFontSize(), "OUTLINE")
            cell.overlayText:Hide()
            cell.overlayText:SetText("")
        end
        cell:Show()
        return cell
    end

    cell = CreateFrame("Button", nil, parent)
    cell:SetSize(iconSize, iconSize)

    local icon = cell:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local iconMask = cell:CreateMaskTexture()
    iconMask:SetAllPoints(icon)
    iconMask:SetTexture("Interface\\AddOns\\NaowhQOL\\Assets\\Textures\\RoundedMask.tga")
    icon:AddMaskTexture(iconMask)
    cell.icon = icon

    local durationText = cell:CreateFontString(nil, "OVERLAY")
    durationText:SetFont(GetDurationFontPath(), GetDurationFontSize(), "OUTLINE")
    durationText:SetPoint("CENTER", icon, "CENTER", 0, 0)
    durationText:SetJustifyH("CENTER")
    durationText:SetShadowOffset(1, -1)
    durationText:Hide()
    cell.durationText = durationText

    local overlayLabel = cell:CreateFontString(nil, "OVERLAY")
    overlayLabel:SetFont(GetDurationFontPath(), GetOverlayFontSize(), "OUTLINE")
    overlayLabel:SetPoint("CENTER", icon, "CENTER", 0, 0)
    overlayLabel:SetJustifyH("CENTER")
    overlayLabel:SetShadowOffset(1, -1)
    overlayLabel:SetTextColor(1, 1, 1)
    overlayLabel:Hide()
    cell.overlayText = overlayLabel

    local close = CreateFrame("Button", nil, cell)
    close:SetSize(14, 14)
    close:SetPoint("TOPRIGHT", 4, 4)
    close:SetFrameLevel(cell:GetFrameLevel() + 5)
    local closeTex = close:CreateTexture(nil, "ARTWORK")
    closeTex:SetAllPoints()
    closeTex:SetTexture("Interface\\Buttons\\UI-StopButton")
    closeTex:SetVertexColor(1, 0.3, 0.3)
    close:SetScript("OnEnter", function() closeTex:SetVertexColor(1, 0.6, 0.6) end)
    close:SetScript("OnLeave", function() closeTex:SetVertexColor(1, 0.3, 0.3) end)
    close:Hide()
    cell.closeBtn = close

    cell:RegisterForClicks("AnyUp")
    cell:SetScript("OnClick", function(self, button)
        if button == "RightButton" and self._alertKey then
            BuffDropAlert:DismissAlert(self._alertKey)
        end
    end)

    cell:SetScript("OnEnter", function(self)
        self.closeBtn:Show()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(self._alertName or "", 1, 1, 1)
        if self._isGroupCoverage then
            GameTooltip:AddLine("Not all group members are buffed!", 1, 0.6, 0.0)
        elseif self._checkType == "inventory" then
            GameTooltip:AddLine("You are out of these!", 1, 0.4, 0.0)
        else
            GameTooltip:AddLine("This buff is missing or expired!", 1, 0.4, 0.0)
        end
        GameTooltip:AddLine("Right-click or click X to dismiss.", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    cell:SetScript("OnLeave", function(self)
        self.closeBtn:Hide()
        GameTooltip:Hide()
    end)

    cell:EnableMouse(true)
    return cell
end

local function ReleaseCell(cell)
    StopGlow(cell)
    cell:Hide()
    cell:ClearAllPoints()
    cell:SetParent(nil)
    cell.closeBtn:SetScript("OnClick", nil)
    cell._alertKey = nil
    cell._alertName = nil
    cell._spellIDs = nil
    cell._checkType = nil
    cell._enchantIDs = nil
    cell._minRequired = nil
    cell._isGroupCoverage = nil
    cell._expiryTime = nil
    cell._expiryAcc = nil
    cell:SetScript("OnUpdate", nil)
    if cell.durationText then
        cell.durationText:Hide()
        cell.durationText:SetText("")
    end
    if cell.overlayText then
        cell.overlayText:Hide()
        cell.overlayText:SetText("")
    end
    table.insert(cellPool, cell)
end

function BuffDropAlert:GetFrame()
    if self.frame then return self.frame end

    local db = BWV2:GetDB()

    local f = CreateFrame("Frame", "NaowhQOL_BuffDropAlert", UIParent, "BackdropTemplate")
    f:SetSize(10, 10)
    f:SetPoint("TOP", UIParent, "TOP", 0, -180)
    f:SetFrameStrata("HIGH")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(false)

    f:SetScale(db.buffDropScale or 1.0)

    local unlockText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    unlockText:SetPoint("BOTTOM", f, "TOP", 0, 2)
    unlockText:SetText("Buff Drop Alert")
    unlockText:SetTextColor(1, 0.66, 0)
    unlockText:Hide()
    f.unlockText = unlockText

    local dragOverlay = CreateFrame("Frame", nil, f)
    dragOverlay:SetAllPoints()
    dragOverlay:SetFrameLevel(f:GetFrameLevel() + 100)
    dragOverlay:EnableMouse(true)
    dragOverlay:RegisterForDrag("LeftButton")
    dragOverlay:SetScript("OnDragStart", function()
        f:StartMoving()
    end)
    dragOverlay:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
        local point, _, _, x, y = f:GetPoint()
        if point then
            local currentDB = BWV2:GetDB()
            currentDB.buffDropPosition = { point = point, x = x, y = y }
        end
    end)
    dragOverlay:Hide()
    f.dragOverlay = dragOverlay

    if db.buffDropPosition then
        f:ClearAllPoints()
        f:SetPoint(
            db.buffDropPosition.point,
            UIParent,
            db.buffDropPosition.point,
            db.buffDropPosition.x,
            db.buffDropPosition.y
        )
    end

    f:Hide()
    self.frame = f
    return f
end

function BuffDropAlert:SyncFromState()
    local alerts = BWV2.activeAlerts
    local parent = self:GetFrame()
    local db = BWV2:GetDB()

    if self._previewMode then
        self:SyncRaidTextFrame()
        return
    end

    local newKeys = {}
    for key, data in pairs(alerts) do
        if not BWV2:IsAlertDismissed(key) then
            if not (db.buffDropRaidTextOnly and data.category == "raidBuff") then
                newKeys[key] = data
            end
        end
    end

    for key, cell in pairs(self.activeCells) do
        if not newKeys[key] then
            self.activeCells[key] = nil
            ReleaseCell(cell)
        end
    end

    for key, data in pairs(newKeys) do
        local cell = self.activeCells[key]
        if cell then
            if data.isGroupCoverage and cell.durationText and data.covered ~= nil and data.total ~= nil then
                cell.durationText:SetText(data.covered .. "/" .. data.total)
                cell.durationText:Show()
            elseif not data.isGroupCoverage then
                if data.expiryTime then
                    cell.icon:SetDesaturated(false)
                    cell.icon:SetVertexColor(1, 1, 1)
                else
                    cell.icon:SetDesaturated(true)
                    local tr, tg, tb = GetMissingTintColor()
                    cell.icon:SetVertexColor(tr, tg, tb)
                end
            end
        else
            cell = AcquireCell(parent)
            cell._alertKey = key
            cell._alertName = data.name
            cell._spellIDs = data.spellIDs
            cell._checkType = data.checkType
            cell._enchantIDs = data.enchantIDs
            cell._minRequired = data.minRequired
            cell._isGroupCoverage = data.isGroupCoverage

            if data.icon then
                cell.icon:SetTexture(data.icon)
            else
                cell.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end

            if data.isGroupCoverage then
                cell.icon:SetDesaturated(false)
                cell.icon:SetVertexColor(1, 0.75, 0.25)
            elseif data.expiryTime then
                cell.icon:SetDesaturated(false)
                cell.icon:SetVertexColor(1, 1, 1)
            else
                cell.icon:SetDesaturated(true)
                local tr, tg, tb = GetMissingTintColor()
                cell.icon:SetVertexColor(tr, tg, tb)
            end

            cell.closeBtn:SetScript("OnClick", function()
                BuffDropAlert:DismissAlert(key)
            end)

            cell:SetScript("OnEnter", function(self)
                self.closeBtn:Show()
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(self._alertName or "", 1, 1, 1)
                if self._isGroupCoverage then
                    GameTooltip:AddLine("Not all group members are buffed!", 1, 0.6, 0.0)
                elseif self._checkType == "inventory" then
                    GameTooltip:AddLine("You are out of these!", 1, 0.4, 0.0)
                else
                    GameTooltip:AddLine("This buff is missing or expired!", 1, 0.4, 0.0)
                end
                GameTooltip:AddLine("Right-click or click X to dismiss.", 0.6, 0.6, 0.6)
                GameTooltip:Show()
            end)

            self.activeCells[key] = cell
            StartGlow(cell)

            if data.overlayText and cell.overlayText then
                cell.overlayText:SetText(data.overlayText)
                cell.overlayText:Show()
            end

            if data.isGroupCoverage and data.covered ~= nil and data.total ~= nil then
                if cell.durationText then
                    cell.durationText:SetText(data.covered .. "/" .. data.total)
                    cell.durationText:Show()
                end
            elseif data.expiryTime and data.expiryTime > GetTime() then
                cell._expiryTime = data.expiryTime
                cell._expiryAcc = 0
                local remaining = data.expiryTime - GetTime()
                if cell.durationText and remaining > 0 then
                    cell.durationText:SetText(FormatDuration(remaining))
                    cell.durationText:Show()
                end
                cell:SetScript("OnUpdate", function(self, elapsed)
                    self._expiryAcc = (self._expiryAcc or 0) + elapsed
                    if self._expiryAcc < 1 then return end
                    self._expiryAcc = 0
                    local rem = (self._expiryTime or 0) - GetTime()
                    if rem <= 0 then
                        self._expiryTime = nil
                        if self.durationText then self.durationText:Hide() end
                        self:SetScript("OnUpdate", nil)
                        self.icon:SetDesaturated(true)
                        local tr, tg, tb = GetMissingTintColor()
                        self.icon:SetVertexColor(tr, tg, tb)
                    else
                        if self.durationText then
                            self.durationText:SetText(FormatDuration(rem))
                            self.durationText:Show()
                        end
                    end
                end)
            end
        end
    end

    self:Relayout()
    self:SyncRaidTextFrame()
end

function BuffDropAlert:DismissAlert(key)
    BWV2:DismissAlert(key)

    local cell = self.activeCells[key]
    if not cell then return end

    self.activeCells[key] = nil
    ReleaseCell(cell)

    self:Relayout()
end

function BuffDropAlert:DismissAll()
    for key, cell in pairs(self.activeCells) do
        ReleaseCell(cell)
    end
    wipe(self.activeCells)

    if self.frame then
        self.frame:Hide()
    end

    if raidTextFrame then
        raidTextFrame:Hide()
    end
end

function BuffDropAlert:DismissNonCombatSafe()
    local anyDismissed = false
    for key, cell in pairs(self.activeCells) do
        local isSafe = false
        if cell._spellIDs then
            isSafe = BWV2:HasCombatSafeSpell(cell._spellIDs)
        end
        if cell._checkType == "weaponEnchant" then
            isSafe = true
        end
        if cell._checkType == "inventory" then
            isSafe = true
        end
        if not isSafe then
            self.activeCells[key] = nil
            ReleaseCell(cell)
            anyDismissed = true
        end
    end
    if anyDismissed then
        self:Relayout()
    end
end

function BuffDropAlert:HasAlerts()
    return next(self.activeCells) ~= nil
end

function BuffDropAlert:RefreshTextFont()
    local fontPath = GetDurationFontPath()
    local fontSize = GetDurationFontSize()
    local overlaySize = GetOverlayFontSize()
    for _, cell in pairs(self.activeCells) do
        if cell.durationText then
            cell.durationText:SetFont(fontPath, fontSize, "OUTLINE")
        end
        if cell.overlayText then
            cell.overlayText:SetFont(fontPath, overlaySize, "OUTLINE")
        end
    end
    for _, cell in ipairs(cellPool) do
        if cell.durationText then
            cell.durationText:SetFont(fontPath, fontSize, "OUTLINE")
        end
        if cell.overlayText then
            cell.overlayText:SetFont(fontPath, overlaySize, "OUTLINE")
        end
    end
end

function BuffDropAlert:Relayout()
    local parent = self:GetFrame()

    local keys = {}
    for key in pairs(self.activeCells) do
        keys[#keys + 1] = key
    end
    table.sort(keys)

    if #keys == 0 then
        parent:Hide()
        parent:EnableMouse(false)
        return
    end

    local iconSize = GetIconSize()
    local totalWidth = #keys * iconSize + (#keys - 1) * ICON_SPACING
    parent:SetSize(totalWidth, iconSize)
    parent:EnableMouse(true)
    parent:Show()

    local db = BWV2:GetDB()
    parent:SetScale(db.buffDropScale or 1.0)

    parent:RegisterForDrag("LeftButton")
    parent:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    parent:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        if point then
            local cdb = BWV2:GetDB()
            cdb.buffDropPosition = { point = point, x = x, y = y }
        end
    end)

    local x = 0
    for _, key in ipairs(keys) do
        local cell = self.activeCells[key]
        cell:ClearAllPoints()
        cell:SetSize(iconSize, iconSize)
        cell:SetPoint("TOPLEFT", parent, "TOPLEFT", x, 0)
        x = x + iconSize + ICON_SPACING
    end
end

function BuffDropAlert:ShowPreview()
    local parent = self:GetFrame()
    local db = BWV2:GetDB()

    if not self._previewMode then
        self._previewMode = true
        self._previewKeys = {}

        local previewData = {
            { key = "_preview_1", name = "Preview Buff 1", icon = 135932 },
            { key = "_preview_2", name = "Preview Buff 2", icon = 135987 },
            { key = "_preview_3", name = "Preview Buff 3", icon = 134830 },
        }

        for _, data in ipairs(previewData) do
            if not self.activeCells[data.key] then
                local cell = AcquireCell(parent)
                cell._alertKey = data.key
                cell._alertName = data.name

                cell.icon:SetTexture(data.icon)
                cell.icon:SetDesaturated(true)
                local tr, tg, tb = GetMissingTintColor()
                cell.icon:SetVertexColor(tr, tg, tb)

                cell.closeBtn:SetScript("OnClick", function()
                    BuffDropAlert:DismissAlert(data.key)
                end)

                self.activeCells[data.key] = cell
                self._previewKeys[#self._previewKeys + 1] = data.key

                StartGlow(cell)
            end
        end
    end

    parent:SetScale(db.buffDropScale or 1.0)

    if parent.unlockText then
        parent.unlockText:Show()
    end
    if parent.dragOverlay then
        parent.dragOverlay:Show()
    end

    self:SyncRaidTextFrame()
    self:Relayout()
end

function BuffDropAlert:HidePreview()
    if self._previewMode and self._previewKeys then
        for _, key in ipairs(self._previewKeys) do
            local cell = self.activeCells[key]
            if cell then
                self.activeCells[key] = nil
                ReleaseCell(cell)
            end
        end
        self._previewKeys = nil
        self._previewMode = false
    end

    if self.frame then
        if self.frame.unlockText then
            self.frame.unlockText:Hide()
        end
        if self.frame.dragOverlay then
            self.frame.dragOverlay:Hide()
        end
    end

    if raidTextFrame then
        if raidTextFrame.unlockText then
            raidTextFrame.unlockText:Hide()
        end
        if raidTextFrame.dragOverlay then
            raidTextFrame.dragOverlay:Hide()
        end
    end

    self:Relayout()
end

function BuffDropAlert:RefreshGlowColor()
    for _, cell in pairs(self.activeCells) do
        if cell._hasGlow then
            StopGlow(cell)
            StartGlow(cell)
        end
    end
end

function BuffDropAlert:RefreshIconTint()
    local tr, tg, tb = GetMissingTintColor()
    for _, cell in pairs(self.activeCells) do
        if not cell._isGroupCoverage and cell.icon:IsDesaturated() then
            cell.icon:SetVertexColor(tr, tg, tb)
        end
    end
end

function BuffDropAlert:GetRaidTextFrame()
    if raidTextFrame then return raidTextFrame end

    local db = BWV2:GetDB()

    local f = CreateFrame("Frame", "NaowhQOL_BuffDropRaidText", UIParent, "BackdropTemplate")
    f:SetSize(150, 20)
    f:SetPoint("TOP", UIParent, "TOP", 200, -180)
    f:SetFrameStrata("HIGH")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(false)
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(0, 0, 0, 0)

    local unlockText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    unlockText:SetPoint("BOTTOM", f, "TOP", 0, 2)
    unlockText:SetText(L["BWV2_RAID_TEXT_ANCHOR"])
    unlockText:SetTextColor(1, 0.66, 0)
    unlockText:Hide()
    f.unlockText = unlockText

    local dragOverlay = CreateFrame("Frame", nil, f)
    dragOverlay:SetAllPoints()
    dragOverlay:SetFrameLevel(f:GetFrameLevel() + 100)
    dragOverlay:EnableMouse(true)
    dragOverlay:RegisterForDrag("LeftButton")
    dragOverlay:SetScript("OnDragStart", function()
        f:StartMoving()
    end)
    dragOverlay:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
        local point, _, _, x, y = f:GetPoint()
        if point then
            local cdb = BWV2:GetDB()
            cdb.buffDropRaidTextPosition = { point = point, x = x, y = y }
        end
    end)
    dragOverlay:Hide()
    f.dragOverlay = dragOverlay

    if db.buffDropRaidTextPosition then
        f:ClearAllPoints()
        f:SetPoint(
            db.buffDropRaidTextPosition.point,
            UIParent,
            db.buffDropRaidTextPosition.point,
            db.buffDropRaidTextPosition.x,
            db.buffDropRaidTextPosition.y
        )
    end

    f:Hide()
    raidTextFrame = f
    return f
end

local function GetRaidTextColor()
    local db = BWV2:GetDB()
    if db.buffDropRaidTextUseClassColor then
        local cc = ns.Widgets.GetPlayerClassColor()
        return cc.r, cc.g, cc.b
    end
    return db.buffDropRaidTextR or 1, db.buffDropRaidTextG or 0.8, db.buffDropRaidTextB or 0.35
end

local function GetRaidTextFontPath()
    local db = BWV2:GetDB()
    if db.buffDropRaidTextFont then return db.buffDropRaidTextFont end
    return BWV2:GetBuffDropFont()
end

local function GetRaidTextFontSize()
    local db = BWV2:GetDB()
    return db.buffDropRaidTextFontSize or 14
end

function BuffDropAlert:SyncRaidTextFrame()
    local db = BWV2:GetDB()

    if not db.buffDropRaidTextOnly then
        if raidTextFrame then raidTextFrame:Hide() end
        return
    end

    local parent = self:GetRaidTextFrame()

    local names = {}

    local missingPrefix = L["BWV2_BUFF_DROP_MISSING"] .. " "
    if self._previewMode then
        names = { missingPrefix .. "Arcane Intellect", missingPrefix .. "Mark of the Wild" }
    else
        local alerts = BWV2.activeAlerts
        for key, data in pairs(alerts) do
            if data.category == "raidBuff" and not BWV2:IsAlertDismissed(key) then
                names[#names + 1] = missingPrefix .. data.name
            end
        end
        table.sort(names)
    end

    for i = #names + 1, #raidTextLabels do
        raidTextLabels[i]:Hide()
        raidTextLabels[i]:SetText("")
    end

    if #names == 0 and not self._previewMode then
        parent:Hide()
        parent:EnableMouse(false)
        return
    end

    local fontPath = GetRaidTextFontPath()
    local fontSize = GetRaidTextFontSize()
    local lineH = fontSize + RAID_TEXT_LINE_SPACING
    local tr, tg, tb = GetRaidTextColor()

    local maxWidth = 0
    for i, name in ipairs(names) do
        local label = raidTextLabels[i]
        if not label then
            label = parent:CreateFontString(nil, "OVERLAY")
            raidTextLabels[i] = label
        end
        label:SetFont(fontPath, fontSize, "OUTLINE")
        label:SetText(name)
        label:SetShadowOffset(1, -1)
        label:SetTextColor(tr, tg, tb)
        label:ClearAllPoints()
        label:SetPoint("TOPLEFT", parent, "TOPLEFT", RAID_TEXT_PADDING, -(RAID_TEXT_PADDING + (i - 1) * lineH))
        label:Show()
        local w = label:GetStringWidth()
        if w > maxWidth then maxWidth = w end
    end

    local frameW = math.max(80, maxWidth + RAID_TEXT_PADDING * 2)
    local frameH = #names * lineH + RAID_TEXT_PADDING * 2
    parent:SetSize(frameW, frameH)
    parent:SetScale(db.buffDropScale or 1.0)
    parent:EnableMouse(true)
    parent:Show()

    if self._previewMode then
        parent:SetBackdropColor(0, 0, 0, 0.55)
        parent:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.9)
        if parent.unlockText then parent.unlockText:Show() end
        if parent.dragOverlay then parent.dragOverlay:Show() end
    else
        parent:SetBackdropColor(0, 0, 0, 0)
        parent:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

function BuffDropAlert:RefreshRaidTextColor()
    self:SyncRaidTextFrame()
end
