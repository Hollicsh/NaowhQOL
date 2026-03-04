local addonName, ns = ...

local builtIn = {
    { name = "2002",                           path = "Fonts\\2002.TTF" },
    { name = "2002 Bold",                      path = "Fonts\\2002B.TTF" },
    { name = "AR CrystalzcuheiGBK Demibold",   path = "Fonts\\ARHei.TTF" },
    { name = "AR Heiti2 Medium B5",            path = "Fonts\\bHEI00M.ttf" },
    { name = "AR Heiti2 Bold B5",              path = "Fonts\\bHEI01B.ttf" },
    { name = "AR Kaiti Medium B5",             path = "Fonts\\bKAI00M.ttf" },
    { name = "AR Leisu Demi B5",               path = "Fonts\\bLEI00D.ttf" },
    { name = "AR ZhongkaiGBK Medium",          path = "Fonts\\ARKai_T.TTF" },
    { name = "AR ZhongkaiGBK Medium (Combat)", path = "Fonts\\ARKai_C.TTF" },
    { name = "Arial Narrow",                   path = "Fonts\\ARIALN.TTF" },
    { name = "Friends",                        path = "Fonts\\FRIENDS.TTF" },
    { name = "Friz Quadrata TT",               path = "Fonts\\FRIZQT__.TTF" },
    { name = "Friz Quadrata TT CYR",           path = "Fonts\\FRIZQT___CYR.TTF" },
    { name = "MoK",                            path = "Fonts\\K_Pagetext.TTF" },
    { name = "Morpheus",                       path = "Fonts\\MORPHEUS.TTF" },
    { name = "Morpheus CYR",                   path = "Fonts\\MORPHEUS_CYR.TTF" },
    { name = "Nimrod MT",                      path = "Fonts\\NIM_____.ttf" },
    { name = "Skurri",                         path = "Fonts\\skurri.ttf" },
    { name = "Skurri CYR",                     path = "Fonts\\SKURRI_CYR.TTF" },
    { name = "YDIWingsM",                      path = "Fonts\\K_Damage.TTF" },
}

ns.FontList = {}

local dirty = true

function ns.FontList.Rebuild()
    if not dirty then return end
    dirty = false

    local merged = {}
    local seenPath = {}
    local seenName = {}

    for _, f in ipairs(builtIn) do
        merged[#merged + 1] = { name = f.name, path = f.path }
        seenPath[f.path] = true
        seenName[f.name] = true
    end

    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then
        local fontTable = LSM:HashTable("font")
        if fontTable then
            for name, path in pairs(fontTable) do
                if not seenPath[path] and not seenName[name] then
                    merged[#merged + 1] = { name = name, path = path }
                    seenPath[path] = true
                    seenName[name] = true
                end
            end
        end
    end

    table.sort(merged, function(a, b) return a.name < b.name end)

    for i = 1, #ns.FontList do ns.FontList[i] = nil end
    for i, f in ipairs(merged) do ns.FontList[i] = f end

    ns.FontList._nameByPath = {}
    ns.FontList._pathByName = {}
    for _, f in ipairs(ns.FontList) do
        ns.FontList._nameByPath[f.path] = f.name
        if not ns.FontList._pathByName[f.name] then
            ns.FontList._pathByName[f.name] = f.path
        end
    end
end

function ns.FontList.MarkDirty()
    dirty = true
end

function ns.FontList.GetName(nameOrPath)
    if dirty or not ns.FontList._nameByPath then ns.FontList.Rebuild() end
    if type(nameOrPath) == "string" and not nameOrPath:find("\\") and not nameOrPath:find("/") then
        if ns.FontList._pathByName[nameOrPath] then
            return nameOrPath
        end
    end
    return ns.FontList._nameByPath[nameOrPath] or ("Unknown (" .. tostring(nameOrPath) .. ")")
end

function ns.FontList.GetPath(name)
    if dirty or not ns.FontList._pathByName then ns.FontList.Rebuild() end
    return ns.FontList._pathByName[name]
end

local function HookLSM()
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then
        LSM.RegisterCallback(ns.FontList, "LibSharedMedia_Registered", function(_, mediatype)
            if mediatype == "font" then dirty = true end
        end)
    end
end

ns.FontList.Rebuild()
HookLSM()
