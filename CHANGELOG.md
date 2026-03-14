# Changelog

## [20260314.03]

### New
**Pet Tracker**
- Added low health warning: displays a configurable on-screen alert when your pet's HP drops below a set threshold (default: 25%). Enable in the Behavior section; customize the text and threshold % in Warning Text
- Added option to suppress the "Pet Passive" notification independently of all other pet alerts. Useful for players who keep their pet on Passive by default and don't want the constant reminder

**Mouse Ring**
- Added 18 new ring shape options: soft circle, hard circle, rings (4 variants), soft rings (4 variants), glows (3 variants), crosses (3 variants), star, swirl, and sphere edge
- Added center dot overlay with configurable color, size, and class color support
- Added fade-on-idle: ring fades out after a configurable delay when the mouse stops moving
- Added trail shape selection: glow, circle, ring, star, and sparkle
- Added trail size slider
- Added trail length slider (5-60 points)
- Added trail brightness slider
- Added sparkle colors option for rainbow-cycling trail points

### Fix
**Mouse Ring**
- Fixed: AFK state check no longer causes a taint error ("attempt to perform boolean test on a secret boolean value")

**Buff Watcher**
- Fixed: Consuming an item no longer causes a taint error ("attempt to compare a secret number value") in the consumable always-on check; the aura re-check triggered by `UNIT_INVENTORY_CHANGED` is now deferred out of the protected execution frame

**UI**
- Fixed: Long dropdown text no longer line-wraps; text is truncated with ellipsis instead
