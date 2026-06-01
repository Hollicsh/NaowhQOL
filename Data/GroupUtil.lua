local addonName, ns = ...

ns.GroupUtil = {}

local cachedClasses = {}
local cachedVisibleClasses = {}
local callbacks = {}
local visibleCallbacks = {}

local function ScanGroupClasses()
    local classes = {}
    local _, playerClass = UnitClass("player")
    if playerClass then classes[playerClass] = true end

    local numMembers = GetNumGroupMembers()
    if numMembers > 0 then
        local prefix = IsInRaid() and "raid" or "party"
        local count = IsInRaid() and numMembers or (numMembers - 1)
        for i = 1, count do
            local _, classFile = UnitClass(prefix .. i)
            if classFile then classes[classFile] = true end
        end
    end

    return classes
end

local function ScanGroupClassesVisible()
    local classes = {}
    local _, playerClass = UnitClass("player")
    if playerClass then classes[playerClass] = true end

    local numMembers = GetNumGroupMembers()
    if numMembers > 0 then
        local prefix = IsInRaid() and "raid" or "party"
        local count = IsInRaid() and numMembers or (numMembers - 1)
        for i = 1, count do
            local unit = prefix .. i
            if UnitIsVisible(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
                local _, classFile = UnitClass(unit)
                if classFile then classes[classFile] = true end
            end
        end
    end

    return classes
end

local function ClassSetsEqual(a, b)
    for k in pairs(a) do
        if not b[k] then return false end
    end
    for k in pairs(b) do
        if not a[k] then return false end
    end
    return true
end

local function NotifyCallbacks()
    for key, fn in pairs(callbacks) do
        local ok, err = pcall(fn, cachedClasses)
        if not ok then
            print("|cffff0000NaowhQOL GroupUtil:|r callback '" .. key .. "' error: " .. tostring(err))
        end
    end
end

local function NotifyVisibleCallbacks()
    for key, fn in pairs(visibleCallbacks) do
        local ok, err = pcall(fn, cachedVisibleClasses)
        if not ok then
            print("|cffff0000NaowhQOL GroupUtil:|r visible callback '" .. key .. "' error: " .. tostring(err))
        end
    end
end

local function Refresh()
    local fresh = ScanGroupClasses()
    if not ClassSetsEqual(fresh, cachedClasses) then
        cachedClasses = fresh
        NotifyCallbacks()
    end
end

local function RefreshVisible()
    local fresh = ScanGroupClassesVisible()
    if not ClassSetsEqual(fresh, cachedVisibleClasses) then
        cachedVisibleClasses = fresh
        NotifyVisibleCallbacks()
    end
end

function ns.GroupUtil.GetGroupClasses()
    return cachedClasses
end

function ns.GroupUtil.GetGroupClassesVisible()
    return cachedVisibleClasses
end

function ns.GroupUtil.HasClass(classFile)
    return cachedClasses[classFile] == true
end

function ns.GroupUtil.HasClassVisible(classFile)
    return cachedVisibleClasses[classFile] == true
end

function ns.GroupUtil.RegisterCallback(key, func)
    if type(key) == "string" and type(func) == "function" then
        callbacks[key] = func
    end
end

function ns.GroupUtil.UnregisterCallback(key)
    callbacks[key] = nil
end

function ns.GroupUtil.RegisterVisibleCallback(key, func)
    if type(key) == "string" and type(func) == "function" then
        visibleCallbacks[key] = func
    end
end

function ns.GroupUtil.UnregisterVisibleCallback(key)
    visibleCallbacks[key] = nil
end

function ns.GroupUtil.Cleanup()
    wipe(cachedClasses)
    wipe(cachedVisibleClasses)
    wipe(callbacks)
    wipe(visibleCallbacks)
end

function ns.GroupUtil.ForceRefresh()
    local fresh = ScanGroupClasses()
    cachedClasses = fresh
    NotifyCallbacks()
    local freshVisible = ScanGroupClassesVisible()
    cachedVisibleClasses = freshVisible
    NotifyVisibleCallbacks()
end

local eventFrame = CreateFrame("Frame", "NaowhQOL_GroupUtil")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    Refresh()
    RefreshVisible()
end)

cachedClasses = ScanGroupClasses()
cachedVisibleClasses = ScanGroupClassesVisible()

C_Timer.NewTicker(3, function()
    if next(visibleCallbacks) then
        RefreshVisible()
    end
end)
