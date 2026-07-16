# Changelog
## [20260716.01]
### Hotfix
**Dragonriding**
- Fix mana/power bar flashing on non-mana classes: only hide/restore bars that were actually visible (respect Ellesmere `SetElementVisibility` / `hidePowerIfResource`)
- Disable "Hide Resource Bars While Mounted" / "Hide Cooldown Manager While Mounted" with a muted note when EllesmereUI already handles them via its own Hide when Mounted / Dragonriding visibility options