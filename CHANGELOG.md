# Changelog
## [20260519.01]

### Changes
**Buffwatcher**
- Scanner:ScanRaidBuffs() — Ready-check / report card scans treat a raid buff as present if any eligible member has the aura, regardless of remaining time. Duration thresholds still apply to consumables and class buffs.
- RefreshRaidBuffAlerts() — “Always Monitor My Raid Buffs” uses the same rule: alert only when the buff is missing on a covered player/party/raid member, not when it’s low duration.