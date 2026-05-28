# Changelog

## [20260528.01]

### Added
**Alerts**
- Added a new Alerts tab with Spell Alerts, Dispel Glow, and Potion Ready tools.
  - Spell Alerts can now be enabled per spec across every class.
  - Dispel Glow highlights party and raid frames when a player has something you can dispel, with configurable glow color and style.
  - Potion Ready adds a movable alert when a combat potion is ready, with custom text, font, color, sound, glow, combat-only, instance-only, and healer-disable options.

**Mouse Ring**
- Added an optional dispel cooldown timer near the cursor.
- Added font size, color, and position controls for the dispel cursor timer.

**QOL Misc**
- Added Global Copy for copying hovered UI text or tooltip IDs with a configurable hotkey.
- Added `/copy`, `/ncopy`, and `/naocopy` slash commands for copying frame text.
- Added a setting to hide the minimap icon.

**System Optimizations**
- Expanded the FPS optimization preset with raid graphics, FPS caps, loading screen FPS, visual effects, network/logging, and camera/nameplate settings.
- Added more optimization categories so individual settings are easier to review and apply.

### Improved
**Profiles**
- Corrected a niche bug where importing another profile could potentially clear out settings of other profiles if the source profile had the module disabled.

**Movement Alerts**
- Improved the existing Time Spiral tracker so spec-specific movement procs and spell overrides are detected more reliably.
- Time Spiral alerts now clear when the related Blizzard overlay fades instead of lingering.
- Added clearer notes and spacing for Movement Alert, Time Spiral, and Gateway Shard settings.

**Audio**
- SharedMedia sound selection now correctly support BigWigs sounds more reliably, including both file-based and in-game BigWigs entries.

**GCD Tracker**
- Improved icon handling so GCD Tracker icons stay visible and fade more consistently during gameplay.