local addonName, ns = ...
local L = ns.L

local cache = {}
local W = ns.Widgets
local C = ns.COLORS

local ringShapes = {
    { text = L["MOUSE_SHAPE_CIRCLE"], value = "ring.tga" },
    { text = L["MOUSE_SHAPE_THIN"],   value = "thin_ring.tga" },
    { text = L["MOUSE_SHAPE_THICK"],  value = "thick_ring.tga" },
}

local function GetDB()
    NaowhQOL = NaowhQOL or {}
    NaowhQOL.mouseRing = NaowhQOL.mouseRing or {}
    return NaowhQOL.mouseRing
end

local saveTimer = nil
local function DebouncedSave()
    if saveTimer then saveTimer:Cancel() end
    saveTimer = C_Timer.NewTimer(0.3, function()
        saveTimer = nil
    end)
end

function ns.InitMouseOptions()
    local p = ns.MainFrame.Content
    local display = ns.MouseRingDisplay

    W:CachedPanel(cache, "cursorPanel", p, function(f)
        local db = GetDB()
        local sf, sc = W:CreateScrollFrame(f, 1300)

        W:CreatePageHeader(sc,
            {{"MOUSE", C.BLUE}, {"RING", C.ORANGE}},
            W.Colorize(L["MOUSE_SUBTITLE"], C.GRAY))

        local function refresh()
            if display then display:UpdateDisplay() end
        end

        local sectionContainer = CreateFrame("Frame", nil, sc)

        local killArea = CreateFrame("Frame", nil, sc, "BackdropTemplate")
        killArea:SetSize(460, 111)
        killArea:SetPoint("TOPLEFT", 10, -75)
        killArea:SetBackdrop({ bgFile = [[Interface\Buttons\WHITE8x8]] })
        killArea:SetBackdropColor(0.01, 0.56, 0.91, 0.08)

        local masterCB = W:CreateCheckbox(killArea, {
            label = L["MOUSE_ENABLE"],
            db = db, key = "enabled",
            x = 15, y = -8,
            isMaster = true,
            onChange = function(enabled)
                W:SetSectionContainerEnabled(sectionContainer, enabled)
            end,
        })

        local oocCB = W:CreateCheckbox(killArea, {
            label = L["MOUSE_VISIBLE_OOC"],
            db = db, key = "showOutOfCombat",
            x = 15, y = -38,
            template = "ChatConfigCheckButtonTemplate",
            onChange = function()
                if display then display:RefreshVisibility() end
            end
        })
        oocCB:SetShown(db.enabled)

        local hideOnClickCB = W:CreateCheckbox(killArea, {
            label = L["MOUSE_HIDE_ON_CLICK"],
            db = db, key = "hideOnMouseClick",
            x = 15, y = -63,
            template = "ChatConfigCheckButtonTemplate",
            onChange = function()
                if display then display:RefreshVisibility() end
            end
        })
        hideOnClickCB:SetShown(db.enabled)

        local hideUnfocusedCB = W:CreateCheckbox(killArea, {
            label = L["MOUSE_HIDE_UNFOCUSED"],
            db = db, key = "hideWhenUnfocused",
            x = 15, y = -87,
            template = "ChatConfigCheckButtonTemplate",
            onChange = function()
                if display then display:RefreshVisibility() end
            end
        })
        hideUnfocusedCB:SetShown(db.enabled)

        sectionContainer:SetPoint("TOPLEFT", killArea, "BOTTOMLEFT", 0, -10)
        sectionContainer:SetPoint("RIGHT", sc, "RIGHT", -10, 0)
        sectionContainer:SetHeight(900)

        local RelayoutSections

        local appWrap, appContent = W:CreateCollapsibleSection(sectionContainer, {
            text = L["MOUSE_SECTION_APPEARANCE"],
            startOpen = false,
            onCollapse = function() if RelayoutSections then RelayoutSections() end end,
        })

        local G = ns.Layout:New(2)

        W:CreateDropdown(appContent, {
            label = L["MOUSE_SHAPE"],
            db = db, key = "shape",
            options = ringShapes,
            x = G:Col(1), y = G:Row(1),
            width = 120,
            onChange = function(val)
                if display then display:UpdateShape(val) end
            end
        })

        W:CreateColorPicker(appContent, {
            label = L["MOUSE_COLOR_BACKGROUND"], db = db,
            rKey = "colorR", gKey = "colorG", bKey = "colorB",
            classColorKey = "useClassColor",
            x = G:Col(2), y = G:Row(1) - 10,
            onChange = function(r, g, b)
                if display then display:UpdateColor(r, g, b) end
            end
        })

        W:CreateSlider(appContent, {
            label = L["MOUSE_SIZE"],
            min = 16, max = 256, step = 1,
            x = G:Col(1), y = G:Row(2),
            value = db.size or 48,
            onChange = function(val)
                if display then display:UpdateSize(val) end
            end
        })

        W:CreateSlider(appContent, {
            label = L["MOUSE_OPACITY_COMBAT"],
            min = 0, max = 100, step = 10,
            x = G:Col(2), y = G:Row(2),
            isPercent = true,
            value = (db.opacityInCombat or 1.0) * 100,
            onChange = function(val)
                db.opacityInCombat = val / 100
                DebouncedSave()
            end
        })

        W:CreateSlider(appContent, {
            label = L["MOUSE_OPACITY_OOC"],
            min = 0, max = 100, step = 10,
            x = G:Col(1), y = G:Row(3),
            isPercent = true,
            value = (db.opacityOutOfCombat or 1.0) * 100,
            onChange = function(val)
                db.opacityOutOfCombat = val / 100
                DebouncedSave()
            end
        })

        W:CreateCheckbox(appContent, {
            label = L["MOUSE_BORDER_ENABLE"],
            db = db, key = "borderEnabled",
            x = G:Col(1), y = G:Row(4) + 10,
            template = "ChatConfigCheckButtonTemplate",
            onChange = refresh,
        })

        W:CreateColorPicker(appContent, {
            label = L["MOUSE_BORDER_COLOR"], db = db,
            rKey = "borderR", gKey = "borderG", bKey = "borderB",
            classColorKey = "borderUseClassColor",
            x = G:Col(2), y = G:Row(4) - 5,
            onChange = refresh,
        })

        W:CreateSlider(appContent, {
            label = L["MOUSE_BORDER_WEIGHT"],
            min = 1, max = 8, step = 1,
            x = G:Col(1), y = G:Row(5),
            value = db.borderWeight or 2,
            onChange = function(val)
                db.borderWeight = val
                refresh()
            end
        })

        appContent:SetHeight(G:Height(5))
        appWrap:RecalcHeight()

        local gcdWrap, gcdContent = W:CreateCollapsibleSection(sectionContainer, {
            text = L["MOUSE_SECTION_GCD"],
            startOpen = false,
            onCollapse = function() if RelayoutSections then RelayoutSections() end end,
        })

        local GG = ns.Layout:New(2)

        local function gcdDisabled() return not db.gcdEnabled end

        W:CreateCheckbox(gcdContent, {
            label = L["MOUSE_GCD_ENABLE"],
            db = db, key = "gcdEnabled",
            x = GG:Col(1), y = GG:Row(1) + 5,
            template = "ChatConfigCheckButtonTemplate",
            onChange = function()
                W:ApplyDisableStates(gcdContent)
                if display then display:RefreshGCD() end
            end
        })

        W:CreateCheckbox(gcdContent, {
            label = L["MOUSE_HIDE_BACKGROUND"],
            db = db, key = "hideBackground",
            x = GG:Col(2), y = GG:Row(1) + 5,
            template = "ChatConfigCheckButtonTemplate",
            disableif = gcdDisabled,
            onChange = function()
                if display then display:RefreshVisibility() end
            end
        })

        local swipeBtn, swipePreview, swipeToggle = W:CreateColorPicker(gcdContent, {
            label = L["MOUSE_COLOR_SWIPE"], db = db,
            rKey = "gcdR", gKey = "gcdG", bKey = "gcdB",
            classColorKey = "gcdUseClassColor",
            x = GG:Col(1), y = GG:Row(2) - 10,
            disableif = gcdDisabled,
            onChange = function()
                if display then display:RefreshGCD() end
            end
        })

        local readyBtn, readyPreview, readyToggle = W:CreateColorPicker(gcdContent, {
            label = L["MOUSE_COLOR_READY"], db = db,
            rKey = "gcdReadyR", gKey = "gcdReadyG", bKey = "gcdReadyB",
            classColorKey = "gcdReadyUseClassColor",
            x = GG:Col(2), y = GG:Row(2) - 10,
            disableif = gcdDisabled,
            onChange = function()
                if display then display:RefreshGCD() end
            end
        })

        local matchSwipeCB = W:CreateCheckbox(gcdContent, {
            label = L["MOUSE_GCD_READY_MATCH"],
            db = db, key = "gcdReadyMatchSwipe",
            x = GG:Col(2), y = GG:Row(3) + 5,
            template = "ChatConfigCheckButtonTemplate",
            disableif = gcdDisabled,
            onChange = function(enabled)
                readyBtn:SetShown(not enabled)
                readyPreview:SetShown(not enabled)
                readyToggle:SetShown(not enabled)
                if display then display:RefreshGCD() end
            end
        })

        readyBtn:SetShown(not db.gcdReadyMatchSwipe)
        readyPreview:SetShown(not db.gcdReadyMatchSwipe)
        readyToggle:SetShown(not db.gcdReadyMatchSwipe)

        W:CreateSlider(gcdContent, {
            label = L["MOUSE_OPACITY_SWIPE"],
            min = 0, max = 100, step = 10,
            x = GG:Col(1), y = GG:Row(3),
            isPercent = true,
            disableif = gcdDisabled,
            value = (db.gcdAlpha or 1.0) * 100,
            onChange = function(val)
                db.gcdAlpha = val / 100
                DebouncedSave()
                if display then display:RefreshGCD() end
            end
        })

        W:CreateCheckbox(gcdContent, {
            label = L["MOUSE_CAST_SWIPE_ENABLE"],
            db = db, key = "castSwipeEnabled",
            x = GG:Col(1), y = GG:Row(4) + 5,
            template = "ChatConfigCheckButtonTemplate",
            disableif = gcdDisabled,
            onChange = function() end
        })

        W:CreateColorPicker(gcdContent, {
            label = L["MOUSE_COLOR_CAST_SWIPE"] or "Cast Swipe", db = db,
            rKey = "castSwipeR", gKey = "castSwipeG", bKey = "castSwipeB",
            classColorKey = "castSwipeUseClassColor",
            x = GG:Col(1), y = GG:Row(5) - 10,
            disableif = gcdDisabled,
            onChange = function() end
        })

        W:CreateSlider(gcdContent, {
            label = L["MOUSE_SWIPE_DELAY"],
            min = 0, max = 200, step = 5,
            x = GG:Col(2), y = GG:Row(5),
            disableif = gcdDisabled,
            value = (db.swipeDelay or 0.08) * 1000,
            onChange = function(val)
                db.swipeDelay = val / 1000
                DebouncedSave()
            end
        })

        gcdContent:SetHeight(GG:Height(5))
        gcdWrap:RecalcHeight()

        local trailWrap, trailContent = W:CreateCollapsibleSection(sectionContainer, {
            text = L["MOUSE_SECTION_TRAIL"],
            startOpen = false,
            onCollapse = function() if RelayoutSections then RelayoutSections() end end,
        })

        local GT = ns.Layout:New(2)

        local function trailDisabled() return not db.trailEnabled end

        W:CreateCheckbox(trailContent, {
            label = L["MOUSE_TRAIL_ENABLE"],
            db = db, key = "trailEnabled",
            x = GT:Col(1), y = GT:Row(1) + 5,
            template = "ChatConfigCheckButtonTemplate",
            onChange = function()
                W:ApplyDisableStates(trailContent)
                if display then display:RefreshVisibility() end
            end
        })

        W:CreateColorPicker(trailContent, {
            label = L["MOUSE_TRAIL_COLOR"], db = db,
            rKey = "trailR", gKey = "trailG", bKey = "trailB",
            classColorKey = "trailUseClassColor",
            x = GT:Col(2), y = GT:Row(1) - 10,
            disableif = trailDisabled,
            onChange = function() end
        })

        W:CreateSlider(trailContent, {
            label = L["MOUSE_TRAIL_DURATION"],
            min = 10, max = 100, step = 5,
            x = GT:Col(1), y = GT:Row(2),
            disableif = trailDisabled,
            value = ((db.trailDuration or 0.6) - 0.1) / 0.4 * 100,
            onChange = function(val)
                db.trailDuration = 0.1 + (val / 100) * 0.4
                DebouncedSave()
            end
        })

        trailContent:SetHeight(GT:Height(2))
        trailWrap:RecalcHeight()

        local mlWrap, mlContent = W:CreateCollapsibleSection(sectionContainer, {
            text = L["MOUSE_SECTION_DETECTION"],
            startOpen = false,
            onCollapse = function() if RelayoutSections then RelayoutSections() end end,
        })

        local meleeSubElements = {}

        local function updateMeleeSubVisibility()
            local show = db.meleeRecolor
            for _, el in ipairs(meleeSubElements) do
                el:SetShown(show)
            end
            mlContent:SetHeight(show and 330 or 35)
            mlWrap:RecalcHeight()
            if RelayoutSections then RelayoutSections() end
        end

        W:CreateCheckbox(mlContent, {
            label = L["MOUSE_MELEE_ENABLE"],
            db = db, key = "meleeRecolor",
            x = 10, y = -5,
            template = "ChatConfigCheckButtonTemplate",
            onChange = function()
                refresh()
                updateMeleeSubVisibility()
            end
        })

        meleeSubElements[#meleeSubElements + 1] = W:CreateCheckbox(mlContent, {
            label = L["MOUSE_RECOLOR_BORDER"],
            db = db, key = "meleeRecolorBorder",
            x = 10, y = -35,
            template = "ChatConfigCheckButtonTemplate",
            onChange = refresh
        })

        meleeSubElements[#meleeSubElements + 1] = W:CreateCheckbox(mlContent, {
            label = L["MOUSE_RECOLOR_RING"],
            db = db, key = "meleeRecolorRing",
            x = 150, y = -35,
            template = "ChatConfigCheckButtonTemplate",
            onChange = refresh
        })

        local soundCB = W:CreateCheckbox(mlContent, {
            label = L["MOUSE_SOUND_ENABLE"],
            db = db, key = "meleeSoundEnabled",
            x = 10, y = -65,
            template = "ChatConfigCheckButtonTemplate",
            onChange = function(enabled)
                if not enabled and display and display.StopMeleeSound then
                    display.StopMeleeSound()
                end
                refresh()
            end
        })
        meleeSubElements[#meleeSubElements + 1] = soundCB

        local soundPicker = W:CreateSoundPicker(mlContent, 10, -95, db.meleeSoundID or ns.Media.DEFAULT_SOUND,
            function(sound) db.meleeSoundID = sound end)
        meleeSubElements[#meleeSubElements + 1] = soundPicker

        local intervalSliderWrapper = W:CreateSlider(mlContent, {
            label = L["MOUSE_SOUND_INTERVAL"],
            min = 0, max = 15, step = 1,
            x = 10, y = -135,
            value = db.meleeSoundInterval or 3,
            onChange = function(val)
                db.meleeSoundInterval = val
                DebouncedSave()
            end
        })
        meleeSubElements[#meleeSubElements + 1] = intervalSliderWrapper

        local spellLabel = mlContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        spellLabel:SetPoint("TOPLEFT", 10, -200)
        spellLabel:SetText(W.Colorize(L["MOUSE_SPELL_ID"], C.WHITE))
        meleeSubElements[#meleeSubElements + 1] = spellLabel

        local spellStatusText = mlContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        spellStatusText:SetPoint("TOPLEFT", 10, -217)
        spellStatusText:SetTextColor(0.6, 0.6, 0.6)
        meleeSubElements[#meleeSubElements + 1] = spellStatusText

        local spellInputContainer = CreateFrame("Frame", nil, mlContent)
        spellInputContainer:SetSize(250, 25)
        spellInputContainer:SetPoint("TOPLEFT", 10, -235)
        meleeSubElements[#meleeSubElements + 1] = spellInputContainer

        local spellInput = CreateFrame("EditBox", nil, spellInputContainer, "InputBoxTemplate")
        spellInput:SetSize(100, 20)
        spellInput:SetPoint("LEFT", 0, 0)
        spellInput:SetAutoFocus(false)
        spellInput:SetNumeric(true)
        spellInput:SetMaxLetters(9)

        NaowhQOL.crosshair = NaowhQOL.crosshair or {}
        local crosshairDb = NaowhQOL.crosshair

        local function UpdateSpellDisplay()
            local info = ns.MeleeRangeInfo
            if not info then return end

            local current = info.GetCurrentSpell()
            local default = info.GetDefaultSpell()

            if current then
                spellInput:SetText(tostring(current))
                local spellInfo = C_Spell.GetSpellInfo(current)
                local spellName = spellInfo and spellInfo.name or "Unknown"
                spellStatusText:SetText(string.format(L["MOUSE_SPELL_CURRENT"], spellName))
                spellStatusText:SetTextColor(0.5, 1, 0.5)
            elseif default == nil then
                spellInput:SetText("")
                spellStatusText:SetText(L["MOUSE_SPELL_UNSUPPORTED"])
                spellStatusText:SetTextColor(1, 0.5, 0.5)
            else
                spellInput:SetText("")
                spellStatusText:SetText(L["MOUSE_SPELL_NONE"])
                spellStatusText:SetTextColor(1, 0.5, 0.5)
            end
        end

        spellInput:SetScript("OnEnterPressed", function(self)
            local info = ns.MeleeRangeInfo
            if not info then return end

            local key = info.GetSpellKey()
            if not key then return end

            local val = tonumber(self:GetText())
            if val and val > 0 then
                crosshairDb.meleeSpellOverrides = crosshairDb.meleeSpellOverrides or {}
                crosshairDb.meleeSpellOverrides[key] = val
                info.RefreshCache()
                refresh()
            end
            UpdateSpellDisplay()
            self:ClearFocus()
        end)

        spellInput:SetScript("OnEscapePressed", function(self)
            UpdateSpellDisplay()
            self:ClearFocus()
        end)

        local resetSpellBtn = W:CreateButton(spellInputContainer, {
            text = L["MOUSE_RESET_SPELL"],
            width = 120,
            height = 22,
            onClick = function()
                local info = ns.MeleeRangeInfo
                if not info then return end

                local key = info.GetSpellKey()
                if key and crosshairDb.meleeSpellOverrides then
                    crosshairDb.meleeSpellOverrides[key] = nil
                end
                info.RefreshCache()
                UpdateSpellDisplay()
                refresh()
            end
        })
        resetSpellBtn:SetPoint("LEFT", spellInput, "RIGHT", 10, 0)

        local hpalNote = mlContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        hpalNote:SetPoint("TOPLEFT", 250, -238)
        hpalNote:SetText(L["MOUSE_HPAL_NOTE"])
        hpalNote:SetTextColor(1, 0.82, 0)
        local isHpal = ns.SpecUtil.GetClassName() == "PALADIN" and ns.SpecUtil.GetSpecIndex() == 1
        hpalNote:SetAlpha(isHpal and 1 or 0)
        hpalNote:SetShown(db.meleeRecolor)
        meleeSubElements[#meleeSubElements + 1] = hpalNote

        UpdateSpellDisplay()

        ns.SpecUtil.RegisterCallback("MouseRingConfig", function()
            UpdateSpellDisplay()
        end)

        updateMeleeSubVisibility()

        mlContent:SetHeight(db.meleeRecolor and 330 or 35)
        mlWrap:RecalcHeight()

        local allSections = { appWrap, gcdWrap, trailWrap, mlWrap }

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

            local totalH = 100 + 95 + 10
            if db.enabled then
                for _, s in ipairs(allSections) do
                    totalH = totalH + s:GetHeight() + 12
                end
            end
            sc:SetHeight(math.max(totalH + 40, 600))
        end

        masterCB:HookScript("OnClick", function(self)
            db.enabled = self:GetChecked() and true or false

            if display then
                display:UpdateDisplay()
            end

            oocCB:SetShown(db.enabled)
            hideOnClickCB:SetShown(db.enabled)
            sectionContainer:SetShown(db.enabled)
            if db.enabled then
                killArea:SetBackdropColor(0.01, 0.56, 0.91, 0.08)
            end
            RelayoutSections()
        end)
        sectionContainer:SetShown(db.enabled)

        local restoreBtn = W:CreateRestoreDefaultsButton({
            moduleName = "mouseRing",
            parent = sc,
            initFunc = function() ns.InitMouseOptions() end,
            onRestore = function()
                if cache.cursorPanel then
                    cache.cursorPanel:Hide()
                    cache.cursorPanel:SetParent(nil)
                    cache.cursorPanel = nil
                end
                if display then display:UpdateDisplay() end
            end
        })
        restoreBtn:SetPoint("BOTTOMLEFT", sc, "BOTTOMLEFT", 10, 20)

        RelayoutSections()
    end)
end

function ns.UpdateMouseCircle()
    if ns.MouseRingDisplay then
        ns.MouseRingDisplay:UpdateDisplay()
    end
end
