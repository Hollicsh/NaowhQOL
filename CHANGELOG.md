# Changelog
## [20260517.01]

### Bug Fixes
  - Emote Detection: Spell-based auto emotes no longer try to post while you are in combat (the client blocks that and error addons could flood you with "action blocked" / `SendChatMessage` reports, sometimes shown as a cryptic `UNKNOWN()`). The emote is queued and sent after you leave combat instead.
  - Buff Watcher: Shaman Earth Shield reminder no longer sticks on "NO ES" after wipes or in instances when ES is active — targeted checks accept auras when Blizzard omits `sourceUnit`, both ES spell IDs are matched, and always-on alerts refresh during combat/M+.
  - Buff Watcher: Fixed `FontString:SetText(): Font not set` spam from the raid-buff text list when clearing or updating labels (now applies a fallback font before any `SetText` call).