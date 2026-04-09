local addonName, ns = ...
local L = ns.L
local W = ns.Widgets

local isMounted = false
local isInVehicle = false
local isDead = false
local isInCombat = false
local dismountTimer = nil
local DISMOUNT_DELAY = 5

local WARNING_NONE = 0
local WARNING_MISSING = 1
local WARNING_PASSIVE = 2
local WARNING_WRONG_PET = 3
local WARNING_LOW_HEALTH = 4

local UNLOCK_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local HUNTER_NO_PET_TALENTS = { 466846, 1232995, 1223323 }
local GRIMOIRE_OF_SACRIFICE = 108503
local GRIMOIRE_SACRIFICE_BUFF = 196099
local FELGUARD_SPELL = 30146
local WATER_ELEMENTAL_SPELL = 31687
local DEMONOLOGY_SPEC = 2
local UNHOLY_SPEC = 3
local FROST_MAGE_SPEC = 3

local function IsPetClass()
    local cls = ns.SpecUtil.GetClassName()
    return cls == "HUNTER" or cls == "WARLOCK" or cls == "DEATHKNIGHT" or cls == "MAGE"
end

local function ShouldHavePet()
    local cls = ns.SpecUtil.GetClassName()
    local specIdx = ns.SpecUtil.GetSpecIndex()

    if cls == "HUNTER" then
        for _, spellID in ipairs(HUNTER_NO_PET_TALENTS) do
            if ns.IsPlayerSpell(spellID) then
                return false
            end
        end
        return true

    elseif cls == "WARLOCK" then
        if ns.IsPlayerSpell(GRIMOIRE_OF_SACRIFICE) then
            local auraData = C_UnitAuras.GetPlayerAuraBySpellID(GRIMOIRE_SACRIFICE_BUFF)
            if auraData then
                return false
            end
        end
        return true

    elseif cls == "DEATHKNIGHT" then
        return specIdx == UNHOLY_SPEC

    elseif cls == "MAGE" then
        if specIdx == FROST_MAGE_SPEC then
            return ns.IsPlayerSpell(WATER_ELEMENTAL_SPELL)
        end
        return false
    end

    return false
end

local healthCurves = {}
local function GetHealthCurve(thresholdPct)
    thresholdPct = math.max(1, math.min(100, thresholdPct or 30))
    if healthCurves[thresholdPct] then return healthCurves[thresholdPct] end
    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    curve:AddPoint(0, CreateColor(1, 1, 1, 1))
    curve:AddPoint(thresholdPct / 100, CreateColor(1, 1, 1, 0))
    healthCurves[thresholdPct] = curve
    return curve
end

local function GetPetLowHealthAlpha(thresholdPct)
    if not UnitHealthPercent then return nil end
    if not UnitExists("pet") or UnitIsDeadOrGhost("pet") then return nil end
    local curve = GetHealthCurve(thresholdPct)
    local ok, color = pcall(UnitHealthPercent, "pet", false, curve)
    if not ok or not color or type(color.GetRGBA) ~= "function" then return nil end
    local _, _, _, a = color:GetRGBA()
    return a
end

local function IsPetPassive()
    if not PetHasActionBar() then return false end

    for i = 1, NUM_PET_ACTION_SLOTS or 10 do
        local name, _, _, isActive = GetPetActionInfo(i)
        if name == "PET_MODE_PASSIVE" and isActive then
            return true
        end
    end
    return false
end

local FELGUARD_FAMILY_NAMES = {
    ["enUS"] = "felguard",
    ["enGB"] = "felguard",
    ["deDE"] = "teufelswache",
    ["esES"] = "guardia vil",
    ["esMX"] = "guardia vil",
    ["frFR"] = "gangregarde",
    ["koKR"] = "지옥수호병",
    ["ptBR"] = "guarda vil",
    ["ruRU"] = "страж скверны",
    ["zhCN"] = "恶魔卫士",
    ["zhTW"] = "惡魔守衛",
}

local function IsWrongPet()
    local cls = ns.SpecUtil.GetClassName()
    local specIdx = ns.SpecUtil.GetSpecIndex()

    if cls == "WARLOCK" and specIdx == DEMONOLOGY_SPEC then
        if ns.IsPlayerSpell(FELGUARD_SPELL) then
            local petFamily = UnitCreatureFamily("pet")
            if petFamily then
                local lowerFamily = petFamily:lower()

                local locale = GetLocale()
                local builtIn = FELGUARD_FAMILY_NAMES[locale]
                if builtIn and lowerFamily:find(builtIn, 1, true) then
                    return false
                end

                local db = NaowhQOL.petTracker
                local felguardNames = db and db.felguardFamily
                if felguardNames and felguardNames ~= "" then
                    for name in felguardNames:gmatch("[^,]+") do
                        local trimmed = name:match("^%s*(.-)%s*$"):lower()
                        if trimmed ~= "" and lowerFamily:find(trimmed, 1, true) then
                            return false
                        end
                    end
                end

                return true
            end
        end
    end
    return false
end

local function EvaluateWarning()
    local db = NaowhQOL.petTracker
    if not db or not db.enabled then return WARNING_NONE end

    if not IsPetClass() then return WARNING_NONE end

    if isDead or isInVehicle then return WARNING_NONE end

    if db.hideWhenMounted and isMounted then return WARNING_NONE end

    if db.combatOnly and not isInCombat then return WARNING_NONE end

    if db.onlyInInstance then
        local inInstance = IsInInstance()
        if not inInstance then return WARNING_NONE end
    end

    if not ShouldHavePet() then return WARNING_NONE end

    if not UnitExists("pet") then
        return WARNING_MISSING
    end

    if IsWrongPet() then
        return WARNING_WRONG_PET
    end

    if IsPetPassive() then
        if not db.showPassive then return WARNING_NONE end
        return WARNING_PASSIVE
    end

    return WARNING_NONE
end

local petFrame = CreateFrame("Frame", "NaowhQOL_PetTracker", UIParent, "BackdropTemplate")
petFrame:SetSize(200, 50)
petFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
petFrame:Hide()

local iconTexture = petFrame:CreateTexture(nil, "ARTWORK")
iconTexture:SetSize(32, 32)
iconTexture:SetPoint("LEFT", petFrame, "LEFT", 10, 0)
iconTexture:SetTexture(132161)

local warningLabel = petFrame:CreateFontString(nil, "OVERLAY")
warningLabel:SetFont(ns.DefaultFontPath(), 20, "OUTLINE")
warningLabel:SetPoint("CENTER")

local resizeHandle

function petFrame:UpdateDisplay()
    local db = NaowhQOL.petTracker
    if not db then return end

    local canUnlock = db.enabled and db.unlock
    petFrame:EnableMouse(canUnlock)
    if canUnlock then
        petFrame:SetBackdrop(UNLOCK_BACKDROP)
        petFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        petFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        if resizeHandle then resizeHandle:Show() end
        petFrame:Show()
    else
        petFrame:SetBackdrop(nil)
        if resizeHandle then resizeHandle:Hide() end
    end

    if not petFrame.initialized then
        petFrame:ClearAllPoints()
        local point = db.point or "CENTER"
        local x = db.x or 0
        local y = db.y or 200
        petFrame:SetPoint(point, UIParent, point, x, y)
        petFrame:SetSize(db.width or 200, db.height or 50)
        petFrame.initialized = true
    end

    local fontSize = math.max(12, math.min(48, db.textSize or 20))
    local fontPath = ns.Media.ResolveFont(db.font)
    warningLabel:SetFont(fontPath, fontSize, "OUTLINE")

    if db.showIcon then
        iconTexture:Show()
        iconTexture:SetSize(db.iconSize or 32, db.iconSize or 32)
        warningLabel:ClearAllPoints()
        warningLabel:SetPoint("LEFT", iconTexture, "RIGHT", 8, 0)
    else
        iconTexture:Hide()
        warningLabel:ClearAllPoints()
        warningLabel:SetPoint("CENTER")
    end

    local warning = EvaluateWarning()

    local r, g, b = W.GetEffectiveColor(db, "colorR", "colorG", "colorB", "colorUseClassColor")

    if warning == WARNING_NONE then
        if db.lowHealthEnabled then
            local threshold = db.lowHealthThreshold or 25
            local alpha = GetPetLowHealthAlpha(threshold)
            if alpha ~= nil then
                warningLabel:SetText(db.lowHealthText or L["PETTRACKER_LOW_HEALTH_DEFAULT"])
                warningLabel:SetTextColor(r, g, b)
                pcall(petFrame.SetAlpha, petFrame, alpha)
                petFrame:Show()
                return
            end
        end
        pcall(petFrame.SetAlpha, petFrame, 1)
        if not canUnlock then
            petFrame:Hide()
        else
            warningLabel:SetText(db.missingText or L["PETTRACKER_MISSING_DEFAULT"])
            warningLabel:SetTextColor(0.5, 0.5, 0.5)
        end
        return
    end

    pcall(petFrame.SetAlpha, petFrame, 1)

    if warning == WARNING_MISSING then
        warningLabel:SetText(db.missingText or L["PETTRACKER_MISSING_DEFAULT"])
        warningLabel:SetTextColor(r, g, b)
    elseif warning == WARNING_PASSIVE then
        warningLabel:SetText(db.passiveText or L["PETTRACKER_PASSIVE_DEFAULT"])
        warningLabel:SetTextColor(r, g, b)
    elseif warning == WARNING_WRONG_PET then
        warningLabel:SetText(db.wrongPetText or L["PETTRACKER_WRONGPET_DEFAULT"])
        warningLabel:SetTextColor(r, g, b)
    end

    petFrame:Show()
end

local function CancelDismountTimer()
    if dismountTimer then
        dismountTimer:Cancel()
        dismountTimer = nil
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("UNIT_PET")
loader:RegisterEvent("PET_BAR_UPDATE")
loader:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
loader:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
loader:RegisterEvent("UNIT_ENTERED_VEHICLE")
loader:RegisterEvent("UNIT_EXITED_VEHICLE")
loader:RegisterEvent("PLAYER_DEAD")
loader:RegisterEvent("PLAYER_ALIVE")
loader:RegisterEvent("PLAYER_UNGHOST")
loader:RegisterEvent("SPELLS_CHANGED")
loader:RegisterEvent("PLAYER_REGEN_DISABLED")
loader:RegisterEvent("PLAYER_REGEN_ENABLED")
loader:RegisterEvent("UNIT_HEALTH")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")

loader:SetScript("OnEvent", ns.PerfMonitor:Wrap("PetTracker", function(self, event, unit)
    local db = NaowhQOL.petTracker
    if not db then return end

    if event == "PLAYER_LOGIN" then
        isMounted = IsMounted()
        isInVehicle = UnitInVehicle("player")
        isDead = UnitIsDeadOrGhost("player")
        isInCombat = UnitAffectingCombat("player")

        db.width = db.width or 200
        db.height = db.height or 50
        db.point = db.point or "CENTER"
        db.x = db.x or 0
        db.y = db.y or 200

        W.MakeDraggable(petFrame, { db = db })
        resizeHandle = W.CreateResizeHandle(petFrame, {
            db = db,
            onResize = function() petFrame:UpdateDisplay() end,
        })

        petFrame.initialized = false
        petFrame:UpdateDisplay()

        ns.SpecUtil.RegisterCallback("PetTracker", function()
            petFrame:UpdateDisplay()
        end)

        ns.SettingsIO:RegisterRefresh("petTracker", function()
            petFrame:UpdateDisplay()
        end)

        return
    end

    if event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
        local wasMounted = isMounted
        isMounted = IsMounted()

        if wasMounted and not isMounted then
            CancelDismountTimer()
            dismountTimer = C_Timer.NewTimer(DISMOUNT_DELAY, function()
                dismountTimer = nil
                petFrame:UpdateDisplay()
            end)
            return
        elseif isMounted then
            CancelDismountTimer()
        end
    elseif event == "UNIT_ENTERED_VEHICLE" and unit == "player" then
        isInVehicle = true
    elseif event == "UNIT_EXITED_VEHICLE" and unit == "player" then
        isInVehicle = false
    elseif event == "PLAYER_DEAD" then
        isDead = true
    elseif event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" then
        isDead = false
    elseif event == "PLAYER_REGEN_DISABLED" then
        isInCombat = true
    elseif event == "PLAYER_REGEN_ENABLED" then
        isInCombat = false
    elseif event == "PLAYER_ENTERING_WORLD" then
        isMounted = IsMounted()
        isInVehicle = UnitInVehicle("player")
        isDead = UnitIsDeadOrGhost("player")
        isInCombat = UnitAffectingCombat("player")
    elseif event == "UNIT_PET" then
        CancelDismountTimer()
    elseif event == "UNIT_HEALTH" then
        if unit ~= "pet" then return end
    end

    petFrame:UpdateDisplay()
end))

ns.PetTrackerDisplay = petFrame
