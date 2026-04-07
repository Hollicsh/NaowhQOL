# Changelog
## [20260407.01]

### Fixes
- **Buff Tracker**
  - **Taint error fixed**: Resolved "secret boolean value" taint errors caused by `UnitIsUnit` returning protected values. Ready checks and player detection now use a safe GUID-based fallback.
  - **Duplicate augment rune alerts**: Fixed Ethereal Augment Rune and Void-Touched Augment Rune sometimes showing as two separate glowing icons after dying and being revived in the same cache window.
  - **Ghost alerts after death**: Buff Drop alerts are now properly dismissed when you die, preventing stale icons from lingering on screen.
  - **Dead players excluded from raid buff counts**: Dead or ghosted players are no longer included in the "missing buff" count, so the numbers actually reflect who needs the buff.
  - **Accurate raid buff totals**: Raid buff counts now only include players who actually benefit from each buff. For example, Arcane Intellect shows "3/15" (casters only) instead of "3/20" (the whole raid).
  - **Consumable and class buff overlap**: If a consumable buff and a class buff share the same spell, you'll no longer get a redundant class buff alert when the consumable already covers it.

