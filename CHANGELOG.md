# Changelog
## [20260405.01]

### New
- **Buff Tracker**
  - **Buff Drop glow styles**: Added 4 glow options for Buff Drop alerts: **Pixel**, **AutoCast**, **Border**, and **Proc**. Each style has its own settings so you can fine-tune the look.
  - **Class color glow**: Optional toggle to color the glow using your class color.
  - **Tidecaller's Guard tracking**: Added tracking for the Restoration Shaman imbue **Tidecaller's Guard** (requires the talent).

### Improvements
- **Buff Tracker**
  - **More reliable alerts**: Buff Drop alerts have been rebuilt into a single unified system, reducing duplicate edge cases and keeping the display in sync more consistently.
  - **Better combat and encounter tracking**: Expanded the list of buffs that can be safely checked during combat and boss encounters, including many healer HoTs and common group buffs like **Source of Magic** and **Symbiotic Relationship**.
  - **Elemental Orbit support**: Shaman shield tracking now accounts for the **Elemental Orbit** talent — with it, you'll see separate alerts for Earth Shield (self) and a second shield (Water/Lightning). Without it, any single shield satisfies the check.
  - **Updated flask list**: Added **Flask of Saving Graces** and **Vicious Thalassian Flask of Honor**.

### Fixes
- **Buff Tracker**
  - **Earth Shield tracking**: Fixed Earth Shield using the wrong spell ID for the targetted spell specifically. Existing settings are migrated automatically.