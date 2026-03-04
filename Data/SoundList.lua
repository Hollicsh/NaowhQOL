local addonName, ns = ...

local SOURCE_COLORS = {
    { 1.0, 1.0, 1.0, 1 },
    { 0.4, 0.8, 1.0, 1 },
    { 0.8, 0.5, 1.0, 1 },
    { 1.0, 0.8, 0.4, 1 },
    { 0.5, 1.0, 0.5, 1 },
    { 1.0, 0.5, 0.5, 1 },
    { 0.5, 1.0, 1.0, 1 },
}

local BASE_GAME = "Base Game"

local builtIn = {
    { name = "Achievement Unlocked",    id = 13833 },
    { name = "Alarm Clock Warning 1",   id = 18871 },
    { name = "Alarm Clock Warning 2",   id = 12867 },
    { name = "Alarm Clock Warning 3",   id = 12889 },
    { name = "Battleground Countdown",  id = 25477 },
    { name = "Battleground Start",      id = 25478 },
    { name = "BNet Toast",              id = 18019 },
    { name = "Bonus Roll End",          id = 31581 },
    { name = "Bonus Roll Start",        id = 31579 },
    { name = "Challenge Complete",      id = 74526 },
    { name = "Challenge Keystone Up",   id = 74437 },
    { name = "Challenge New Record",    id = 33338 },
    { name = "Epic Loot Toast",         id = 31578 },
    { name = "Fishing Reel In",         id = 3407 },
    { name = "Flag Captured",           id = 8174 },
    { name = "GM Chat Warning",         id = 15273 },
    { name = "Group Finder App",        id = 47615 },
    { name = "Honor Rank Up",           id = 77003 },
    { name = "Item Repair",             id = 7994 },
    { name = "Legendary Loot Toast",    id = 63971 },
    { name = "Level Up",                id = 888  },
    { name = "LFG Denied",              id = 17341 },
    { name = "LFG Rewards",             id = 17316 },
    { name = "LFG Role Check",          id = 17317 },
    { name = "Loot Coin",               id = 120  },
    { name = "Loss of Control",         id = 34468 },
    { name = "Map Ping",                id = 3175 },
    { name = "Mission Complete",        id = 44294 },
    { name = "Mission Success Cheers",  id = 74702 },
    { name = "Personal Loot Banner",    id = 50893 },
    { name = "Pet Battle Start",        id = 31584 },
    { name = "Power Aura",              id = 23287 },
    { name = "PVP Enter Queue",         id = 8458 },
    { name = "PVP Through Queue",       id = 8459 },
    { name = "Quest Auto Complete",     id = 23404 },
    { name = "Quest Complete",          id = 878  },
    { name = "Quest List Open",         id = 875  },
    { name = "Raid Boss Defeated",      id = 50111 },
    { name = "Raid Boss Emote Warning", id = 12197 },
    { name = "Raid Boss Whisper",       id = 37666 },
    { name = "Raid Warning",            id = 8959 },
    { name = "Ready Check",             id = 8960 },
    { name = "Recipe Learned Toast",    id = 73919 },
    { name = "Scenario Ending",         id = 31754 },
    { name = "Scenario Stage End",      id = 31757 },
    { name = "Store Unwrap",            id = 64329 },
    { name = "Talent Ready Check",      id = 73281 },
    { name = "Talent Ready Toast",      id = 73280 },
    { name = "Talent Select",           id = 73279 },
    { name = "Tell Message",            id = 3081 },
    { name = "Tutorial Popup",          id = 7355 },
    { name = "Warforged Loot Toast",    id = 51561 },
    { name = "Warmode Activate",        id = 118563 },
    { name = "World Quest Complete",    id = 73277 },
    { name = "World Quest Start",       id = 73275 },
}

ns.SoundList = {}

local function RegisterBuiltInWithLSM()
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if not LSM then return end
    for _, s in ipairs(builtIn) do
        LSM:Register(LSM.MediaType.SOUND, s.name, s.id)
    end
end

RegisterBuiltInWithLSM()

local dirty = true
local sourceColors = {}
local sourceList = {}
local colorIndex = 2

local function GetSourceFromPath(path)
    if type(path) == "number" then
        return "SharedMedia"
    end
    local addon = path:match("Interface\\AddOns\\([^\\]+)")
    if addon then
        return addon
    end
    return "SharedMedia"
end

local function GetColorForSource(source)
    if sourceColors[source] then
        return sourceColors[source]
    end
    local color = SOURCE_COLORS[colorIndex] or SOURCE_COLORS[#SOURCE_COLORS]
    sourceColors[source] = color
    colorIndex = colorIndex + 1
    if colorIndex > #SOURCE_COLORS then
        colorIndex = 2
    end
    return color
end

function ns.SoundList.Rebuild()
    if not dirty then return end
    dirty = false

    local merged = {}
    local seenName = {}
    local seenID = {}
    local seenPath = {}
    local sourcesFound = {}

    sourceColors = { [BASE_GAME] = SOURCE_COLORS[1] }
    colorIndex = 2

    local baseGameColor = SOURCE_COLORS[1]
    for _, s in ipairs(builtIn) do
        merged[#merged + 1] = {
            name = s.name,
            id = s.id,
            path = nil,
            source = BASE_GAME,
            color = baseGameColor,
        }
        seenName[s.name] = true
        seenID[s.id] = true
        sourcesFound[BASE_GAME] = true
    end

    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then
        local soundTable = LSM:HashTable("sound")
        if soundTable then
            for name, pathOrID in pairs(soundTable) do
                local isNumeric = type(pathOrID) == "number"
                local skipKey = isNumeric and pathOrID or pathOrID

                if not seenName[name] and not (isNumeric and seenID[pathOrID]) and not (not isNumeric and seenPath[pathOrID]) then
                    local source = GetSourceFromPath(pathOrID)
                    local color = GetColorForSource(source)
                    merged[#merged + 1] = {
                        name = name,
                        id = isNumeric and pathOrID or nil,
                        path = isNumeric and nil or pathOrID,
                        source = source,
                        color = color,
                    }
                    seenName[name] = true
                    if isNumeric then
                        seenID[pathOrID] = true
                    else
                        seenPath[pathOrID] = true
                    end
                    sourcesFound[source] = true
                end
            end
        end
    end

    table.sort(merged, function(a, b) return a.name < b.name end)

    for i = 1, #ns.SoundList do ns.SoundList[i] = nil end
    for i, s in ipairs(merged) do ns.SoundList[i] = s end

    ns.SoundList._nameByID = {}
    ns.SoundList._nameByPath = {}
    ns.SoundList._entryByID = {}
    ns.SoundList._entryByPath = {}
    ns.SoundList._entryByName = {}
    for _, s in ipairs(ns.SoundList) do
        if s.id then
            ns.SoundList._nameByID[s.id] = s.name
            ns.SoundList._entryByID[s.id] = s
        end
        if s.path then
            ns.SoundList._nameByPath[s.path] = s.name
            ns.SoundList._entryByPath[s.path] = s
        end
        ns.SoundList._entryByName[s.name] = s
    end

    sourceList = { "All" }
    if sourcesFound[BASE_GAME] then
        sourceList[#sourceList + 1] = BASE_GAME
    end
    local otherSources = {}
    for src in pairs(sourcesFound) do
        if src ~= BASE_GAME then
            otherSources[#otherSources + 1] = src
        end
    end
    table.sort(otherSources)
    for _, src in ipairs(otherSources) do
        sourceList[#sourceList + 1] = src
    end
end

function ns.SoundList.MarkDirty()
    dirty = true
end

function ns.SoundList.GetName(idOrPath)
    ns.SoundList.Rebuild()
    if type(idOrPath) == "number" then
        return ns.SoundList._nameByID[idOrPath] or ("Unknown (" .. tostring(idOrPath) .. ")")
    else
        return ns.SoundList._nameByPath[idOrPath] or ("Unknown")
    end
end

function ns.SoundList.GetEntry(soundData)
    if not soundData then return nil end
    ns.SoundList.Rebuild()
    if type(soundData) == "string" then
        return ns.SoundList._entryByName[soundData]
    elseif type(soundData) == "number" then
        return ns.SoundList._entryByID[soundData]
    elseif soundData.id then
        return ns.SoundList._entryByID[soundData.id]
    elseif soundData.path then
        return ns.SoundList._entryByPath[soundData.path]
    end
    return nil
end

function ns.SoundList.GetSources()
    if #sourceList == 0 then ns.SoundList.Rebuild() end
    return sourceList
end

local FALLBACK_SOUND_ID = 8959

function ns.SoundList.Play(soundData)
    if not soundData then return false end

    if type(soundData) == "string" then
        if ns.Media and ns.Media.ResolveSound then
            local resolved = ns.Media.ResolveSound(soundData)
            if resolved then
                if type(resolved) == "number" then
                    PlaySound(resolved, "Master")
                    return true
                else
                    local willPlay = PlaySoundFile(resolved, "Master")
                    if not willPlay then
                        PlaySound(FALLBACK_SOUND_ID, "Master")
                        return false
                    end
                    return true
                end
            end
        end
        PlaySound(FALLBACK_SOUND_ID, "Master")
        return false
    end

    if type(soundData) == "number" then
        PlaySound(soundData, "Master")
        return true
    end

    if soundData.id then
        PlaySound(soundData.id, "Master")
        return true
    elseif soundData.path then
        local willPlay = PlaySoundFile(soundData.path, "Master")
        if not willPlay then
            PlaySound(FALLBACK_SOUND_ID, "Master")
            return false
        end
        return true
    end
    return false
end

function ns.SoundList.GetNameFromLegacy(soundData)
    if not soundData then return nil end
    ns.SoundList.Rebuild()

    if type(soundData) == "number" then
        return ns.SoundList._nameByID[soundData]
    elseif type(soundData) == "table" then
        if soundData.id and type(soundData.id) == "number" then
            return ns.SoundList._nameByID[soundData.id]
        elseif soundData.path then
            return ns.SoundList._nameByPath[soundData.path]
        end
    elseif type(soundData) == "string" then
        if not soundData:find("\\") and not soundData:find("/") then
            return soundData
        end
        return ns.SoundList._nameByPath[soundData]
    end
    return nil
end

local function HookLSM()
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then
        LSM.RegisterCallback(ns.SoundList, "LibSharedMedia_Registered", function(_, mediatype)
            if mediatype == "sound" then dirty = true end
        end)
    end
end

ns.SoundList.Rebuild()
HookLSM()
