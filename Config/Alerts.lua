local addonName, ns = ...

local L = ns.L
local cache = {}
local W = ns.Widgets
local C = ns.COLORS

local function RefreshAll()
    if ns.SpellAlerts then ns.SpellAlerts.Apply(true) end
    if ns.DispelGlow then ns.DispelGlow.Refresh() end
    if ns.PotionReadyDisplay then ns.PotionReadyDisplay.Update() end
end

local function PlaceSlider(slider, parent, x, y)
    local frame = slider:GetParent()
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    return slider
end

local function CreateNote(parent, text, x, y, width)
    local note = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", x, y)
    note:SetWidth(width or 520)
    note:SetJustifyH("LEFT")
    note:SetText(W.Colorize(text, C.GRAY))
    return note
end

local function ClassColorText(classFile, text)
    local color = classFile and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
    if color and color.colorStr then
        return "|c" .. color.colorStr .. text .. "|r"
    end
    return text
end

local function GetClassInfoByID(classID)
    if C_CreatureInfo and C_CreatureInfo.GetClassInfo then
        local info = C_CreatureInfo.GetClassInfo(classID)
        if info then return info.className, info.classFile end
    end
    if GetClassInfo then
        local className, classFile = GetClassInfo(classID)
        return className, classFile
    end
    return nil, nil
end

function ns:InitAlerts()
    local p = ns.MainFrame.Content

    W:CachedPanel(cache, "alertsFrame", p, function(f)
        local sf, sc = W:CreateScrollFrame(f, 1000)

        W:CreatePageHeader(sc,
            {{"ALERT ", C.BLUE}, {"TOOLS", C.ORANGE}},
            W.Colorize(L["ALERTS_SUBTITLE"], C.GRAY))

        local sections = CreateFrame("Frame", nil, sc)
        sections:SetPoint("TOPLEFT", 10, -75)
        sections:SetPoint("RIGHT", sc, "RIGHT", -10, 0)
        sections:SetHeight(900)

        local RelayoutSections
        local sectionList = {}

        local spellDB = NaowhQOL.spellAlerts
        local spellWrap, spellContent = W:CreateCollapsibleSection(sections, {
            text = L["ALERTS_SPELL_ALERTS"],
            startOpen = true,
            onCollapse = function() if RelayoutSections then RelayoutSections() end end,
        })
        sectionList[#sectionList + 1] = spellWrap

        W:CreateCheckbox(spellContent, {
            label = L["ALERTS_ENABLE_SPELL_ALERTS"],
            db = spellDB, key = "enabled",
            x = 10, y = -5,
            isMaster = true,
            onChange = RefreshAll,
        })

        spellDB.enabledSpecs = spellDB.enabledSpecs or {}
        local opacityValue = tonumber(GetCVar("spellActivationOverlayOpacity") or "0.65") or 0.65
        W:CreateSlider(spellContent, {
            label = L["ALERTS_SPELL_ALERT_OPACITY"],
            min = 0, max = 100, step = 5,
            x = 30, y = -35,
            isPercent = true,
            value = opacityValue * 100,
            onChange = function(value)
                local setter = SetCVar or (C_CVar and C_CVar.SetCVar)
                if setter then pcall(setter, "spellActivationOverlayOpacity", tostring(value / 100)) end
            end,
        })

        local y = -95
        local classCount = GetNumClasses and GetNumClasses() or 0
        for classID = 1, classCount do
            local className, classFile = GetClassInfoByID(classID)
            if className then
                local header = spellContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                header:SetPoint("TOPLEFT", 10, y)
                header:SetText(ClassColorText(classFile, className))
                y = y - 24

                local specs = {}
                if GetSpecializationInfoForClassID then
                    for specNum = 1, 4 do
                        local specID, specName, _, specIcon = GetSpecializationInfoForClassID(classID, specNum)
                        if specID and specName then
                            specs[#specs + 1] = { id = specID, name = specName, icon = specIcon }
                        end
                    end
                end

                for i, spec in ipairs(specs) do
                    local col = (i - 1) % 4
                    local row = math.floor((i - 1) / 4)
                    local icon = spec.icon and ("|T" .. spec.icon .. ":14:14:0:0:64:64:4:60:4:60|t ") or ""
                    local cb = W:CreateCheckbox(spellContent, {
                        label = icon .. spec.name,
                        x = 20 + col * 145,
                        y = y - row * 25,
                        template = "ChatConfigCheckButtonTemplate",
                        onChange = function(checked)
                            spellDB.enabledSpecs[spec.id] = checked and true or nil
                            RefreshAll()
                        end,
                    })
                    cb:SetChecked(spellDB.enabledSpecs[spec.id] == true)
                end

                y = y - math.max(1, math.ceil(#specs / 4)) * 25 - 8
            end
        end

        CreateNote(spellContent, L["ALERTS_SPELL_ALERTS_NOTE"], 10, y, 560)
        spellContent:SetHeight(math.abs(y) + 45)
        spellWrap:RecalcHeight()

        local dispelDB = NaowhQOL.dispelGlow
        local dispelWrap, dispelContent = W:CreateCollapsibleSection(sections, {
            text = L["ALERTS_DISPEL_GLOW"],
            startOpen = false,
            onCollapse = function() if RelayoutSections then RelayoutSections() end end,
        })
        sectionList[#sectionList + 1] = dispelWrap

        W:CreateCheckbox(dispelContent, {
            label = L["ALERTS_ENABLE_DISPEL_GLOW"],
            db = dispelDB, key = "enabled",
            x = 10, y = -5,
            isMaster = true,
            onChange = RefreshAll,
        })
        W:CreateCheckbox(dispelContent, {
            label = L["ALERTS_USE_DISPEL_COLOR"],
            db = dispelDB, key = "useDispelColor",
            x = 30, y = -35,
            template = "ChatConfigCheckButtonTemplate",
            onChange = RefreshAll,
        })
        W:CreateCheckbox(dispelContent, {
            label = L["ALERTS_ENABLE_GLOW_ANIM"],
            db = dispelDB, key = "glowEnabled",
            x = 30, y = -62,
            template = "ChatConfigCheckButtonTemplate",
            onChange = RefreshAll,
        })
        W:CreateColorPicker(dispelContent, {
            label = L["COMMON_LABEL_COLOR"],
            db = dispelDB,
            rKey = "colorR", gKey = "colorG", bKey = "colorB",
            x = 10, y = -95,
            noClassColor = true,
            onChange = RefreshAll,
        })
        W:CreateDropdown(dispelContent, {
            label = L["BWV2_GLOW_TYPE"],
            db = dispelDB, key = "glowType",
            options = {
                { text = "Pixel", value = "pixel" },
                { text = "Autocast", value = "autocast" },
                { text = "Button", value = "button" },
                { text = "Proc", value = "proc" },
            },
            x = 210, y = -92,
            width = 150,
            onChange = RefreshAll,
        })
        CreateNote(dispelContent, L["ALERTS_DISPEL_GLOW_NOTE"], 10, -130, 560)
        dispelContent:SetHeight(185)
        dispelWrap:RecalcHeight()

        local potDB = NaowhQOL.potionReady
        local potWrap, potContent = W:CreateCollapsibleSection(sections, {
            text = L["ALERTS_POTION_READY"],
            startOpen = false,
            onCollapse = function() if RelayoutSections then RelayoutSections() end end,
        })
        sectionList[#sectionList + 1] = potWrap

        W:CreateCheckbox(potContent, {
            label = L["ALERTS_ENABLE_POTION"],
            db = potDB, key = "enabled",
            x = 10, y = -5,
            isMaster = true,
            onChange = RefreshAll,
        })
        W:CreateCheckbox(potContent, {
            label = L["COMMON_UNLOCK"],
            db = potDB, key = "unlock",
            x = 260, y = -5,
            template = "ChatConfigCheckButtonTemplate",
            onChange = RefreshAll,
        })
        W:CreateTextInput(potContent, {
            label = L["ALERTS_POTION_TEXT"],
            db = potDB, key = "text",
            default = "Potion ready",
            x = 10, y = -42,
            width = 150,
            onChange = RefreshAll,
        })
        W:CreateFontPicker(potContent, 10, -85, potDB.font or ns.Media.DEFAULT_FONT, function(name)
            potDB.font = name
            RefreshAll()
        end)
        PlaceSlider(W:CreateAdvancedSlider(potContent,
            W.Colorize(L["COMMON_LABEL_FONT_SIZE"], C.ORANGE), 10, 60, -120, 1, false,
            function(val) potDB.fontSize = val; RefreshAll() end,
            { db = potDB, key = "fontSize", moduleName = "potionReady" }), potContent, 285, -82)
        W:CreateColorPicker(potContent, {
            label = L["COMMON_LABEL_TEXT_COLOR"],
            db = potDB,
            rKey = "colorR", gKey = "colorG", bKey = "colorB",
            x = 10, y = -145,
            noClassColor = true,
            onChange = RefreshAll,
        })
        W:CreateSlider(potContent, {
            label = L["COMMON_ALPHA"],
            min = 0.1, max = 1, step = 0.05,
            x = 260, y = -142,
            db = potDB, key = "alpha",
            onChange = function(val) potDB.alpha = val; RefreshAll() end,
        })
        W:CreateCheckbox(potContent, {
            label = L["GCD_COMBAT_ONLY"],
            db = potDB, key = "combatOnly",
            x = 10, y = -200,
            template = "ChatConfigCheckButtonTemplate",
            onChange = RefreshAll,
        })
        W:CreateCheckbox(potContent, {
            label = L["ALERTS_INSTANCE_ONLY"],
            db = potDB, key = "instanceOnly",
            x = 180, y = -200,
            template = "ChatConfigCheckButtonTemplate",
            onChange = RefreshAll,
        })
        W:CreateCheckbox(potContent, {
            label = L["ALERTS_DISABLE_HEALER"],
            db = potDB, key = "disableOnHealer",
            x = 10, y = -228,
            template = "ChatConfigCheckButtonTemplate",
            onChange = RefreshAll,
        })
        W:CreateCheckbox(potContent, {
            label = L["COMMON_LABEL_ENABLE_SOUND"],
            db = potDB, key = "soundEnabled",
            x = 10, y = -260,
            template = "ChatConfigCheckButtonTemplate",
            onChange = RefreshAll,
        })
        W:CreateSoundPicker(potContent, 190, -254, potDB.soundID or ns.Media.DEFAULT_SOUND, function(sound)
            potDB.soundID = sound
            RefreshAll()
        end)
        W:CreateCheckbox(potContent, {
            label = L["ALERTS_ENABLE_GLOW_ANIM"],
            db = potDB, key = "glowEnabled",
            x = 10, y = -300,
            template = "ChatConfigCheckButtonTemplate",
            onChange = RefreshAll,
        })
        W:CreateDropdown(potContent, {
            label = L["BWV2_GLOW_TYPE"],
            db = potDB, key = "glowType",
            options = {
                { text = "Pixel", value = "pixel" },
                { text = "Autocast", value = "autocast" },
                { text = "Button", value = "button" },
                { text = "Proc", value = "proc" },
            },
            x = 260, y = -300,
            width = 150,
            onChange = RefreshAll,
        })

        local potPosFrame = CreateFrame("Frame", nil, potContent)
        potPosFrame:SetPoint("TOPLEFT", 0, -330)
        potPosFrame:SetSize(500, 120)
        W:CreatePositionControls(potPosFrame, {
            db = potDB,
            moduleName = "potionReady",
            pointKey = "point",
            display = ns.PotionReadyDisplay and ns.PotionReadyDisplay.Frame,
            onChange = RefreshAll,
        })

        CreateNote(potContent, L["ALERTS_POTION_READY_NOTE"], 10, -440, 560)

        potContent:SetHeight(490)
        potWrap:RecalcHeight()

        RelayoutSections = function()
            local totalH = 0
            for i, section in ipairs(sectionList) do
                section:ClearAllPoints()
                if i == 1 then
                    section:SetPoint("TOPLEFT", sections, "TOPLEFT", 0, 0)
                else
                    section:SetPoint("TOPLEFT", sectionList[i - 1], "BOTTOMLEFT", 0, -12)
                end
                section:SetPoint("RIGHT", sections, "RIGHT", 0, 0)
                totalH = totalH + section:GetHeight() + 12
            end
            sections:SetHeight(math.max(totalH, 1))
            sc:SetHeight(math.max(75 + totalH + 60, 600))
        end

        RelayoutSections()
    end)
end
