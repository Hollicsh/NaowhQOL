# Changelog
## [20260314.05]
### Fix
**Buff Watcher**
- Fixed: Shaman Lightning Shield (and similar short-duration self-buffs) no longer triggers false "buff dropped" reminders when the buff is still active — duration threshold is now treated as presence-only for shield checks
- Updated: `shamanShield` split into separate Lightning Shield, Earth Shield, and Water Shield entries with correct spec filters and talent conditions
**Mouse Ring**
- Fixed: Lua errors no longer appear when mousing over enemy players or NPCs in PvP — the AFK state check is now skipped entirely during combat and instanced PvP where going AFK shouldnt be checked against
