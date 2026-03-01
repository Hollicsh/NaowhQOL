local addonName, ns = ...

if not ns then
    print("|cffff0000Naowh QOL Error:|r Namespace failed to load. Init aborted.")
    return
end

-- Compat shim: C_SpellBook.PlayerHasSpell (11.1.0+) replaces deprecated IsPlayerSpell.
-- PlayerHasSpell handles talent-replacement spells (e.g. Death Charge replacing Death's Advance).
-- Falls back to IsPlayerSpell (deprecated 11.2.0) then C_SpellBook.IsSpellKnown.
ns.IsPlayerSpell = (C_SpellBook and C_SpellBook.PlayerHasSpell)
    or IsPlayerSpell
    or (C_SpellBook and C_SpellBook.IsSpellKnown)
    or function() return false end

-- Shared logging utility
local ADDON_PREFIX = "|cff018ee7Naowh|r |cffffa900QOL|r"

function ns:Log(message, color)
    color = color or "ffffff"
    print(ADDON_PREFIX .. " " .. "|cff" .. color .. message .. "|r")
end

function ns:LogSuccess(message)
    ns:Log(message, "00ff00")
end

function ns:LogError(message)
    ns:Log(message, "ff0000")
end

-- Namespace validation only. Full initialization is handled by Core.lua
