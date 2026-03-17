# Changelog
## [20260317.02]

### Bug Fixes
- **Battleground / PvP Taint Errors** — Fixed widespread errors that occurred in battlegrounds and other PvP instances caused by Blizzard's secret/tainted aura and spell data. Buff Watcher, Movement Alert, and Mouse Ring now gracefully skip checks when data is restricted instead of throwing errors.
- **Mouse Ring** — Fixed a taint error on the AFK check when entering a battleground or arena.
- **Buff Watcher — Class Buffs / Consumables / Raid Buffs / Buff Drop** — Fixed repeated taint errors from reading aura fields (spell ID, expiration, icon) that Blizzard marks as secret in PvP. These checks now safely bail out when aura data is unreadable.
- **Buff Watcher — Weapon Enchant Checks** — Weapon enchant detection (poisons, sharpening stones, etc.) no longer causes errors when enchant info is tainted.
- **Movement Alert** — Removed 26 instances of a forbidden conversion pattern on spell cooldown, charge, and override data that could produce taint errors in combat. Cooldown and charge tracking now reads API values directly.

## [20260317.01]

### Changes
- **Buff Drop Alert** — The "Dungeons / Raids Only" filter no longer blocks alerts for personal raid buffs (Battle Shout, Mark of the Wild, etc.) or class buffs. Those will now always alert regardless of zone.
- **Buff Drop Alert** — With "Always Monitor Raid Buffs" enabled, an icon now appears showing how many group members are missing a buff you provide (e.g. **3/5**), updating live — no more guessing who's unbuffed.

### Bug Fixes
- **Import / Export** — Profiles exported via the WagoUI API are now fully compatible with the in-game Import button, and vice versa.
- **Dragonriding bar** — The bar no longer loses its position after a UI reload when anchored to a CDM frame. It now repositions itself automatically on login.
- **Dragonriding bar — Hide CDM / BCM while skyriding** — This option now actually works for **Ayije CDM** as well. Left backwards support for **BetterCooldownManager** 
