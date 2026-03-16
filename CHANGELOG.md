# Changelog
## [20260316.02]

### Buff Watcher – Buff Drop Reminder

- **Fixed:**
- Scan / Ready Check no longer clears active reminders.
  - Running `/nscan`, `/scannow`, or accepting a ready check would make all buff drop reminder icons vanish until a buff actually fell off or you reloaded. Buff drop reminders and the scan report now work side by side and no longer interfere with each other.
- Flask near-expiry no longer shows the icon as red/desaturated.
  - If a consumable is running low (but still active), the icon now shows in normal color with a countdown timer. Only completely missing buffs are shown in red.
- **Added:**
- Font size slider and font picker for buff drop reminder duration text (in the Buff Watcher config, Buff Drop Reminder section).
- Rounded corners on buff drop reminder icons so they sit cleanly behind the proc glow border.
- New Checks for Buff Drop disable in rested or make instance only

