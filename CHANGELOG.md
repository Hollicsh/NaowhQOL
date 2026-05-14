# Changelog
## [20260514.01]

### Bug Fixes
  - Emote Detection: Spell-based auto emotes no longer try to post while you are in combat (the client blocks that and error addons could flood you with "action blocked" / `SendChatMessage` reports, sometimes shown as a cryptic `UNKNOWN()`). The emote is queued and sent after you leave combat instead.
  - Movement Cooldown Alert: Buff-based rows (for example Warlock Burning Rush) keep polling briefly while you are in combat even when nothing is shown yet, so the alert can appear reliably if aura updates lag behind spell events in combat.
