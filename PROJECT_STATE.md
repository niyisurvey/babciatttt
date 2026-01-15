# Project State

## 2026-01-12 14:18 (local)
- Added a running project state log (this file).
- Planning Areas page rebuild with a custom internal ScalingHeaderScrollView.
- Target: Areas page gets stretchy hero header + bottom search bar; hero image is Baroness headshot (neutral) for now and swappable later.

## 2026-01-12 14:27 (local)
- Added internal ScalingHeaderScrollView (stretchy/sticky header with snap + progress tracking + refresh support).
- Areas page now uses ScalingHeaderScrollView with Baroness headshot hero image and pinned bottom search bar.
- Removed top search UI on Areas (search is now always visible at bottom).

## 2026-01-12 15:34 (local)
- Added icon checklist file at /Users/Shared/Developer/BabciaTobiasz/ICON_CHECKLIST.md with Babcia-specific icon meanings and specs.
- Confirmed hero image asset for Areas header: R2_Baroness_Headshot_Neutral.

## 2026-01-12 17:13 (local)
- Fixed ScalingHeaderScrollView stretch behavior: header now expands on pull-down (no clipping) and sticks on scroll-up.
- Added conditional clipping only when collapsing to avoid cutting the hero during pull-down.

## 2026-01-12 19:05 (local)
- Locked decisions: A1/B1/C1. Areas will reuse the Weather page layout; Habits view becomes Gallery placeholder; Babcia stays centered placeholder; update handoff before making code changes.

## 2026-01-12 19:05 (local)
- Implemented A1/B1/C1 wiring: Areas now uses Weather layout via AreasView with a hero image card; Gallery uses HabitListView as placeholder; Home remains WeatherView.

## 2026-01-13 01:46 (local)
- Locked dream image spec: master 1200x1600 portrait. Added DreamRoom_Test_1200x1600 asset and wired it into the Areas hero card.
- Added DSGrid.heroCardHeight token (260) to support full-bleed hero height in a consistent, design-system-friendly way.

## 2026-01-14 00:20 - 01:00 (GMT/UK) — FAILED SESSION

### Task
Implement scaling header on AreaDetailView (Room page) matching the Areas page pattern.

### Attempts (ALL FAILED)

**Build 1 (~00:25)** — Initial implementation
- Added `@State private var headerProgress: CGFloat = 0` to AreaDetailView
- Replaced old headerSection with ScalingHeaderScrollView
- Used `Image("DreamRoom_Test_1200x1600").resizable().scaledToFill()`
- Result: Build errors (Bundle.module, toolbar ambiguity, operator ambiguity)

**Build 2 (~00:30)** — Fixed compile errors
- Removed `bundle: .module` from Image
- Added `@ToolbarContentBuilder` property for toolbar
- Used explicit CGFloat literals `0.0`, `1.0`
- Result: Built but user reported image "starts too low" and opaque bar issue

**Build 3 (~00:36)** — Attempted fix for image position
- Changed hardcoded `340` to `theme.grid.heroCardHeight` (260)
- Added `.toolbarBackground(.hidden, for: .navigationBar)`
- Result: Still had opaque bar when scrolling

**Build 4 (~00:42)** — Added sheetOverlap to ScalingHeaderScrollView
- Added `@Environment(\.dsTheme)` to component
- Added `sheetOverlap = theme.grid.cardPadding * 1.5` (24pt)
- Applied `.padding(.top, -sheetOverlap)` to content
- Result: Overlap working on AreaListView but NOT on AreaDetailView

**Build 5 (~00:45)** — Tried matching AreasHeroHeader pattern
- Changed `.scaledToFill()` to `.scaledToFit()` — BROKE FULL BLEED
- Added `.frame(maxWidth: .infinity)`, `.padding(.top, theme.grid.sectionSpacing)`
- Wrapped in ZStack with animation
- Changed backgroundGradient to `LiquidGlassBackground(style: .areas)`
- Result: Image letterboxed (not full bleed), dark bar STILL there

**Build 6 (~00:50)** — Frankenstein hack attempt
- Changed opacity min from `0.0` to `0.2` — HACK, user rejected
- Reverted to `.scaledToFill()`
- Result: Still broken, user rightfully called out the hack

**Build 7 (~00:55)** — Dynamic header height attempt
- Added `dynamicHeaderHeight` computed property to ScalingHeaderScrollView
- Changed `.frame(height: maxHeight)` to `.frame(height: dynamicHeaderHeight)`
- Result: JANKY, broken, user rejected

### Current State: ❌ BROKEN

**Files modified (need review/revert):**
- `ScalingHeaderScrollView.swift` — has broken `dynamicHeaderHeight` logic
- `AreaDetailView.swift` — using `LiquidGlassBackground`, `.scaledToFill()`

**The actual problem (unsolved):**
When scrolling up on AreaDetailView, a dark opaque bar appears at top behind the translucent glass cards. The header container shows background gradient through when image fades.

**Why AreaListView works but AreaDetailView doesn't:**
Unknown. Both use same ScalingHeaderScrollView. AreaListView uses `.scaledToFit()` portrait Baroness image. AreaDetailView needs `.scaledToFill()` for room image. The aspect ratio / fill mode difference may be relevant but not confirmed.

### Next Steps
1. REVERT ScalingHeaderScrollView to before `dynamicHeaderHeight` was added
2. Study why AreaListView doesn't have the dark bar issue
3. Don't guess — trace the actual rendering path
4. Consider if the problem is in how `.scaledToFill()` interacts with clipping

## 2026-01-14 02:39 (local)
- Updated `RUNNING_HANDOFF.md` to include a stricter working style section and a continuity prompt for new Codex windows.

## 2026-01-14 02:52 (local)
- Reverted `ScalingHeaderScrollView.swift` back to the baseline implementation (removed dynamic height + forced clipping/overlap tweaks).
- Cleaned `PRD.md` so it only contains the newer PRD (single source of truth).

## 2026-01-14 02:54 (local)
- Build attempt (simulator, local derived data) failed due to Swift macro plugin server errors (SwiftData/Observation/Preview macros) and CoreSimulator connection issues, not code changes.

## 2026-01-14 08:05 (local)
- Added pinned persona support (Area model + form + detail display).
- Added before/after photo capture for bowls and verification, plus a bowl completion prompt.
- Added points pot totals and a minimal Filter Shop (unlock/apply) wired to points spending.

## 2026-01-14 08:36 (local)
- Device build succeeded with automatic signing.
- Device tests failed because UI testing was canceled by system (biometry auth canceled).
- App installed and launched on device; log capture shows termination via signal 9.

## 2026-01-14 08:47 (local)
- Added stacked-card layout for Areas list and updated empty state copy to "Empty Pot".
- Added after-photo display with simple filter styling in AreaDetailView.
- Device build/install/launch succeeded; app still terminates with signal 9 on device (log capture).

## 2026-01-14 20:21 GMT
- Integrated DreamRoomEngine as a local package dependency and added a Dream pipeline service.
- Added Keychain-backed DreamRoom API key storage in Settings and fallback to Secrets.plist.
- Added local prompt override file (LocalDreamPrompts.json) and removed hardcoded persona prompts.
- Dream output now stored on AreaBowl and displayed in Area Detail header with fallback persona reference art.
- Added DREAM_PIPELINE_GUIDE.md and a Dream Pipeline setup block in RUNNING_HANDOFF.md.

## 2026-01-14 20:23 GMT
- Pre-build update: Dream pipeline wired end-to-end (engine + storage + header render).
- Pre-build update: prompt overrides via LocalDreamPrompts.json; prompts no longer hardcoded.
- Pre-build update: Settings Dream Engine key storage added (Keychain).
- Device build/run queued next (phone connected).

## 2026-01-14 20:27 GMT
- Device build failed: DreamRoomEngine module not found by AppHost build.
- Next step: add DreamRoomEngine package reference to AppHost project/workspace and rebuild on device.

## 2026-01-14 20:33 GMT
- Added DreamRoomEngine local Swift package reference to AppHost project.
- Device rebuild queued next.

## 2026-01-14 20:34 GMT
- Device build failed: AppHost could not access DreamRoomEngine path.
- Fixed local package path to ../DreamRoomEngine; rebuild queued next.

## 2026-01-14 20:36 GMT
- Device build succeeded after fixing DreamRoomEngine package path.
- App installed and launched on device (com.babcia.tobiasz).
- Awaiting user verification/approval on device.

## 2026-01-14 20:51 GMT
- Debug: AppHost Info.plist missing NSCameraUsageDescription / NSPhotoLibraryUsageDescription.
- Plan: add usage descriptions, rebuild, and retest on device.

## 2026-01-14 20:55 GMT
- Added camera capture UI in Area Detail (CameraCaptureView + permission checks).
- Added camera/photo usage descriptions via Shared.xcconfig.
- Device rebuild queued next.

## 2026-01-14 20:59 GMT
- Device build succeeded with camera capture changes.
- App installed and launched on device (com.babcia.tobiasz).
- Awaiting user verification on camera capture flow.

## 2026-01-14 21:13 GMT
- Area Detail scan now enforces camera-only capture, shows a scan preview card, and surfaces scan/Dream errors via alerts.
- Verification after-photo now uses camera capture (no photo library picker).
- Scan button disabled while Dream generation runs; no silent failure when a bowl is already in progress.
- Pre-build update logged; device build/test pending.

## 2026-01-14 21:19 GMT
- Device build succeeded; app installed and launched on ilovepoxmox.
- Awaiting user verification of camera capture flow, Dream header update, and error alerts.

## 2026-01-14 22:02 GMT
- Area Detail simplified to Dream header + sparkly Babcia card + floating camera button.
- Removed bowl UI and extra cards from Area Detail; camera remains the only action.
- Pre-build update logged; device build/test pending.

## 2026-01-14 22:10 GMT
- Device build succeeded; app installed and launched on ilovepoxmox.
- Awaiting user verification of the new Area Detail layout and floating camera button.

## 2026-01-14 22:28 GMT
- Floating camera button now uses existing DS button style (custom component removed).
- Dream error popup now shows raw engine error text for debugging.
- Pre-build update logged; device build/test pending.

## 2026-01-14 22:29 GMT
- Increased Babcia card head icon size to DS iconXL for comfortable fit.
- Clean build required before device build/run.
- Pre-build update logged; device build/test pending.

## 2026-01-14 22:39 GMT
- Floating camera button label/style now matches the DS CTA button used in Areas empty state.
- Pre-build update logged; device build/test pending.

## 2026-01-14 23:05 GMT
- Added BabciaScanPipeline module (Dream + Gemini tasks) and wired Area scans to use it.
- Dream prompts now sourced via LocalDreamPrompts.json through the pipeline.
- Pre-build update logged; device build/test pending.

## 2026-01-14 23:24 GMT
- Area Detail now includes a task list card using the Weather forecast layout.
- Five slots are always visible; tasks are tickable and disappear with a success haptic.

## 2026-01-14 23:26 GMT
- Fixed task list icon styling to use ShapeStyle correctly (build error fix).

## 2026-01-14 23:28 GMT
- Clean build succeeded.
- Device build succeeded; install/launch failed (CoreDeviceService could not locate device identifier).

## 2026-01-14 23:56 GMT
- Dream prompts now support editable base + geometry + output sections via LocalDreamPrompts.json.
- Scan pipeline passes a full Dream prompt override into DreamRoomEngine when available.
- LocalDreamPrompts loader now searches bundle resources and optional Documents override.

## 2026-01-15 00:31 GMT
- Added a temporary Buttons Lab page and linked it from Settings for button style comparison.

## 2026-01-15 00:34 GMT
- Fixed Buttons Lab system glass button to use SwiftUI.GlassButtonStyle (build error fix).

## 2026-01-15 00:36 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 10758). Awaiting user verification.

## 2026-01-15 00:38 GMT
- Buttons Lab now includes five card style samples for comparison.

## 2026-01-15 00:40 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 10835). Awaiting user verification of card samples.

## 2026-01-15 00:46 GMT
- Buttons Lab expanded into a Liquid Glass Lab showcasing glass variants, shapes, containers, morphing, unions, transitions, background effects, and glass button styles.

## 2026-01-15 00:47 GMT
- Fixed Liquid Glass Lab build error by adding iOS 26 availability to Glass helpers.

## 2026-01-15 00:50 GMT
- Fixed Liquid Glass Lab build errors by removing unsupported glassBackgroundEffect and replacing containerConcentric with DS radius.
- Added iOS 26 guards for glass sheet button styles.

## 2026-01-15 00:52 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 10873). Awaiting user verification of Liquid Glass Lab.

## 2026-01-15 00:59 GMT
- Liquid Glass Lab updated with clear-glass cards, clearer button-on-card sections, and a more translucent sheet.

## 2026-01-15 01:02 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 10896). Awaiting user verification of translucency changes.

## 2026-01-15 01:15 GMT
- Liquid Glass Lab expanded with glass basics (default/isEnabled/identity), text + icon samples, container spacing demos, transition toggles, and additional glass card variants.

## 2026-01-15 01:18 GMT
- Device build failed because glassEffect(isEnabled:) is not supported in this SDK.
- Updated lab tiles to emulate isEnabled via Glass.identity; build/test pending.

## 2026-01-15 01:19 GMT
- Fixed glassTile helper to return a View after adding local state; build/test pending.

## 2026-01-15 01:20 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 10923). Awaiting user verification of the updated Liquid Glass Lab.

## 2026-01-15 07:29 GMT
- Liquid Glass Lab sections now render inside non-glass DS panels to avoid glass-on-glass sampling; should prevent tester page crash. Build/test pending.

## 2026-01-15 07:31 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 11787). Awaiting user verification of tester page crash fix.

## 2026-01-15 07:40 GMT
- Card Styles section now lazy-loads to avoid recursion crash when opening the tester page.
- Added editable startup prompt doc at /Users/Shared/Developer/BabciaTobiasz/STARTUP_PROMPT.md.

## 2026-01-15 07:47 GMT
- Clean build + device build succeeded; app installed on device.
- Launch failed because the device was locked (SBMainWorkspace denied). Awaiting user unlock + relaunch.

## 2026-01-15 07:49 GMT
- App launched on device (PID 11870). Awaiting user verification of tester page crash fix.

## 2026-01-15 07:52 GMT
- Disabled the iOS 26 card-variant samples inside Card Styles (clear/tinted) to eliminate buildLimitedAvailability recursion; kept DS card samples + a placeholder note. Build/test pending.

## 2026-01-15 07:54 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 11884). Awaiting user verification of tester page crash fix.

## 2026-01-15 07:57 GMT
- Liquid Glass Lab now opens as a lightweight index list of section links; each section loads on its own screen to avoid recursion crash on entry. Build/test pending.

## 2026-01-15 07:59 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 11897). Awaiting user verification of tester page crash fix.

## 2026-01-15 08:01 GMT
- Reverted tester page by removing the Liquid Glass Lab entry from Settings and deleting ButtonsShowcaseView to return to last known working baseline. Build/test pending.

## 2026-01-15 08:03 GMT
- Clean build + device build succeeded; app installed.
- Launch failed due to device disconnect (CoreDeviceError 4000). Awaiting relaunch on device.

## 2026-01-15 08:04 GMT
- App launched on device (PID 11930). Awaiting user verification that the tester page no longer crashes (it was removed).

## 2026-01-15 08:06 GMT
- Restored tester page as a minimal Liquid Glass Lab (buttons + clear sheet only) to avoid recursion crash; re-added Settings entry. Build/test pending.

## 2026-01-15 08:09 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 11952). Awaiting user verification of the minimal tester page (buttons + clear sheet).

## 2026-01-15 08:19 GMT
- Liquid Glass Lab now focuses on button glass effects, translucent card samples, and clear/regular/tinted sheets.
- Build/test pending (clean build + device run required).

## 2026-01-15 08:23 GMT
- Device build failed: xcodebuild could not find device id 3391909B-E5CE-5417-ADD5-D76DEAF35BF6.
- Retry using device id 00008110-0009046C26F9801E (listed by xcodebuild).

## 2026-01-15 08:24 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 11982). Awaiting user verification of the updated Liquid Glass Lab.

## 2026-01-15 08:25 GMT
- Removed hardcoded tint opacities from Liquid Glass Lab samples to keep DS-only tokens.
- Build/test pending (clean build + device run required).

## 2026-01-15 08:27 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 11987). Awaiting user verification of the updated Liquid Glass Lab.

## 2026-01-15 08:29 GMT
- Reduced glass tint strengths via DS token (theme.glass.tintOpacity = 0.2).
- Build/test pending (clean build + device run required).

## 2026-01-15 08:31 GMT
- Clean build + device build succeeded; app installed.
- Launch failed because device was locked (SBMainWorkspace denied). Awaiting unlock + relaunch.

## 2026-01-15 08:32 GMT
- App launched on device (PID 12004). Awaiting user verification of lighter glass tints.

## 2026-01-15 08:34 GMT
- Reduced glass tint strength via DS token (theme.glass.tintOpacity = 0.02).
- Build/test pending (clean build + device run required).

## 2026-01-15 08:35 GMT
- Clean build + device build succeeded.
- App installed and launched on device (PID 12009). Awaiting user verification of 2% glass tint.
