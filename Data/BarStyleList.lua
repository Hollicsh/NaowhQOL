local addonName, ns = ...

local builtIn = {
    { name = "Blizzard",                       path = [[Interface\TargetingFrame\UI-StatusBar]] },
    { name = "Blizzard Character Skills Bar",  path = [[Interface\PaperDollInfoFrame\UI-Character-Skills-Bar]] },
    { name = "Blizzard Raid Bar",              path = [[Interface\RaidFrame\Raid-Bar-Hp-Fill]] },
    { name = "Solid",                          path = [[Interface\Buttons\WHITE8X8]] },
}

ns.BarStyleList = {}

local dirty = true

function ns.BarStyleList.Rebuild()
    if not dirty then return end
    dirty = false

    local merged = {}
    local seen = {}

    for _, t in ipairs(builtIn) do
        merged[#merged + 1] = { name = t.name, path = t.path }
        seen[t.path] = true
    end

    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then
        local barTable = LSM:HashTable("statusbar")
        if barTable then
            for name, path in pairs(barTable) do
                if not seen[path] then
                    merged[#merged + 1] = { name = name, path = path }
                    seen[path] = true
                end
            end
        end
    end

    table.sort(merged, function(a, b) return a.name < b.name end)

    for i = 1, #ns.BarStyleList do ns.BarStyleList[i] = nil end
    for i, t in ipairs(merged) do ns.BarStyleList[i] = t end

    ns.BarStyleList._nameByPath = {}
    ns.BarStyleList._pathByName = {}
    for _, t in ipairs(ns.BarStyleList) do
        ns.BarStyleList._nameByPath[t.path] = t.name
        if not ns.BarStyleList._pathByName[t.name] then
            ns.BarStyleList._pathByName[t.name] = t.path
        end
    end
end

function ns.BarStyleList.MarkDirty()
    dirty = true
end

function ns.BarStyleList.GetName(nameOrPath)
    if dirty or not ns.BarStyleList._nameByPath then ns.BarStyleList.Rebuild() end
    if type(nameOrPath) == "string" and not nameOrPath:find("\\") and not nameOrPath:find("/") then
        if ns.BarStyleList._pathByName[nameOrPath] then
            return nameOrPath
        end
    end
    return ns.BarStyleList._nameByPath[nameOrPath] or ("Unknown (" .. tostring(nameOrPath) .. ")")
end

function ns.BarStyleList.GetPath(name)
    if dirty or not ns.BarStyleList._pathByName then ns.BarStyleList.Rebuild() end
    return ns.BarStyleList._pathByName[name]
end

local function HookLSM()
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then
        LSM.RegisterCallback(ns.BarStyleList, "LibSharedMedia_Registered", function(_, mediatype)
            if mediatype == "statusbar" then dirty = true end
        end)
    end
end

ns.BarStyleList.Rebuild()
HookLSM()
