# Changelog
# Hotfix
## [20260317.03]

### Bug Fixes
- **Buff Watcher — Raid Buff Scanning** — Fixed "attempt to compare secret number value" errors that could occur when receiving buffs during a boss encounter (e.g. Arcane Familiar). Aura spell ID comparisons are now fully protected against Blizzard taint.
- **Movement Alert — Charge Tracking** — Fixed "attempt to perform arithmetic on secret number value" errors during combat. Charge count math (incrementing, decrementing, comparisons) is now taint-safe and won't throw errors mid-fight.
- **Movement Alert — Charge Updates** — Added an extra combat lockdown check to prevent reading tainted charge data during the brief window between entering combat and the addon being notified.
- **Mouse Ring — PvP Loading** — Fixed a "container is nil" error  that happened when loading into battlegrounds or arenas where combat starts before the UI is fully initialized. The ring now waits until it's been created before trying to update.
- **Taint Detection** — Improved the internal aura-readability check so it correctly detects Blizzard's secret/tainted values. The previous check could miss tainted data, allowing other modules to hit errors downstream.
