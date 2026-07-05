local addonName, ns = ...

local GetCVar = GetCVar
local SetCVar = SetCVar

ns.CVarSync = {}

local TRACKED_CVARS = {
    { cvar = "SpellQueueWindow", dbKey = "spellQueueWindow" },
}

local function GetManagedTable()
    if not NaowhQOL then return nil end
    NaowhQOL.cvarManaged = NaowhQOL.cvarManaged or {}
    return NaowhQOL.cvarManaged
end

function ns.CVarSync:GetLive(cvar)
    local ok, live = pcall(GetCVar, cvar)
    if ok and live ~= nil then
        return tostring(live)
    end
    return nil
end

function ns.CVarSync:RecordApplied(cvar, value)
    local managed = GetManagedTable()
    if managed then
        managed[cvar] = tostring(value)
    end
    if NaowhQOL and NaowhQOL.cvarExternal then
        NaowhQOL.cvarExternal[cvar] = nil
    end
end

function ns.CVarSync:IsExternal(cvar)
    return NaowhQOL and NaowhQOL.cvarExternal and NaowhQOL.cvarExternal[cvar] == true
end

function ns.CVarSync:MarkExternal(cvar)
    if not NaowhQOL then return end
    NaowhQOL.cvarExternal = NaowhQOL.cvarExternal or {}
    NaowhQOL.cvarExternal[cvar] = true
    local live = self:GetLive(cvar)
    local managed = GetManagedTable()
    if managed and live then
        managed[cvar] = live
    end
end

function ns.CVarSync:WasExternallyChanged(cvar)
    local managed = GetManagedTable()
    if not managed or managed[cvar] == nil then
        return false
    end
    local live = self:GetLive(cvar)
    return live ~= nil and live ~= managed[cvar]
end

-- Prefer live value over stale DB when another addon or macro changed the CVar.
function ns.CVarSync:AdoptLive(cvar, dbKey)
    if not NaowhQOL then return nil end

    local live = self:GetLive(cvar)
    if not live then return nil end

    if dbKey then
        local stored = NaowhQOL[dbKey]
        if stored == nil or tostring(stored) ~= live then
            NaowhQOL[dbKey] = tonumber(live) or live
        end
    end

    self:RecordApplied(cvar, live)
    return live
end

function ns.CVarSync:Apply(cvar, value, dbKey)
    if not NaowhQOL then NaowhQOL = {} end

    local strVal = tostring(value)
    pcall(SetCVar, cvar, strVal)
    self:RecordApplied(cvar, strVal)

    if dbKey then
        NaowhQOL[dbKey] = tonumber(value) or value
    end
end

function ns.CVarSync:SyncAllOnLogin()
    if not NaowhQOL then return end

    for _, entry in ipairs(TRACKED_CVARS) do
        self:AdoptLive(entry.cvar, entry.dbKey)
    end

    local managed = GetManagedTable()
    if not managed then return end

    NaowhQOL.cvarExternal = NaowhQOL.cvarExternal or {}

    for cvar, managedVal in pairs(managed) do
        local live = self:GetLive(cvar)
        if live and live ~= managedVal then
            NaowhQOL.cvarExternal[cvar] = true
            managed[cvar] = live
        end
    end
end

function ns.CVarSync:OnExternalUpdate(cvar)
    if not NaowhQOL then return end

    for _, entry in ipairs(TRACKED_CVARS) do
        if entry.cvar == cvar then
            self:AdoptLive(cvar, entry.dbKey)
            return
        end
    end

    local managed = GetManagedTable()
    if managed and managed[cvar] then
        local live = self:GetLive(cvar)
        if live and live ~= managed[cvar] then
            NaowhQOL.cvarExternal = NaowhQOL.cvarExternal or {}
            NaowhQOL.cvarExternal[cvar] = true
            managed[cvar] = live
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CVAR_UPDATE")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(0, function()
            ns.CVarSync:SyncAllOnLogin()
        end)
    elseif event == "CVAR_UPDATE" and arg1 then
        ns.CVarSync:OnExternalUpdate(arg1)
    end
end)
