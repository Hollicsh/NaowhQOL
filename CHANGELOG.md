# Changelog
## [20260408.02]

### New Features
- **Buff Watcher V2**
  - **Ring Color Transparency**: All mouse ring color pickers now include an alpha/opacity slider, allowing rings to be made fully transparent (e.g. outer-ring-only or inner-ring-only setups).
  - **Buff Drop: No Red Tint**: New option to show missing buff icons desaturated only, without the red tint overlay.
  - **Buff Drop: Raid Buff Text Mode**: New option to display missing raid buffs (e.g. Arcane Intellect, Mark of the Wild) as a floating text in a separate, movable anchor instead of icons. The anchor includes an independent color picker (with class color default), font picker, and font size slider. The background and border are hidden unless the anchor is unlocked.

### Fixes
- **Addon Profiler**
  - **Max CPU column**: Fixed the Max column resetting every tick alongside the Average. It now tracks the true session peak per addon and only resets when the Reset button is clicked or the profiler is closed/stopped.

### Locale
- **ru.RU** Added provided Russian Locale updates