local addonName, ns = ...
if not ns then return end

local M = {}
ns.GlobalFonts = M

local DEFAULT_FONT = "Naowh"

local QOL_FONT_KEYS = {
    { db = "combatTimer",     key = "font" },
    { db = "combatAlert",     key = "font" },
    { db = "stealthReminder", key = "font" },
    { db = "stealthReminder", key = "stanceFont" },
    { db = "movementAlert",   key = "font" },
    { db = "rangeCheck",      key = "rangeFont" },
    { db = "emoteDetection",  key = "font" },
    { db = "focusCastBar",    key = "font" },
    { db = "dragonriding",    key = "speedFont" },
    { db = "buffTracker",     key = "font" },
    { db = "petTracker",      key = "font" },
    { db = "misc",            key = "durabilityFont" },
    { db = "cRez",            key = "font" },
    { db = "coTank",          key = "font" },
    { db = "potionReady",     key = "font" },
}

local UI_FONT_OBJECTS = {
    "SystemFont_Tiny",
    "SystemFont_Small",
    "SystemFont_Small2",
    "SystemFont_Med1",
    "SystemFont_Med2",
    "SystemFont_Med3",
    "SystemFont_Large",
    "SystemFont_Huge1",
    "SystemFont_Huge1_Outline",
    "SystemFont_Huge2",
    "SystemFont_Shadow_Small",
    "SystemFont_Shadow_Med1",
    "SystemFont_Shadow_Med2",
    "SystemFont_Shadow_Med3",
    "SystemFont_Shadow_Large",
    "SystemFont_Shadow_Large2",
    "SystemFont_Shadow_Huge1",
    "SystemFont_Shadow_Huge2",
    "SystemFont_Outline",
    "SystemFont_Outline_Small",
    "SystemFont_OutlineThick_Huge2",
    "SystemFont_OutlineThick_WTF",
    "SystemFont_NamePlate",
    "SystemFont_NamePlateFixed",
    "SystemFont_NamePlateCastBar",
    "SystemFont_NamePlate_Outlined",
    "SystemFont_LargeNamePlate",
    "SystemFont_LargeNamePlateFixed",

    "GameFontNormal",
    "GameFontNormalSmall",
    "GameFontNormalMed1",
    "GameFontNormalMed2",
    "GameFontNormalMed3",
    "GameFontNormalLarge",
    "GameFontNormalLarge2",
    "GameFontNormalHuge",
    "GameFontNormalHuge2",
    "GameFontHighlight",
    "GameFontHighlightSmall",
    "GameFontHighlightSmall2",
    "GameFontHighlightMedium",
    "GameFontHighlightLarge",
    "GameFontHighlightHuge",
    "GameFontHighlightHuge2",
    "GameFontDisable",
    "GameFontDisableSmall",
    "GameFontGreen",
    "GameFontRed",
    "GameFont_Gigantic",

    "Number11Font",
    "Number12Font",
    "Number12Font_o1",
    "Number13Font",
    "Number13FontGray",
    "Number13FontWhite",
    "Number13FontYellow",
    "Number14FontGray",
    "Number14FontWhite",
    "Number15Font",
    "Number18Font",
    "Number18FontWhite",
    "NumberFont_Small",
    "NumberFontNormalSmall",
    "NumberFontNormal",
    "NumberFont_Outline_Med",
    "NumberFont_Outline_Large",
    "NumberFont_Outline_Huge",
    "NumberFont_OutlineThick_Mono_Small",
    "NumberFont_Shadow_Small",
    "NumberFont_Shadow_Med",

    "ObjectiveTrackerHeaderFont",
    "ObjectiveTrackerLineFont",
    "ObjectiveTrackerFont12",
    "ObjectiveTrackerFont13",
    "ObjectiveTrackerFont14",
    "ObjectiveTrackerFont15",
    "ObjectiveTrackerFont16",
    "ObjectiveTrackerFont17",
    "ObjectiveTrackerFont18",
    "ObjectiveTrackerFont19",
    "ObjectiveTrackerFont20",
    "ObjectiveTrackerFont21",
    "ObjectiveTrackerFont22",

    "QuestFont",
    "QuestFont_Large",
    "QuestFont_Larger",
    "QuestFont_Huge",
    "QuestFont_Super_Huge",
    "QuestFont_Enormous",
    "QuestFont_Shadow_Small",
    "QuestFont_Shadow_Huge",
    "QuestFont_Shadow_Super_Huge",
    "QuestFont_Shadow_Enormous",
    "QuestFont_39",

    "ChatBubbleFont",
    "FriendsFont_Small",
    "FriendsFont_11",
    "FriendsFont_UserText",
    "FriendsFont_Normal",
    "FriendsFont_Large",
    "MailFont_Large",
    "InvoiceFont_Small",
    "InvoiceFont_Med",
    "Tooltip_Small",
    "Tooltip_Med",
    "GameTooltipHeader",
    "SpellFont_Small",
    "SubSpellFont",
    "ReputationDetailFont",
    "PriceFont",
    "WorldMapTextFont",
    "SubZoneTextFont",
    "ZoneTextFont",
    "PVPInfoTextFont",
    "PVPArenaTextString",
}

local function GetGeneralDB()
    return (NaowhQOL and NaowhQOL.general) or {}
end

local function ResolveFont(fontName)
    if ns.Media and ns.Media.ResolveFont then
        return ns.Media.ResolveFont(fontName or DEFAULT_FONT)
    end
    return "Fonts\\FRIZQT__.TTF"
end

function M:GetGlobalFontName()
    local db = GetGeneralDB()
    return db.globalFont or db.qolFont or db.globalGameFont or DEFAULT_FONT
end

function M:GetQOLFontName()
    return self:GetGlobalFontName()
end

function M:GetCombatFontName()
    local db = GetGeneralDB()
    if db.combatFontOverride and db.combatFont then
        return db.combatFont
    end
    return self:GetGlobalFontName()
end

function M:IsGameFontEnabled()
    local db = GetGeneralDB()
    return db.applyGameFontToBlizzard == true
end

local function ApplyFontObject(fontObject, fontPath, fallbackSize, fallbackFlags)
    if not fontObject or type(fontObject.SetFont) ~= "function" then
        return false
    end

    local size, flags
    if type(fontObject.GetFont) == "function" then
        local ok, _, currentSize, currentFlags = pcall(fontObject.GetFont, fontObject)
        if ok then
            size = currentSize
            flags = currentFlags
        end
    end

    size = size or fallbackSize or 12
    flags = flags or fallbackFlags or ""

    return pcall(fontObject.SetFont, fontObject, fontPath, size, flags)
end

function M:ApplyGameFont()
    if not self:IsGameFontEnabled() then
        return
    end

    local fontPath = ResolveFont(self:GetGlobalFontName())

    _G.STANDARD_TEXT_FONT = fontPath
    _G.UNIT_NAME_FONT = fontPath
    _G.NAMEPLATE_FONT = fontPath

    for _, objectName in ipairs(UI_FONT_OBJECTS) do
        ApplyFontObject(_G[objectName], fontPath)
    end
end

function M:ApplyCombatFont()
    local db = GetGeneralDB()
    if not db.combatFontOverride and not self:IsGameFontEnabled() then
        return
    end

    local fontPath = ResolveFont(self:GetCombatFontName())

    _G.DAMAGE_TEXT_FONT = fontPath
    ApplyFontObject(_G.CombatTextFont, fontPath, 120, "SHADOW")
end

function M:ApplyQOLFont(fontName)
    fontName = fontName or self:GetQOLFontName()

    for _, entry in ipairs(QOL_FONT_KEYS) do
        local modDb = NaowhQOL and NaowhQOL[entry.db]
        if modDb then
            modDb[entry.key] = fontName
        end
    end
end

function M:ApplyAll()
    self:ApplyQOLFont()
    self:ApplyGameFont()
    self:ApplyCombatFont()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, event, loadedAddon)
    if not NaowhQOL or not NaowhQOL.general then
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(0.25, function()
            if ns.GlobalFonts then
                ns.GlobalFonts:ApplyAll()
            end
        end)
    elseif loadedAddon and loadedAddon:match("^Blizzard_") then
        C_Timer.After(0, function()
            if ns.GlobalFonts then
                ns.GlobalFonts:ApplyAll()
            end
        end)
    end
end)
