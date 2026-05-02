# Changelog
## [20260501.01]

### Bug Fixes
  - Range Check: Fixed font reverting to NaowhAsia.ttf on first login by deferring display initialization until all PLAYER_LOGIN handlers (including LSM font registrations) have completed
  - Range Check: Fixed font size reverting to default on first login by reading from the saved frame height instead of the unlaid-out frame
  - Buff Watcher / Stealth Reminder: "Dungeons / Raids Only" option no longer activates in Delves (which use scenario instance type); now correctly restricts to party dungeons and raids only
