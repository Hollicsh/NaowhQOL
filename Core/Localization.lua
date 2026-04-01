local addonName, ns = ...

local locales = {}
local currentLocale = (GetLocale and GetLocale()) or "enUS"
local fallbackLocale = "enUS"
local missingKeys = {}

local L = setmetatable({}, {
    __index = function(self, key)
        local localeTable = locales[currentLocale]
        if localeTable and localeTable[key] then
            return localeTable[key]
        end
        local fallback = locales[fallbackLocale]
        if fallback and fallback[key] then
            return fallback[key]
        end
        if not missingKeys[key] then
            missingKeys[key] = true
            if ns.Debug then
                print("|cffff6600[NaowhQOL]|r Missing localization key: " .. tostring(key))
            end
        end
        return key
    end,
    __newindex = function() end
})

function ns:RegisterLocale(locale, strings)
    locales[locale] = locales[locale] or {}
    for k, v in pairs(strings) do
        locales[locale][k] = v
    end
end

function ns:GetLocale()
    return currentLocale
end

function ns:SetLocale(locale)
    if locales[locale] then
        currentLocale = locale
        return true
    end
    return false
end

ns.L = L
