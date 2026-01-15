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
- 2026-01-14 22:29 GMT: Always run a clean build (Cmd-Shift-K) before device build/run.
(These are also saved in: /Users/Shared/Developer/BabciaTobiasz/PROJECT_RULES.md)

CRITICAL: AGENT PROTOCOL (MANDATORY)
-----------------------------------
- The HARD CHAT-ONLY MODE rules are for Gemini only, not Codex or Claude.
- Always use the latest files as the source of truth; older notes are often stale.
- Design system usage is mandatory; no Frankenstein fixes or vibe-coding.
- Keep changes best-practice, reproducible, and consistent with the design system.

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
- Replaced invalid spacing token usages (componentSpacing -> listSpacing) in SettingsView/HabitFormView.
- Updated HabitFormView dsFont weights to use .bold (DSFontWeight supports regular/bold only).

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
- Simulator build via xcodebuild failed in sandbox (CoreSimulator service connection + workspace error). Re-run outside sandbox if needed.

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

Latest Updates
- Mesh animation timing now uses theme.motion.meshAnimationInterval everywhere (LiquidGlassBackground, Onboarding, Weather, Settings, HabitForm, HabitDetail) with larger, slower offsets.
- Weather detail cards now use DSGrid height tokens (small/large). UV + Visibility are the large pair; other cards are small.
- Home/Areas mapping: WeatherView title now shows "Home"; Habits tab title shows "Areas".
- Removed Weather search button + search sheet from Home (LocationSearchView still exists, unused for now).
- Areas page now uses an internal ScalingHeaderScrollView with a Baroness headshot hero and a pinned bottom search bar.
- Added a timestamped project log at /Users/Shared/Developer/BabciaTobiasz/PROJECT_STATE.md.
- Decision locked (A1/B1/C1): Areas will reuse the Weather layout; current Habits view moves to Gallery placeholder; Babcia tab stays centered placeholder; handoff updated first before code.
- Implemented A1/B1/C1: Areas now uses Weather layout via a new AreasView with a hero image card replacing the weather card; Gallery now shows HabitListView placeholder; Home remains WeatherView.
- Dream image spec locked: master 1200x1600 portrait. Test asset stored as DreamRoom_Test_1200x1600 in BabciaAssets.xcassets and used in Areas hero card.
- Added DSGrid.heroCardHeight token (260) and set Areas hero card to full-bleed within its glass card using the dream image.
- Reverted ScalingHeaderScrollView back to baseline behavior (removed dynamic height + forced clipping/overlap tweaks).
- Cleaned PRD.md to a single, newer PRD (old PRD removed).
- Build attempt failed due to Swift macro plugin server errors (SwiftData/Observation/Preview macros) and CoreSimulator connection issues.
- Added pinned persona support (model + form + detail display).
- Added before/after photo capture for bowls and verification + completion prompt.
- Added points pot totals and a minimal Filter Shop (unlock/apply) wired to points spending.
- Device build succeeded with automatic signing.
- Device tests failed due to UI testing canceled by system (biometry auth canceled).
- App installed/launched on device; log capture shows termination via signal 9.
- Added stacked-card layout for Areas list and set empty state to "Empty Pot".
- Added after-photo display with simple filter styling in AreaDetailView.
- Device build/install/launch still ends with signal 9 (log capture).
- 2026-01-14 21:13 GMT: Area Detail scan enforces camera-only capture, shows a scan preview card, and surfaces scan/Dream errors via alerts; verification after-photo now uses camera capture; scan button disabled while Dream generation runs. Device build/test pending.
- 2026-01-14 21:19 GMT: Device build succeeded; app installed and launched on ilovepoxmox. Awaiting user verification of camera capture + Dream header update + error alerts.
- 2026-01-14 22:02 GMT: Area Detail simplified to Dream header + sparkly Babcia card + floating camera button; removed bowl UI and extra cards. Device build/test pending.
- 2026-01-14 22:10 GMT: Device build succeeded; app installed and launched on ilovepoxmox. Awaiting user verification of the new Area Detail layout and floating camera button.
- 2026-01-14 22:28 GMT: Floating camera button now uses existing DS button style (no custom component). Dream error popup now shows raw engine error text. Device build/test pending.
- 2026-01-14 22:29 GMT: Persona head icon size increased to DS iconXL in the Babcia card. Clean build required before device test.
- 2026-01-14 22:39 GMT: Floating camera button label/style now matches the DS CTA button used on the Areas empty state. Device build/test pending.
- 2026-01-14 23:05 GMT: Added BabciaScanPipeline module (Dream + Gemini tasks), shared DreamRoomSecrets + DreamFilterApplier, and wired Area scans to use the new pipeline with LocalDreamPrompts.json. Device build/test pending.
- 2026-01-14 23:24 GMT: Area Detail now includes a task list card using the Weather forecast layout with five slots; tasks are tickable with a success haptic. Device build/test pending.
- 2026-01-14 23:26 GMT: Fixed task list icon styling to use ShapeStyle correctly (build fix). Device build/test pending.
- 2026-01-14 23:28 GMT: Clean build and device build succeeded; install/launch failed (CoreDeviceService could not locate device identifier). Device test blocked.
- 2026-01-14 23:56 GMT: Dream prompt loader now supports editable base/geometry/output + persona prompts via LocalDreamPrompts.json and passes a full prompt override into DreamRoomEngine; optional Documents override supported. Build/test pending.
- 2026-01-15 00:31 GMT: Added a temporary Buttons Lab page in Settings to compare button styles. Build/test pending.
- 2026-01-15 00:34 GMT: Fixed Buttons Lab system glass button to use SwiftUI.GlassButtonStyle (build fix). Build/test pending.
- 2026-01-15 00:36 GMT: Clean build + device build succeeded; app installed and launched on device (PID 10758). Awaiting user verification of Buttons Lab and button styles.
- 2026-01-15 00:38 GMT: Buttons Lab now includes five card style samples for comparison. Build/test pending.
- 2026-01-15 00:40 GMT: Clean build + device build succeeded; app installed and launched on device (PID 10835). Awaiting user verification of card samples.
- 2026-01-15 00:46 GMT: Buttons Lab expanded into a Liquid Glass Lab showcasing glass variants, shapes, containers, morphing, unions, transitions, background effects, and glass button styles. Build/test pending.
- 2026-01-15 00:47 GMT: Fixed Liquid Glass Lab build error by adding iOS 26 availability to Glass helpers. Build/test pending.
- 2026-01-15 00:50 GMT: Fixed Liquid Glass Lab build errors by removing unsupported glassBackgroundEffect and replacing containerConcentric with DS radius; added iOS 26 guards for glass sheet button styles. Build/test pending.
- 2026-01-15 00:52 GMT: Clean build + device build succeeded; app installed and launched on device (PID 10873). Awaiting user verification of Liquid Glass Lab.
- 2026-01-15 00:59 GMT: Liquid Glass Lab updated with clear-glass cards, clearer button-on-card sections, and a more translucent sheet. Build/test pending.
- 2026-01-15 01:02 GMT: Clean build + device build succeeded; app installed and launched on device (PID 10896). Awaiting user verification of translucency changes.
- 2026-01-15 01:15 GMT: Liquid Glass Lab now includes glass basics (default/isEnabled/identity), text + icon samples, container spacing demos, transition toggles, and additional glass card variants. Build/test pending.
- 2026-01-15 01:18 GMT: Device build failed because glassEffect(isEnabled:) is not supported in this SDK; updated the lab to emulate isEnabled via Glass.identity. Build/test pending.
- 2026-01-15 01:19 GMT: Fixed glassTile helper to return a View after adding local state; build/test pending.
- 2026-01-15 01:20 GMT: Clean build + device build succeeded; app installed and launched on device (PID 10923). Awaiting user verification of the updated Liquid Glass Lab.
- 2026-01-15 07:29 GMT: Liquid Glass Lab sections now render inside non-glass DS panels to avoid glass-on-glass sampling; this should stop tester page crashes. Build/test pending.
- 2026-01-15 07:31 GMT: Clean build + device build succeeded; app installed and launched on device (PID 11787). Awaiting user verification of tester page crash fix.
- 2026-01-15 07:40 GMT: Card Styles section now lazy-loads to avoid recursion crash; added editable startup prompt doc at /Users/Shared/Developer/BabciaTobiasz/STARTUP_PROMPT.md. Build/test pending.
- 2026-01-15 07:47 GMT: Clean build + device build succeeded; app installed on device. Launch failed because the device was locked (SBMainWorkspace denied). Awaiting user unlock + relaunch.
- 2026-01-15 07:49 GMT: App launched on device (PID 11870). Awaiting user verification of tester page crash fix.
- 2026-01-15 07:52 GMT: Disabled the iOS 26 card-variant samples inside Card Styles (clear/tinted) to eliminate buildLimitedAvailability recursion; left DS card samples + a placeholder note. Build/test pending.
- 2026-01-15 07:54 GMT: Clean build + device build succeeded; app installed and launched on device (PID 11884). Awaiting user verification of tester page crash fix.
- 2026-01-15 07:57 GMT: Liquid Glass Lab now opens as a lightweight index list of section links; each section loads on its own screen to avoid recursion crash on entry. Build/test pending.
- 2026-01-15 07:59 GMT: Clean build + device build succeeded; app installed and launched on device (PID 11897). Awaiting user verification of tester page crash fix.
- 2026-01-15 08:01 GMT: Reverted tester page by removing the Liquid Glass Lab entry from Settings and deleting ButtonsShowcaseView to return to last known working baseline. Build/test pending.
- 2026-01-15 08:03 GMT: Clean build + device build succeeded; app installed. Launch failed due to device disconnect (CoreDeviceError 4000). Awaiting relaunch on device.
- 2026-01-15 08:04 GMT: App launched on device (PID 11930). Awaiting user verification that the tester page no longer crashes (it was removed).
- 2026-01-15 08:06 GMT: Restored tester page as a minimal Liquid Glass Lab (buttons + clear sheet only) to avoid recursion crash; re-added Settings entry. Build/test pending.
- 2026-01-15 08:09 GMT: Clean build + device build succeeded; app installed and launched on device (PID 11952). Awaiting user verification of the minimal tester page (buttons + clear sheet).

Last Updated
- 2026-01-12 19:05 GMT: Logged A1/B1/C1 decisions and requirement to update handoff before code changes.
- 2026-01-12 19:05 GMT: Applied A1/B1/C1 wiring and added AreasView hero card.
- 2026-01-13 01:46 GMT: Added hero card height token and wired DreamRoom_Test_1200x1600 into Areas hero card.
- 2026-01-14 02:52 local: Reverted ScalingHeaderScrollView and cleaned PRD.md.
- 2026-01-14 02:54 local: Build failed due to macro plugin server + CoreSimulator issues.
- 2026-01-14 08:05 local: Added persona selection, photo capture flow, points pot, and filter shop.
- 2026-01-14 08:36 local: Device build ok; tests failed (biometry auth canceled); app terminated with signal 9 on device.
- 2026-01-14 08:47 local: Added stacked card layout + after-photo filter display; device launch still terminates with signal 9.
- 2026-01-14 21:13 GMT: Camera-only scan + scan preview + scan/Dream alerts added in Area Detail; pending device build/test.
- 2026-01-14 21:19 GMT: Device build/install/launch succeeded; user verification pending.
- 2026-01-14 22:02 GMT: Area Detail simplified (header + sparkly Babcia card + floating camera button); build/test pending.
- 2026-01-14 22:10 GMT: Device build/install/launch succeeded; user verification pending for new layout.
- 2026-01-14 22:28 GMT: DS-only floating button + raw error popup; build/test pending.
- 2026-01-14 22:29 GMT: Head icon size increased to DS iconXL; clean build required before device test.
- 2026-01-14 22:39 GMT: Floating camera button now reuses DS CTA label/style; build/test pending.
- 2026-01-14 23:05 GMT: BabciaScanPipeline module wired in; build/test pending.
- 2026-01-14 23:24 GMT: Task list card added to Area Detail using Weather forecast layout; build/test pending.
- 2026-01-14 23:26 GMT: Task list icon styling build fix; build/test pending.
- 2026-01-14 23:28 GMT: Clean + device build ok; install/launch failed (CoreDeviceService device lookup). Device test blocked.
- 2026-01-14 23:56 GMT: Dream prompt loader supports editable base/geometry/output + persona prompts (LocalDreamPrompts.json); full prompt override wired. Build/test pending.
- 2026-01-15 00:31 GMT: Buttons Lab page added in Settings for button style comparisons. Build/test pending.
- 2026-01-15 00:34 GMT: Buttons Lab system glass button build fix. Build/test pending.
- 2026-01-15 00:36 GMT: Device build/install/launch succeeded; user verification pending (Buttons Lab).
- 2026-01-15 00:38 GMT: Buttons Lab card style samples added. Build/test pending.
- 2026-01-15 00:40 GMT: Device build/install/launch succeeded; user verification pending (card samples).
- 2026-01-15 00:46 GMT: Liquid Glass Lab showcase added; build/test pending.
- 2026-01-15 00:47 GMT: Liquid Glass Lab build fix applied; build/test pending.
- 2026-01-15 00:50 GMT: Liquid Glass Lab build fixes applied; build/test pending.
- 2026-01-15 00:52 GMT: Device build/install/launch succeeded; user verification pending (Liquid Glass Lab).
- 2026-01-15 00:59 GMT: Liquid Glass Lab clarity/translucency tweaks applied; build/test pending.
- 2026-01-15 01:02 GMT: Device build/install/launch succeeded; user verification pending (translucency tweaks).
- 2026-01-15 01:15 GMT: Liquid Glass Lab expanded with glass basics (default/isEnabled/identity), text + icon samples, container spacing demos, transition toggles, and additional glass card variants. Build/test pending.
- 2026-01-15 01:18 GMT: Device build failed due to glassEffect(isEnabled:) unsupported; lab now uses Glass.identity to emulate disable. Build/test pending.
- 2026-01-15 01:19 GMT: Fixed glassTile helper to return a View after adding local state; build/test pending.
- 2026-01-15 01:20 GMT: Clean build + device build succeeded; app installed and launched on device (PID 10923). Awaiting user verification of the updated Liquid Glass Lab.
- 2026-01-15 07:29 GMT: Liquid Glass Lab sections now render inside non-glass DS panels to avoid glass-on-glass sampling; this should stop tester page crashes. Build/test pending.
- 2026-01-15 07:31 GMT: Clean build + device build succeeded; app installed and launched on device (PID 11787). Awaiting user verification of tester page crash fix.
- 2026-01-15 07:40 GMT: Card Styles section now lazy-loads to avoid recursion crash; added editable startup prompt doc at /Users/Shared/Developer/BabciaTobiasz/STARTUP_PROMPT.md. Build/test pending.
- 2026-01-15 07:47 GMT: Clean build + device build succeeded; app installed on device. Launch failed because the device was locked (SBMainWorkspace denied). Awaiting user unlock + relaunch.
- 2026-01-15 07:49 GMT: App launched on device (PID 11870). Awaiting user verification of tester page crash fix.
- 2026-01-15 07:52 GMT: Disabled the iOS 26 card-variant samples inside Card Styles (clear/tinted) to eliminate buildLimitedAvailability recursion; left DS card samples + a placeholder note. Build/test pending.
- 2026-01-15 07:54 GMT: Clean build + device build succeeded; app installed and launched on device (PID 11884). Awaiting user verification of tester page crash fix.
- 2026-01-15 07:57 GMT: Liquid Glass Lab now opens as a lightweight index list of section links; each section loads on its own screen to avoid recursion crash on entry. Build/test pending.
- 2026-01-15 07:59 GMT: Clean build + device build succeeded; app installed and launched on device (PID 11897). Awaiting user verification of tester page crash fix.
- 2026-01-15 08:01 GMT: Reverted tester page by removing the Liquid Glass Lab entry from Settings and deleting ButtonsShowcaseView to return to last known working baseline. Build/test pending.
- 2026-01-15 08:03 GMT: Clean build + device build succeeded; app installed. Launch failed due to device disconnect (CoreDeviceError 4000). Awaiting relaunch on device.
- 2026-01-15 08:04 GMT: App launched on device (PID 11930). Awaiting user verification that the tester page no longer crashes (it was removed).
- 2026-01-15 08:06 GMT: Restored tester page as a minimal Liquid Glass Lab (buttons + clear sheet only) to avoid recursion crash; re-added Settings entry. Build/test pending.
- 2026-01-15 08:09 GMT: Clean build + device build succeeded; app installed and launched on device (PID 11952). Awaiting user verification of the minimal tester page (buttons + clear sheet).

Working Style (How we work together)
- Do not touch files without explicit user permission. If asked to report only, report only.
- No shortcuts and no Frankenstein fixes. No big redesigns during transplant.
- Design system is non-negotiable for UI changes: GlassCardView, LiquidGlassBackground, dsFont, mesh gradients.
- Core order: (1) Transplant backend -> (2) Wire UI -> (3) Build/run -> (4) PRD checklist one item at a time.
- Keep visuals stable unless a PRD item explicitly changes visuals.
- Explain decisions in plain English; avoid jargon; ask multiple-choice questions when needed.
- Keep a running, dated log in PROJECT_STATE.md and update this handoff after meaningful changes.

Branch Note: wip/codex-prd-migration (Claude)
- Build reportedly worked on this branch.
- Main risk: ScalingHeaderScrollView change now always clips header and adds content overlap; this likely causes the hero image cutoff and the opaque bar when scrolling up.
- AreaDetailView now uses ScalingHeaderScrollView and LiquidGlassBackground; hero is DreamRoom_Test_1200x1600.
- PRD.md now has a "NEW PRD" pasted above the old PRD; needs cleanup to a single source of truth.

New Codex Continuity Prompt (paste into a fresh Codex window)
You are continuing an existing BabciaTobiasz session with the same tone, history, and working style. Act like the conversation never ended. No shortcuts, no Frankenstein patches, and no big redesigns during transplant. The design system is non-negotiable: use GlassCardView, LiquidGlassBackground, dsFont, and mesh gradients for all UI changes. Core order is: (1) transplant backend (Habit -> Area/Bowl/CleaningTask) (2) wire UI (3) build/run (4) PRD checklist items one by one. Keep visuals stable unless the PRD explicitly changes them. Ask the user multiple-choice questions when choices are needed. Use PROJECT_STATE.md and RUNNING_HANDOFF.md as the ground truth and update both after meaningful progress. Branch note: wip/codex-prd-migration likely introduced a hack in ScalingHeaderScrollView causing hero image cutoff and an opaque bar; confirm with the user before changing it. PRD.md currently has two PRDs; clean it to a single source of truth.

Dream Pipeline Setup (Fast Onboarding)
-------------------------------------
Summary
- Dream output is generated by DreamRoomEngine and stored on each AreaBowl.
- Prompts are editable via a local JSON file, not hardcoded.
- Filters apply to Dream outputs (not after photos).

Setup
1) Connect device and set DreamRoom API key
   - Settings -> Dream Engine -> Save
   - Stored in Keychain; overrides Secrets.plist
2) Edit prompts
   - File: BabciaTobiasz/Resources/LocalDreamPrompts.json
   - Keep persona keys: classic, baroness, warrior, wellness, coach

Fallback art
- If Dream generation fails (missing API key or prompt, or API error),
  the app uses persona reference art instead of raw scans.
- Mapping:
  classic -> R1_Classic_Reference_NormalizedFull
  baroness -> R2_Baroness_Reference_NormalizedFull
  warrior -> R3_Warrior_Reference_NormalizedFull
  wellness -> R4_Wellness_Reference_NormalizedFull
  coach -> R5_ToughLifecoach_Reference_NormalizedFull

Build rule
- A feature is only done after device build + run + your approval.
- Update RUNNING_HANDOFF.md before builds and update results after device tests.

Update 2026-01-14 20:23 GMT
- Dream pipeline wired: DreamRoomEngine package + DreamPipelineService with filter apply + Keychain API key.
- Local prompt overrides enabled via BabciaTobiasz/Resources/LocalDreamPrompts.json; hardcoded prompts removed.
- Area Detail header now renders latest Dream output with fallback persona reference art.
- Settings includes Dream Engine API key input (Keychain storage).
- Device build/run queued next (phone connected).

Update 2026-01-14 20:27 GMT
- Device build failed: module dependency `DreamRoomEngine` not found in AppHost build.
- Next fix: add DreamRoomEngine package reference to AppHost project/workspace and rebuild.

Update 2026-01-14 20:33 GMT
- Added DreamRoomEngine as a local Swift package to AppHost project (pbxproj).
- Ready to rebuild on device.

Update 2026-01-14 20:34 GMT
- Device build failed: AppHost package path was incorrect (looked inside AppHost/DreamRoomEngine).
- Fixed package path to ../DreamRoomEngine; rebuilding next.

Update 2026-01-14 20:36 GMT
- Device build succeeded after fixing DreamRoomEngine package path.
- App installed and launched on device (com.babcia.tobiasz).
- Awaiting on-device verification and user approval.

Update 2026-01-14 20:51 GMT
- Debug finding: AppHost Info.plist lacks camera/photo usage descriptions; likely causing silent photo capture failures.
- Plan: add NSCameraUsageDescription and NSPhotoLibraryUsageDescription, then rebuild and retest on device.

Update 2026-01-14 20:55 GMT
- Added camera capture flow in Area Detail (CameraCaptureView + permission checks).
- Added Info.plist camera/photo usage descriptions via Shared.xcconfig.
- Ready to rebuild and retest on device.

Update 2026-01-14 20:59 GMT
- Device build succeeded with camera capture changes.
- App installed and launched on device (com.babcia.tobiasz).
- Awaiting user verification on camera capture flow.

Update 2026-01-15 08:19 GMT
- Liquid Glass Lab refocused to show glass-effect variants on buttons, plus translucent card samples and clear/regular/tinted sheets.
- Build/test pending (clean build + device run required).

Update 2026-01-15 08:23 GMT
- Device build failed: xcodebuild couldn’t match the device destination (CoreDevice UDID mismatch).
- Next: retry build targeting device id 00008110-0009046C26F9801E.

Update 2026-01-15 08:24 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 11982). Awaiting user verification of Liquid Glass Lab (button glass effects + translucent cards/sheets).

Update 2026-01-15 08:25 GMT
- Removed hardcoded tint opacities in Liquid Glass Lab samples to keep DS-only tokens.
- Build/test pending (clean build + device run required).

Update 2026-01-15 08:27 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 11987). Awaiting user verification of Liquid Glass Lab (button glass effects + translucent cards/sheets).

Update 2026-01-15 08:29 GMT
- Reduced all glass tint strengths to DS token `theme.glass.tintOpacity` (20%).
- Build/test pending (clean build + device run required).

Update 2026-01-15 08:31 GMT
- Clean build + device build succeeded.
- App installed; launch failed because device was locked (SBMainWorkspace denied). Awaiting unlock + relaunch.

Update 2026-01-15 08:32 GMT
- App launched on device (PID 12004). Awaiting user verification of lighter glass tints.

Update 2026-01-15 08:34 GMT
- Reduced glass tint strength to 2% via DS token (theme.glass.tintOpacity = 0.02).
- Build/test pending (clean build + device run required).

Update 2026-01-15 08:35 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 12009). Awaiting user verification of 2% glass tint.
