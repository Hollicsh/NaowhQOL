local addonName, ns = ...

local NaowhOrange = { r = 255/255, g = 169/255, b = 0/255 }
local NaowhDarkBlue = { r = 0.00, g = 0.49, b = 0.79 }

local MainWindow = CreateFrame("Frame", "NaowhQOL_MainFrame", UIParent, "BackdropTemplate")
MainWindow:SetSize(950, 650)
MainWindow:SetPoint("CENTER")
MainWindow:SetFrameStrata("HIGH")
MainWindow:SetMovable(true)
MainWindow:SetResizable(true)
MainWindow:SetResizeBounds(400, 300, 1400, 900)
MainWindow:EnableMouse(true)
MainWindow:RegisterForDrag("LeftButton")
local function ClampFrameToScreen(frame)
    local width, height = frame:GetSize()
    local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
    local minVisibleW = width * 0.10
    local minVisibleH = height * 0.10

    local left = frame:GetLeft()
    local right = frame:GetRight()
    local top = frame:GetTop()
    local bottom = frame:GetBottom()

    if not left or not right or not top or not bottom then return end

    local needsClamp = false
    local clampedLeft, clampedTop = left, top

    if right < minVisibleW then
        clampedLeft = minVisibleW - width
        needsClamp = true
    elseif left > screenWidth - minVisibleW then
        clampedLeft = screenWidth - minVisibleW
        needsClamp = true
    end

    if top < minVisibleH then
        clampedTop = minVisibleH
        needsClamp = true
    elseif bottom > screenHeight - minVisibleH then
        clampedTop = screenHeight - minVisibleH + height
        needsClamp = true
    end

    if needsClamp then
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", clampedLeft, clampedTop)
    end
end

MainWindow:SetScript("OnDragStart", MainWindow.StartMoving)
MainWindow:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    ClampFrameToScreen(self)
end)
MainWindow:SetScript("OnShow", function(self)
    ClampFrameToScreen(self)
end)
MainWindow:Hide()

MainWindow:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
MainWindow:SetBackdropColor(0.02, 0.02, 0.02, 0.95)
MainWindow:SetBackdropBorderColor(NaowhDarkBlue.r, NaowhDarkBlue.g, NaowhDarkBlue.b, 0.7)

tinsert(UISpecialFrames, MainWindow:GetName())

local TopAccent = MainWindow:CreateTexture(nil, "OVERLAY")
TopAccent:SetHeight(3)
TopAccent:SetPoint("TOPLEFT", 1, -1)
TopAccent:SetPoint("TOPRIGHT", -1, -1)
TopAccent:SetColorTexture(NaowhOrange.r, NaowhOrange.g, NaowhOrange.b, 1)

local BottomAccent = MainWindow:CreateTexture(nil, "OVERLAY")
BottomAccent:SetHeight(2)
BottomAccent:SetPoint("BOTTOMLEFT", 1, 1)
BottomAccent:SetPoint("BOTTOMRIGHT", -1, 1)
BottomAccent:SetColorTexture(NaowhDarkBlue.r, NaowhDarkBlue.g, NaowhDarkBlue.b, 0.7)

local CloseButton = CreateFrame("Button", nil, MainWindow, "UIPanelCloseButton")
CloseButton:SetPoint("TOPRIGHT", -3, -3)
CloseButton:SetSize(32, 32)

do
    local srchBlue   = { r = 0.00, g = 0.49, b = 0.79 }
    local srchOrange = { r = 1.00, g = 0.66, b = 0.00 }
    local SRCH_H, SRCH_MAX = 26, 8
    local srchBtns = {}

    local SearchBox = CreateFrame("EditBox", nil, MainWindow, "BackdropTemplate")
    SearchBox:SetSize(160, 24)
    SearchBox:SetPoint("TOPRIGHT", MainWindow, "TOPRIGHT", -40, -11)
    SearchBox:SetBackdrop({
        bgFile   = [[Interface\Buttons\WHITE8X8]],
        edgeFile = [[Interface\Buttons\WHITE8X8]],
        edgeSize = 1,
    })
    SearchBox:SetBackdropColor(0.04, 0.04, 0.04, 0.95)
    SearchBox:SetBackdropBorderColor(srchBlue.r, srchBlue.g, srchBlue.b, 0.5)
    SearchBox:SetFont([[Interface\AddOns\NaowhQOL\Assets\Fonts\Naowh.ttf]], 11, "")
    SearchBox:SetTextColor(1, 1, 1, 0.9)
    SearchBox:SetTextInsets(22, 6, 0, 0)
    SearchBox:SetAutoFocus(false)
    SearchBox:SetMaxLetters(50)

    local MagIcon = SearchBox:CreateTexture(nil, "OVERLAY")
    MagIcon:SetSize(13, 13)
    MagIcon:SetPoint("LEFT", SearchBox, "LEFT", 5, 0)
    MagIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
    MagIcon:SetVertexColor(0.6, 0.6, 0.6, 0.9)

    local Placeholder = SearchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    Placeholder:SetPoint("LEFT",  SearchBox, "LEFT",  22, 0)
    Placeholder:SetPoint("RIGHT", SearchBox, "RIGHT", -6, 0)
    Placeholder:SetJustifyH("LEFT")
    Placeholder:SetNonSpaceWrap(false)
    Placeholder:SetText("Search")

    local Results = CreateFrame("Frame", nil, MainWindow, "BackdropTemplate")
    Results:SetWidth(200)
    Results:SetPoint("TOPRIGHT", SearchBox, "BOTTOMRIGHT", 0, -2)
    Results:SetFrameStrata("DIALOG")
    Results:SetFrameLevel(300)
    Results:SetBackdrop({
        bgFile   = [[Interface\Buttons\WHITE8X8]],
        edgeFile = [[Interface\Buttons\WHITE8X8]],
        edgeSize = 1,
    })
    Results:SetBackdropColor(0.04, 0.04, 0.04, 0.97)
    Results:SetBackdropBorderColor(srchBlue.r, srchBlue.g, srchBlue.b, 0.6)
    Results:Hide()

    local function ClearBtns()
        for _, b in ipairs(srchBtns) do b:Hide() end
    end

    local function GetBtn(i)
        if srchBtns[i] then return srchBtns[i] end
        local b = CreateFrame("Button", nil, Results, "BackdropTemplate")
        b:SetSize(198, SRCH_H - 2)
        b:SetPoint("TOPLEFT", 1, -((i - 1) * SRCH_H) - 1)
        b:SetBackdrop({ bgFile = [[Interface\Buttons\WHITE8X8]] })
        b:SetBackdropColor(0.04, 0.04, 0.04, 0)
        local t = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        t:SetPoint("LEFT",  b, "LEFT",  8, 0)
        t:SetPoint("RIGHT", b, "RIGHT", -8, 0)
        t:SetJustifyH("LEFT")
        t:SetNonSpaceWrap(false)
        t:SetTextColor(1, 1, 1, 0.9)
        b.lbl = t
        b:SetScript("OnEnter", function(self) self:SetBackdropColor(srchOrange.r, srchOrange.g, srchOrange.b, 0.2) end)
        b:SetScript("OnLeave", function(self) self:SetBackdropColor(0.04, 0.04, 0.04, 0) end)
        srchBtns[i] = b
        return b
    end

    local function DoSearch(query)
        ClearBtns()
        if not query or query == "" then Results:Hide() return end
        query = strlower(strtrim(query))
        local reg    = ns.MODULE_REGISTRY
        local dnames = ns.MODULE_DISPLAY_NAMES
        local kws    = ns.MODULE_KEYWORDS
        if not reg then Results:Hide() return end
        local seen, count = {}, 0
        for _, e in ipairs(reg) do
            if count >= SRCH_MAX then break end
            local dn = (dnames and dnames[e.db]) or e.db
            if strlower(dn):find(query, 1, true) and not seen[e.db] then
                seen[e.db] = true; count = count + 1
                local b = GetBtn(count)
                b.lbl:SetText("|cffffa900\194\187|r " .. dn)
                b:SetScript("OnClick", function()
                    SearchBox:SetText(""); Placeholder:Show(); Results:Hide()
                    if e.tab and ns.OpenTab then ns:OpenTab(e.tab) end
                end)
                b:Show()
            end
        end
        if kws then
            for _, e in ipairs(reg) do
                if count >= SRCH_MAX then break end
                if not seen[e.db] and kws[e.db] then
                    for _, kw in ipairs(kws[e.db]) do
                        if strlower(kw):find(query, 1, true) then
                            seen[e.db] = true; count = count + 1
                            local dn = (dnames and dnames[e.db]) or e.db
                            local b = GetBtn(count)
                            b.lbl:SetText("|cffffa900\194\187|r " .. dn .. " |cff666666\226\128\186 " .. kw .. "|r")
                            b:SetScript("OnClick", function()
                                SearchBox:SetText(""); Placeholder:Show(); Results:Hide()
                                if e.tab and ns.OpenTab then ns:OpenTab(e.tab) end
                            end)
                            b:Show(); break
                        end
                    end
                end
            end
        end
        if count == 0 then
            local b = GetBtn(1)
            b.lbl:SetText("|cff666666No results found.|r")
            b:SetScript("OnClick", nil); b:Show(); count = 1
        end
        Results:SetHeight(count * SRCH_H + 2)
        Results:Show()
    end

    SearchBox:SetScript("OnEditFocusGained", function(self)
        Placeholder:Hide()
        MagIcon:Hide()
        self:SetBackdropBorderColor(srchOrange.r, srchOrange.g, srchOrange.b, 0.9)
        self:SetTextInsets(6, 6, 0, 0)
        if self:GetText() ~= "" then DoSearch(self:GetText()) end
    end)
    SearchBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            Placeholder:Show()
            MagIcon:Show()
            self:SetTextInsets(22, 6, 0, 0)
        end
        self:SetBackdropBorderColor(srchBlue.r, srchBlue.g, srchBlue.b, 0.5)
        C_Timer.After(0.15, function()
            if not SearchBox:HasFocus() then Results:Hide() end
        end)
    end)
    SearchBox:SetScript("OnTextChanged", function(self) DoSearch(self:GetText()) end)
    SearchBox:SetScript("OnEscapePressed", function(self)
        self:SetText(""); Placeholder:Show(); MagIcon:Show()
        self:SetTextInsets(22, 6, 0, 0)
        Results:Hide(); self:ClearFocus()
    end)
    SearchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
end

local ResizeHandle = CreateFrame("Button", nil, MainWindow)
ResizeHandle:SetSize(16, 16)
ResizeHandle:SetPoint("BOTTOMRIGHT", -2, 2)
ResizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
ResizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
ResizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
ResizeHandle:SetScript("OnMouseDown", function() MainWindow:StartSizing("BOTTOMRIGHT") end)
ResizeHandle:SetScript("OnMouseUp", function() MainWindow:StopMovingOrSizing() end)

local ContentArea = CreateFrame("Frame", nil, MainWindow, "BackdropTemplate")
ContentArea:SetPoint("TOPLEFT", 202, -5)
ContentArea:SetPoint("BOTTOMRIGHT", -2, 2)
ContentArea:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
ContentArea:SetBackdropColor(0, 0, 0, 0.3)
ContentArea:SetBackdropBorderColor(NaowhDarkBlue.r, NaowhDarkBlue.g, NaowhDarkBlue.b, 0.35)
ContentArea:SetClipsChildren(false)

MainWindow.Content = ContentArea

function MainWindow:ResetContent()
    if ContentArea then
        local children = {ContentArea:GetChildren()}
        for _, child in ipairs(children) do
            if child then
                child:Hide()
            end
        end

        local regions = {ContentArea:GetRegions()}
        for _, region in ipairs(regions) do
            if region and region.Hide then
                region:Hide()
            end
        end
    end
end

ns.MainFrame = MainWindow

SLASH_NAOWHQOL1 = "/nao"
SLASH_NAOWHQOL2 = "/nqol"

SlashCmdList["NAOWHQOL"] = function()
    if MainWindow:IsShown() then
        MainWindow:Hide()
    else
        MainWindow:Show()
        if MainWindow.ResetContent then
            MainWindow:ResetContent()
        end
        local lastTab = NaowhQOL and NaowhQOL.config and NaowhQOL.config.lastTab
        if lastTab and ns.OpenTab then
            ns:OpenTab(lastTab)
        else
            if ns.InitOptOptions then
                ns:InitOptOptions()
            end
            if ns.ResetSidebarToOptimizations then
                ns:ResetSidebarToOptimizations()
            end
        end
    end
end

function NaowhQOL_OnAddonCompartmentClick(addonName, buttonName)
    SlashCmdList["NAOWHQOL"]()
end

do
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local panel = CreateFrame("Frame")
        panel.name = "NaowhQOL"

        local bg = panel:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.02, 0.02, 0.02, 0.6)

        local icon = panel:CreateTexture(nil, "ARTWORK")
        icon:SetSize(64, 64)
        icon:SetPoint("TOP", 0, -40)
        icon:SetTexture("Interface\\AddOns\\NaowhQOL\\Assets\\LogoAddon.tga")

        local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", icon, "BOTTOM", 0, -12)
        title:SetText("|cff0091edNaowh|r|cffffa300QOL|r")

        local sub = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        sub:SetPoint("TOP", title, "BOTTOM", 0, -6)
        sub:SetText("Quality of Life improvements")

        local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        btn:SetSize(180, 32)
        btn:SetPoint("TOP", sub, "BOTTOM", 0, -20)
        btn:SetText("Open NaowhQOL")
        btn:SetScript("OnClick", function()
            C_Timer.After(0, function()
                SlashCmdList["NAOWHQOL"]()
            end)
        end)

        local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        hint:SetPoint("TOP", btn, "BOTTOM", 0, -10)
        hint:SetText("or type  /nao  in chat")

        local category = Settings.RegisterCanvasLayoutCategory(panel, "NaowhQOL")
        category.ID = "NaowhQOL"
        Settings.RegisterAddOnCategory(category)
    end
end

local WelcomeFrame = CreateFrame("Frame")
WelcomeFrame:RegisterEvent("PLAYER_LOGIN")
WelcomeFrame:SetScript("OnEvent", function()
    if NaowhQOL and NaowhQOL.general and NaowhQOL.general.disableLoginMessage then return end
    ns:Log("Loaded. Type |cff00ff00/nao|r to open settings.")
end)

function ns:InitHomePage()
    local p = ns.MainFrame.Content
    local L = ns.L

    local iconFrame = CreateFrame("Frame", nil, p)
    iconFrame:SetSize(200, 200)
    iconFrame:SetPoint("CENTER", 0, 40)

    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture("Interface\\AddOns\\NaowhQOL\\Assets\\welcomeicon.tga")
    icon:SetAlpha(0.4)

    local mask = iconFrame:CreateMaskTexture()
    mask:SetAllPoints()
    mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    icon:AddMaskTexture(mask)

    local subtitle = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("TOP", iconFrame, "BOTTOM", 0, -15)
    subtitle:SetText(L["HOME_SUBTITLE"])
    subtitle:SetTextColor(0.6, 0.6, 0.6, 1)
end
