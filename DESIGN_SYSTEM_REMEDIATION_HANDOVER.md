# DESIGN SYSTEM REMEDIATION - EXECUTE IMMEDIATELY

## DIRECTIVE

DO NOT ASK QUESTIONS. DO NOT WAIT FOR CONFIRMATION. EXECUTE ALL CHANGES NOW.

Process EVERY file listed below. Fix ALL violations. Complete the ENTIRE task in one go.

START IMMEDIATELY WITH FILE #1 AND CONTINUE UNTIL ALL FILES ARE DONE.

---

## STEP 1: EXECUTE THESE REPLACEMENTS IN EVERY FILE

### Color Replacements (find → replace)

```
.foregroundStyle(.secondary)     →  .foregroundStyle(theme.palette.textSecondary)
.foregroundStyle(.orange)        →  .foregroundStyle(theme.palette.warning)
.foregroundStyle(.yellow)        →  .foregroundStyle(theme.palette.warning)
.foregroundStyle(.green)         →  .foregroundStyle(theme.palette.success)
.foregroundStyle(.red)           →  .foregroundStyle(theme.palette.error)
.foregroundStyle(.blue)          →  .foregroundStyle(theme.palette.primary)
.foregroundStyle(.purple)        →  .foregroundStyle(theme.palette.secondary)
.foregroundStyle(.white)         →  .foregroundStyle(theme.palette.onPrimary)
.foregroundStyle(.primary)       →  .foregroundStyle(theme.palette.primary)

color: .orange                   →  color: theme.palette.warning
color: .green                    →  color: theme.palette.success
color: .red                      →  color: theme.palette.error
color: .blue                     →  color: theme.palette.primary
color: .purple                   →  color: theme.palette.secondary

Color.black.opacity(             →  theme.palette.neutral.opacity(
.black.opacity(                  →  theme.palette.neutral.opacity(
.white.opacity(                  →  theme.palette.onPrimary.opacity(
.orange.opacity(                 →  theme.palette.warning.opacity(
.green.opacity(                  →  theme.palette.success.opacity(
.red.opacity(                    →  theme.palette.error.opacity(
.blue.opacity(                   →  theme.palette.primary.opacity(
.gray.opacity(                   →  theme.palette.textSecondary.opacity(

iconColor: .orange               →  iconColor: theme.palette.warning
iconColor: .red                  →  iconColor: theme.palette.error
iconColor: .green                →  iconColor: theme.palette.success
iconColor: .blue                 →  iconColor: theme.palette.primary

return .orange                   →  return .appWarning
return .green                    →  return .appSuccess
return .red                      →  return .appError
return .blue                     →  return .appAccent
return .purple                   →  return .purple
```

### Button Style Replacements

```
.buttonStyle(.glass(color: .blue, prominent: true))    →  .buttonStyle(.glass(color: theme.palette.primary, prominent: true))
.buttonStyle(.glass(color: .blue))                     →  .buttonStyle(.glass(color: theme.palette.primary))
.buttonStyle(.glass(color: .green, prominent: true))   →  .buttonStyle(.glass(color: theme.palette.success, prominent: true))
.buttonStyle(.glass(color: .green))                    →  .buttonStyle(.glass(color: theme.palette.success))
.buttonStyle(.glass(color: .red, prominent: true))     →  .buttonStyle(.glass(color: theme.palette.error, prominent: true))
.buttonStyle(.glass(color: .red))                      →  .buttonStyle(.glass(color: theme.palette.error))
.buttonStyle(.glass(color: .orange, prominent: true))  →  .buttonStyle(.glass(color: theme.palette.warning, prominent: true))
.buttonStyle(.glass(color: .orange))                   →  .buttonStyle(.glass(color: theme.palette.warning))
```

### Shadow Replacements

```
.shadow(color: .black.opacity(0.08), radius: 4       →  .dsElevation(.level1)
.shadow(color: .black.opacity(0.1), radius: 10      →  .dsElevation(.level2)
.shadow(color: .black.opacity(0.12), radius: 10     →  .dsElevation(.level2)
.shadow(color: .black.opacity(0.15), radius: 20     →  .dsElevation(.level3)
```

Remove the entire .shadow(...) call and replace with .dsElevation(.levelX)

### Spacing Replacements

```
padding(16)          →  padding(theme.grid.cardPadding)
padding(12)          →  padding(theme.grid.cardPaddingTight)
padding(20)          →  padding(theme.grid.sectionSpacing)
padding(8)           →  padding(8)  // KEEP - no token for this
padding(4)           →  padding(4)  // KEEP - no token for this

spacing: 12          →  spacing: theme.grid.listSpacing
spacing: 16          →  spacing: theme.grid.cardPadding
spacing: 20          →  spacing: theme.grid.sectionSpacing
spacing: 8           →  spacing: 8  // KEEP - no token for this
```

### Corner Radius Replacements

```
cornerRadius: 20     →  cornerRadius: theme.shape.cardCornerRadius
cornerRadius: 24     →  cornerRadius: theme.shape.glassCornerRadius
cornerRadius: 12     →  cornerRadius: theme.shape.subtleCornerRadius
cornerRadius: 16     →  cornerRadius: theme.shape.tooltipCornerRadius
cornerRadius: 10     →  cornerRadius: theme.shape.controlCornerRadius
cornerRadius: 8      →  cornerRadius: theme.shape.controlCornerRadius
```

---

## STEP 2: ADD THEME ENVIRONMENT IF MISSING

If a file uses ANY `theme.` reference, it MUST have this property in the View struct:

```swift
@Environment(\.dsTheme) private var theme
```

Add it right after other @State/@Binding properties, before the body.

---

## STEP 3: FILES TO PROCESS - DO ALL OF THESE

Process in this exact order. DO NOT SKIP ANY FILE.

1. `BabciaTobiasz/Features/Areas/AreaFormView.swift`
2. `BabciaTobiasz/Features/Settings/Analytics/AnalyticsView.swift`
3. `BabciaTobiasz/Features/Areas/AreaDetailView.swift`
4. `BabciaTobiasz/Features/SpotCheck/SpotCheckCards.swift`
5. `BabciaTobiasz/Features/Settings/SettingsView.swift`
6. `BabciaTobiasz/Features/Settings/CameraSetupView.swift`
7. `BabciaTobiasz/Shared/Components/BabciaPersonaSelectionView.swift`
8. `BabciaTobiasz/Features/Gallery/GalleryDetailView.swift`
9. `BabciaTobiasz/Features/Filters/FilterShopView.swift`
10. `BabciaTobiasz/Features/MicroTidy/MicroTidyView.swift`
11. `BabciaTobiasz/Features/Settings/DreamAPIKeyCardView.swift`
12. `BabciaTobiasz/Features/Settings/GeminiAPIKeyCardView.swift`
13. `BabciaTobiasz/Features/Home/HomeView.swift`
14. `BabciaTobiasz/Features/Home/Components/DailyProgressCard.swift`
15. `BabciaTobiasz/Features/Home/Components/StreakCard.swift`
16. `BabciaTobiasz/Features/Home/Components/LatestDreamCard.swift`
17. `BabciaTobiasz/Features/Babcia/BabciaStatusView.swift`
18. `BabciaTobiasz/Features/Gallery/Components/GalleryImageView.swift`
19. `BabciaTobiasz/Shared/Components/GlassCardView.swift`
20. `BabciaTobiasz/Shared/Components/FeatureTooltip.swift`
21. `BabciaTobiasz/Shared/Components/SparkleIconView.swift`
22. `BabciaTobiasz/Features/Areas/Components/ScanProcessingOverlayView.swift`
23. `BabciaTobiasz/Features/Areas/Components/CompletionSummaryView.swift`
24. `BabciaTobiasz/Features/Areas/Components/PierogiDropView.swift`
25. `BabciaTobiasz/Features/Areas/AreaViewModel.swift`
26. `BabciaTobiasz/Features/Areas/AreaModels.swift`
27. `BabciaTobiasz/Core/Scoring/ScoringService.swift`
28. `BabciaTobiasz/Shared/Extensions/View+Extensions.swift`
29. `BabciaTobiasz/App/BabciaTobiaszAppView.swift`

---

## EXCEPTIONS - DO NOT MODIFY THESE PATTERNS

### 1. Color Picker Arrays - SKIP THESE
```swift
let availableColors: [Color] = [.teal, .green, .mint, .cyan, .blue, ...]
// DO NOT CHANGE - these are user-selectable options
```

### 2. Enum Cases - SKIP THESE
```swift
case .blue:  // This is BowlVerificationTier.blue, NOT a color
verificationTier = .blue  // Enum assignment, NOT a color
```

### 3. String Literals - SKIP THESE
```swift
String(localized: "areaDetail.verify.celebration.title.blue")
"Bowl_Clay_Blue"  // Asset name
```

### 4. Design System Definition Files - SKIP ENTIRELY
- `BabciaTobiasz/DesignSystem/DesignSystemTheme.swift` - DO NOT TOUCH
- `BabciaTobiasz/Shared/Extensions/Color+Extensions.swift` - DO NOT TOUCH

### 5. Computed Properties Without Theme Access
For computed properties on enums/structs that can't access Environment:
```swift
// Use static color extensions instead of theme
return .appWarning    // instead of theme.palette.warning
return .appSuccess    // instead of theme.palette.success
return .appError      // instead of theme.palette.error
return .appAccent     // instead of theme.palette.primary
```

---

## EXECUTION ORDER

For EACH file:
1. Read the file
2. Add `@Environment(\.dsTheme) private var theme` if needed
3. Apply ALL replacements from Step 1
4. Save the file
5. Move to next file

DO NOT STOP. DO NOT ASK. PROCESS ALL 29 FILES.

---

## BEGIN NOW

Start with file #1: `BabciaTobiasz/Features/Areas/AreaFormView.swift`

Read it, fix it, save it, move to #2. Continue until all 29 files are complete.

GO.
