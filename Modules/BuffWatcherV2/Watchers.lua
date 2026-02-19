local _, ns = ...

-- BuffWatcherV2 Watchers Module
-- No-op stubs (scanning now uses interval polling)

local Watchers = {}
ns.BWV2Watchers = Watchers

function Watchers:SetCallback(callback) end
function Watchers:StartGlobalEvents() end
function Watchers:StopGlobalEvents() end
function Watchers:SetupWatcher(unit) end
function Watchers:RemoveWatcher(unit) end
function Watchers:RemoveAllWatchers() end
function Watchers:GetWatcherCount() return 0 end
function Watchers:IsWatching(unit) return false end
