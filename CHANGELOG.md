# Changelog

## [20260704.01]

### Improvements
**CVar handling**
- Spell Queue Window and other managed settings now respect values changed outside NaowhQOL (macros, other addons, or the default UI). On reload, QOL adopts the live value instead of forcing an old saved value. Spell Alerts follow the same rule and will not overwrite external changes until you change them in QOL’s settings.
**Dragon Riding icon font**
- Whirling Surge cooldown text on the icon can use its own font and size. Find **Icon Font** and **Icon Font Size** under Dragon Riding → Icon (separate from the speed bar font).

### New Feature
**Lock Cursor in Combat**
- New option under QOL Misc → Combat. While in combat, the mouse stays clipped to the WoW window (similar to BattleCursorClip). Your normal cursor lock setting is restored when combat ends.

### Localization
- Synced locale files with enUS: added 130 missing strings to deDE, esES, frFR, ptBR, koKR, zhCN, and zhTW (Alerts, fonts, mouse ring, combat cursor clip, dragon riding icon font, and related notes).
- Added Russian translations provided by native speaker.