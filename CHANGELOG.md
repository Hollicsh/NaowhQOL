# Changelog
## [20260317.01]

### Changes
- **Buff Drop Alert** — The "Dungeons / Raids Only" filter no longer blocks alerts for personal raid buffs (Battle Shout, Mark of the Wild, etc.) or class buffs. Those will now always alert regardless of zone.
- **Buff Drop Alert** — With "Always Monitor Raid Buffs" enabled, an icon now appears showing how many group members are missing a buff you provide (e.g. **3/5**), updating live — no more guessing who's unbuffed.

### Bug Fixes
- **Import / Export** — Profiles exported via the WagoUI API are now fully compatible with the in-game Import button, and vice versa.
- **Dragonriding bar** — The bar no longer loses its position after a UI reload when anchored to a CDM frame. It now repositions itself automatically on login.
- **Dragonriding bar — Hide CDM / BCM while skyriding** — This option now actually works for **Ayije CDM** as well. Left backwards support for **BetterCooldownManager** 
