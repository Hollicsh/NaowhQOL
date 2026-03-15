local addonName, ns = ...

NaowhQOL = NaowhQOL or {}

ns.notificationsSuppressed = false

local MIGRATION_DEBUG = false

local function DebugPrint(msg)
    if MIGRATION_DEBUG then
        print("|cff00aaff[NaowhQOL]|r " .. msg)
    end
end

local AceDB = LibStub("AceDB-3.0")

local function deepCopy(orig)
    if type(orig) ~= "table" then return orig end
    local copy = {}
    for k, v in pairs(orig) do
        copy[deepCopy(k)] = deepCopy(v)
    end
    return copy
end

local NAOWH_FONT = "Naowh"

local COMBAT_TIMER_DEFAULTS = {
    enabled = false, unlock = false, font = NAOWH_FONT,
    colorR = 1, colorG = 1, colorB = 1, useClassColor = false, point = "CENTER",
    x = 0, y = -200, width = 400, height = 100, hidePrefix = false,
    instanceOnly = false, chatReport = true, stickyTimer = false,
    showBackground = false,
}

local COMBAT_ALERT_DEFAULTS = {
    enabled = false, unlock = false, font = NAOWH_FONT,
    enterR = 0, enterG = 1, enterB = 0, leaveR = 1, leaveG = 0, leaveB = 0,
    point = "CENTER", x = 0, y = 100, width = 200, height = 50,
    enterText = "+Combat", leaveText = "-Combat",
    enterAudioMode = "none", enterSound = "Raid Warning",
    enterTtsMessage = "Combat", enterTtsVolume = 50, enterTtsRate = 0, enterTtsVoiceID = 0,
    leaveAudioMode = "none", leaveSound = "Raid Warning",
    leaveTtsMessage = "Safe", leaveTtsVolume = 50, leaveTtsRate = 0, leaveTtsVoiceID = 0,
}

local CROSSHAIR_DEFAULTS = {
    enabled = false, size = 20, thickness = 2, gap = 6,
    colorR = 0, colorG = 1, colorB = 0, useClassColor = false, opacity = 0.8,
    offsetX = 0, offsetY = 0, combatOnly = false,
    dotEnabled = false, dotSize = 2,
    outlineEnabled = true, outlineWeight = 1,
    outlineR = 0, outlineG = 0, outlineB = 0, rotation = 0,
    showTop = true, showRight = true, showBottom = true, showLeft = true,
    dualColor = false, color2R = 1, color2G = 0, color2B = 0,
    circleEnabled = false, circleSize = 30, circleR = 0, circleG = 1, circleB = 0,
    hideWhileMounted = false, meleeRecolor = false,
    meleeRecolorBorder = true, meleeRecolorArms = false,
    meleeRecolorDot = false, meleeRecolorCircle = false,
    meleeOutColorR = 1, meleeOutColorG = 0, meleeOutColorB = 0,
    meleeSoundEnabled = false, meleeSoundID = "Raid Warning", meleeSoundInterval = 3,
}

local COMBAT_LOGGER_DEFAULTS = {
    enabled = false,
}

local DRAGONRIDING_DEFAULTS = {
    enabled = false, barWidth = 36, speedHeight = 14, chargeHeight = 14,
    gap = 0, showSpeedText = true, swapPosition = false, hideWhenGroundedFull = false,
    showSecondWind = true, showWhirlingSurge = true, colorPreset = "Classic",
    unlocked = false, point = "BOTTOM", posX = 0, posY = 200,
    barStyle = "Solid",
    speedColorR = 0.00, speedColorG = 0.49, speedColorB = 0.79,
    thrillColorR = 1.00, thrillColorG = 0.66, thrillColorB = 0.00,
    chargeColorR = 0.01, chargeColorG = 0.56, chargeColorB = 0.91,
    speedFont = NAOWH_FONT, speedFontSize = 12,
    speedTextOffsetX = 0, speedTextOffsetY = 0,
    surgeIconSize = 0, surgeAnchor = "RIGHT", surgeOffsetX = 6, surgeOffsetY = 0,
    anchorFrame = "UIParent", anchorTo = "BOTTOM", matchAnchorWidth = false,
    bgColorR = 0.12, bgColorG = 0.12, bgColorB = 0.12, bgAlpha = 0.8,
    borderColorR = 0, borderColorG = 0, borderColorB = 0, borderAlpha = 1.0, borderSize = 1,
    iconBorderColorR = 0, iconBorderColorG = 0, iconBorderColorB = 0, iconBorderAlpha = 1.0, iconBorderSize = 1,
    hideCdmWhileMounted = false,
}

local BUFF_TRACKER_DEFAULTS = {
    enabled = false, iconSize = 40, spacing = 4, textSize = 14,
    font = NAOWH_FONT, showMissingOnly = false, combatOnly = false,
    showCooldown = true, showStacks = true, unlocked = false,
    showAllRaidBuffs = false, showRaidBuffs = true, showPersonalAuras = true,
    showStances = true, growDirection = "RIGHT", maxIconsPerRow = 10,
    point = "TOP", posX = 0, posY = -100, width = 450, height = 60,
}

local GCD_TRACKER_DEFAULTS = {
    enabled = false, unlock = false, duration = 5, iconSize = 32,
    direction = "RIGHT", spacing = 4, fadeStart = 0.5, stackOverlapping = true,
    point = "CENTER", x = 0, y = -100, combatOnly = false,
    showInDungeon = true, showInRaid = true, showInArena = true,
    showInBattleground = true, showInWorld = true,
    blocklist = { [6603] = true, [75] = true },
    timelineColorR = 0.01, timelineColorG = 0.56, timelineColorB = 0.91, timelineHeight = 4,
    downtimeSummaryEnabled = false,
}

local STEALTH_REMINDER_DEFAULTS = {
    enabled = false, unlock = false, font = NAOWH_FONT,
    stealthR = 0, stealthG = 1, stealthB = 0, warningR = 1, warningG = 0, warningB = 0,
    showStealthed = true, showNotStealthed = true, disableWhenRested = false,
    stealthText = "STEALTH", warningText = "RESTEALTH",
    point = "CENTER", x = 0, y = 150, width = 200, height = 40,
    enableBalance = false, enableGuardian = false, enableResto = false,
    stanceEnabled = false, stanceUnlock = false, stanceFont = NAOWH_FONT,
    stanceWarnR = 1, stanceWarnG = 0.4, stanceWarnB = 0,
    stancePoint = "CENTER", stanceX = 0, stanceY = 100, stanceWidth = 200, stanceHeight = 40,
    stanceCombatOnly = false, stanceDisableWhenRested = false, stanceInstanceOnly = false,
    stanceSoundEnabled = false, stanceSound = "Raid Warning", stanceSoundInterval = 3,
    groupOnly = false,
}

local MOVEMENT_ALERT_DEFAULTS = {
    enabled = false, unlock = false, font = NAOWH_FONT,
    displayMode = "text",
    textFormat = "%ts\nNo %a",
    barShowIcon = true,
    textColorR = 1, textColorG = 1, textColorB = 1,
    precision = 1,
    pollRate = 100,
    point = "CENTER", x = 0, y = 50, width = 200, height = 40,
    combatOnly = false,
    disabledClasses = {},
    spellOverrides = {},
    tsEnabled = false, tsUnlock = false,
    tsText = "FREE MOVEMENT", tsColorR = 0.53, tsColorG = 1, tsColorB = 0,
    tsPoint = "CENTER", tsX = 0, tsY = 100, tsWidth = 200, tsHeight = 40,
    tsSoundEnabled = false, tsSoundID = "Raid Warning",
    tsTtsEnabled = false, tsTtsMessage = "Free movement", tsTtsVolume = 50, tsTtsRate = 0,
    gwEnabled = false, gwUnlock = false, gwCombatOnly = true,
    gwText = "GATEWAY READY", gwColorR = 0.5, gwColorG = 0, gwColorB = 0.8, gwColorUseClassColor = false,
    gwPoint = "CENTER", gwX = 0, gwY = 150, gwWidth = 200, gwHeight = 40,
    gwSoundEnabled = true, gwSoundID = "Raid Warning",
    gwTtsEnabled = false, gwTtsMessage = "Gateway ready", gwTtsVolume = 50,
}

local RANGE_CHECK_DEFAULTS = {
    enabled = false, rangeEnabled = true, rangeUnlock = false, rangeFont = NAOWH_FONT,
    rangeColorR = 0.01, rangeColorG = 0.56, rangeColorB = 0.91,
    rangePoint = "CENTER", rangeX = 0, rangeY = -190, rangeWidth = 200, rangeHeight = 40, rangeCombatOnly = false,
}

local EMOTE_DETECTION_DEFAULTS = {
    enabled = false, unlock = false, font = NAOWH_FONT,
    point = "TOP", x = 0, y = -50, width = 200, height = 60, fontSize = 16,
    textR = 1, textG = 1, textB = 1, emotePattern = "prepares,places", soundOn = true, soundID = "Raid Warning",
    autoEmoteEnabled = false, autoEmoteCooldown = 2,
    autoEmotes = {
        { spellId = 29893, emoteText = "prepares soulwell", enabled = true },
        { spellId = 698, emoteText = "prepares ritual of summoning", enabled = true },
    },
}

local FOCUS_CAST_BAR_DEFAULTS = {
    enabled = false, unlock = false, point = "CENTER", x = 0, y = 100, width = 250, height = 24,
    barStyle = "Solid",
    barColorR = 0.01, barColorG = 0.56, barColorB = 0.91,
    barColorCdR = 0.5, barColorCdG = 0.5, barColorCdB = 0.5,
    bgColorR = 0.12, bgColorG = 0.12, bgColorB = 0.12, bgAlpha = 0.8,
    showIcon = true, iconSize = 24, iconPosition = "LEFT", autoSizeIcon = true,
    showSpellName = true, showTimeRemaining = true, font = NAOWH_FONT, fontSize = 12,
    textColorR = 1, textColorG = 1, textColorB = 1, hideFriendlyCasts = false,
    showEmpowerStages = true, showShieldIcon = true, showInterruptTick = true, tickColorR = 1, tickColorG = 1, tickColorB = 1, tickColorUseClassColor = false, colorNonInterrupt = true,
    nonIntColorR = 0.8, nonIntColorG = 0.2, nonIntColorB = 0.2,
    soundEnabled = false, sound = "Raid Warning", ttsEnabled = false, ttsMessage = "Interrupt", ttsVolume = 50, ttsRate = 0,
    hideOnCooldown = false,
}

local TALENT_REMINDER_DEFAULTS = {
    enabled = false,
}

local RAID_ALERTS_DEFAULTS = {
    enabled = false,
}

local POISON_REMINDER_DEFAULTS = {
    enabled = false,
}

local EQUIPMENT_REMINDER_DEFAULTS = {
    enabled = false,
    showOnInstance = true,
    showOnReadyCheck = true,
    autoHideDelay = 10,
    iconSize = 40,
    point = "CENTER",
    x = 0,
    y = 100,
    ecEnabled = false,
    ecUseAllSpecs = true,
    ecSpecRules = {},
}

local MOUSE_RING_DEFAULTS = {
    enabled = false,
    size = 48,
    shape = "ring.tga",
    colorR = 1.0, colorG = 0.66, colorB = 0.0,
    useClassColor = false,
    showOutOfCombat = true,
    opacityInCombat = 1.0,
    opacityOutOfCombat = 1.0,
    trailEnabled = false,
    trailDuration = 2.0,
    trailShape = "glow",
    trailSize = 24,
    trailLength = 20,
    trailBrightness = 0.8,
    trailSparkle = false,
    trailR = 1.0, trailG = 1.0, trailB = 1.0,
    gcdEnabled = true,
    gcdR = 0.004, gcdG = 0.56, gcdB = 0.91,
    gcdReadyR = 0.0, gcdReadyG = 0.8, gcdReadyB = 0.3,
    gcdReadyMatchSwipe = false,
    gcdAlpha = 1.0,
    hideOnMouseClick = false,
    hideBackground = false,
    castSwipeEnabled = true,
    castSwipeR = 0.004, castSwipeG = 0.56, castSwipeB = 0.91,
    borderEnabled = false,
    borderR = 1.0, borderG = 1.0, borderB = 1.0, borderUseClassColor = false,
    borderWeight = 2,
    meleeRecolor = false,
    meleeRecolorBorder = true, meleeRecolorRing = false,
    meleeSoundEnabled = false, meleeSoundID = "Raid Warning", meleeSoundInterval = 3,
    hideWhenUnfocused = false,
}

local CREZ_DEFAULTS = {
    enabled = false, unlock = false, font = NAOWH_FONT,
    point = "CENTER", x = 0, y = 150, iconSize = 40,
    timerFontSize = 11, timerColorR = 1, timerColorG = 1, timerColorB = 1, timerAlpha = 1.0,
    countFontSize = 11, countColorR = 1, countColorG = 1, countColorB = 1, countAlpha = 1.0,
    deathWarning = false,
}

local PET_TRACKER_DEFAULTS = {
    enabled = false, unlock = false, font = NAOWH_FONT,
    showIcon = true, onlyInInstance = false,
    showPassive = true,
    lowHealthEnabled = false, lowHealthThreshold = 25, lowHealthText = "Pet Low HP",
    point = "CENTER", x = 0, y = 200,
    width = 200, height = 50,
    textSize = 20, iconSize = 32,
    missingText = "Pet Missing",
    passiveText = "Pet Passive",
    wrongPetText = "Wrong Pet",
    colorR = 1, colorG = 0, colorB = 0,
}

local CO_TANK_DEFAULTS = {
    enabled = false, unlock = false, font = NAOWH_FONT,
    point = "CENTER", x = 200, y = 0,
    width = 150, height = 20,
    healthColorR = 0, healthColorG = 0.8, healthColorB = 0.2,
    useClassColor = true,
    bgAlpha = 0.6,
    showName = true,
    nameFormat = "full",
    nameLength = 6,
    nameFontSize = 12,
    nameColorR = 1, nameColorG = 1, nameColorB = 1,
    nameColorUseClassColor = true,
}

ns.ModuleDefaults = {
    combatTimer = COMBAT_TIMER_DEFAULTS,
    combatAlert = COMBAT_ALERT_DEFAULTS,
    crosshair = CROSSHAIR_DEFAULTS,
    combatLogger = COMBAT_LOGGER_DEFAULTS,
    dragonriding = DRAGONRIDING_DEFAULTS,
    buffTracker = BUFF_TRACKER_DEFAULTS,
    gcdTracker = GCD_TRACKER_DEFAULTS,
    stealthReminder = STEALTH_REMINDER_DEFAULTS,
    movementAlert = MOVEMENT_ALERT_DEFAULTS,
    rangeCheck = RANGE_CHECK_DEFAULTS,
    emoteDetection = EMOTE_DETECTION_DEFAULTS,
    focusCastBar = FOCUS_CAST_BAR_DEFAULTS,
    talentReminder = TALENT_REMINDER_DEFAULTS,
    raidAlerts = RAID_ALERTS_DEFAULTS,
    poisonReminder = POISON_REMINDER_DEFAULTS,
    equipmentReminder = EQUIPMENT_REMINDER_DEFAULTS,
    mouseRing = MOUSE_RING_DEFAULTS,
    cRez = CREZ_DEFAULTS,
    petTracker = PET_TRACKER_DEFAULTS,
    coTank = CO_TANK_DEFAULTS,
}

local aceDBDefaults = {
    profile = {
        config = {
            lastTab = nil,
        },

        general = {
            globalFont = NAOWH_FONT,
            disableLoginMessage = false,
        },

        combatTimer = COMBAT_TIMER_DEFAULTS,
        combatAlert = COMBAT_ALERT_DEFAULTS,
        crosshair = CROSSHAIR_DEFAULTS,
        combatLogger = {
            enabled = false,
            instances = {},
        },
        dragonriding = DRAGONRIDING_DEFAULTS,
        buffTracker = BUFF_TRACKER_DEFAULTS,
        gcdTracker = GCD_TRACKER_DEFAULTS,
        stealthReminder = STEALTH_REMINDER_DEFAULTS,
        movementAlert = MOVEMENT_ALERT_DEFAULTS,
        rangeCheck = RANGE_CHECK_DEFAULTS,
        emoteDetection = EMOTE_DETECTION_DEFAULTS,
        focusCastBar = FOCUS_CAST_BAR_DEFAULTS,
        talentReminder = {
            enabled = false,
            loadouts = {},
        },
        raidAlerts = RAID_ALERTS_DEFAULTS,
        poisonReminder = POISON_REMINDER_DEFAULTS,
        equipmentReminder = EQUIPMENT_REMINDER_DEFAULTS,
        mouseRing = MOUSE_RING_DEFAULTS,
        cRez = CREZ_DEFAULTS,
        petTracker = PET_TRACKER_DEFAULTS,
        coTank = CO_TANK_DEFAULTS,

        misc = {
            autoFillDelete = false,
            fasterLoot = false,
            suppressLootWarnings = false,
            hideAlerts = false,
            hideTalkingHead = false,
            hideEventToasts = false,
            hideZoneText = false,
            autoRepair = false,
            guildRepair = false,
            durabilityWarning = false,
            durabilityThreshold = 30,
            durabilityFont = NAOWH_FONT,
            autoSlotKeystone = false,
            skipQueueConfirm = false,
            deathReleaseProtection = false,
            ahCurrentExpansion = false,
            hideMinimapIcon = false,
        },

        slashCommands = {
            enabled = false,
            commands = {
                { name = "cdm", frame = "CooldownViewerSettings", enabled = true, default = true },
                { name = "em", frame = "EditModeManagerFrame", enabled = true, default = true },
                { name = "kb", frame = "QuickKeybindFrame", enabled = true, default = true },
            },
        },

        buffWatcherV2 = {
            enabled = false,
            userEntries = {
                raidBuffs = { spellIDs = {} },
                consumables = { spellIDs = {} },
                shamanImbues = { enchantIDs = {} },
                roguePoisons = { enchantIDs = {} },
                shamanShields = { spellIDs = {} },
            },
            categoryEnabled = {
                raidBuffs = true,
                consumables = true,
                shamanImbues = true,
                roguePoisons = true,
                shamanShields = true,
            },
            thresholds = {
                dungeon = 2400,
                raid = 900,
                other = 300,
            },
            talentMods = {
                roguePoisons = {
                    { type = "requireCount", talentID = 381802, count = 4 },
                },
            },
            disabledDefaults = {},
            consumableGroupEnabled = {
                flask = true,
                food = true,
                rune = true,
                weaponBuff = true,
            },
            consumableAutoUse = {
                flask = nil,
                food = nil,
                rune = nil,
                weaponBuff = nil,
            },
            inventoryGroupEnabled = {
                dpsPotion = true,
                healthPotion = true,
                healthstone = true,
                gatewayControl = true,
                manaBun = false,
            },
            classBuffs = {
                WARRIOR     = { enabled = true, groups = {} },
                PALADIN     = { enabled = true, groups = {} },
                HUNTER      = { enabled = true, groups = {} },
                ROGUE       = { enabled = true, groups = {} },
                PRIEST      = { enabled = true, groups = {} },
                DEATHKNIGHT = { enabled = true, groups = {} },
                SHAMAN      = { enabled = true, groups = {} },
                MAGE        = { enabled = true, groups = {} },
                WARLOCK     = { enabled = true, groups = {} },
                MONK        = { enabled = true, groups = {} },
                DRUID       = { enabled = true, groups = {} },
                DEMONHUNTER = { enabled = true, groups = {} },
                EVOKER      = { enabled = true, groups = {} },
            },
            reportCardPosition = nil,
            reportCardIconSize = 32,
            reportCardUnlock = false,
            reportCardScale = 1.0,
            reportCardAutoCloseDelay = 5,
            scanOnLogin = false,
            lastSection = "classBuffs",
            chatReportEnabled = false,
        },
    },
    char = {
        specProfiles = {},
        migrationCompleted = false,
    },
    global = {
        minimapIcon = {},
        savedProfiles = {},
    },
}

function ns:RestoreModuleDefaults(moduleName, skipKeys)
    local defaults = ns.ModuleDefaults[moduleName]
    if not defaults then return false end

    local db = NaowhQOL[moduleName]

    if not db then return false end

    skipKeys = skipKeys or {}
    local skipSet = {}
    for _, k in ipairs(skipKeys) do skipSet[k] = true end

    for k, v in pairs(defaults) do
        if not skipSet[k] then
            if type(v) == "table" then
                db[k] = {}
                for tk, tv in pairs(v) do
                    db[k][tk] = tv
                end
            else
                db[k] = v
            end
        end
    end
    return true
end

local OLD_TRUE_DEFAULTS = {
    { module = "combatAlert",     key = "enabled" },
    { module = "dragonriding",    key = "enabled" },
    { module = "buffTracker",     key = "enabled" },
    { module = "emoteDetection",  key = "enabled" },
    { module = "emoteDetection",  key = "autoEmoteEnabled" },
    { module = "raidAlerts",      key = "enabled" },
    { module = "misc",            key = "autoFillDelete" },
    { module = "misc",            key = "fasterLoot" },
    { module = "misc",            key = "suppressLootWarnings" },
    { module = "misc",            key = "durabilityWarning" },
    { module = "misc",            key = "autoSlotKeystone" },
    { module = "slashCommands",   key = "enabled" },
    { module = "buffWatcherV2",   key = "enabled" },
}

local function MigrateDefaultsV2()
    if not ns.db or not ns.db.sv then return end
    if ns.db.global.defaultsV2Migrated then return end

    local rawProfiles = ns.db.sv.profiles
    if not rawProfiles then
        ns.db.global.defaultsV2Migrated = true
        return
    end

    local migrated = false
    for profileName, profileData in pairs(rawProfiles) do
        if next(profileData) ~= nil then
            for _, entry in ipairs(OLD_TRUE_DEFAULTS) do
                local modData = profileData[entry.module]
                if modData then
                    if modData[entry.key] == nil then
                        modData[entry.key] = true
                        migrated = true
                    end
                else
                    profileData[entry.module] = {}
                    profileData[entry.module][entry.key] = true
                    migrated = true
                end
            end
        end
    end

    ns.db.global.defaultsV2Migrated = true
    if migrated then
        DebugPrint("Defaults v2 migration: preserved old enabled=true values for existing profiles.")
    end
end

local function MigrateAutoShotBlocklist()
    if not ns.db or not ns.db.sv then return end
    if ns.db.global.autoShotBlocklistMigrated then return end

    local rawProfiles = ns.db.sv.profiles
    if rawProfiles then
        for _, profileData in pairs(rawProfiles) do
            if type(profileData) == "table" and profileData.gcdTracker then
                local bl = profileData.gcdTracker.blocklist
                if bl and bl[75] == nil then
                    bl[75] = true
                end
            end
        end
    end

    ns.db.global.autoShotBlocklistMigrated = true
end

local function MigrateSnapshotProfiles()
    if not ns.db or not ns.db.sv then return end

    if ns.db.global.profileSnapshotMigrated then return end

    local snapDB = rawget(_G, "NaowhQOL_Profiles")
    if not snapDB or not snapDB.profileData then
        ns.db.global.profileSnapshotMigrated = true
        return
    end

    DebugPrint("Migrating snapshot profiles to AceDB format...")

    ns.db.sv.profiles = ns.db.sv.profiles or {}
    ns.db.sv.profileKeys = ns.db.sv.profileKeys or {}

    local migrated = 0
    for profileName, profileData in pairs(snapDB.profileData) do
        if type(profileData) == "table" and next(profileData) then
            ns.db.sv.profiles[profileName] = deepCopy(profileData)
            migrated = migrated + 1
            DebugPrint("  Migrated profile: " .. profileName)

            if ns.db.global then
                ns.db.global.savedProfiles = ns.db.global.savedProfiles or {}
                ns.db.global.savedProfiles[profileName] = true
            end
        end
    end

    if snapDB.activeProfile then
        local target = snapDB.activeProfile
        if ns.db.sv.profiles[target] then
            ns.db:SetProfile(target)
            NaowhQOL = ns.db.profile
            DebugPrint("  Restored active profile: " .. target)
        end
    end

    ns.db.global.profileSnapshotMigrated = true

    if migrated > 0 then
        DebugPrint("Snapshot migration completed: " .. migrated .. " profile(s) migrated to AceDB format.")
    else
        DebugPrint("No snapshot profiles found to migrate.")
    end
end

local function MigrateFromLegacy(legacyCharData)
    DebugPrint("Migration check starting...")

    if ns.db.char.migrationCompleted then
        DebugPrint("Migration already completed for this character, skipping.")
        return
    end

    local oldData = legacyCharData or rawget(_G, "NaowhQOL_Legacy") or {}
    DebugPrint("Checking for legacy data in NaowhQOL_Legacy...")

    local currentProfile = ns.db.profile
    local hasOldData = false
    local foundKeys = {}

    local keysToCheck = {
        "combatTimer", "combatAlert", "crosshair", "dragonriding",
        "misc", "gcdTracker", "stealthReminder", "focusCastBar",
        "emoteDetection", "rangeCheck", "mouseRing", "cRez", "petTracker",
        "coTank", "slashCommands", "profiles", "specProfiles", "buffWatcherV2"
    }

    for _, key in ipairs(keysToCheck) do
        if oldData[key] and type(oldData[key]) == "table" then
            hasOldData = true
            table.insert(foundKeys, key)
        end
    end

    if hasOldData then
        DebugPrint("Found legacy data for: " .. table.concat(foundKeys, ", "))

        for _, key in ipairs(keysToCheck) do
            if oldData[key] and type(oldData[key]) == "table" and key ~= "profiles" and key ~= "specProfiles" then
                if not currentProfile[key] then
                    currentProfile[key] = {}
                end
                for k, v in pairs(oldData[key]) do
                    if type(v) == "table" then
                        currentProfile[key][k] = {}
                        for tk, tv in pairs(v) do
                            currentProfile[key][k][tk] = tv
                        end
                    else
                        currentProfile[key][k] = v
                    end
                end
            end
        end

        if oldData.specProfiles then
            DebugPrint("Migrating spec profiles...")
            for specIndex, specData in pairs(oldData.specProfiles) do
                ns.db.char.specProfiles[specIndex] = specData
            end
        end

        if oldData.minimapIcon then
            DebugPrint("Migrating minimap icon position...")
            for k, v in pairs(oldData.minimapIcon) do
                ns.db.global.minimapIcon[k] = v
            end
        end

        DebugPrint("Migration completed successfully!")
    else
        DebugPrint("No legacy data found, using fresh AceDB profile.")
    end

    ns.db.char.migrationCompleted = true
    DebugPrint("Migration flag set to true for this character.")
end

local function CleanupSlashCommands()
    local sc = NaowhQOL.slashCommands
    if not sc or not sc.commands then return end

    local cleaned = {}
    for _, cmd in ipairs(sc.commands) do
        if cmd.actionType == "command" and cmd.command then
            table.insert(cleaned, cmd)
        elseif cmd.frame then
            table.insert(cleaned, cmd)
        elseif cmd.actionType == "frameToggle" and cmd.action then
            table.insert(cleaned, {
                name = cmd.name,
                actionType = "frame",
                frame = cmd.action,
                enabled = cmd.enabled,
            })
        end
    end
    sc.commands = cleaned
end

function ns:OnProfileChanged()
    NaowhQOL = ns.db.profile

    CleanupSlashCommands()

    if NaowhQOL.coTank then
        NaowhQOL.coTank.privateAuras = nil
    end

    if NaowhQOL.equipmentReminder and NaowhQOL.equipmentReminder.ecSpecRules == nil then
        NaowhQOL.equipmentReminder.ecSpecRules = {}
    end

    if NaowhQOL.combatLogger then
        NaowhQOL.combatLogger.instances = NaowhQOL.combatLogger.instances or {}
    end

    if NaowhQOL.talentReminder then
        NaowhQOL.talentReminder.loadouts = NaowhQOL.talentReminder.loadouts or {}
    end

    if ns.SetLocale then
        ns:SetLocale(GetLocale())
    end

    if ns.SettingsIO then
        ns.SettingsIO:TriggerRefreshAll()
    end
end

local function InitializeDB()
    local legacyCharData = type(NaowhQOL) == "table" and NaowhQOL or nil

    ns.db = AceDB:New("NaowhQOLDB", aceDBDefaults, true)

    NaowhQOL = ns.db.profile

    NaowhQOL_Profiles = NaowhQOLDB

    ns.db.RegisterCallback(ns, "OnProfileChanged", "OnProfileChanged")
    ns.db.RegisterCallback(ns, "OnProfileCopied", "OnProfileChanged")
    ns.db.RegisterCallback(ns, "OnProfileReset", "OnProfileChanged")

    MigrateFromLegacy(legacyCharData)

    MigrateSnapshotProfiles()

    MigrateDefaultsV2()

    MigrateAutoShotBlocklist()

    if ns.SetLocale then
        ns:SetLocale(GetLocale())
    end

    NaowhQOL.combatLogger = NaowhQOL.combatLogger or {}
    NaowhQOL.combatLogger.instances = NaowhQOL.combatLogger.instances or {}

    NaowhQOL.talentReminder = NaowhQOL.talentReminder or {}
    NaowhQOL.talentReminder.loadouts = NaowhQOL.talentReminder.loadouts or {}

    if NaowhQOL.coTank then
        NaowhQOL.coTank.privateAuras = nil
    end

    if NaowhQOL.equipmentReminder then
        NaowhQOL.equipmentReminder.ecSpecRules = NaowhQOL.equipmentReminder.ecSpecRules or {}
    end

    if NaowhQOL.stealthReminder and NaowhQOL.stealthReminder.font and not NaowhQOL.stealthReminder.stanceFont then
        NaowhQOL.stealthReminder.stanceFont = NaowhQOL.stealthReminder.font
    end

    if ns.Media and ns.Media.MigrateDB then
        ns.Media.MigrateDB(NaowhQOL.combatTimer,    {"font"},                  nil,            nil)
        ns.Media.MigrateDB(NaowhQOL.combatAlert,     {"font"},                  nil,            {"enterSound", "leaveSound"})
        ns.Media.MigrateDB(NaowhQOL.dragonriding,    {"speedFont"},             {"barStyle"},   nil)
        ns.Media.MigrateDB(NaowhQOL.buffTracker,     {"font"},                  nil,            nil)
        ns.Media.MigrateDB(NaowhQOL.stealthReminder, {"font", "stanceFont"},    nil,            {"stanceSound"})
        ns.Media.MigrateDB(NaowhQOL.movementAlert,   {"font"},                  nil,            {"tsSoundID", "gwSoundID"})
        ns.Media.MigrateDB(NaowhQOL.rangeCheck,      {"rangeFont"},             nil,            nil)
        ns.Media.MigrateDB(NaowhQOL.emoteDetection,  {"font"},                  nil,            {"soundID"})
        ns.Media.MigrateDB(NaowhQOL.focusCastBar,    {"font"},                  {"barStyle"},   {"sound"})
        ns.Media.MigrateDB(NaowhQOL.petTracker,      {"font"},                  nil,            nil)
        ns.Media.MigrateDB(NaowhQOL.crosshair,       nil,                       nil,            {"meleeSoundID"})
    end

    CleanupSlashCommands()
end

local function DefaultFontPath()
    if ns.Media then return ns.Media.ResolveFont("Naowh") end
    local loc = GetLocale()
    local asia = (loc == "koKR" or loc == "zhCN" or loc == "zhTW")
    return "Interface\\AddOns\\NaowhQOL\\Assets\\Fonts\\" .. (asia and "NaowhAsia.ttf" or "Naowh.ttf")
end
ns.DefaultFontPath = DefaultFontPath

function ns:ApplyFPSOptimization()

    SetCVar("gxVSync", 0)
    SetCVar("MSAAAlphaTest", 0)
    SetCVar("tripleBuffering", 0)

    SetCVar("shadowMode", 1)
    SetCVar("SSAO", 0)

    SetCVar("liquidDetail", 2)
    SetCVar("depthEffects", 0)
    SetCVar("computeEffects", 0)
    SetCVar("fringeEffect", 0)

    SetCVar("textureFilteringMode", 5)
    SetCVar("ResampleAlwaysSharpen", 0)

    SetCVar("gxMaxBackgroundFPS", 30)
    SetCVar("targetFPS", 0)

    SetCVar("processPriority", 3)
    SetCVar("WorldTextScale", 1)
    SetCVar("nameplateMaxDistance", 41)

    ns:LogSuccess("FPS optimization applied.")
    StaticPopup_Show("NAOWH_QOL_RELOAD")
end

function ns:OptimizeNetwork()
    SetCVar("SpellQueueWindow", 150)
    SetCVar("reducedLagTolerance", 1)
    SetCVar("MaxSpellQueueWindow", 150)

    ns:LogSuccess("Network optimized (150ms Spell Queue).")
end

function ns:DeepGraphicsPurge()
    SetCVar("physicsLevel", 0)
    SetCVar("groundEffectDist", 40)
    SetCVar("groundEffectDensity", 16)
    SetCVar("worldBaseTickRate", 150)
    SetCVar("clutterFarDist", 20)

    ns:LogSuccess("Physics and clutter purged.")
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" and name == addonName then
        InitializeDB()
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGOUT" then
        NaowhQOL = {}
        NaowhQOL_Profiles = nil
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        C_Timer.After(0.5, function()
            if ns.SettingsIO then
                ns.SettingsIO:TriggerRefreshAll()
            end
        end)
    end
end)

SLASH_NAOWHQOLSUP1 = "/nsup"
SlashCmdList["NAOWHQOLSUP"] = function()
    ns.notificationsSuppressed = not ns.notificationsSuppressed
    if ns.notificationsSuppressed then
        print("|cff00ff00NaowhQOL:|r Notifications suppressed until reload")
    else
        print("|cff00ff00NaowhQOL:|r Notifications re-enabled")
    end
end
