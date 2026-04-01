# Changelog

## [20260331.01]

### New
- **Auto Accept Queue Joins added to "Skip Queue Confirmation"**: Automatically picks your role and accepts LFG role checks from team leader based on your current spec

### Fixes
- **Buff Tracker**
  - PvP: Buff checks now disable in battlegrounds and arenas
  - Mythic+: Fixed cases where reminders and tracking could stop after the timer starts
  - Raid buffs: Pre-combat raid buff coverage now persists into combat instead of being dismissed 
  - Source of Magic: No longer shows as missing if the Evoker talent is not selected
  - Buff Drop: Alert frame is now included in **Lock/Unlock All**
  - Combat stability: Fixed a rare "table index is secret" crash when scanning buffs during restricted combat windows
- **Pet Tracker / Movement Alerts**: Fixed notifications stopping after zone transitions by resetting state during loading screens
- **Stealth Reminder**: **Group Only** now appears immediately when enabling the module (no reload needed)
- **Edit Mode Drawer**: **Unlock All** now correctly shows/hides Report Card and Buff Drop previews, matching the General page behavior
- **Queue confirmation**: Reduced taint errors from the existing auto-confirm flow
