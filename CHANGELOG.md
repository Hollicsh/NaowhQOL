# Changelog
# Hotfix
## [20260317.04]

### Fixes
- **Search for Buff Watcher**
  Searching for things like **"buff drop"** should now correctly bring up the **Buff Watcher** module.

  We also added more search terms for that section, including:
  - Buff Drop Reminder
  - Always Monitor My Raid Buffs
  - Always Monitor My Class Buffs
  - Always Monitor My Consumables
  - Always Monitor My Inventory

- **Continued Lua Errors**
  Fixed addon-wide issues related to secret Values, which could cause Lua errors in certain situations.
  This hotfix improves how the addon handles cooldowns, charges, durations, and similar timer data so affected modules work properly without throwing errors.
  Modules most impacted as part of this fix:
  - Movement Alert
  - Combat Rez Timer
  - Dragonriding / Vigor
  - Mouse Ring GCD Sweep

