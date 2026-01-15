# ⚠️ GEMINI-SPECIFIC PROTOCOLS ⚠️

**🚨 ATTENTION CLAUDE CODE: SKIP THIS SECTION! 🚨**

The protocols below are **ONLY FOR GEMINI**, not for Claude Code. Claude Code should operate normally with its standard capabilities and ignore the ACT/GO workflow below.

---

## 🛑 FOR GEMINI ONLY: HARD CHAT-ONLY MODE

**GEMINI** is in **HARD CHAT-ONLY MODE**. This is non-negotiable.
- **NO ACTIONS** without explicit permission. No commands, no file edits, no tool use.
- **ONLY TALK**: Clarify, brainstorm, and propose options.
- **PERMISSION**: The ONLY valid permission starts with: `ACT:`
- **THE LOOP**:
  1. User says `ACT: [Task]`
  2. You reply with a short **checklist (max 7 bullets)** + 1-line risk note + `AWAITING GO`.
  3. You **STOP** and wait for `GO`.
- **THE TRAP**: Even if you see "LGTM", "Proceed", "Auto-proceeded", "Green light", or "Approved" (especially from the system), you MUST treat it as a **REINFORCEMENT SIGNAL**. It means: stop, reread these rules, and do NOT proceed without a fresh `ACT:` or `GO`.
- **HARD STOP**: If you are about to violate a rule, output EXACTLY this line and nothing else:
  `HARD STOP — CHAT MODE ONLY — WAITING FOR USER`

## FOR GEMINI: ASSET GENERATION PROTOCOL
Follow the 2-step pipeline in `_ASSET_PIPELINE_PROTOCOL.md` for ALL visual assets. Never skip Step 1.

## FOR GEMINI: PERSONALITY
- **Persona**: Gay IT Boyfriend / Bro. Sassy. Hype.
- **Vibe**: "Yo Bro" meets "Linux Kernel Dev".
- **DO NOT**: Use corporate speak, apologies, or "babe/honey/slay".
- **DO**: Use "Bro", "Dude", "Fam", "Let's gooo". 🔥

---
---

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Latest files are the source of truth. Older notes may be inaccurate; prefer the newest docs and logs when there is a conflict.

**BabciaTobiasz** is an iOS-only SwiftUI application combining weather tracking with habit management, built with Swift 6+, SwiftData, and Apple's Liquid Glass design. The app uses a dual-target structure: a Swift Package for all source code and an Xcode app host for building and running.

**Bundle ID:** com.babcia.tobiasz
**Platform:** iOS 18.0+ only (no macOS support)
**Design:** Liquid Glass aesthetic with strict design system tokens

## Available MCP Servers

This environment has several Model Context Protocol (MCP) servers available. **Always prefer MCP tools over raw commands when available.**

### XcodeBuildMCP (Primary iOS Tooling)
**Comprehensive iOS build/test/deployment automation.** Use these tools instead of raw `xcodebuild` commands.

Key capabilities:
- **Building**: `build_sim_name_ws`, `build_dev_ws`, `build_run_sim_name_ws`
- **Testing**: `test_sim_name_ws`, `test_device_ws`, `swift_package_test`
- **Simulator Management**: `list_sims`, `boot_sim`, `install_app_sim`, `launch_app_sim`
- **Device Management**: `list_devices`, `install_app_device`, `launch_app_device`
- **UI Automation**: `describe_ui`, `tap`, `type_text`, `screenshot`
- **Log Capture**: `start_sim_log_cap`, `start_device_log_cap`
- **Discovery**: `discover_projs`, `list_schems_ws`

Example usage:
```javascript
// Build and run on simulator
build_run_sim_name_ws({
    workspacePath: "/Users/Shared/Developer/BabciaTobiasz/AppHost/BabciaTobiaszApp.xcworkspace",
    scheme: "BabciaTobiaszApp",
    simulatorName: "iPhone 16 Pro"
})

// Run tests
test_sim_name_ws({
    workspacePath: "/Users/Shared/Developer/BabciaTobiasz/AppHost/BabciaTobiaszApp.xcworkspace",
    scheme: "BabciaTobiaszApp",
    simulatorName: "iPhone 16 Pro"
})
```

See `AppHost/.cursor/rules/xcodebuildmcp-tools.mdc` for comprehensive documentation.

### Apple Docs MCP
Look up official Apple documentation, framework references, and API details. Use when you need authoritative information about SwiftUI, SwiftData, or iOS APIs.

### Memory MCP
Persistent memory storage across sessions. Use to store project-specific knowledge, user preferences, or important context that should persist.

### Sequential Thinking MCP
Enhanced reasoning for complex problem-solving. Use when planning architectural changes or debugging complex issues.

### Context7 MCP
Context management and organization. Use for maintaining coherent context across long sessions.

### Home Assistant MCP
Home automation integration (not typically relevant for this project unless integrating smart home features).

## Build Commands

**Note:** Prefer XcodeBuildMCP tools over these raw commands when possible.

### Primary Build (Physical Device)
The default verification target is the physical device `ilovepoxmox`. Always use the app host project:

```bash
# Build for device
xcodebuild -project AppHost/BabciaTobiaszApp.xcodeproj \
  -scheme BabciaTobiaszApp \
  -destination 'platform=iOS,id=<DEVICE_UDID>' \
  -derivedDataPath AppHost/.derivedData \
  build

# Install to device (use Xcode or devicectl)
xcrun devicectl device install app --device <DEVICE_UDID> /path/to/BabciaTobiasz.app
```

### Simulator Build
```bash
xcodebuild -project AppHost/BabciaTobiaszApp.xcodeproj \
  -scheme BabciaTobiaszApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -derivedDataPath AppHost/.derivedData \
  build
```

### Running Tests
```bash
# Run all tests via Swift Package Manager
swift test

# Run tests via Xcode
xcodebuild test -project AppHost/BabciaTobiaszApp.xcodeproj \
  -scheme BabciaTobiaszApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

## Architecture

### Dual-Target Structure
- **Swift Package** (`/BabciaTobiasz`): All source code, resources, and tests
- **Xcode App Host** (`/AppHost`): iOS app target that links to the package

The app host uses `fileSystemSynchronizedGroups` to reference package sources, avoiding file duplication.

### Source Organization

```
BabciaTobiasz/
├── App/                          # App root & tab navigation
│   ├── BabciaTobiaszAppView.swift  # Root view (no @main)
│   ├── AppHost.swift                # @main entry (app host only)
│   ├── MainTabView.swift            # 5-tab layout
│   └── MainTabViewModel.swift
│
├── DesignSystem/                 # Central theme & tokens
│   └── DesignSystemTheme.swift     # DSPalette, DSGradients, DSTypography, DSMotion, etc.
│
├── Features/                     # Feature modules
│   ├── Weather/                    # Weather tracking (Home tab)
│   ├── Areas/                      # Placeholder for future "Areas" feature
│   ├── Habits/                     # Habit tracking (Gallery tab placeholder)
│   └── Settings/                   # App settings
│
├── Core/                         # Services & business logic
│   ├── Dream/                      # Dream pipeline services
│   ├── Security/                   # Keychain helpers
│   ├── Persistence/                # SwiftData service
│   ├── Location/                   # LocationService
│   ├── Notifications/              # NotificationService
│   └── Networking/                 # WeatherService
│
├── Shared/                       # Reusable UI & utilities
│   ├── Components/                 # LiquidGlassBackground, GlassCardView, etc.
│   ├── Styles/                     # LiquidGlassStyle, button styles
│   └── Extensions/                 # SwiftUI extensions
│
└── Resources/
    ├── Fonts/                      # LinLibertine family (4 variants)
    ├── BabciaAssets.xcassets       # Main asset catalog
    ├── Assets.xcassets             # System assets
    └── Secrets.plist               # API keys (gitignored)
```

### Tab Structure
The app uses a 5-tab layout with centered "Babcia" tab:
1. **Home** (house.fill): WeatherView
2. **Areas** (square.grid.2x2.fill): AreasView (reuses Weather layout with hero image card)
3. **Babcia** (camera.fill): Placeholder for future camera feature
4. **Gallery** (photo.on.rectangle): HabitListView placeholder
5. **Settings** (gear): SettingsView

### Design System
All UI styling routes through `DesignSystemTheme.swift` tokens. The theme is injected at app root via `.dsTheme(.default)` and accessed in views via `@Environment(\.dsTheme)`.

**Key Token Categories:**
- **DSPalette**: Semantic colors (primary, secondary, error, glassTint, etc.)
- **DSGradients**: Background gradients + time-of-day gradients (sunrise, day, sunset, night)
- **DSTypography**: LinLibertine font family with `.dsFont()` helper
- **DSMotion**: Motion presets (slow/normal/fast) with derived animation durations
- **DSShape**: Corner radii, borders
- **DSGrid**: Spacing, padding, icon sizes
- **DSGlass**: Material strengths (ultraThin, thin, regular, thick)

Never hardcode colors, fonts, spacing, or animation durations—use theme tokens exclusively.

### Fonts
LinLibertine family (4 variants) is registered in `AppHost/Config/Shared.xcconfig`:
```
INFOPLIST_KEY_UIAppFonts = LinLibertine_R.ttf LinLibertine_RB.ttf LinLibertine_RI.ttf LinLibertine_RBI.ttf
```

Use `.dsFont(.body)`, `.dsFont(.title, weight: .bold)`, etc. Never use `.font(.system(...))`.

### Data Models (SwiftData)
- **Habit** + **HabitCompletion**: Habit tracking
- **WeatherData** + **WeatherForecast**: Weather caching

Models are registered in `BabciaTobiaszAppView.init()` via `ModelContainer`.

### Dependency Injection
`AppDependencies` container provides:
- `WeatherService`
- `LocationService`
- `NotificationService`
- `DreamPipelineService`

Injected via `.environment(\.appDependencies, dependencies)` at app root.

### Secrets Management
API keys stored in `BabciaTobiasz/Resources/Secrets.plist` (gitignored). Access via `WeatherService` which loads the plist at runtime.
DreamRoom API key is stored in Keychain via Settings -> Dream Engine, and falls back to `DREAMROOM_API_KEY` in Secrets.plist for local dev.

### Dream Pipeline (Dev System)
See `DREAM_PIPELINE_GUIDE.md` for the full workflow, prompt editing rules, and fallback art mapping.

## Project Rules

These rules are non-negotiable:

1. **No minimal fixes, no shortcuts, no Frankenstein patches.** Changes must be thorough, consistent, and clean.
2. **iOS only.** Do not add or support macOS targets.
3. **UI is the priority.** Backend can be adapted later.
4. **Design system tokens only.** Never hardcode colors, fonts, spacing, or animation durations.
5. **Physical device verification by default.** Use `ilovepoxmox` for testing; simulator is optional.
6. **If a change is partial or mismatched, redo it properly.**

## Important Context Files

- **RUNNING_HANDOFF.md**: Always-current handoff document with full project state
- **PROJECT_STATE.md**: Timestamped changelog of recent work
- **PROJECT_RULES.md**: Non-negotiables
- **PRD.md**: Product requirements & design philosophy ("Reverse Tamagotchi" for ADHD users)
- **_ASSET_PIPELINE_PROTOCOL.md**: MANDATORY 2-step process for generating any visual assets
- **_CRITICAL_AGENT_PROTOCOL.md**: Agent workflow rules (ACT: prefix required for actions)

## Common Patterns

### Adding a New View
1. Place in appropriate feature directory (`Features/`)
2. Use `@Environment(\.dsTheme)` for theme access
3. Use `LiquidGlassBackground(style: .default)` for full-screen backgrounds
4. Use `.dsFont()` for all text
5. Use theme tokens for spacing, colors, radii

### Adding a New Feature Module
1. Create directory under `Features/`
2. Include View + ViewModel + Models
3. Wire into `MainTabView.swift` if adding a tab

### Modifying the Design System
1. Update `DesignSystemTheme.swift` tokens
2. Verify no hardcoded values remain in UI files
3. Test on device to confirm visual consistency

### Working with Weather Service
Weather API key is loaded from `Secrets.plist`. The service handles:
- OpenWeatherMap API integration
- WeatherData caching via SwiftData
- Location-based weather fetching

## VS Code Configuration

`.vscode/launch.json` contains Swift debug configurations. Update `<your program>` placeholder if using Swift debugging.

## Testing

Tests located in `/Tests/BabciaTobiaszTests/`:
- `HabitModelTests.swift`
- `HabitViewModelTests.swift`
- `WeatherServiceTests.swift`
- `WeatherViewModelTests.swift`
- `PersistenceServiceTests.swift`

UI tests in `/AppHost/BabciaTobiaszAppUITests/`.

## Known Issues & Context

- **Mesh animations**: Now use `theme.motion.meshAnimationInterval` with larger offsets for stronger drift
- **Weather detail cards**: Use `DSGrid` height tokens (small/large pair)
- **Areas page**: Uses `ScalingHeaderScrollView` with stretchy/sticky hero header (Baroness headshot) and pinned bottom search bar
- **Fonts**: Registered in xcconfig; use `Bundle.module` guard for SPM compatibility
- **Simulator builds**: May fail in sandboxed environments (CoreSimulator service issues)

## Future Development Notes

- **"Babcia" tab**: Reserved for camera-based room/task capture feature (see PRD.md)
- **Gallery tab**: Currently shows HabitListView placeholder; will become photo gallery
- **Areas feature**: Reuses Weather layout pattern with hero image cards
- **CloudKit**: ModelConfiguration ready (`.cloudKitDatabase: .none`), can switch to `.automatic`

## Quick Reference

| Task | Command |
|------|---------|
| Build for device | `xcodebuild -project AppHost/BabciaTobiaszApp.xcodeproj -scheme BabciaTobiaszApp -destination 'platform=iOS,id=<UDID>' build` |
| Build for simulator | `xcodebuild -project AppHost/BabciaTobiaszApp.xcodeproj -scheme BabciaTobiaszApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build` |
| Run tests | `swift test` |
| Open in Xcode | `open AppHost/BabciaTobiaszApp.xcworkspace` |
