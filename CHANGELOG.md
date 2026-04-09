# Changelog
## [20260409.01]

### Fixed
- **Alpha Coloring on Ready Color**- Mouse ring alpha coloring was still the old RGB despite having the RGBA color picker, updated so ready ring now matches RGBA of both its own color or if set to match swipe color

### Performance
- **CRez Timer**: The timer update loop now only runs while the rez timer is actually visible, reducing background CPU usage when the feature is not in use. 
- **Co-Tank**: Updates now only run while the frame is visible. Also improved efficiency by caching class lookups instead of recalculating them constantly.
- **Buff Watcher V2**: Reduced overhead in several places by cutting down repeated work and extra allocations, improving overall performance during regular scanning and refreshes.