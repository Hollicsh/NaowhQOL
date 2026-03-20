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

BuffDropAlert.activeCells = {}
BuffDropAlert.frame = nil

local function StartGlow(cell)
    if cell._hasGlow then return end
    cell._hasGlow = true
    local db = BWV2:GetDB()
    local r, g, b
    if db.buffDropGlowUseClassColor then
        local classColor = ns.Widgets.GetPlayerClassColor()
        r, g, b = classColor.r, classColor.g, classColor.b
    else
        r = db.buffDropGlowR or 0.95
        g = db.buffDropGlowG or 0.95
        b = db.buffDropGlowB or 0.32
    end
    LCG.ProcGlow_Start(cell, { color = {r, g, b, 1}, key = GLOW_KEY, duration = 1, startAnim = false })
end

local function StopGlow(cell)
    if not cell._hasGlow then return end
    cell._hasGlow = false
    LCG.ProcGlow_Stop(cell, GLOW_KEY)
end

local cellPool = {}

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
    cell._checkType = nil
    cell._enchantIDs = nil
    cell._minRequired = nil
    cell._isAlwaysOn = nil
    cell._isGroupCoverage = nil
    cell._expiryTime = nil
    cell._expiryAcc = nil
    cell:SetScript("OnUpdate", nil)
    if cell.durationText then
        cell.durationText:Hide()
        cell.durationText:SetText("")
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

function BuffDropAlert:AddAlerts(droppedList)
    if not droppedList or #droppedList == 0 then return end

    local parent = self:GetFrame()

    for _, data in ipairs(droppedList) do
        local key = data.key or data.name
        local isAlwaysOn = (key:sub(1, 11) == "raidAlways_") or (key:sub(1, 12) == "classAlways_")
            or (key:sub(1, 18) == "consumableAlways_") or (key:sub(1, 16) == "inventoryAlways_")
        local shouldAdd = true

        if isAlwaysOn then
            local baseKey = key:match("^raidAlways_(.+)$") or key:match("^classAlways_(.+)$")
                or key:match("^consumableAlways_(.+)$") or key:match("^inventoryAlways_(.+)$")
            if baseKey and self.activeCells[baseKey] then
                shouldAdd = false
            end
        else
            for _, prefix in ipairs({"raidAlways_", "classAlways_", "consumableAlways_", "inventoryAlways_"}) do
                local alwaysKey = prefix .. key
                if self.activeCells[alwaysKey] then
                    self:DismissAlert(alwaysKey)
                end
            end
        end

        if data.isGroupCoverage and self.activeCells[key] then
            local existingCell = self.activeCells[key]
            if existingCell.durationText and data.covered ~= nil and data.total ~= nil then
                existingCell.durationText:SetText(data.covered .. "/" .. data.total)
                existingCell.durationText:Show()
            end
            shouldAdd = false
        end

        if shouldAdd and not self.activeCells[key] then
            local cell = AcquireCell(parent)
            cell._alertKey = key
            cell._alertName = data.name
            cell._spellIDs = data.spellIDs
            cell._checkType = data.checkType
            cell._enchantIDs = data.enchantIDs
            cell._minRequired = data.minRequired
            cell._isAlwaysOn = isAlwaysOn
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
                cell.icon:SetVertexColor(1, 0.4, 0.3)
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
                elseif self._isAlwaysOn then
                    GameTooltip:AddLine("You know this buff but it's not active!", 1, 0.4, 0.0)
                else
                    GameTooltip:AddLine("This buff has expired!", 1, 0.4, 0.0)
                end
                GameTooltip:AddLine("Right-click or click X to dismiss.", 0.6, 0.6, 0.6)
                GameTooltip:Show()
            end)

            self.activeCells[key] = cell

            StartGlow(cell)

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
end

function BuffDropAlert:DismissAlert(key)
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
end

function BuffDropAlert:RefreshTextFont()
    local fontPath = GetDurationFontPath()
    local fontSize = GetDurationFontSize()
    for _, cell in pairs(self.activeCells) do
        if cell.durationText then
            cell.durationText:SetFont(fontPath, fontSize, "OUTLINE")
        end
    end
    for _, cell in ipairs(cellPool) do
        if cell.durationText then
            cell.durationText:SetFont(fontPath, fontSize, "OUTLINE")
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

function BuffDropAlert:CheckRebuffs()
    local anyDismissed = false

    for key, cell in pairs(self.activeCells) do
        local snap = BWV2.buffSnapshot and BWV2.buffSnapshot[key]
        if snap then
            local isBack = false

            if snap.spellIDs and #snap.spellIDs > 0 then
                for _, spellID in ipairs(snap.spellIDs) do
                    local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                    if aura then
                        isBack = true
                        break
                    end
                end
            end

            if not isBack and snap.iconCheck and not InCombatLockdown() then
                local idx = 1
                local auraData = C_UnitAuras.GetAuraDataByIndex("player", idx, "HELPFUL")
                while auraData do
                    local icon = auraData.icon
                    if not IsSecret(icon) and icon == snap.iconCheck then
                        isBack = true
                        break
                    end
                    idx = idx + 1
                    auraData = C_UnitAuras.GetAuraDataByIndex("player", idx, "HELPFUL")
                end
            end

            if not isBack and snap.checkType == "weaponEnchant" then
                local wOk, hasMain, _, _, mainID, hasOff, _, _, offID = pcall(GetWeaponEnchantInfo)
                if wOk then
                    if snap.enchantIDs and #snap.enchantIDs > 0 then
                        local count = 0
                        for _, eid in ipairs(snap.enchantIDs) do
                            if (hasMain and mainID == eid) or (hasOff and offID == eid) then
                                count = count + 1
                            end
                        end
                        local needed = (snap.minRequired == 0) and #snap.enchantIDs or (snap.minRequired or 1)
                        isBack = count >= needed
                    else
                        isBack = hasMain and true or false
                    end
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

function BuffDropAlert:HasAlerts()
    return next(self.activeCells) ~= nil
end

function BuffDropAlert:CheckRebuffsForPrefix(prefix)
    local anyDismissed = false

    for key, cell in pairs(self.activeCells) do
        if key:sub(1, #prefix) == prefix and not cell._isGroupCoverage then
            local isBack = false

            if cell._checkType == "weaponEnchant" and cell._enchantIDs then
                local wOk, hasMain, _, _, mainID, hasOff, _, _, offID = pcall(GetWeaponEnchantInfo)
                if wOk then
                    local count = 0
                    for _, eid in ipairs(cell._enchantIDs) do
                        if (hasMain and mainID == eid) or (hasOff and offID == eid) then
                            count = count + 1
                        end
                    end
                    local needed = (cell._minRequired == 0) and #cell._enchantIDs or (cell._minRequired or 1)
                    isBack = count >= needed
                end
            elseif cell._spellIDs then
                for _, spellID in ipairs(cell._spellIDs) do
                    local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                    if aura then
                        isBack = true
                        break
                    end
                end
                -- In combat, aura queries can return nil due to taint;
                -- trust the out-of-combat cache if it says the buff is active
                if not isBack and InCombatLockdown() then
                    local baseKey = key:match("^classAlways_(.+)$")
                    if baseKey and BWV2.classBuffSelfCache[baseKey] then
                        isBack = true
                    end
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
                cell.icon:SetVertexColor(1, 0.4, 0.3)

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
