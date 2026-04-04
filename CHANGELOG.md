# Changelog
## [20260404.01]

### Fixes
- **Buff Tracker**
  - **Duplicate weapon enchant alert on death**: Fixed an issue where dying could show two separate "Weapon Buff missing" icons. Weapon enchants temporarily disappear while dead, so weapon enchant checks are now suppressed until you are alive again.
  - **Buff Drop Reminder is now the master toggle**: The **Always Monitor** options (Raid Buffs, Class Buffs, Consumables, Inventory) now require **Buff Drop Reminder** to be enabled. Disabling Buff Drop Reminder will also stop monitoring and clear any active alerts.
  - **Weapon enchant alert deduplication**: Fixed a few unique cases where the always-on consumable monitor could create a second weapon buff alert when Buff Drop Reminder was already tracking it.