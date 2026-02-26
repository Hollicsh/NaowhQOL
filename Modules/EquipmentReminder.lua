local addonName, ns = ...

local COLORS = ns.COLORS

-- Equipment slots to display in the reminder frame
local EQUIPMENT_SLOTS = {
    { id = 13, name = "Trinket 1" },
    { id = 14, name = "Trinket 2" },
    { id = 16, name = "Main Hand" },
    { id = 17, name = "Off Hand" },
}

-- All equipment slots that can have enchants (for enchant checker)
local ENCHANTABLE_SLOTS = {
    { id = 1,  name = "Head" },
    { id = 2,  name = "Neck" },
    { id = 3,  name = "Shoulder" },
    { id = 5,  name = "Chest" },
    { id = 6,  name = "Waist" },
    { id = 7,  name = "Legs" },
    { id = 8,  name = "Feet" },
    { id = 9,  name = "Wrist" },
    { id = 10, name = "Hands" },
    { id = 11, name = "Ring 1" },
    { id = 12, name = "Ring 2" },
    { id = 15, name = "Back" },
    { id = 16, name = "Main Hand" },
    { id = 17, name = "Off Hand" },
}

-- Lookup table for slot names by ID
local SLOT_NAMES = {}
for _, slot in ipairs(ENCHANTABLE_SLOTS) do
    SLOT_NAMES[slot.id] = slot.name
end

local equipmentFrame = nil
local itemButtons = {}
local autoHideTimer = nil
local enchantStatusRow = nil

local function GetDB()
    return NaowhQOL.equipmentReminder
end

-- Debug: Print all info about an equipped slot
local function DebugSlotInfo(slotID)
    local link = GetInventoryItemLink("player", slotID)
    if not link then
        print("Slot " .. slotID .. ": No item equipped")
        return
    end

    print("=== Slot " .. slotID .. " Debug ===")
    print("Link: " .. link)

    -- Parse link data
    local linkData = link:match("item:([^|]+)")
    if linkData then
        print("Link data: " .. linkData)
        local fields = { strsplit(":", linkData) }
        for i, v in ipairs(fields) do
            if v ~= "" then
                print("  Field " .. i .. ": " .. v)
            end
        end
    end

    -- Try C_TooltipInfo
    if C_TooltipInfo and C_TooltipInfo.GetInventoryItem then
        local tooltipData = C_TooltipInfo.GetInventoryItem("player", slotID)
        if tooltipData and tooltipData.lines then
            print("Tooltip lines:")
            for i, line in ipairs(tooltipData.lines) do
                local typeStr = line.type and (" [type=" .. line.type .. "]") or ""
                local text = line.leftText or line.rightText or ""
                if text ~= "" then
                    print("  " .. i .. typeStr .. ": " .. text)
                end
                -- For type 15 (enchant), print ALL fields
                if line.type == 15 then
                    print("    === Type 15 fields ===")
                    for k, v in pairs(line) do
                        print("    " .. tostring(k) .. " = " .. tostring(v))
                    end
                end
            end
        end
    end
end

-- Get permanent enchant from tooltip data
local function GetPermanentEnchantFromTooltip(slotID)
    if not C_TooltipInfo or not C_TooltipInfo.GetInventoryItem then
        return nil, nil
    end

    local tooltipData = C_TooltipInfo.GetInventoryItem("player", slotID)
    if not tooltipData or not tooltipData.lines then
        return nil, nil
    end

    -- Look for ItemEnchantmentPermanent line (type 15)
    for _, line in ipairs(tooltipData.lines) do
        if line.type == 15 then  -- Enum.TooltipDataLineType.ItemEnchantmentPermanent
            return line.leftText, line.enchantID
        end
    end

    return nil, nil
end

-- Get enchant name from spell ID
local function GetEnchantName(enchantID)
    if not enchantID or enchantID == 0 then return nil end
    local info = C_Spell.GetSpellInfo(enchantID)
    return info and info.name or nil
end

-- Check all configured slots for enchant mismatches
local function CheckEnchantMismatches()
    local db = GetDB()
    if not db or not db.ecEnabled then
        return {}
    end

    local specRules
    if db.ecUseAllSpecs then
        -- Use shared rules (stored under key 0)
        specRules = db.ecSpecRules and db.ecSpecRules[0]
    else
        -- Use spec-specific rules
        local specIndex = GetSpecialization()
        local specID = specIndex and GetSpecializationInfo(specIndex)
        if not specID then return {} end
        specRules = db.ecSpecRules and db.ecSpecRules[specID]
    end

    if not specRules then return {} end

    local mismatches = {}

    -- Helper to parse enchant name from tooltip text (same logic as capture)
    local function ParseEnchantName(enchantText)
        if not enchantText then return nil end
        local name = enchantText
        local parsed = name:match("Enchanted: (.+)")
        if parsed then name = parsed end
        -- Strip color codes and icons
        name = name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|A.-|a", "")
        return name
    end

    for slotID, expectedData in pairs(specRules) do
        slotID = tonumber(slotID)
        local expectedName = expectedData and expectedData.name
        if slotID and expectedName and expectedName ~= "" then
            local itemID = GetInventoryItemID("player", slotID)
            if itemID then
                local enchantText, enchantID = GetPermanentEnchantFromTooltip(slotID)
                local equippedName = ParseEnchantName(enchantText)
                local slotName = SLOT_NAMES[slotID] or ("Slot " .. slotID)

                if not equippedName or equippedName == "" then
                    table.insert(mismatches, {
                        slotID = slotID,
                        slotName = slotName,
                        issue = "missing",
                        equippedName = nil,
                        expectedName = expectedName,
                    })
                elseif equippedName ~= expectedName then
                    table.insert(mismatches, {
                        slotID = slotID,
                        slotName = slotName,
                        issue = "wrong",
                        equippedName = equippedName,
                        expectedName = expectedName,
                    })
                end
            end
        end
    end

    return mismatches
end

local function UpdateSlot(button, slotID)
    local texture = GetInventoryItemTexture("player", slotID)
    local quality = GetInventoryItemQuality("player", slotID)

    if texture then
        button.icon:SetTexture(texture)
        button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        button.icon:Show()

        if quality and quality >= 0 then
            local r, g, b = C_Item.GetItemQualityColor(quality)
            button.border:SetVertexColor(r, g, b, 1)
            button.border:Show()
        else
            button.border:Hide()
        end
    else
        button.icon:SetTexture(0)
        button.icon:Hide()
        button.border:Hide()
    end
end

local function UpdateAllSlots()
    for _, button in ipairs(itemButtons) do
        UpdateSlot(button, button.slotID)
    end
end

local function CreateItemButton(parent, slotID, slotName)
    local db = GetDB()
    local size = db.iconSize or 40

    local button = CreateFrame("Button", nil, parent)
    button:SetSize(size, size)
    button.slotID = slotID
    button.slotName = slotName

    -- Icon texture
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture(0)
    button.icon = icon

    -- Quality border (4 edge textures for a clean outline)
    local borderSize = 2
    button.borderTextures = {}

    local sides = {
        {point1 = "TOPLEFT", point2 = "TOPRIGHT", x1 = -borderSize, y1 = borderSize, x2 = borderSize, y2 = 0},
        {point1 = "BOTTOMLEFT", point2 = "BOTTOMRIGHT", x1 = -borderSize, y1 = 0, x2 = borderSize, y2 = -borderSize},
        {point1 = "TOPLEFT", point2 = "BOTTOMLEFT", x1 = -borderSize, y1 = borderSize, x2 = 0, y2 = -borderSize},
        {point1 = "TOPRIGHT", point2 = "BOTTOMRIGHT", x1 = 0, y1 = borderSize, x2 = borderSize, y2 = -borderSize},
    }

    for i, side in ipairs(sides) do
        local tex = button:CreateTexture(nil, "OVERLAY")
        tex:SetPoint(side.point1, button, side.point1, side.x1, side.y1)
        tex:SetPoint(side.point2, button, side.point2, side.x2, side.y2)
        tex:SetColorTexture(1, 1, 1, 1)
        button.borderTextures[i] = tex
    end

    -- Wrapper for compatibility
    button.border = {
        SetVertexColor = function(_, r, g, b, a)
            for _, tex in ipairs(button.borderTextures) do
                tex:SetVertexColor(r, g, b, a or 1)
            end
        end,
        Show = function()
            for _, tex in ipairs(button.borderTextures) do
                tex:Show()
            end
        end,
        Hide = function()
            for _, tex in ipairs(button.borderTextures) do
                tex:Hide()
            end
        end,
    }

    -- Tooltip handling
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        if GetInventoryItemID("player", self.slotID) then
            GameTooltip:SetInventoryItem("player", self.slotID)
        else
            GameTooltip:SetText(self.slotName .. " - Empty")
        end
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return button
end

-- Update the enchant status row in the equipment frame
local function UpdateEnchantStatus()
    if not enchantStatusRow then return end

    local db = GetDB()
    if not db or not db.ecEnabled then
        enchantStatusRow:Hide()
        return
    end

    local mismatches = CheckEnchantMismatches()
    if #mismatches == 0 then
        enchantStatusRow.text:SetText("|cff00ff00Enchants OK|r")
        enchantStatusRow.text:SetTextColor(0.3, 0.8, 0.3)
        enchantStatusRow.mismatches = nil
    else
        local count = #mismatches
        enchantStatusRow.text:SetText("|cffff6666" .. count .. " Enchant Issue" .. (count > 1 and "s" or "") .. "|r")
        enchantStatusRow.text:SetTextColor(1, 0.4, 0.4)
        enchantStatusRow.mismatches = mismatches
    end

    enchantStatusRow:Show()
end

local function CreateEquipmentFrame()
    if equipmentFrame then return equipmentFrame end

    local db = GetDB()

    local frame = CreateFrame("Frame", "NaowhQOL_EquipmentReminder", UIParent, "BackdropTemplate")
    frame:SetSize(220, 90)
    frame:SetPoint(db.point or "CENTER", UIParent, db.point or "CENTER", db.x or 0, db.y or 100)
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")

    frame:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]],
        edgeFile = [[Interface\Buttons\WHITE8x8]],
        edgeSize = 1,
    })
    frame:SetBackdropColor(0.08, 0.08, 0.12, 0.95)
    frame:SetBackdropBorderColor(0.01, 0.56, 0.91, 0.8)

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", frame, "TOP", 0, -8)
    title:SetText("|cff" .. COLORS.BLUE .. "Equipment|r |cff" .. COLORS.ORANGE .. "Check|r")
    frame.title = title

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(16, 16)
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
    closeBtn:SetNormalTexture([[Interface\Buttons\UI-StopButton]])
    closeBtn:SetHighlightTexture([[Interface\Buttons\UI-StopButton]])
    closeBtn:GetHighlightTexture():SetVertexColor(1, 0.66, 0, 1)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
        if autoHideTimer then
            autoHideTimer:Cancel()
            autoHideTimer = nil
        end
    end)

    -- Item buttons container
    local buttonContainer = CreateFrame("Frame", nil, frame)
    buttonContainer:SetPoint("TOP", title, "BOTTOM", 0, -8)
    buttonContainer:SetSize(200, 50)

    local iconSize = db.iconSize or 40
    local spacing = 6
    local totalWidth = (#EQUIPMENT_SLOTS * iconSize) + ((#EQUIPMENT_SLOTS - 1) * spacing)
    local startX = -totalWidth / 2 + iconSize / 2

    for i, slot in ipairs(EQUIPMENT_SLOTS) do
        local button = CreateItemButton(buttonContainer, slot.id, slot.name)
        button:SetPoint("CENTER", buttonContainer, "CENTER", startX + (i - 1) * (iconSize + spacing), 0)
        itemButtons[i] = button
    end

    -- Enchant status row
    local statusRow = CreateFrame("Frame", nil, frame)
    statusRow:SetSize(200, 20)
    statusRow:SetPoint("TOP", buttonContainer, "BOTTOM", 0, -4)
    statusRow:EnableMouse(true)

    local statusText = statusRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetPoint("CENTER")
    statusRow.text = statusText

    -- Tooltip on hover
    statusRow:SetScript("OnEnter", function(self)
        if not self.mismatches or #self.mismatches == 0 then return end

        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:AddLine("Enchant Issues", 1, 0.4, 0.4)
        GameTooltip:AddLine(" ")

        for _, m in ipairs(self.mismatches) do
            if m.issue == "missing" then
                GameTooltip:AddDoubleLine(m.slotName .. ":", "Missing", 1, 1, 1, 1, 0.4, 0.4)
                GameTooltip:AddDoubleLine("  Expected:", m.expectedName or "?", 0.6, 0.6, 0.6, 0.5, 0.8, 0.5)
            else
                GameTooltip:AddDoubleLine(m.slotName .. ":", "Wrong Enchant", 1, 1, 1, 1, 0.6, 0.2)
                GameTooltip:AddDoubleLine("  Have:", m.equippedName or "?", 0.6, 0.6, 0.6, 1, 0.5, 0.5)
                GameTooltip:AddDoubleLine("  Expected:", m.expectedName or "?", 0.6, 0.6, 0.6, 0.5, 0.8, 0.5)
            end
        end

        GameTooltip:Show()
    end)

    statusRow:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    statusRow:Hide()
    enchantStatusRow = statusRow

    -- Resize frame to accommodate status row
    frame:SetHeight(110)

    -- Dragging
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        db.point = point
        db.x = x
        db.y = y
    end)

    frame:Hide()
    equipmentFrame = frame
    return frame
end

local function ShowFrame()
    local db = GetDB()
    if not db or not db.enabled then return end
    if InCombatLockdown() then return end

    local frame = CreateEquipmentFrame()
    UpdateAllSlots()
    UpdateEnchantStatus()
    frame:Show()

    -- Cancel existing timer
    if autoHideTimer then
        autoHideTimer:Cancel()
        autoHideTimer = nil
    end

    -- Start auto-hide timer if configured
    local delay = db.autoHideDelay or 10
    if delay > 0 then
        autoHideTimer = C_Timer.NewTimer(delay, function()
            if frame and frame:IsShown() then
                frame:Hide()
            end
            autoHideTimer = nil
        end)
    end
end

local function HideFrame()
    if equipmentFrame then
        equipmentFrame:Hide()
    end
    if autoHideTimer then
        autoHideTimer:Cancel()
        autoHideTimer = nil
    end
end

local function OnInstanceEnter()
    local db = GetDB()
    if not db or not db.enabled or not db.showOnInstance then return end

    local inInstance, instanceType = IsInInstance()
    if inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "scenario") then
        C_Timer.After(1, function()
            if not InCombatLockdown() then
                ShowFrame()
            end
        end)
    end
end

local function OnReadyCheck()
    local db = GetDB()
    if not db or not db.enabled or not db.showOnReadyCheck then return end

    C_Timer.After(0.2, function()
        if not InCombatLockdown() then
            ShowFrame()
        end
    end)
end

-- Check and update enchant status (called by events)
local function CheckAndAlertEnchants()
    local db = GetDB()
    if not db or not db.ecEnabled then
        return
    end

    -- If equipment frame is shown, update the status row
    if equipmentFrame and equipmentFrame:IsShown() then
        UpdateEnchantStatus()
    end
end

-- Event handling
local loader = CreateFrame("Frame", "NaowhQOL_EquipmentReminderLoader")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:RegisterEvent("READY_CHECK")
loader:RegisterEvent("UNIT_INVENTORY_CHANGED")
loader:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

loader:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Register debug slash command
        SLASH_NQOLECDEBUG1 = "/ecdebug"
        SlashCmdList["NQOLECDEBUG"] = function()
            for _, slot in ipairs(ENCHANTABLE_SLOTS) do
                DebugSlotInfo(slot.id)
            end
        end

        -- Debug command to check enchant comparison
        SLASH_NQOLECCHECK1 = "/eccheck"
        SlashCmdList["NQOLECCHECK"] = function()
            local db = GetDB()
            if not db then print("No DB") return end
            print("ecEnabled:", db.ecEnabled)
            print("ecUseAllSpecs:", db.ecUseAllSpecs)

            local specRules
            if db.ecUseAllSpecs then
                specRules = db.ecSpecRules and db.ecSpecRules[0]
                print("Using shared rules (key 0)")
            else
                local specIndex = GetSpecialization()
                local specID = specIndex and GetSpecializationInfo(specIndex)
                print("Current specID:", specID)
                specRules = db.ecSpecRules and db.ecSpecRules[specID]
            end

            if not specRules then
                print("No specRules found!")
                return
            end

            -- Same parsing logic as capture/check
            local function ParseName(text)
                if not text then return nil end
                local name = text:match("Enchanted: (.+)") or text
                return name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|A.-|a", "")
            end

            print("--- Comparing by NAME ---")
            for slotID, expectedData in pairs(specRules) do
                local numSlotID = tonumber(slotID)
                local expectedName = expectedData and expectedData.name
                local enchantText = GetPermanentEnchantFromTooltip(numSlotID)
                local equippedName = ParseName(enchantText)
                local slotName = SLOT_NAMES[numSlotID] or ("Slot " .. tostring(slotID))
                print(slotName .. ":")
                print("  Expected: [" .. tostring(expectedName) .. "]")
                print("  Equipped: [" .. tostring(equippedName) .. "]")
                print("  Match:", expectedName == equippedName)
            end
        end
        return

    elseif event == "PLAYER_ENTERING_WORLD" then
        OnInstanceEnter()

    elseif event == "READY_CHECK" then
        OnReadyCheck()

    elseif event == "UNIT_INVENTORY_CHANGED" then
        local unit = ...
        if unit == "player" and equipmentFrame and equipmentFrame:IsShown() then
            UpdateAllSlots()
            UpdateEnchantStatus()
        end

    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        local unit = ...
        if unit == "player" and equipmentFrame and equipmentFrame:IsShown() then
            UpdateEnchantStatus()
        end
    end
end)

ns.EquipmentReminder = loader
ns.EquipmentReminder.ShowFrame = ShowFrame
ns.EquipmentReminder.HideFrame = HideFrame
ns.EquipmentReminder.CheckAndAlertEnchants = CheckAndAlertEnchants
ns.EquipmentReminder.GetPermanentEnchantFromTooltip = GetPermanentEnchantFromTooltip
ns.EquipmentReminder.DebugSlotInfo = DebugSlotInfo
ns.EquipmentReminder.ENCHANTABLE_SLOTS = ENCHANTABLE_SLOTS
