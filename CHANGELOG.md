# Changelog
## [20260408.02]

### Fixes
- **Addon Profiler**
  - **Max CPU column**: Fixed the Max column resetting every tick alongside the Average. It now tracks the true session peak per addon and only resets when the Reset button is clicked or the profiler is closed/stopped.