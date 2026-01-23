# BabciaTobiasz Handover Sheet

Date: 2026-01-23
Workspace: /Users/Shared/Developer/BabciaTobiasz
Xcode workspace: /Users/Shared/Developer/BabciaTobiasz/AppHost/BabciaTobiaszApp.xcworkspace
Scheme: BabciaTobiaszApp
Bundle ID: com.babcia.tobiasz

## What the app is (purpose)
BabciaTobiasz is a "reverse Tamagotchi" cleaning app. You "feed" the app by cleaning your room. The design goal is anti-engagement: help users finish quickly, close the app, and need it less over time. Target users include people with ADHD/executive function challenges. The core loop is:
1) Take a photo of the mess.
2) AI generates a "dream" clean-room vision (hero image).
3) AI generates up to ~5 simple tasks.
4) Complete tasks to earn points (pierogi -> bowl/pot).
5) Celebrate completion.
6) Optional verification photo for bonus points (blue/golden tier).

Sources: /Users/Shared/Developer/BabciaTobiasz/_putALLmdfilesinhere/AI_MASTER_CONTEXT.md, /Users/Shared/Developer/BabciaTobiasz/_putALLmdfilesinhere/CORE_PHILOSOPHY.md

## What needed to be done (project roadmap)
From the current roadmap docs (not part of this install request):
- Build fix + verification judge debugging.
- UX improvements for task/pierogi mechanics and task list.
- Localization sweep and AppConfig.json centralization.
- Micro tidy polish and Babcia response randomization.

Source: /Users/Shared/Developer/BabciaTobiasz/_putALLmdfilesinhere/CODEX_ROADMAP.md

## What was requested in this session
- Find the phone and install BabciaTobiasz on the device.
- Run a full device build/install cycle.
- Launch (auto-start) the app.

## What was done (this session)
- Located connected device: "ilovepoxmox" via CoreDevice.
- Resolved build failures in AreaDetailView by splitting the massive body chain into smaller computed subviews and by adding missing view-model computed values for verification points.
- Built an iPhoneOS Debug build.
- Installed the .app on the device using devicectl.
- After user trusted the developer profile on device, launched the app successfully.

## Working tree notes
- The repo already had many uncommitted changes before this session. I only changed the two files listed below.

Code changes made in this session:
- /Users/Shared/Developer/BabciaTobiasz/BabciaTobiasz/Features/Areas/AreaDetailView.swift
  - Split the large body modifier chain into smaller computed views to avoid Swift type-checker timeouts.
- /Users/Shared/Developer/BabciaTobiasz/BabciaTobiasz/Features/Areas/AreaViewModel.swift
  - Added computed properties for verificationBluePoints / verificationGoldenPoints.

## Problems encountered and how they were fixed
1) Device connection instability (CoreDevice "connecting" / timeouts).
   - Fix: Waited for stable connection, kept device unlocked, then used devicectl with a longer timeout.

2) Install failed with "invalid bundle / CFBundleExecutable".
   - Cause: The app failed to compile, leaving an incomplete .app.
   - Fix: Rebuilt after resolving compile errors.

3) Swift compiler error: "unable to type-check this expression in reasonable time" in AreaDetailView.swift.
   - Fix: Broke the body into smaller computed subviews (baseContent -> navigation -> presentations -> alerts -> overlays).

4) Swift errors: verificationBluePoints / verificationGoldenPoints missing on AreaViewModel.
   - Fix: Added computed properties backed by AppConfigService (configService).

5) Launch blocked by iOS security (untrusted developer profile).
   - Fix: User trusted the developer profile in Settings, then launch succeeded.

## What I will do next
- Nothing pending unless asked. Ready to re-run build/install/launch or continue with roadmap tasks.

## What I wanted to do but did not
- Use the build_device/install_app_device tool path end-to-end; connection timeouts and signing trust required a devicectl install and user trust step.
- Run tests (none were requested).
- Debug verification judge logic (roadmap item) or other UX roadmap items.

## How to build, install, and auto-start on the phone
These are the exact steps that worked in this session.

1) Build (generic iPhoneOS build):
```bash
xcodebuild -workspace /Users/Shared/Developer/BabciaTobiasz/AppHost/BabciaTobiaszApp.xcworkspace \
  -scheme BabciaTobiaszApp \
  -configuration Debug \
  -sdk iphoneos \
  -quiet build
```

2) Locate the .app (DerivedData path varies):
```bash
BUILD_SETTINGS=$(xcodebuild -workspace /Users/Shared/Developer/BabciaTobiasz/AppHost/BabciaTobiaszApp.xcworkspace \
  -scheme BabciaTobiaszApp -configuration Debug -sdk iphoneos -showBuildSettings)
TARGET_BUILD_DIR=$(echo "$BUILD_SETTINGS" | rg -m1 "TARGET_BUILD_DIR" | awk '{print $3}')
APP_PATH="$TARGET_BUILD_DIR/BabciaTobiasz.app"
```

3) Install on device (CoreDevice identifier from devicectl list):
```bash
xcrun devicectl list devices --columns 'Name,Identifier,State,Model'

xcrun devicectl device install app --timeout 120 \
  --device <DEVICE_IDENTIFIER_FROM_DEVICETCL> \
  "$APP_PATH"
```

4) Trust the developer profile (one-time on device):
- Settings -> General -> VPN & Device Management -> Trust the developer.

5) Launch / auto-start:
```bash
xcrun devicectl device process launch --device <DEVICE_IDENTIFIER_FROM_DEVICETCL> com.babcia.tobiasz
```

Notes:
- If the device stays in "connecting", keep it unlocked and try USB or restart Wi-Fi.
- If install fails with "invalid bundle", the build did not succeed; rebuild first.

## Project history (from docs)
From the project timeline:
- Dec 30-31, 2025: Core infra and refactor from a WeatherHabitTracker baseline.
- Jan 12, 2026: Purge legacy WeatherHabitTracker, set up AppHost structure, establish identity.
- Jan 12, 2026: Liquid Glass design system, Pierogi protocol manifesto, streaming camera roadmap.
- Current status: Phase 2 (Foundational architecture and vision).

Source: /Users/Shared/Developer/BabciaTobiasz/_putALLmdfilesinhere/120126/PROJECT_TIMELINE.md

Latest update note (2026-01-18):
- Onboarding, persona flow, scan flow overlays, verification prompt, streaming camera quick-adds, localization updates, and device install/launch verification.

Source: /Users/Shared/Developer/BabciaTobiasz/_putALLmdfilesinhere/UPDATE_2026-01-18.md

## Full git history
```text
2025-12-30 3c22486 Add unit tests for HabitViewModel, PersistenceService, WeatherService, and UI components
2025-12-30 9ff8042 Refactor code structure for improved readability and maintainability
2025-12-30 f4cece3 Add reusable components for error handling, loading indicators, and glass card styling
2025-12-30 d96b520 Add comprehensive unit and UI tests for WeatherHabitTracker
2025-12-30 9442e03 Modernize UI with scroll transitions and fix CI/CD
2025-12-30 f61a848 fix: Swift 6 concurrency - add @preconcurrency to EnvironmentKey
2025-12-30 2326cdb fix: wrap iOS 26 glassEffect APIs with compiler version checks
2025-12-30 2b4df60 fix: bump compiler check to 7.0 for iOS 26 APIs
2025-12-30 5763e05 fix: use subshell for directory change in CI artifacts step
2025-12-31 53bd40c fix: remove unused CodingKeys from MainWeatherDTO
2025-12-31 76100f6 Refactor code structure and remove redundant sections for improved readability and maintainability
2025-12-31 ccd3eb9 chore: update README to remove redundant descriptions and improve clarity
2025-12-31 ad5db59 fix: correct image filenames in README for habit tracking screenshots
2026-01-12 484daa6 chore: snapshot before antigravity work
2026-01-12 fa5fd72 chore: purge all traces of legacy project and drama
2026-01-12 cb558f4 chore: sanitize VS Code launch configurations
2026-01-13 f8a9a14 chore: sync latest local changes and documentation
2026-01-13 22b2133 WIP: Habits→Areas rename and PRD migration scaffolding
2026-01-13 27748d4 feat: implement PRD v1.0 logic for streaks, scoring, and golden eligibility
2026-01-15 6fb178d chore: snapshot
2026-01-15 a43c861 Add Gemini verification judge service
2026-01-16 61f20db Add room reminders and milestone retention
2026-01-16 6bb460f Ignore DerivedData artifacts
2026-01-16 4e8a0e8 Move markdown docs to ignored folder
2026-01-17 80fe742 checkpoint: before weather removal surgery
2026-01-17 3d42372 chore: remove Weather and Location features
2026-01-17 3876ca0 fix: resolve ReminderConfig predicate and actor isolation errors
2026-01-17 dba8e0a fix: production-ready cleanup
2026-01-17 0ccdc19 Remove debug prints and align header sizing
2026-01-17 23226aa Resolve Swift 6 sendability warnings
2026-01-17 940d400 feat: add Pierogi Drop ceremony for verification tier reveal
2026-01-17 2abdb0c fix: push area navigation on tap
2026-01-17 6e63f7c fix: harden area detail routing and hero fallback
2026-01-18 200557a docs: add CORE PHILOSOPHY to all key docs
2026-01-18 eaa0b0b fix: Swift 6 concurrency error in ScalingHeaderScrollView
2026-01-18 fa13b57 🚀 Babcia is going live! Staging all new features, clay assets, and streaming camera logic. 🔥
2026-01-18 d487e21 🚀 Babcia Updates: Adding new UI cards, onboarding flow, and camera permission primers. 🔥
2026-01-18 bc20f9d 🚀 Babcia Refinements: Polishing Area logic, onboarding views, and syncing external submodules. 🔥
2026-01-19 6fdcb3a CHECKPOINT: Pre-UX-Alignment - Safe State before Codex fixes```
