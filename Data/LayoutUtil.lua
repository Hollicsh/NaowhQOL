local addonName, ns = ...
local L = ns.L

ns.LayoutUtil = {}

function ns.LayoutUtil.CalculateContainerSize(count, size, spacing, direction)
    if count == 0 then return 1, 1 end

    local totalSize = (count * size) + ((count - 1) * spacing)

    if direction == "RIGHT" or direction == "LEFT" then
        return totalSize, size
    else
        return size, totalSize
    end
end

function ns.LayoutUtil.AutoSizeContainer(container, elements, size, spacing, direction)
    local w, h = ns.LayoutUtil.CalculateContainerSize(#elements, size, spacing, direction)
    container:SetSize(w, h)
end

function ns.LayoutUtil.LayoutElements(container, elements, size, spacing, direction, centered)
    if #elements == 0 then return end

    local totalSize = (#elements * size) + ((#elements - 1) * spacing)
    local startOffset = centered and (-(totalSize / 2) + (size / 2)) or 0

    for i, element in ipairs(elements) do
        element:ClearAllPoints()
        element:SetSize(size, size)

        local offset = startOffset + ((i - 1) * (size + spacing))

        if direction == "RIGHT" then
            element:SetPoint(centered and "CENTER" or "LEFT", container, centered and "CENTER" or "LEFT", offset, 0)
        elseif direction == "LEFT" then
            element:SetPoint(centered and "CENTER" or "RIGHT", container, centered and "CENTER" or "RIGHT", -offset, 0)
        elseif direction == "DOWN" then
            element:SetPoint(centered and "CENTER" or "TOP", container, centered and "CENTER" or "TOP", 0, -offset)
        elseif direction == "UP" then
            element:SetPoint(centered and "CENTER" or "BOTTOM", container, centered and "CENTER" or "BOTTOM", 0, offset)
        end
    end
end

function ns.LayoutUtil.AutoLayout(container, elements, size, spacing, direction, centered)
    ns.LayoutUtil.AutoSizeContainer(container, elements, size, spacing, direction)
    ns.LayoutUtil.LayoutElements(container, elements, size, spacing, direction, centered)
end

function ns.LayoutUtil.MatchAnchorWidth(frame, anchorFrame, delay)
    delay = delay or 0.1
    C_Timer.After(delay, function()
        if anchorFrame and anchorFrame:GetWidth() > 0 then
            frame:SetWidth(anchorFrame:GetWidth())
        end
    end)
end

function ns.LayoutUtil.MatchAnchorHeight(frame, anchorFrame, delay)
    delay = delay or 0.1
    C_Timer.After(delay, function()
        if anchorFrame and anchorFrame:GetHeight() > 0 then
            frame:SetHeight(anchorFrame:GetHeight())
        end
    end)
end

function ns.LayoutUtil.CreateThrottledUpdater(callback, interval)
    interval = interval or 0.05
    local nextUpdate = 0

    return function(...)
        local now = GetTime()
        if now < nextUpdate then return end
        nextUpdate = now + interval
        callback(...)
    end
end

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
