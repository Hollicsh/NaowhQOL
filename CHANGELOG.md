# Changelog

## [20260715.01]

### Bug Fixes
**Focus Cast Bar**
- Freeze the cast bar fill when a cast is interrupted so the grey hold no longer keeps growing
- Fix interrupt tick placement (hide when kick will not come up during the cast; correct mid-cast re-snapshot)
- Fix interrupter GUID / channel-stop handling 

**Spell Alerts**
- Module defaults to on with no specs checked (alerts off); checking a spec enables overlays for that spec only
- Checking a spec while the master toggle was off now takes control of overlays
- Reverted earlier CVAR change on Spell Alerts only to assure they are checked per spec on reload/login/spec change

**Dragonriding**
- Fix Ellesmere Cooldown Manager name matching
- Re-apply resource/CDM hide each update so other UIs cannot un-hide bars while skyriding
- Do not force Ellesmere primary/secondary resource bars visible on dismount when they were already off (fixes flash until backpack/UI refresh)
