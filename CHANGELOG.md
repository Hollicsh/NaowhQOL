# Changelog
## [20260316.01]
### Fix
**Pet Tracker**
- Fixed taint on petracker health returning a secret if reloaded in combat (why are you doing this??)
**GCD Tracker**
- Added hunter Auto Shot(id:75) to default block list
**Movement Alert**
- Refactored movement tracker to more accurately detect when spells cds are modified by external sources like hero talents. 
    -# Massive credit to sunaruqtx for not only finding a solutioon but testing these changes for weeks now.