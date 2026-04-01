local addonName, ns = ...
local L = ns.L

ns.LayoutUtil = {}

local ANCHOR_FRAMES = {
    { text = "Screen (UIParent)", value = "UIParent" },
    { text = "Player Frame", value = "PlayerFrame" },
    { text = "Target Frame", value = "TargetFrame" },
    { text = "Focus Frame", value = "FocusFrame" },
    { text = "Pet Frame", value = "PetFrame" },
    { text = "Minimap", value = "Minimap" },
    { text = "Buff Cooldown Viewer", value = "BuffIconCooldownViewer" },
    { text = "Essential Cooldown Viewer", value = "EssentialCooldownViewer" },
    { text = "Utility Cooldown Viewer", value = "UtilityCooldownViewer" },
}

function ns.LayoutUtil.GetAnchorFrameList()
    local frames = {}

    for _, entry in ipairs(ANCHOR_FRAMES) do
        if entry.value == "UIParent" or _G[entry.value] then
            frames[#frames + 1] = { text = entry.text, value = entry.value }
        end
    end

    return frames
end

function ns.LayoutUtil.GetAnchorFrame(frameName)
    if not frameName or frameName == "UIParent" then
        return UIParent
    end

    local frame = _G[frameName]
    if frame and type(frame) == "table" and frame.GetObjectType then
        return frame
    end

    return UIParent
end

ns.LayoutUtil.ANCHOR_POINTS = {
    { text = L["COMMON_ANCHOR_TOPLEFT"],     value = "TOPLEFT" },
    { text = L["COMMON_ANCHOR_TOP"],         value = "TOP" },
    { text = L["COMMON_ANCHOR_TOPRIGHT"],    value = "TOPRIGHT" },
    { text = L["COMMON_ANCHOR_LEFT"],        value = "LEFT" },
    { text = L["COMMON_ANCHOR_CENTER"],      value = "CENTER" },
    { text = L["COMMON_ANCHOR_RIGHT"],       value = "RIGHT" },
    { text = L["COMMON_ANCHOR_BOTTOMLEFT"],  value = "BOTTOMLEFT" },
    { text = L["COMMON_ANCHOR_BOTTOM"],      value = "BOTTOM" },
    { text = L["COMMON_ANCHOR_BOTTOMRIGHT"], value = "BOTTOMRIGHT" },
}
