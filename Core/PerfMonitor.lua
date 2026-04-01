local _, ns = ...

local PerfMonitor = {}

function PerfMonitor:Wrap(label, fn)
    return fn
end

ns.PerfMonitor = PerfMonitor
