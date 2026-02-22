local addonName, ns = ...

local cache = {}
local W = ns.Widgets
local C = ns.COLORS
local L = ns.L

function ns:InitEquipmentReminder()
    local p = ns.MainFrame.Content
    local db = NaowhQOL.equipmentReminder

    W:CachedPanel(cache, "eqFrame", p, function(f)
        local sf, sc = W:CreateScrollFrame(f, 700)

        W:CreatePageHeader(sc,
            {{"EQUIPMENT ", C.BLUE}, {"REMINDER", C.ORANGE}},
            W.Colorize(L["EQUIPMENTREMINDER_DESC"], C.GRAY))

        -- Master toggle
        local toggleArea = CreateFrame("Frame", nil, sc, "BackdropTemplate")
        toggleArea:SetSize(460, 38)
        toggleArea:SetPoint("TOPLEFT", 10, -75)
        toggleArea:SetBackdrop({ bgFile = [[Interface\Buttons\WHITE8x8]] })
        toggleArea:SetBackdropColor(0.01, 0.56, 0.91, 0.08)

        local masterCB = W:CreateCheckbox(toggleArea, {
            label = L["EQUIPMENTREMINDER_ENABLE"],
            db = db, key = "enabled",
            x = 15, y = -8,
            isMaster = true,
        })

        -- Section container
        local sectionContainer = CreateFrame("Frame", nil, sc)
        sectionContainer:SetPoint("TOPLEFT", toggleArea, "BOTTOMLEFT", 0, -10)
        sectionContainer:SetPoint("RIGHT", sc, "RIGHT", -10, 0)
        sectionContainer:SetHeight(400)

        local RelayoutSections

        -- TRIGGERS section
        local triggerWrap, triggerContent = W:CreateCollapsibleSection(sectionContainer, {
            text = L["EQUIPMENTREMINDER_SECTION_TRIGGERS"],
            startOpen = false,
            onCollapse = function() if RelayoutSections then RelayoutSections() end end,
        })

        local triggerDesc = triggerContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        triggerDesc:SetPoint("TOPLEFT", 0, -5)
        triggerDesc:SetText(W.Colorize(L["EQUIPMENTREMINDER_TRIGGER_DESC"], C.GRAY))

        W:CreateCheckbox(triggerContent, {
            label = L["EQUIPMENTREMINDER_SHOW_INSTANCE"],
            tooltip = L["EQUIPMENTREMINDER_SHOW_INSTANCE_DESC"],
            db = db, key = "showOnInstance",
            x = 0, y = -30,
        })

        W:CreateCheckbox(triggerContent, {
            label = L["EQUIPMENTREMINDER_SHOW_READYCHECK"],
            tooltip = L["EQUIPMENTREMINDER_SHOW_READYCHECK_DESC"],
            db = db, key = "showOnReadyCheck",
            x = 0, y = -55,
        })

        triggerContent:SetHeight(90)
        triggerWrap:RecalcHeight()

        -- DISPLAY section
        local displayWrap, displayContent = W:CreateCollapsibleSection(sectionContainer, {
            text = L["COMMON_SECTION_DISPLAY"],
            startOpen = false,
            onCollapse = function() if RelayoutSections then RelayoutSections() end end,
        })

        W:CreateSlider(displayContent, {
            label = L["EQUIPMENTREMINDER_AUTOHIDE"],
            min = 0, max = 30, step = 1,
            db = db, key = "autoHideDelay",
            x = 0, y = -10,
            width = 200,
            tooltip = L["EQUIPMENTREMINDER_AUTOHIDE_DESC"],
            onChange = function(val) db.autoHideDelay = val end,
        })

        W:CreateSlider(displayContent, {
            label = L["COMMON_LABEL_ICON_SIZE"],
            min = 32, max = 64, step = 2,
            db = db, key = "iconSize",
            x = 0, y = -70,
            width = 200,
            tooltip = L["EQUIPMENTREMINDER_ICON_SIZE_DESC"],
            onChange = function(val)
                db.iconSize = val
                -- Force recreation of frame on next show
                if _G["NaowhQOL_EquipmentReminder"] then
                    _G["NaowhQOL_EquipmentReminder"]:Hide()
                    _G["NaowhQOL_EquipmentReminder"] = nil
                end
            end,
        })

        displayContent:SetHeight(130)
        displayWrap:RecalcHeight()

        -- PREVIEW section
        local previewWrap, previewContent = W:CreateCollapsibleSection(sectionContainer, {
            text = L["EQUIPMENTREMINDER_SECTION_PREVIEW"],
            startOpen = false,
            onCollapse = function() if RelayoutSections then RelayoutSections() end end,
        })

        local previewBtn = W:CreateButton(previewContent, {
            text = L["EQUIPMENTREMINDER_SHOW_FRAME"],
            onClick = function()
                if ns.EquipmentReminder and ns.EquipmentReminder.ShowFrame then
                    ns.EquipmentReminder.ShowFrame()
                end
            end,
        })
        previewBtn:SetPoint("TOPLEFT", 0, -10)

        previewContent:SetHeight(50)
        previewWrap:RecalcHeight()

        -- ENCHANT CHECKER section
        local enchantWrap, enchantContent = W:CreateCollapsibleSection(sectionContainer, {
            text = L["EQUIPMENTREMINDER_SECTION_ENCHANT"],
            startOpen = false,
            onCollapse = function() if RelayoutSections then RelayoutSections() end end,
        })

        local enchantDesc = enchantContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        enchantDesc:SetPoint("TOPLEFT", 0, -5)
        enchantDesc:SetText(W.Colorize(L["EQUIPMENTREMINDER_ENCHANT_DESC"], C.GRAY))

        -- Enable checkbox
        local ecEnableCB = W:CreateCheckbox(enchantContent, {
            label = L["EQUIPMENTREMINDER_ENCHANT_ENABLE"],
            tooltip = L["EQUIPMENTREMINDER_ENCHANT_ENABLE_DESC"],
            db = db, key = "ecEnabled",
            x = 0, y = -30,
        })

        -- Use all specs checkbox
        local useAllSpecsCB = W:CreateCheckbox(enchantContent, {
            label = L["EQUIPMENTREMINDER_ALL_SPECS"],
            tooltip = L["EQUIPMENTREMINDER_ALL_SPECS_DESC"],
            db = db, key = "ecUseAllSpecs",
            x = 0, y = -55,
        })

        -- Forward declaration for BuildEnchantGrid
        local BuildEnchantGrid

        -- Capture Current button
        local captureBtn = W:CreateButton(enchantContent, {
            text = L["EQUIPMENTREMINDER_CAPTURE"],
            onClick = function()
                local specIndex = GetSpecialization()
                local specID = specIndex and GetSpecializationInfo(specIndex)
                local SLOTS = ns.EquipmentReminder and ns.EquipmentReminder.ENCHANTABLE_SLOTS or {
                    { id = 16, name = "Main Hand" },
                    { id = 17, name = "Off Hand" },
                }

                db.ecSpecRules = db.ecSpecRules or {}

                local ruleKey = db.ecUseAllSpecs and 0 or specID
                if not ruleKey then return end

                db.ecSpecRules[ruleKey] = db.ecSpecRules[ruleKey] or {}
                local rules = db.ecSpecRules[ruleKey]

                local captured = 0
                for _, slot in ipairs(SLOTS) do
                    if ns.EquipmentReminder and ns.EquipmentReminder.GetPermanentEnchantFromTooltip then
                        local enchantText, enchantID = ns.EquipmentReminder.GetPermanentEnchantFromTooltip(slot.id)
                        if enchantID and enchantID > 0 then
                            -- Parse enchant name from tooltip text
                            -- Format varies: "Enchanted: Name" or just "+21 Mastery" etc
                            local name = enchantText or ("ID: " .. enchantID)
                            -- Try to extract just the name if "Enchanted:" prefix exists
                            local parsed = name:match("Enchanted: (.+)")
                            if parsed then name = parsed end
                            -- Strip any color codes or icons from the name
                            name = name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|A.-|a", "")
                            rules[slot.id] = { id = enchantID, name = name }
                            captured = captured + 1
                        end
                    end
                end

                if BuildEnchantGrid then BuildEnchantGrid() end
                print("|cff00ff00NaowhQOL:|r " .. string.format(L["EQUIPMENTREMINDER_CAPTURED"], captured))
            end,
        })
        captureBtn:SetPoint("TOPLEFT", 0, -80)

        -- Grid container for slot/spec enchant inputs
        local gridContainer = CreateFrame("Frame", nil, enchantContent)
        gridContainer:SetPoint("TOPLEFT", 0, -120)
        gridContainer:SetPoint("RIGHT", enchantContent, "RIGHT", 0, 0)
        gridContainer:SetHeight(400)

        local gridElements = {}
        local SLOTS = ns.EquipmentReminder and ns.EquipmentReminder.ENCHANTABLE_SLOTS or {
            { id = 16, name = L["EQUIPMENTREMINDER_MAIN_HAND"] },
            { id = 17, name = L["EQUIPMENTREMINDER_OFF_HAND"] },
        }

        -- Create an enchant entry (display only)
        local function CreateEnchantEntry(parent, x, y, rules, slotID, rebuildFunc)
            local container = CreateFrame("Frame", nil, parent)
            container:SetPoint("TOPLEFT", x, y)
            container:SetSize(180, 24)

            -- Data is now {id = number, name = string} or nil
            local data = rules[slotID]
            local hasEnchant = data and data.id and data.id > 0

            if hasEnchant then
                -- Show name + delete button
                local nameText = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                nameText:SetPoint("LEFT", 0, 0)
                nameText:SetText(data.name or ("ID: " .. data.id))
                nameText:SetTextColor(0.5, 0.8, 0.5)

                local deleteBtn = CreateFrame("Button", nil, container)
                deleteBtn:SetSize(16, 16)
                deleteBtn:SetPoint("LEFT", nameText, "RIGHT", 6, 0)
                deleteBtn:SetNormalTexture([[Interface\Buttons\UI-StopButton]])
                deleteBtn:SetHighlightTexture([[Interface\Buttons\UI-StopButton]])
                deleteBtn:GetHighlightTexture():SetVertexColor(1, 0.3, 0.3, 1)
                deleteBtn:SetScript("OnClick", function()
                    rules[slotID] = nil
                    rebuildFunc()
                end)
            else
                -- Show "Not set" text (use Capture Current to populate)
                local notSetText = container:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
                notSetText:SetPoint("LEFT", 0, 0)
                notSetText:SetText("-")
            end

            return container
        end

        -- Build the grid
        BuildEnchantGrid = function()
            -- Clear existing elements
            for _, elem in pairs(gridElements) do
                if elem.Hide then elem:Hide() end
            end
            gridElements = {}

            local numSpecs = GetNumSpecializations()
            local useAllSpecs = db.ecUseAllSpecs

            db.ecSpecRules = db.ecSpecRules or {}

            local rowHeight = 28
            local labelWidth = 80
            local entryWidth = 180
            local colSpacing = 10
            local yOffset = 0

            -- Header row
            if useAllSpecs then
                local header = gridContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                header:SetPoint("TOPLEFT", labelWidth + 10, -yOffset)
                header:SetText(L["EQUIPMENTREMINDER_EXPECTED_ENCHANT"])
                header:SetTextColor(0.8, 0.8, 0.8)
                table.insert(gridElements, header)
            else
                for i = 1, numSpecs do
                    local _, specName = GetSpecializationInfo(i)
                    local colX = labelWidth + 10 + (i - 1) * (entryWidth + colSpacing)
                    local header = gridContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    header:SetPoint("TOPLEFT", colX, -yOffset)
                    header:SetText(specName or ("Spec " .. i))
                    header:SetTextColor(0.8, 0.8, 0.8)
                    table.insert(gridElements, header)
                end
            end

            yOffset = yOffset + 20

            -- Slot rows
            for _, slot in ipairs(SLOTS) do
                local slotID = slot.id
                local slotName = slot.name

                local label = gridContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                label:SetPoint("TOPLEFT", 0, -yOffset - 4)
                label:SetText(slotName)
                label:SetWidth(labelWidth)
                label:SetJustifyH("RIGHT")
                table.insert(gridElements, label)

                if useAllSpecs then
                    db.ecSpecRules[0] = db.ecSpecRules[0] or {}
                    local entry = CreateEnchantEntry(gridContainer, labelWidth + 10, -yOffset, db.ecSpecRules[0], slotID, BuildEnchantGrid)
                    table.insert(gridElements, entry)
                else
                    for i = 1, numSpecs do
                        local specID = GetSpecializationInfo(i)
                        db.ecSpecRules[specID] = db.ecSpecRules[specID] or {}
                        local colX = labelWidth + 10 + (i - 1) * (entryWidth + colSpacing)
                        local entry = CreateEnchantEntry(gridContainer, colX, -yOffset, db.ecSpecRules[specID], slotID, BuildEnchantGrid)
                        table.insert(gridElements, entry)
                    end
                end

                yOffset = yOffset + rowHeight
            end

            gridContainer:SetHeight(yOffset + 20)
        end

        -- Rebuild grid when useAllSpecs changes
        useAllSpecsCB:HookScript("OnClick", function()
            C_Timer.After(0.1, BuildEnchantGrid)
            if RelayoutSections then RelayoutSections() end
        end)

        -- Initial grid build
        C_Timer.After(0.1, BuildEnchantGrid)

        enchantContent:SetHeight(550)
        enchantWrap:RecalcHeight()

        -- Relayout sections (preview first)
        local allSections = { previewWrap, triggerWrap, displayWrap, enchantWrap }

        RelayoutSections = function()
            for i, section in ipairs(allSections) do
                section:ClearAllPoints()
                if i == 1 then
                    section:SetPoint("TOPLEFT", sectionContainer, "TOPLEFT", 0, 0)
                else
                    section:SetPoint("TOPLEFT", allSections[i - 1], "BOTTOMLEFT", 0, -12)
                end
                section:SetPoint("RIGHT", sectionContainer, "RIGHT", 0, 0)
            end

            local totalH = 75 + 38 + 10
            if db.enabled then
                for _, s in ipairs(allSections) do
                    totalH = totalH + s:GetHeight() + 12
                end
            end
            sc:SetHeight(math.max(totalH + 40, 600))
        end

        masterCB:HookScript("OnClick", function(self)
            db.enabled = self:GetChecked() and true or false
            sectionContainer:SetShown(db.enabled)
            RelayoutSections()
        end)
        sectionContainer:SetShown(db.enabled)

        -- Restore defaults button
        local restoreBtn = W:CreateRestoreDefaultsButton({
            moduleName = "equipmentReminder",
            parent = sc,
            initFunc = function() ns:InitEquipmentReminder() end,
            onRestore = function()
                if cache.eqFrame then
                    cache.eqFrame:Hide()
                    cache.eqFrame:SetParent(nil)
                    cache.eqFrame = nil
                end
            end
        })
        restoreBtn:SetPoint("BOTTOMLEFT", sc, "BOTTOMLEFT", 10, 20)

        RelayoutSections()
    end)
end
