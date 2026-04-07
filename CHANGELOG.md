# Changelog
## [20260407.02]

### Fixes
- **Buff Tracker**
  - **Interchangeable spells false alert in M+**: Fixed a rare case where Buff Drop could incorrectly show an interchangeable spell as missing when entering combat in a Mythic+ dungeon. The addon will now avoid marking the buff as missing when it cannot safely re-check it during combat.
  - **Food buff expiry color**: Fixed food Buff Drop icons not switching to the missing (red/desaturated) state when the buff expires. Icons now update correctly the moment the timer hits 0.