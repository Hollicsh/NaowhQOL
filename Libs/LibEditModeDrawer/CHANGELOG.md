## [20260313.01] - March 13, 2026

### Bug Fixes & Improvements

**Buff Watcher**
- Fixed taint error "attempt to compare a secret number value" caused by comparing `auraData.icon` (a protected FileDataID) during combat. Food buff checks are now skipped entirely while in combat.

**Movement Alert**
- Fixed: Unchecking a spell in Tracked Spells no longer causes it to still trigger an alert when cast. Alias-group resolution now correctly respects disabled state.
- Fixed: Stampeding Roar separated from the Wild Charge alias group and given a correct 2-minute fallback cooldown.
- Fixed: Roll (Monk) cooldown now correctly accounts for Tiger's Vigor (451041). Tiger's Lust cast immediately reduces Roll cooldown by 4.5s.
- New: Burning Rush (Warlock) tracked as a "buff active" warning — displays "Burning Rush Active!" to remind you to cancel it.

---

## [20260313.01] - ...