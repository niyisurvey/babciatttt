BabciaTobiasz Running Handoff (Do Not Delete)
=============================================

Purpose
This file is the always-current handoff so you can stop at any time and resume later without losing context. It is explicit, critical, and complete. No shortcuts.

Non-Negotiables (Project Rules)
- No minimal fixes, no shortcuts, no Frankenstein patches.
- Changes must be thorough, consistent, and clean.
- iOS only. Do not add or support macOS targets.
- UI is the priority; backend can be adapted later.
- If a change is partial or mismatched, redo it properly.
- Use the physical device (ilovepoxmox) for verification by default.
(These are also saved in: /Users/Shared/Developer/BabciaTobiasz/PROJECT_RULES.md)

Project Identity (Current State)
- Project root: /Users/Shared/Developer/BabciaTobiasz
- App name: BabciaTobiasz
- Bundle identifier: com.babcia.tobiasz
- Target platform: iOS only (macOS support removed)
- Build system: Xcode app host in /Users/Shared/Developer/BabciaTobiasz/AppHost
- README removed per instruction

High-Level Goal
Use the baseline UI as the reference, then build a strict design system layer so the art director can change semantic colors, gradient palettes, and font family, while preserving the layout and “liquid glass” feel. Motion is configurable only via slow/normal/fast preset.

What Was Done (AppHost Conversion)
1) Renamed the app throughout the package:
   - Package name and product name: BabciaTobiasz
   - Bundle id: com.babcia.tobiasz
   - App entry file renamed to BabciaTobiaszAppView.swift and converted to a View (no @main)
2) Removed macOS support from Package.swift.
3) Converted SwiftPM target to a library target (no executable).
4) Created a proper iOS app host:
   - /Users/Shared/Developer/BabciaTobiasz/AppHost/BabciaTobiaszApp.xcodeproj
   - Workspace: /Users/Shared/Developer/BabciaTobiasz/AppHost/BabciaTobiaszApp.xcworkspace
   - Config: /Users/Shared/Developer/BabciaTobiasz/AppHost/Config/Shared.xcconfig
5) Linked the app host to the existing sources using fileSystemSynchronizedGroups.
6) Removed unused scaffold package targets created by the template.
7) Deleted duplicate Info.plist files that were causing build conflicts.
8) Fixed WeatherService to use Bundle.module only when building as a Swift package.
9) Cleaned workspace contents to remove a stale reference to the deleted scaffold package.

What Was Done (Design System Layer)
- Added /Users/Shared/Developer/BabciaTobiasz/BabciaTobiasz/DesignSystem/DesignSystemTheme.swift with tokens:
  - Palette (primary/secondary/tertiary/success/warning/error/glassTint)
  - Gradients (default/weather/habits + time-of-day gradients)
  - Typography (LinLibertine family), dsFont helper
  - Motion preset (slow/normal/fast) with derived animations and durations
  - Shape (radii, borders), Grid (spacing + icon sizes), Glass (material strengths)
- Injected theme at the app root via .dsTheme(.default) in AppHost.
- Converted core UI to use theme tokens:
  - LiquidGlassStyle, GlassCardView, SkeletonLoadingView, FeatureTooltip, ErrorView, LoadingIndicatorView
  - OnboardingView, LaunchView
  - HabitList/HabitRow/HabitDetail/HabitForm
  - WeatherView and LocationSearchView
- Goal: UI should look identical to the baseline app, but now all styling routes through the theme.
 - Fixed build issues in DesignSystemTheme (gradient references, font-name resolver).
 - Fixed ErrorView permission card to read theme from environment.
 - OnboardingView background uses TimelineView with animated mesh points; motion is now slower but with larger offsets (stronger drift).

Fonts + Assets (From Original Babcia)
- Fonts copied from:
  /Users/Shared/Developer/Babcia-Codex/Babcia/Packages/Common/Sources/Common/Resources/Fonts
  into:
  /Users/Shared/Developer/BabciaTobiasz/BabciaTobiasz/Resources/Fonts
- Fonts registered in:
  /Users/Shared/Developer/BabciaTobiasz/AppHost/Config/Shared.xcconfig
  using INFOPLIST_KEY_UIAppFonts with:
  LinLibertine_R.ttf, LinLibertine_RB.ttf, LinLibertine_RI.ttf, LinLibertine_RBI.ttf
- Assets copied to:
  /Users/Shared/Developer/BabciaTobiasz/BabciaTobiasz/Resources/BabciaAssets.xcassets
  (Existing Assets.xcassets preserved.)

Secrets
- Secrets.plist created at:
  /Users/Shared/Developer/BabciaTobiasz/BabciaTobiasz/Resources/Secrets.plist
- Contains OPENWEATHERMAP_API_KEY (value is local-only; do not write to Git).
- .gitignore already excludes Secrets.plist.

Files That Matter Now
- App host project: /Users/Shared/Developer/BabciaTobiasz/AppHost/BabciaTobiaszApp.xcodeproj
- App host workspace: /Users/Shared/Developer/BabciaTobiasz/AppHost/BabciaTobiaszApp.xcworkspace
- App host config: /Users/Shared/Developer/BabciaTobiasz/AppHost/Config/Shared.xcconfig
- App host entitlements: /Users/Shared/Developer/BabciaTobiasz/AppHost/Config/BabciaTobiasz.entitlements
- App entry view (no @main): /Users/Shared/Developer/BabciaTobiasz/BabciaTobiasz/App/BabciaTobiaszAppView.swift
- App entry @main: /Users/Shared/Developer/BabciaTobiasz/BabciaTobiasz/App/AppHost.swift
- Weather secrets loader: /Users/Shared/Developer/BabciaTobiasz/BabciaTobiasz/Core/Networking/WeatherService.swift
- Design system theme: /Users/Shared/Developer/BabciaTobiasz/BabciaTobiasz/DesignSystem/DesignSystemTheme.swift

Build/Run Status (Current)
- App builds, installs, and launches on the physical device (ilovepoxmox) when connected.
- Simulator is optional; device is the default verification target.

How to Build/Install/Run on Device (Authoritative)
1) Build for device:
   xcodebuild -project /Users/Shared/Developer/BabciaTobiasz/AppHost/BabciaTobiaszApp.xcodeproj \
     -scheme BabciaTobiaszApp \
     -destination 'platform=iOS,id=<DEVICE_UDID>' \
     -derivedDataPath /Users/Shared/Developer/BabciaTobiasz/AppHost/.derivedData \
     build
2) Install/Run:
   Use Xcode (preferred for physical device), or:
   xcrun devicectl device install app --device <DEVICE_UDID> /path/to/BabciaTobiasz.app

Planned Next Steps (When Resuming)
1) Verify the LinLibertine font renders correctly on device.
2) Verify UI has no system-font regressions (all text via dsFont).
3) If any view still hardcodes style values, move them into DesignSystemTheme.
4) Keep hero image changes for after the design system is locked.

Current Open Questions
- Which motion preset should be the default (slow/normal/fast) once art direction is decided?

Last Updated
- Updated after restoring Onboarding background animation and re-installing to device.
