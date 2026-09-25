# Changelog

## [1.1.0] - 2026-09-25

### Breaking Changes
- **Complete rebrand from "Sweat Beta Guide" / "SwetBetaGuide" to "Nexus"**
  - Addon folder must now be named `Nexus` (previously `SwetBetaGuide` or `SweatBetaGuide`)
  - Primary slash command is now `/nexus` (legacy commands `/sbg`, `/swet`, `/sweat` still work)
  - TOC file renamed to `Nexus.toc`

### Added
- New primary slash command: `/nexus` (opens guide menu)
- Global `_G.Nexus` accessor for the addon (alongside existing `_G.SBG`)
- Improved drag-and-drop reliability for UI windows

### Changed
- **All user-facing text updated to "Nexus" branding**:
  - Addon title, tooltips, welcome messages, and chat output
  - Minimap button tooltip
  - Options window headers
  - Theme names: "Nexus Blue", "Nexus Red", "Nexus Gold", "Nexus Green"
- **Targeting macro renamed**:
  - `SweatTarget` → `NexusTarget`
  - `SweatFollow` → `NexusFollow`
- **Fixed UI drag handlers**: All windows now use proper `OnDragStart`/`OnDragStop` instead of `OnMouseDown` to prevent double `StartMoving()` errors
- Guide group changed from "Sweat Beta Guide" to "Nexus"
- README and documentation updated for new branding

### Migration Notes
For existing users upgrading from SwetBetaGuide/SweatBetaGuide:
- **Saved variables preserved**: `SBGDB` and `SBGPC` remain unchanged, so your settings and progress are safe
- **Old slash commands still work**: You can continue using `/sbg`, `/swet`, or `/sweat`
- **Targeting macro auto-updates**: If you had `SweatTarget` on your bars, it will be automatically renamed to `NexusTarget` on first load
- **Folder rename required**: Move your addon folder from `Interface\AddOns\SwetBetaGuide` to `Interface\AddOns\Nexus`

---

## [1.0.0] - 2026-09-15

### Initial Release
- Full 10 Library Books guide for both Alliance and Horde factions
- Liquid-glass themed UI with resizable windows
- Waypoint arrow navigation system
- Minimap and world map integration (HereBeDragons)
- Automatic targeting macro creation and updates
- Multiple theme options: Blue, Red, Gold, Dark Mode, Green
- Faction auto-detection and guide filtering
- Customizable fonts, opacity, and window scaling
