local _, ns = ...

-- BuffWatcherV2 Buff Drop Alert Module
-- Displays persistent icon alerts when tracked buffs expire after a scan.
-- Icons have a proc-style glow and persist until the buff is reapplied or dismissed.

local BuffDropAlert = {}
ns.BWV2BuffDropAlert = BuffDropAlert

local BWV2 = ns.BWV2
local L = ns.L

-- Layout
local ICON_SPACING = 6
local BORDER_SIZE = 2
local GLOW_PULSE_MIN = 0.45
local GLOW_PULSE_MAX = 1.0
local GLOW_PULSE_SPEED = 2.2   -- full cycles per second

-- Helper to read icon size from report card settings
local function GetIconSize()
    local db = BWV2:GetDB()
    return db.reportCardIconSize or 32
end

-- Active alert cells: { key = cellFrame }
BuffDropAlert.activeCells = {}
BuffDropAlert.frame = nil

---------------------------------------------------------------------------
-- GLOW ANIMATION (proc-style pulsing border)
---------------------------------------------------------------------------

local glowFrames = {}

local function StartGlow(cell)
    if cell._glowAG then
        cell._glowAG:Play()
        cell.glowOverlay:Show()
        return
    end

    -- Four edge textures forming a bright border that pulses
    local g = CreateFrame("Frame", nil, cell)
    g:SetAllPoints()
    g:SetFrameLevel(cell:GetFrameLevel() + 2)

    -- Overlay texture (fullscreen glow)
    local overlay = g:CreateTexture(nil, "OVERLAY")
    overlay:SetPoint("TOPLEFT", -4, 4)
    overlay:SetPoint("BOTTOMRIGHT", 4, -4)
    overlay:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
    overlay:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
    overlay:SetBlendMode("ADD")
    cell.glowOverlay = overlay

    -- Pulse animation
    local ag = overlay:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")
    local pulse = ag:CreateAnimation("Alpha")
    pulse:SetFromAlpha(GLOW_PULSE_MAX)
    pulse:SetToAlpha(GLOW_PULSE_MIN)
    pulse:SetDuration(1 / GLOW_PULSE_SPEED)
    pulse:SetSmoothing("IN_OUT")
    ag:Play()

    cell._glowAG = ag
    cell._glowFrame = g
    glowFrames[cell] = true
end

local function StopGlow(cell)
    if cell._glowAG then
        cell._glowAG:Stop()
    end
    if cell.glowOverlay then
        cell.glowOverlay:Hide()
    end
end

---------------------------------------------------------------------------
-- ICON CELL POOL
---------------------------------------------------------------------------

local cellPool = {}

local function AcquireCell(parent)
    local iconSize = GetIconSize()
    local cell = table.remove(cellPool)
    if cell then
        cell:SetParent(parent)
        cell:SetSize(iconSize, iconSize)
        cell.icon:ClearAllPoints()
        cell.icon:SetPoint("TOPLEFT", BORDER_SIZE, -BORDER_SIZE)
        cell.icon:SetPoint("BOTTOMRIGHT", -BORDER_SIZE, BORDER_SIZE)
        cell:Show()
        return cell
    end

    -- Create new cell
    cell = CreateFrame("Button", nil, parent, "BackdropTemplate")
    cell:SetSize(iconSize, iconSize)
    cell:SetBackdrop({
        edgeFile = [[Interface\Buttons\WHITE8x8]],
        edgeSize = BORDER_SIZE,
    })
    cell:SetBackdropBorderColor(0.9, 0.3, 0.1, 1)

    local icon = cell:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", BORDER_SIZE, -BORDER_SIZE)
    icon:SetPoint("BOTTOMRIGHT", -BORDER_SIZE, BORDER_SIZE)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    cell.icon = icon

    -- Close (dismiss) button per icon
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

    -- Show close button on cell hover
    -- Right-click on the icon itself to dismiss
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
        GameTooltip:AddLine("This buff has expired!", 1, 0.4, 0.0)
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
    table.insert(cellPool, cell)
end

---------------------------------------------------------------------------
-- CONTAINER FRAME
---------------------------------------------------------------------------

function BuffDropAlert:GetFrame()
    if self.frame then return self.frame end

    local db = BWV2:GetDB()

    local f = CreateFrame("Frame", "NaowhQOL_BuffDropAlert", UIParent, "BackdropTemplate")
    f:SetSize(10, 10)  -- resized dynamically
    f:SetPoint("TOP", UIParent, "TOP", 0, -180)
    f:SetFrameStrata("HIGH")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(false)  -- pass-through when no icons

    -- Restore saved position
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

---------------------------------------------------------------------------
-- PUBLIC API
---------------------------------------------------------------------------

-- Add one or more dropped-buff alerts.
-- droppedList: array of { name, icon, spellIDs, iconCheck, category }
function BuffDropAlert:AddAlerts(droppedList)
    if not droppedList or #droppedList == 0 then return end

    local parent = self:GetFrame()

    for _, data in ipairs(droppedList) do
        -- Build a unique key from the snapshot key stored in data
        local key = data.key or data.name
        if not self.activeCells[key] then
            local cell = AcquireCell(parent)
            cell._alertKey = key
            cell._alertName = data.name

            -- Icon
            if data.icon then
                cell.icon:SetTexture(data.icon)
            else
                cell.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
            cell.icon:SetDesaturated(true)
            cell.icon:SetVertexColor(1, 0.4, 0.3)

            -- Close button dismisses this specific alert
            cell.closeBtn:SetScript("OnClick", function()
                BuffDropAlert:DismissAlert(key)
            end)

            self.activeCells[key] = cell

            -- Start proc glow
            StartGlow(cell)
        end
    end

    self:Relayout()
end

-- Remove a single alert by key (dismissed or rebuffed)
function BuffDropAlert:DismissAlert(key)
    local cell = self.activeCells[key]
    if not cell then return end

    self.activeCells[key] = nil
    ReleaseCell(cell)

    self:Relayout()
end

-- Remove all alerts
function BuffDropAlert:DismissAll()
    for key, cell in pairs(self.activeCells) do
        ReleaseCell(cell)
    end
    wipe(self.activeCells)

    if self.frame then
        self.frame:Hide()
    end
end

-- Relayout icons horizontally
function BuffDropAlert:Relayout()
    local parent = self:GetFrame()

    -- Gather keys for deterministic ordering
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

    -- Enable dragging on the container
    parent:RegisterForDrag("LeftButton")
    parent:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    parent:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        if point then
            local db = BWV2:GetDB()
            db.buffDropPosition = { point = point, x = x, y = y }
        end
    end)

    local x = 0
    local iconSize = GetIconSize()
    for _, key in ipairs(keys) do
        local cell = self.activeCells[key]
        cell:ClearAllPoints()
        cell:SetSize(iconSize, iconSize)
        cell:SetPoint("TOPLEFT", parent, "TOPLEFT", x, 0)
        x = x + iconSize + ICON_SPACING
    end
end

-- Check if a specific buff key has been reapplied and auto-dismiss it.
-- Called from Core on UNIT_AURA; checks every active alert.
function BuffDropAlert:CheckRebuffs()
    local anyDismissed = false

    for key, cell in pairs(self.activeCells) do
        -- Look up snapshot data to know what spellIDs / iconCheck to test
        local snap = BWV2.buffSnapshot and BWV2.buffSnapshot[key]
        if snap then
            local isBack = false

            -- Spell-ID check
            if snap.spellIDs and #snap.spellIDs > 0 then
                for _, spellID in ipairs(snap.spellIDs) do
                    local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                    if aura then
                        isBack = true
                        break
                    end
                end
            end

            -- Icon-based check (food)
            if not isBack and snap.iconCheck then
                local idx = 1
                local auraData = C_UnitAuras.GetAuraDataByIndex("player", idx, "HELPFUL")
                while auraData do
                    if auraData.icon == snap.iconCheck then
                        isBack = true
                        break
                    end
                    idx = idx + 1
                    auraData = C_UnitAuras.GetAuraDataByIndex("player", idx, "HELPFUL")
                end
            end

            if isBack then
                self.activeCells[key] = nil
                ReleaseCell(cell)
                anyDismissed = true
            end
        end
    end

    if anyDismissed then
        self:Relayout()
    end
end

-- Check if any alerts are currently showing
function BuffDropAlert:HasAlerts()
    return next(self.activeCells) ~= nil
end
