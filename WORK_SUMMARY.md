## Project Snapshot
- **App**: BabciaTobiasz (reverse Tamagotchi cleaning coach that rewards scans/tasks/pierogi balance with optional verification tiers).
- **Status before work**: Liquid Glass design system present but the Home dashboard primarily relied on `GlassCardView` and the existing helpers.  
- **Goals today**: Explore whether we can mirror the LiquidGlassSwiftUI action cluster without breaking the rest of the design system; improve the helper utilities, deploy the app to the documented device, and log the work.

## Key Changes
- Added `glassCircleButton`, `glassActionIcon`, and `glassActionCircleStyle` extensions so transparent controls can reuse the same availability guards and fallbacks as the rest of the design system (`Shared/Styles/LiquidGlassStyle.swift`).
- Built `LiquidGlassActionClusterView` + demo card briefly, but removed the showcase from `HomeView` after it introduced oversized elliptical overlays that didn’t respect the DS shape tokens; the helper code remains for future experimentation.
- Fixed the compile issues: switched the font weight for the (now-removed) showcase copy to `.bold` and wrapped the Liquid Glass container in `@available` to keep the build clean on older toolchains.

## Mistakes & Learnings
- Initial build failed because `DSFontWeight` lacks `.semibold`; resolved by switching to `.bold`.
- Forgot to guard `GlassEffectContainer` with availability, so the compiler forced an error; added the helper and `@available` annotation in `LiquidGlassActionClusterView`.
- Introduced the showcase card, realized the oversized circle looked wrong and clashed with the DS shapes, and removed it before shipping so the Home layout reverted to the previous appearance.
- First `xcodebuild` run timed out (120s); reran with 240s delay to finish linking/Archiving.
- First `devicectl install` attempt timed out while the device was still connecting; reran after the device stabilized (still connecting). Devicectl install/launch now succeed.

## Device Workflow (mirror from BABCIA_TOBIASZ_HANDOVER.md)
1. `xcodebuild -workspace AppHost/BabciaTobiaszApp.xcworkspace -scheme BabciaTobiaszApp -configuration Debug -sdk iphoneos -quiet build`
2. Locate the product via `TARGET_BUILD_DIR` and use `xcrun devicectl device install app --device 3391909B-E5CE-5417-ADD5-D76DEAF35BF6 <app path>`
3. Launch with `xcrun devicectl device process launch --device 3391909B-E5CE-5417-ADD5-D76DEAF35BF6 com.babcia.tobiasz`

## Testing & Verification
- Build succeeded after correcting the issues above; no automated test suite run.
- Manual installation/launch path executed on `ilovepoxmox` (device is an iPhone 13 Pro Max).

## Next Steps
- Link the save/like/share buttons to real functionality or analytics if desired.
- Review additional glass surfaces for further animation coherence.

---

## 2026-01-23: Hero Image Swaps & Gallery Fixes

### Changes Made
- **AreaListView.swift** (Line 43): Hero now shows chosen Babcia persona instead of dream image
- **AreaDetailView.swift**: Hero now shows latest dream image from `area.latestBowl?.galleryImageData` instead of persona
- **GalleryDetailView.swift**: Replaced `ScrollView` with `ScalingHeaderScrollView` for stretchy hero header
- **GalleryItemCard.swift**: Removed `GlassCardView` wrapper and ZStack overlays - now uses simple `ultraThinMaterial` background to eliminate Liquid Glass visual artifacts (the weird layering/overlay effect)

### Build Fixes (Swift 6 Concurrency)
- `TapoDiscoveryService.swift`: Added `@preconcurrency import Foundation`
- `StreamingCameraDiscovery.swift`: Added `@preconcurrency import Foundation`, refactored delegate methods
- `StreamingCameraProvider.swift`: Made protocol `@MainActor` 
- `StreamingCameraManager.swift`: Fixed `captureFrame` async handling

### Deployed
App installed on iPhone `ilovepoxmox` via `xcodebuild clean build install`.

