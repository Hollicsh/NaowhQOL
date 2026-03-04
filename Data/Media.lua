local addonName, ns = ...
if not ns then return end

ns.Media = {}

local LSM
local ADDON_FONT_DIR = "Interface\\AddOns\\NaowhQOL\\Assets\\Fonts\\"

ns.Media.DEFAULT_FONT    = "Naowh"
ns.Media.DEFAULT_BAR     = "Solid"
ns.Media.DEFAULT_SOUND   = "Raid Warning"
local FALLBACK_FONT_PATH = "Fonts\\FRIZQT__.TTF"
local FALLBACK_BAR_PATH  = [[Interface\Buttons\WHITE8X8]]
local FALLBACK_SOUND_ID  = 8959

local function RegisterMedia()
    LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if not LSM then return end

    local koKR    = LSM.LOCALE_BIT_koKR or 0
    local ruRU    = LSM.LOCALE_BIT_ruRU or 0
    local zhCN    = LSM.LOCALE_BIT_zhCN or 0
    local zhTW    = LSM.LOCALE_BIT_zhTW or 0
    local western = LSM.LOCALE_BIT_western or 0

    local FONT = LSM.MediaType.FONT

    LSM:Register(FONT, "Naowh",
        ADDON_FONT_DIR .. "Naowh.ttf", ruRU + western)
    LSM:Register(FONT, "Naowh",
        ADDON_FONT_DIR .. "NaowhAsia.ttf", koKR + zhCN + zhTW)

    LSM:Register(FONT, "Metropolis ExtraBold",
        ADDON_FONT_DIR .. "Metropolis-ExtraBold.otf")

    LSM:Register(LSM.MediaType.STATUSBAR, "Solid",
        [[Interface\Buttons\WHITE8X8]])
end

RegisterMedia()

---@param nameOrPath string|nil  stored db value
---@return string path
function ns.Media.ResolveFont(nameOrPath)
    if not nameOrPath then
        return ns.Media.ResolveFont(ns.Media.DEFAULT_FONT)
    end

    if not LSM then LSM = LibStub and LibStub("LibSharedMedia-3.0", true) end

    if LSM and not nameOrPath:find("\\") and not nameOrPath:find("/") then
        local path = LSM:Fetch("font", nameOrPath)
        if path then return path end
    end

    return nameOrPath
end

---@param nameOrPath string|nil
---@return string path
function ns.Media.ResolveBar(nameOrPath)
    if not nameOrPath then
        return FALLBACK_BAR_PATH
    end

    if not LSM then LSM = LibStub and LibStub("LibSharedMedia-3.0", true) end

    if LSM and not nameOrPath:find("\\") and not nameOrPath:find("/") then
        local path = LSM:Fetch("statusbar", nameOrPath)
        if path then return path end
    end

    return nameOrPath
end

---@param nameOrLegacy string|number|table|nil  stored db value
---@return number|string|nil  resolved value for PlaySound/PlaySoundFile
function ns.Media.ResolveSound(nameOrLegacy)
    if not nameOrLegacy then
        return FALLBACK_SOUND_ID
    end

    if type(nameOrLegacy) == "number" then
        return nameOrLegacy
    end

    if type(nameOrLegacy) == "table" then
        return nameOrLegacy.id or nameOrLegacy.path or FALLBACK_SOUND_ID
    end

    if not LSM then LSM = LibStub and LibStub("LibSharedMedia-3.0", true) end

    if LSM then
        local result = LSM:Fetch("sound", nameOrLegacy)
        if result then return result end
    end

    return FALLBACK_SOUND_ID
end

local function BuildReverseFontLookup()
    if not LSM then LSM = LibStub and LibStub("LibSharedMedia-3.0", true) end
    if not LSM then return {} end

    local rev = {}
    local hashTable = LSM:HashTable("font")
    if hashTable then
        for name, path in pairs(hashTable) do
            rev[path] = name
            rev[path:gsub("/", "\\")] = name
            rev[path:gsub("\\", "/")] = name
        end
    end
    return rev
end

local function BuildReverseBarLookup()
    if not LSM then LSM = LibStub and LibStub("LibSharedMedia-3.0", true) end
    if not LSM then return {} end

    local rev = {}
    local hashTable = LSM:HashTable("statusbar")
    if hashTable then
        for name, path in pairs(hashTable) do
            rev[path] = name
            rev[path:gsub("/", "\\")] = name
            rev[path:gsub("\\", "/")] = name
        end
    end
    return rev
end

---@param db table        the settings table
---@param key string      the key to check (e.g. "font", "rangeFont")
---@param mediaType string "font" or "statusbar"
local function MigrateKey(db, key, mediaType)
    local val = db[key]
    if type(val) ~= "string" then return end
    if not val:find("\\") and not val:find("/") then return end

    local rev
    if mediaType == "font" then
        rev = BuildReverseFontLookup()
    else
        rev = BuildReverseBarLookup()
    end

    local name = rev[val] or rev[val:gsub("/", "\\")] or rev[val:gsub("\\", "/")]
    if name then
        db[key] = name
    end
end

local function MigrateSoundKey(db, key)
    local val = db[key]
    if val == nil then return end

    if type(val) == "string" and not val:find("\\") and not val:find("/") then
        return
    end

    if ns.SoundList and ns.SoundList.GetNameFromLegacy then
        local name = ns.SoundList.GetNameFromLegacy(val)
        if name then
            db[key] = name
            return
        end
    end
end

function ns.Media.MigrateDB(db, fontKeys, barKeys, soundKeys)
    if not db then return end
    if fontKeys then
        for _, key in ipairs(fontKeys) do
            MigrateKey(db, key, "font")
        end
    end
    if barKeys then
        for _, key in ipairs(barKeys) do
            MigrateKey(db, key, "statusbar")
        end
    end
    if soundKeys then
        for _, key in ipairs(soundKeys) do
            MigrateSoundKey(db, key)
        end
    end
end
