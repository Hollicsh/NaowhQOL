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

-- LibCustomGlow for proc-style glow effects
local LCG = LibStub("LibCustomGlow-1.0")
local GLOW_KEY = "NaowhQOL_BuffDrop"

-- Helper to read icon size from report card settings
local function GetIconSize()
    local db = BWV2:GetDB()
    return db.reportCardIconSize or 32
end

-- Active alert cells: { key = cellFrame }
BuffDropAlert.activeCells = {}
BuffDropAlert.frame = nil

---------------------------------------------------------------------------
-- GLOW (LibCustomGlow proc glow)
---------------------------------------------------------------------------

local function StartGlow(cell)
    if cell._hasGlow then return end
    cell._hasGlow = true
    LCG.ProcGlow_Start(cell, { color = {0.95, 0.95, 0.32, 1}, key = GLOW_KEY, duration = 1, startAnim = false })
end

local function StopGlow(cell)
    if not cell._hasGlow then return end
    cell._hasGlow = false
    LCG.ProcGlow_Stop(cell, GLOW_KEY)
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
        cell.icon:SetAllPoints()
        cell:Show()
        return cell
    end

    -- Create new cell
    cell = CreateFrame("Button", nil, parent)
    cell:SetSize(iconSize, iconSize)

    local icon = cell:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
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
    cell._spellIDs = nil
    cell._isAlwaysOn = nil
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
            cell._spellIDs = data.spellIDs  -- store for always-on rebuff checks
            cell._isAlwaysOn = (key:sub(1, 11) == "raidAlways_")

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

            -- Tooltip - adjust text based on alert type
            cell:SetScript("OnEnter", function(self)
                self.closeBtn:Show()
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(self._alertName or "", 1, 1, 1)
                if self._isAlwaysOn then
                    GameTooltip:AddLine("You know this buff but it's not active!", 1, 0.4, 0.0)
                else
                    GameTooltip:AddLine("This buff has expired!", 1, 0.4, 0.0)
                end
                GameTooltip:AddLine("Right-click or click X to dismiss.", 0.6, 0.6, 0.6)
                GameTooltip:Show()
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
                    if tonumber(auraData.icon) == snap.iconCheck then
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

-- Check rebuffs only for alerts whose keys start with a given prefix.
-- Used for always-on raid buff alerts that track their own spellIDs.
function BuffDropAlert:CheckRebuffsForPrefix(prefix)
    local anyDismissed = false

    for key, cell in pairs(self.activeCells) do
        if key:sub(1, #prefix) == prefix then
            -- Always-on alerts store their spellIDs directly on the cell
            local spellIDs = cell._spellIDs
            if spellIDs then
                local isBack = false
                for _, spellID in ipairs(spellIDs) do
                    local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                    if aura then
                        isBack = true
                        break
                    end
                end
                if isBack then
                    self.activeCells[key] = nil
                    ReleaseCell(cell)
                    anyDismissed = true
                end
            end
        end
    end

    if anyDismissed then
        self:Relayout()
    end
end

-- Dismiss all alerts whose key starts with a given prefix.
function BuffDropAlert:DismissByPrefix(prefix)
    local anyDismissed = false

    for key, cell in pairs(self.activeCells) do
        if key:sub(1, #prefix) == prefix then
            self.activeCells[key] = nil
            ReleaseCell(cell)
            anyDismissed = true
        end
    end

    if anyDismissed then
        self:Relayout()
    end
end
