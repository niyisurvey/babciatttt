# Design Token Tuning System

Add an on-device theme editor accessible from Settings that enables real-time tweaking of design tokens with UserDefaults persistence and JSON export/import.

---

## Proposed Changes

### DesignSystem Component

#### [NEW] [ThemeOverrides.swift](file:///Users/Shared/Developer/BabciaTobiasz/BabciaTobiasz/DesignSystem/ThemeOverrides.swift)

UserDefaults wrapper that stores/retrieves token overrides:
- `ThemeOverrides` class with `@Published` properties for each overrideable token
- Grouped storage keys by category (palette, shape, grid, glass, motion)
- Method: `override(for keyPath:)` returns stored value or nil
- Method: `reset()` clears all overrides
- Method: `exportJSON() -> Data` exports current overrides
- Method: `importJSON(_ data: Data)` loads overrides from JSON

#### [MODIFY] [DesignSystemTheme.swift](file:///Users/Shared/Developer/BabciaTobiasz/BabciaTobiasz/DesignSystem/DesignSystemTheme.swift)

- Add `static func withOverrides(_ overrides: ThemeOverrides) -> DesignSystemTheme` factory method
- Reads each token from overrides, falling back to `default` if nil
- No changes to existing structs, just adds override resolution layer

---

### Settings Feature

#### [NEW] [ThemeTunerView.swift](file:///Users/Shared/Developer/BabciaTobiasz/BabciaTobiasz/Features/Settings/ThemeTunerView.swift)

Main tuning interface with grouped sections:

**Token Groups (DisclosureGroup sections):**
1. **Colors** — ColorPickers for palette.* tokens
2. **Spacing & Grid** — Sliders for grid.* tokens  
3. **Corner Radii** — Sliders for shape.* tokens
4. **Glass Effects** — Sliders for glass opacity/tint tokens
5. **Animation** — Dropdown for motion preset, sliders for durations
6. **Typography** — Text fields for font family names

**Controls:**
- Reset All button (clears UserDefaults)
- Export JSON button (share sheet)
- Import JSON button (document picker)

#### [MODIFY] [SettingsView.swift](file:///Users/Shared/Developer/BabciaTobiasz/BabciaTobiasz/Features/Settings/SettingsView.swift)

Add NavigationLink to ThemeTunerView after the Appearance section:

```swift
// After Appearance Section (~line 36)
VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
    Text("Design Tokens")
        .dsFont(.headline, weight: .bold)
        .padding(.horizontal, theme.grid.cardPaddingTight / 3)
    Text("Fine-tune the app's visual design")
        .dsFont(.caption)
        .foregroundStyle(theme.palette.textSecondary)
        .padding(.horizontal, theme.grid.cardPaddingTight / 3)
    
    GlassCardView {
        NavigationLink {
            ThemeTunerView()
        } label: {
            HStack {
                Text("Theme Tuner")
                    .dsFont(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(theme.typography.font(.caption2))
                    .foregroundStyle(theme.palette.textSecondary)
                    .opacity(theme.glass.glowOpacityLow)
            }
            .padding(.vertical, theme.grid.cardPaddingTight / 3)
        }
    }
}
```

---

### App Integration

#### [MODIFY] [AppHost.swift](file:///Users/Shared/Developer/BabciaTobiasz/AppHost/AppHost.swift) (or root view)

- Inject `ThemeOverrides` as `@StateObject`
- Pass `DesignSystemTheme.withOverrides(overrides)` to `.dsTheme()` environment

---

## File Summary

| Action | File |
|--------|------|
| NEW | `BabciaTobiasz/DesignSystem/ThemeOverrides.swift` |
| MODIFY | `BabciaTobiasz/DesignSystem/DesignSystemTheme.swift` |
| NEW | `BabciaTobiasz/Features/Settings/ThemeTunerView.swift` |
| MODIFY | `BabciaTobiasz/Features/Settings/SettingsView.swift` |
| MODIFY | `AppHost/AppHost.swift` (or root view) |

---

## Verification Plan

### Build Verification
```bash
cd /Users/Shared/Developer/BabciaTobiasz
xcodebuild -scheme BabciaTobiaszApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

### Manual Testing (User)
1. Launch app in Simulator or device
2. Navigate to Settings → Theme Tuner
3. Verify grouped sections appear (Colors, Spacing, Radii, Glass, Animation)
4. Adjust a slider (e.g., `grid.cardPadding`)
5. Navigate back to Home tab and verify change is visible
6. Kill and restart app
7. Verify the override persists after restart
8. Test "Reset All" button clears overrides
9. Test Export JSON creates shareable file
10. Test Import JSON loads saved config

> [!NOTE]
> Since this is primarily UI/UX work, automated unit tests add limited value. The verification relies on visual confirmation of token changes propagating in real-time.
