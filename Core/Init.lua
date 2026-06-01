local addonName, ns = ...

if not ns then
    print("|cffff0000Naowh QOL Error:|r Namespace failed to load. Init aborted.")
    return
end

ns.IsPlayerSpell = (C_SpellBook and C_SpellBook.PlayerHasSpell)
    or IsPlayerSpell
    or (C_SpellBook and C_SpellBook.IsSpellKnown)
    or function() return false end

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
