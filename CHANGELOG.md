# Changelog
## [20260408.03]

### Performance
- **CRez Timer**: The timer update loop now only runs while the rez timer is actually visible, reducing background CPU usage when the feature is not in use. 
- **Co-Tank**: Updates now only run while the frame is visible. Also improved efficiency by caching class lookups instead of recalculating them constantly.
- **Buff Watcher V2**: Reduced overhead in several places by cutting down repeated work and extra allocations, improving overall performance during regular scanning and refreshes.