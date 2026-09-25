# Nexus - CurseForge Package Information

## Title
Nexus

## Tagline
In-game leveling and library-book guides for WoW Forever

## Summary
Step-by-step quest guides with waypoint navigation, automatic targeting, and a beautiful liquid-glass UI. Currently includes the complete 10 Library Books route for both factions.

## Full Description

**Nexus** is an in-game leveling guide addon for **WoW Forever (Classic Beta)**, featuring full step-by-step routes with integrated waypoint navigation, automatic targeting assistance, and a modern liquid-glass UI.

### Current Guides

- **10 Library Books (Alliance)**: Complete route from Stormwind through Elwynn, Westfall, Duskwood, Ironforge, Loch Modan, Wetlands, Darkshore, Ashenvale, and The Barrens to unlock *Friend of the Library* achievement and necklace reward
- **10 Library Books (Horde)**: Complete route from Crossroads through multiple zones including Sludge Fen, Ratchet, Stonetalon, Orgrimmar, Brill, Undercity, and more

### Key Features

**Navigation & Waypoints**
- Dynamic 3D waypoint arrow with distance tracking
- Minimap and world map integration with live pins (powered by HereBeDragons)
- Automatic waypoint updates as you progress

**Targeting & Automation**
- Automatic creation and updates of the `NexusTarget` macro
- Smart unit marking with raid icons
- One-click targeting assistance
- Keybindable targeting for faster gameplay

**Beautiful UI**
- Liquid-glass themed interface with smooth transparency effects
- Five premium themes: Nexus Blue, Red, Gold, Dark Mode, and Green
- Fully resizable and draggable windows
- Customizable fonts, sizes, opacity, and scaling
- Split-panel design: floating current step tracker + full guide list

**Quality of Life**
- Faction auto-detection (shows only relevant guides)
- Step completion tracking with manual skip options
- Minimap button for quick access
- Auto-advance when objectives are complete
- Profile system for multiple characters

### Commands

- `/nexus` — Open the guide selection menu
- `/nexus opt` — Open options and customization
- `/nexus reset` — Reset current guide to step 1
- `/nexus show` / `/nexus hide` — Toggle guide visibility
- `/nexus arrow` — Reset waypoint arrow position

Legacy commands (`/sbg`, `/swet`, `/sweat`) are also supported for compatibility.

### Installation

1. Download and extract to `World of Warcraft\_classic_beta_\Interface\AddOns\`
2. Ensure the folder is named **`Nexus`**
3. Enable the addon in your AddOns list
4. Type `/nexus` in-game to get started

### Technical Details

- **Interface**: 16001, 11509 (WoW Forever / Classic Beta)
- **SavedVariables**: SBGDB (account-wide), SBGPC (per-character)
- **Dependencies**: Includes HereBeDragons-2.0, LibStub, CallbackHandler-1.0

### Feedback & Support

Found a bug or have a suggestion? Please report it on GitHub or in the comments below!

---

## Categories
- **Primary**: Quests & Leveling
- **Secondary**: Map & Minimap, Miscellaneous

## Game Versions
- WoW Forever (Classic Beta): 1.16.0
- Classic Era: 1.15.5

## Tags
leveling, guide, quests, waypoint, navigation, library-books, forever, classic

## License
MIT License

## Author
Nexus Development Team

## Website
https://github.com/gitBellucci/Nexus
