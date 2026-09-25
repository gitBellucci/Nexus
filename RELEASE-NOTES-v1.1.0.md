# Nexus v1.1.0 Release Summary

## Release Date
September 25, 2026

## Pull Request
https://github.com/gitBellucci/SweatBetaGuide/pull/1

## Downloads

### Addon Package (CurseForge/Manual Install)
- **File**: `Nexus-v1.1.0.zip` (2.9 MB)
- **Location**: Available in repository root
- **Installation**: Extract to `World of Warcraft\_classic_beta_\Interface\AddOns\` (folder will be named `Nexus`)

## What's New in v1.1.0

### Complete Rebrand
- Full rename from "Sweat Beta Guide" / "SwetBetaGuide" to **Nexus**
- **ONLY slash command: `/nexus`** — all legacy commands removed (`/sbg`, `/swet`, `/sweat`)
- Updated all UI text, tooltips, and messages
- Theme names now branded as "Nexus Blue", "Nexus Red", "Nexus Gold", "Nexus Green"

### Bug Fixes
- Fixed drag-and-drop Lua errors when moving addon windows
- Improved reliability of frame dragging
- Font consistency between top and bottom windows

### For Existing Users
**Migration required!**
- Rename your addon folder: `SwetBetaGuide` → `Nexus`
- Use new slash command: `/nexus` (old commands no longer work)
- All settings, progress, and themes are preserved
- Targeting macro auto-updates from `SweatTarget` to `NexusTarget`

## CurseForge Package Details

### Addon Information
- **Title**: Nexus
- **Version**: 1.1.0
- **Interface**: 16001, 11509 (WoW Forever / Classic Beta)
- **Category**: Quests & Leveling
- **License**: MIT

### Description
In-game leveling and library-book guides for **WoW Forever (Classic Beta)** with step-by-step routes, waypoint navigation, automatic targeting, and a beautiful liquid-glass UI.

**Current Guides**:
- 10 Library Books (Alliance) - Stormwind start
- 10 Library Books (Horde) - Crossroads start

**Features**:
- Dynamic 3D waypoint arrow
- Minimap & world map integration
- Automatic targeting macro (`NexusTarget`)
- 5 premium themes with liquid-glass effects
- Fully customizable: fonts, opacity, scaling, colors
- Split-panel UI: current step tracker + full guide list

### Commands
- `/nexus` — Open guide menu
- `/nexus opt` — Options & customization
- `/nexus reset` — Reset current guide
- `/nexus show` / `/nexus hide` — Toggle visibility
- `/nexus arrow` — Reset waypoint arrow

### Tags
`leveling`, `guide`, `quests`, `waypoint`, `navigation`, `library-books`, `forever`, `classic`

## File Manifest

### Included in Package
```
Nexus/
├── Nexus.toc              # Addon TOC (v1.1.0)
├── Core.lua               # Main addon core
├── UI.lua                 # User interface (with drag fixes)
├── Menu.lua               # Guide selection menu
├── Options.lua            # Settings panel
├── Engine.lua             # Guide engine
├── Parser.lua             # Guide parser
├── Theme.lua              # Theme definitions
├── Widgets.lua            # UI widgets
├── Targeting.lua          # NexusTarget macro system
├── Arrow.lua              # Waypoint arrow
├── Pins.lua               # Map integration
├── DB.lua                 # Database / settings
├── Bindings.xml           # Keybind definitions
├── LICENSE                # MIT License
├── README.md              # Installation & usage
├── CHANGELOG.md           # Full version history
├── CURSEFORGE.md          # CurseForge metadata
├── libs/                  # Libraries
│   ├── LibStub/
│   ├── CallbackHandler-1.0/
│   └── HereBeDragons/
├── Guides/                # Quest guides
│   ├── Alliance-10-Library-Books.lua
│   └── Horde-10-Library-Books.lua
├── Textures/              # Icons & arrows
└── Media/                 # Theme textures (liquid-glass)
```

## Git Commit History (v1.1.0)

1. `e3b3ec0` - Add CHANGELOG and CurseForge packaging documentation
2. `611d40c` - Rename TOC files: remove dual TOCs, use single Nexus.toc
3. `502d56c` - Rebrand Sweat/SwetBetaGuide to Nexus (main rebrand commit)
4. `4b054b4` - fix: match top window font size to bottom list
5. `6e950a9` - fix: IsSizing() not available in WoW Classic
6. `af5d9d8` - fix: drag snap bug - guard StartMoving() against double-call

## Next Steps

1. **Merge PR**: Review and merge https://github.com/gitBellucci/SweatBetaGuide/pull/1
2. **Create GitHub Release**: Tag `v1.1.0` with `Nexus-v1.1.0.zip` as release asset
3. **Upload to CurseForge**:
   - Upload `Nexus-v1.1.0.zip`
   - Copy description from `CURSEFORGE.md`
   - Copy changelog from `CHANGELOG.md`
   - Set game versions: 1.16.0 (Forever), 1.15.5 (Classic Era)
   - Set categories: Quests & Leveling (primary), Map & Minimap
   - Add tags from CURSEFORGE.md

## Testing Notes

All changes tested:
- ✅ Slash command works (`/nexus` and subcommands)
- ✅ Legacy commands removed (`/sbg`, `/swet`, `/sweat` no longer function)
- ✅ UI drag-and-drop functions without errors
- ✅ Branding updated throughout (tooltips, menus, chat messages)
- ✅ Targeting macro creates `NexusTarget` correctly
- ✅ Themes show "Nexus" prefixes
- ✅ Guide group names updated to "Nexus"
- ✅ Both windows use matching fonts
- ✅ Saved variables preserved for migration

---

**Contact**: GitHub issues or CurseForge comments
**License**: MIT
**Repository**: https://github.com/gitBellucci/Nexus (update after rebrand complete)
