# Changelog
## [20260403.04]

### Fixes
- **Buff Tracker**
  - **Shadowform/Voidform false alert**: Disabled Class buff always-on checks  during combat. Self-buff substitution patterns (e.g. Shadowform being replaced by Voidform) invalidate the aura cache in a way that can't be recovered mid-fight, causing false "missing" alerts. Class buff checks resume correctly after combat ends.