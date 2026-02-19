local addonName, ns = ...
local L = ns.L

local cache = {}
local W = ns.Widgets
local C = ns.COLORS

local function PlaceSlider(slider, parent, x, y)
    local frame = slider:GetParent()
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    return slider
end

-- Name format options
local nameFormatOptions = {
    { text = L["COTANK_NAME_FULL"] or "Full", value = "full" },
    { text = L["COTANK_NAME_ABBREV"] or "Abbreviated", value = "abbreviated" },
}

function ns:InitCoTank()
    local p = ns.MainFrame.Content
    local db = NaowhQOL.coTank
    local display = ns.CoTankDisplay

    local function refreshDisplay() if display then display:Refresh() end end

    W:CachedPanel(cache, "coTankFrame", p, function(f)
        local sf, sc = W:CreateScrollFrame(f, 1200)

        W:CreatePageHeader(sc,
            {{"CO-TANK", C.BLUE}, {" FRAME", C.ORANGE}},
            W.Colorize(L["COTANK_SUBTITLE"] or "Display the other tank's health in your raid", C.GRAY))

        local RelayoutAll

        -- ============================================================
        -- MASTER TOGGLE
        -- ============================================================

        local masterArea = CreateFrame("Frame", nil, sc, "BackdropTemplate")
        masterArea:SetSize(460, 62)
        masterArea:SetPoint("TOPLEFT", 10, -75)
        masterArea:SetBackdrop({ bgFile = [[Interface\Buttons\WHITE8x8]] })
        masterArea:SetBackdropColor(0.01, 0.56, 0.91, 0.08)

        local masterCB = W:CreateCheckbox(masterArea, {
            label = L["COTANK_ENABLE"] or "Enable Co-Tank Frame",
            db = db, key = "enabled",
            x = 15, y = -8,
            isMaster = true,
        })

        local unlockCB = W:CreateCheckbox(masterArea, {
            label = L["COMMON_UNLOCK"],
            db = db, key = "unlock",
            x = 15, y = -38,
            template = "ChatConfigCheckButtonTemplate",
            onChange = refreshDisplay
        })
        unlockCB:SetShown(db.enabled)

        local noteText = masterArea:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        noteText:SetPoint("TOPLEFT", 200, -18)
        noteText:SetText(W.Colorize(L["COTANK_ENABLE_DESC"] or "Shows only in raids when you are tank spec and another tank is present", C.GRAY))
        noteText:SetWidth(250)
        noteText:SetJustifyH("LEFT")

        -- Settings container
        local settingsContainer = CreateFrame("Frame", nil, sc)
        settingsContainer:SetPoint("TOPLEFT", masterArea, "BOTTOMLEFT", 0, -10)
        settingsContainer:SetPoint("RIGHT", sc, "RIGHT", -10, 0)
        settingsContainer:SetHeight(800)

        -- ============================================================
        -- HEALTH BAR SECTION
        -- ============================================================

        local healthWrap, healthContent = W:CreateCollapsibleSection(settingsContainer, {
            text = L["COTANK_SECTION_HEALTH"] or "HEALTH BAR",
            startOpen = true,
            onCollapse = function() if RelayoutAll then RelayoutAll() end end,
        })

        local G = ns.Layout:New(2)

        W:CreateCheckbox(healthContent, {
            label = L["COTANK_USE_CLASS_COLOR"] or "Use Class Color",
            db = db, key = "useClassColor",
            x = G:Col(1), y = G:CheckboxY(1),
            onChange = refreshDisplay
        })

        W:CreateColorPicker(healthContent, {
            label = L["COTANK_HEALTH_COLOR"] or "Health Color", db = db,
            rKey = "healthColorR", gKey = "healthColorG", bKey = "healthColorB",
            x = G:Col(2), y = G:ColorY(1),
            onChange = refreshDisplay
        })

        local widthSlider = W:CreateAdvancedSlider(healthContent,
            W.Colorize(L["COTANK_WIDTH"] or "Width", C.ORANGE), 50, 300, G:Row(2), 1, false,
            function(val) db.width = val; refreshDisplay() end,
            { db = db, key = "width", moduleName = "coTank" })
        PlaceSlider(widthSlider, healthContent, G:Col(1), G:SliderY(2))

        local heightSlider = W:CreateAdvancedSlider(healthContent,
            W.Colorize(L["COTANK_HEIGHT"] or "Height", C.ORANGE), 10, 60, G:Row(2), 1, false,
            function(val) db.height = val; refreshDisplay() end,
            { db = db, key = "height", moduleName = "coTank" })
        PlaceSlider(heightSlider, healthContent, G:Col(2), G:SliderY(2))

        local bgSlider = W:CreateAdvancedSlider(healthContent,
            W.Colorize(L["COTANK_BG_OPACITY"] or "Background Opacity", C.ORANGE), 0, 100, G:Row(3), 5, true,
            function(val) db.bgAlpha = val / 100; refreshDisplay() end,
            { value = (db.bgAlpha or 0.6) * 100 })
        PlaceSlider(bgSlider, healthContent, G:Col(1), G:SliderY(3))

        healthContent:SetHeight(G:Height(3))
        healthWrap:RecalcHeight()

        -- ============================================================
        -- NAME SECTION
        -- ============================================================

        local nameWrap, nameContent = W:CreateCollapsibleSection(settingsContainer, {
            text = L["COTANK_SECTION_NAME"] or "NAME",
            startOpen = true,
            onCollapse = function() if RelayoutAll then RelayoutAll() end end,
        })

        local NG = ns.Layout:New(2)

        -- Row 1: Show Name, Name Format
        W:CreateCheckbox(nameContent, {
            label = L["COTANK_SHOW_NAME"] or "Show Name",
            db = db, key = "showName",
            x = NG:Col(1), y = NG:CheckboxY(1),
            onChange = refreshDisplay
        })

        W:CreateDropdown(nameContent, {
            label = L["COTANK_NAME_FORMAT"] or "Name Format",
            db = db, key = "nameFormat",
            x = NG:Col(2), y = NG:Row(1),
            options = nameFormatOptions,
            onChange = refreshDisplay
        })

        -- Row 2: Name Length, Font Size
        local nameLengthSlider = W:CreateAdvancedSlider(nameContent,
            W.Colorize(L["COTANK_NAME_LENGTH"] or "Name Length", C.ORANGE), 3, 12, NG:Row(2), 1, false,
            function(val) db.nameLength = val; refreshDisplay() end,
            { db = db, key = "nameLength", moduleName = "coTank" })
        PlaceSlider(nameLengthSlider, nameContent, NG:Col(1), NG:SliderY(2))

        local nameFontSlider = W:CreateAdvancedSlider(nameContent,
            W.Colorize(L["COTANK_NAME_FONT_SIZE"] or "Font Size", C.ORANGE), 8, 24, NG:Row(2), 1, false,
            function(val) db.nameFontSize = val; refreshDisplay() end,
            { db = db, key = "nameFontSize", moduleName = "coTank" })
        PlaceSlider(nameFontSlider, nameContent, NG:Col(2), NG:SliderY(2))

        -- Row 3: Use Class Color, Name Color
        W:CreateCheckbox(nameContent, {
            label = L["COTANK_NAME_USE_CLASS_COLOR"] or "Use Class Color",
            db = db, key = "nameColorUseClassColor",
            x = NG:Col(1), y = NG:CheckboxY(3),
            template = "ChatConfigCheckButtonTemplate",
            onChange = refreshDisplay
        })

        W:CreateColorPicker(nameContent, {
            label = L["COTANK_NAME_COLOR"] or "Name Color", db = db,
            rKey = "nameColorR", gKey = "nameColorG", bKey = "nameColorB",
            x = NG:Col(2), y = NG:ColorY(3),
            onChange = refreshDisplay
        })

        nameContent:SetHeight(NG:Height(3))
        nameWrap:RecalcHeight()

        -- ============================================================
        -- Layout
        -- ============================================================

        local allSections = { healthWrap, nameWrap }

        RelayoutAll = function()
            for i, section in ipairs(allSections) do
                section:ClearAllPoints()
                if i == 1 then
                    section:SetPoint("TOPLEFT", settingsContainer, "TOPLEFT", 0, 0)
                else
                    section:SetPoint("TOPLEFT", allSections[i - 1], "BOTTOMLEFT", 0, -12)
                end
                section:SetPoint("RIGHT", settingsContainer, "RIGHT", 0, 0)
            end

            local totalH = 0
            if db.enabled then
                for _, s in ipairs(allSections) do
                    totalH = totalH + s:GetHeight() + 12
                end
            end
            settingsContainer:SetHeight(math.max(totalH, 1))

            local scrollH = 75 + 62 + 10 + totalH + 60
            sc:SetHeight(math.max(scrollH, 1200))
        end

        masterCB:HookScript("OnClick", function(self)
            db.enabled = self:GetChecked() and true or false
            refreshDisplay()
            unlockCB:SetShown(db.enabled)
            settingsContainer:SetShown(db.enabled)
            RelayoutAll()
        end)
        settingsContainer:SetShown(db.enabled)

        -- Restore defaults button
        local restoreBtn = W:CreateRestoreDefaultsButton({
            moduleName = "coTank",
            parent = sc,
            initFunc = function() ns:InitCoTank() end,
            onRestore = function()
                if cache.coTankFrame then
                    cache.coTankFrame:Hide()
                    cache.coTankFrame:SetParent(nil)
                    cache.coTankFrame = nil
                end
                refreshDisplay()
            end
        })
        restoreBtn:SetPoint("BOTTOMLEFT", sc, "BOTTOMLEFT", 10, 20)

        RelayoutAll()
    end)
end
