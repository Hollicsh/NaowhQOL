# Changelog
## [20260408.01]

### Fixes
- **Combat Logger**
  - **Global logging override**: Fixed a bug where the Combat Logger module would forcefully disable combat logging globally, preventing other addons (e.g. BW/WCL Helper/MRT) from keeping it active. The module now only stops logging it started itself.