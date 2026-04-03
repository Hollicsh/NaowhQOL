# Changelog

## [20260403.01]

### Fixes
- **Buff Tracker**
  - **Shaman Shields**: Earth Shield is now checked correctly as a buff you place on someone else. If your Earth Shield is on a tank, it will no longer show as missing. Shield exclusivity also behaves properly, so having one shield active stops alerts for the others, this should stop the false positives on Lightning Shield
  - **Duplicate consumable alerts**: fixed an issue where missing a consumable (e.g. augment rune) could show two separate reminder icons at the same time. 