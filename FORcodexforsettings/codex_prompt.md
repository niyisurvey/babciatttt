# CODEX PROMPT: Design Token Tuning System for BabciaTobiasz

You are implementing an on-device Design Token Tuner for an iOS SwiftUI app. This is a complete, production-ready prompt. Read it carefully.

---

## 🎯 GOAL

Create a Theme Tuner page accessible from Settings → "Theme Tuner" that allows real-time editing of design tokens with UserDefaults persistence and JSON export/import.

---

## ⚠️ CRITICAL SAFETY REQUIREMENTS

**The app must NEVER crash from bad theme data.** Follow these patterns:

### 1. Fallback-on-failure (from AppConfigService.swift lines 106-114)
```swift
func load() {
    do {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(ThemeOverridesData.self, from: data)
        apply(decoded)
    } catch {
        // Silently fall back to defaults - NEVER crash
        reset()
    }
}
```

### 2. Optional overrides with nil = default
```swift
// Every override is optional. nil means "use default value"
var cardPadding: CGFloat?  // nil = use DesignSystemTheme.default.grid.cardPadding
```

### 3. Bounds validation for numeric values
```swift
func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
    Swift.min(Swift.max(value, min), max)
}
// Example: shape.borderOpacity must be 0-1, grid.cardPadding must be 0-300
```

### 4. Use existing Color+Extensions.swift hex helpers
```swift
// Already exists at BabciaTobiasz/Shared/Extensions/Color+Extensions.swift
Color(hex: "#FF0000")  // Failable initializer - returns nil on bad input
color.hexString        // Returns "#007AFF" fallback on error
```

---

## 📁 PROJECT STRUCTURE

```
/Users/Shared/Developer/BabciaTobiasz/
├── BabciaTobiasz/
│   ├── App/
│   │   └── AppHost.swift                    # @main entry point - inject theme here
│   ├── DesignSystem/
│   │   └── DesignSystemTheme.swift          # DO NOT modify structs, only add factory
│   ├── Shared/Extensions/
│   │   └── Color+Extensions.swift           # EXISTING hex parsing - reuse this
│   └── Features/Settings/
│       └── SettingsView.swift               # Add NavigationLink to ThemeTunerView
└── temptokensjsonsbuildertemp/
    ├── tokeninventory.json                  # CANONICAL: all tokens with constraints
    └── exmpleoutput.json                    # JSON schema + example output format
```

---

## 📊 COMPLETE TOKEN INVENTORY (from tokeninventory.json)

### Palette — 12 Color tokens (ColorPicker)
| Token ID | Default |
|----------|---------|
| `palette.primary` | `.appAccent` (blue) |
| `palette.secondary` | `.purple` |
| `palette.tertiary` | `.cyan` |
| `palette.success` | `.appSuccess` (green) |
| `palette.warning` | `.appWarning` (orange) |
| `palette.error` | `.appError` (red) |
| `palette.glassTint` | `.white` |
| `palette.coolAccent` | `.teal` |
| `palette.warmAccent` | `.orange` |
| `palette.onPrimary` | `.white` |
| `palette.textSecondary` | `Color(.secondaryLabel)` |
| `palette.neutral` | `.black` |

### Shape — 8 tokens (Slider, range varies)
| Token ID | Default | Range |
|----------|---------|-------|
| `shape.cardCornerRadius` | 20 | 0-100 |
| `shape.glassCornerRadius` | 24 | 0-100 |
| `shape.subtleCornerRadius` | 12 | 0-100 |
| `shape.tooltipCornerRadius` | 16 | 0-100 |
| `shape.heroCornerRadius` | 70 | 0-100 |
| `shape.controlCornerRadius` | 16 | 0-100 |
| `shape.borderWidth` | 0 | 0-20 |
| `shape.borderOpacity` | 0.0 | 0-1 step 0.01 |

### Grid — 28 tokens (Slider, 0-300)
| Token ID | Default | Notes |
|----------|---------|-------|
| `grid.cardPadding` | 16 | |
| `grid.cardPaddingTight` | 12 | |
| `grid.sectionSpacing` | 20 | |
| `grid.listSpacing` | 12 | |
| `grid.buttonMinHeight` | 48 | |
| `grid.buttonHorizontalPadding` | 24 | |
| `grid.buttonVerticalPadding` | 12 | |
| `grid.iconTiny` | 12 | |
| `grid.iconSmall` | 20 | |
| `grid.iconTitle2` | 22 | |
| `grid.iconTitle3` | 20 | |
| `grid.iconMedium` | 32 | |
| `grid.iconLarge` | 44 | |
| `grid.iconSplashSecondary` | 40 | |
| `grid.iconError` | 50 | |
| `grid.iconXL` | 60 | |
| `grid.iconXXL` | 80 | |
| `grid.iconXXXL` | 110 | |
| `grid.ringSize` | 100 | |
| `grid.detailCardHeightSmall` | 120 | |
| `grid.detailCardHeightLarge` | 150 | |
| `grid.heroHeaderCollapsedHeight` | 120 | |
| `grid.heroCardWidth` | 260 | |
| `grid.heroCardHeight` | 260 | |
| `grid.pierogiSize` | 60 | |
| `grid.pierogiEmojiScale` | 2.2 | 0-5, step 0.1 |
| `grid.pierogiPotSize` | 140 | |
| `grid.pierogiPotGrowStep` | 6 | |

### Glass — 6 core tokens
| Token ID | Default | Control |
|----------|---------|---------|
| `glass.strength` | `.regular` | Picker: ultraThin/thin/regular/thick |
| `glass.prominentStrength` | `.thin` | Picker: ultraThin/thin/regular/thick |
| `glass.effectStyle` | `.clear` | Picker: clear/regular |
| `glass.tintOpacity` | 0.02 | Slider 0-1 step 0.01 |
| `glass.glowOpacityHigh` | 0.7 | Slider 0-1 step 0.01 |
| `glass.glowOpacityLow` | 0.2 | Slider 0-1 step 0.01 |

### Motion — 5 tokens
| Token ID | Default | Control |
|----------|---------|---------|
| `motion.preset` | `.normal` | Picker: slow/normal/fast |
| `motion.shimmerDuration` | 1.2 | Slider 0-10 step 0.1 |
| `motion.shimmerLongDuration` | 1.5 | Slider 0-10 step 0.1 |
| `motion.spinnerDuration` | 1.0 | Slider 0-10 step 0.1 |
| `motion.meshAnimationInterval` | 3.0 | Slider 0-10 step 0.1 |

### Typography — 4 font family tokens (TextField)
| Token ID | Default |
|----------|---------|
| `typography.family.regular` | "LinLibertine" |
| `typography.family.bold` | "LinLibertineB" |
| `typography.family.italic` | "LinLibertineI" |
| `typography.family.boldItalic` | "LinLibertineBI" |

---

## 📝 HUMAN-READABLE JSON FORMAT

Export must be pretty-printed and hand-editable:

```json
{
  "version": 1,
  "exportDate": "2026-01-24T14:00:00Z",
  "overrides": {
    "palette": {
      "primary": "#007AFF",
      "secondary": "#AF52DE"
    },
    "shape": {
      "cardCornerRadius": 24,
      "glassCornerRadius": 28
    },
    "grid": {
      "cardPadding": 20,
      "sectionSpacing": 24
    },
    "glass": {
      "strength": "thin",
      "tintOpacity": 0.05
    },
    "motion": {
      "preset": "fast",
      "shimmerDuration": 1.0
    },
    "typography": {
      "family": {
        "regular": "LinLibertine"
      }
    }
  }
}
```

**Key rules for JSON:**
- Only include overridden values (omit tokens using defaults)
- Use `JSONEncoder.OutputFormatting.prettyPrinted` + `.sortedKeys`
- Colors as hex strings (#RRGGBB)
- Enums as lowercase string rawValues

---

## 🏗️ FILES TO CREATE

### 1. ThemeOverrides.swift

**Path:** `BabciaTobiasz/DesignSystem/ThemeOverrides.swift`

```swift
import SwiftUI
import Combine

/// Stores user-defined token overrides in UserDefaults with crash-safe loading
@MainActor
final class ThemeOverrides: ObservableObject {
    private let defaults = UserDefaults.standard
    private let prefix = "themeOverride."
    
    // MARK: - Palette (optional Colors)
    @Published var primaryColor: Color?
    @Published var secondaryColor: Color?
    @Published var tertiaryColor: Color?
    @Published var successColor: Color?
    @Published var warningColor: Color?
    @Published var errorColor: Color?
    @Published var glassTintColor: Color?
    @Published var coolAccentColor: Color?
    @Published var warmAccentColor: Color?
    @Published var onPrimaryColor: Color?
    @Published var textSecondaryColor: Color?
    @Published var neutralColor: Color?
    
    // MARK: - Shape (optional CGFloats)
    @Published var cardCornerRadius: CGFloat?
    @Published var glassCornerRadius: CGFloat?
    @Published var subtleCornerRadius: CGFloat?
    @Published var tooltipCornerRadius: CGFloat?
    @Published var heroCornerRadius: CGFloat?
    @Published var controlCornerRadius: CGFloat?
    @Published var borderWidth: CGFloat?
    @Published var borderOpacity: Double?
    
    // MARK: - Grid (optional CGFloats - all 28 tokens)
    @Published var cardPadding: CGFloat?
    @Published var cardPaddingTight: CGFloat?
    @Published var sectionSpacing: CGFloat?
    @Published var listSpacing: CGFloat?
    // ... add remaining grid tokens
    
    // MARK: - Glass
    @Published var glassStrength: DSGlassStrength?
    @Published var glassProminentStrength: DSGlassStrength?
    @Published var glassEffectStyle: DSGlassEffectStyle?
    @Published var glassTintOpacity: Double?
    @Published var glassGlowOpacityHigh: Double?
    @Published var glassGlowOpacityLow: Double?
    
    // MARK: - Motion
    @Published var motionPreset: DSMotionPreset?
    @Published var shimmerDuration: Double?
    @Published var shimmerLongDuration: Double?
    @Published var spinnerDuration: Double?
    @Published var meshAnimationInterval: Double?
    
    // MARK: - Typography
    @Published var fontFamilyRegular: String?
    @Published var fontFamilyBold: String?
    @Published var fontFamilyItalic: String?
    @Published var fontFamilyBoldItalic: String?
    
    // MARK: - Lifecycle
    
    init() {
        loadFromDefaults()
    }
    
    /// Safely load all values - NEVER crashes
    private func loadFromDefaults() {
        // Colors: stored as hex strings
        primaryColor = loadColor(forKey: "palette.primary")
        // ... repeat for all colors
        
        // CGFloats: stored as Double
        cardCornerRadius = loadCGFloat(forKey: "shape.cardCornerRadius")
        // ... repeat for all CGFloats
        
        // Enums: stored as rawValue strings
        glassStrength = loadEnum(forKey: "glass.strength")
        // ... repeat for all enums
    }
    
    /// Save current values to UserDefaults
    func save() {
        // Colors
        saveColor(primaryColor, forKey: "palette.primary")
        // ... repeat
        
        // CGFloats
        saveCGFloat(cardCornerRadius, forKey: "shape.cardCornerRadius")
        // ... repeat
        
        // Enums
        saveEnum(glassStrength, forKey: "glass.strength")
        // ... repeat
    }
    
    /// Reset all overrides to nil (use defaults)
    func reset() {
        let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(prefix) }
        keys.forEach { defaults.removeObject(forKey: $0) }
        loadFromDefaults()  // Reload (all will be nil)
    }
    
    // MARK: - JSON Export/Import
    
    /// Export non-nil overrides as human-readable JSON
    func exportJSON() -> Data? {
        var dict: [String: Any] = [
            "version": 1,
            "exportDate": ISO8601DateFormatter().string(from: Date())
        ]
        
        var overrides: [String: Any] = [:]
        
        // Build palette dict
        var palette: [String: String] = [:]
        if let c = primaryColor { palette["primary"] = c.hexString }
        // ... repeat for all colors
        if !palette.isEmpty { overrides["palette"] = palette }
        
        // Build shape dict
        var shape: [String: Any] = [:]
        if let v = cardCornerRadius { shape["cardCornerRadius"] = v }
        // ... repeat
        if !shape.isEmpty { overrides["shape"] = shape }
        
        // Continue for grid, glass, motion, typography...
        
        dict["overrides"] = overrides
        
        return try? JSONSerialization.data(
            withJSONObject: dict, 
            options: [.prettyPrinted, .sortedKeys]
        )
    }
    
    /// Import JSON - silently ignores invalid data
    func importJSON(_ data: Data) {
        guard let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let overrides = dict["overrides"] as? [String: Any] else { return }
        
        // Parse palette
        if let palette = overrides["palette"] as? [String: String] {
            primaryColor = Color(hex: palette["primary"] ?? "")
            // ... repeat
        }
        
        // Parse shape
        if let shape = overrides["shape"] as? [String: Any] {
            cardCornerRadius = (shape["cardCornerRadius"] as? NSNumber)?.doubleValue.map { CGFloat($0) }
            // ... repeat
        }
        
        // Continue for other sections...
        
        save()  // Persist to UserDefaults
    }
    
    // MARK: - Private Helpers (crash-safe)
    
    private func loadColor(forKey key: String) -> Color? {
        guard let hex = defaults.string(forKey: prefix + key) else { return nil }
        return Color(hex: hex)  // Failable - returns nil on bad data
    }
    
    private func saveColor(_ color: Color?, forKey key: String) {
        if let color = color {
            defaults.set(color.hexString, forKey: prefix + key)
        } else {
            defaults.removeObject(forKey: prefix + key)
        }
    }
    
    private func loadCGFloat(forKey key: String) -> CGFloat? {
        let value = defaults.object(forKey: prefix + key) as? Double
        return value.map { CGFloat($0) }
    }
    
    private func saveCGFloat(_ value: CGFloat?, forKey key: String) {
        if let value = value {
            defaults.set(Double(value), forKey: prefix + key)
        } else {
            defaults.removeObject(forKey: prefix + key)
        }
    }
    
    private func loadEnum<E: RawRepresentable>(forKey key: String) -> E? where E.RawValue == String {
        guard let raw = defaults.string(forKey: prefix + key) else { return nil }
        return E(rawValue: raw)  // Returns nil if invalid
    }
    
    private func saveEnum<E: RawRepresentable>(_ value: E?, forKey key: String) where E.RawValue == String {
        if let value = value {
            defaults.set(value.rawValue, forKey: prefix + key)
        } else {
            defaults.removeObject(forKey: prefix + key)
        }
    }
}
```

### 2. ThemeTunerView.swift

**Path:** `BabciaTobiasz/Features/Settings/ThemeTunerView.swift`

Follow the UI patterns from SettingsView.swift:
- Use `GlassCardView` for sections
- Use `DisclosureGroup` for collapsible groups
- Use `@Environment(\.dsTheme)` for styling
- Match existing spacing (`theme.grid.sectionSpacing`, `theme.grid.listSpacing`)

**Structure:**
1. Colors Section (DisclosureGroup with ColorPickers)
2. Spacing Section (key grid.* sliders)
3. Corner Radii Section (shape.* sliders)
4. Glass Section (strength pickers + opacity sliders)
5. Animation Section (motion preset picker + duration sliders)
6. Actions (Export, Import, Reset buttons)

---

## 🔧 FILES TO MODIFY

### 3. DesignSystemTheme.swift (L387 extension)

Add factory method after `static let default`:

```swift
/// Creates theme with user overrides applied (nil = use default)
static func withOverrides(_ overrides: ThemeOverrides) -> DesignSystemTheme {
    let base = DesignSystemTheme.default
    return DesignSystemTheme(
        palette: DSPalette(
            primary: overrides.primaryColor ?? base.palette.primary,
            secondary: overrides.secondaryColor ?? base.palette.secondary,
            tertiary: overrides.tertiaryColor ?? base.palette.tertiary,
            success: overrides.successColor ?? base.palette.success,
            warning: overrides.warningColor ?? base.palette.warning,
            error: overrides.errorColor ?? base.palette.error,
            glassTint: overrides.glassTintColor ?? base.palette.glassTint,
            coolAccent: overrides.coolAccentColor ?? base.palette.coolAccent,
            warmAccent: overrides.warmAccentColor ?? base.palette.warmAccent,
            onPrimary: overrides.onPrimaryColor ?? base.palette.onPrimary,
            textSecondary: overrides.textSecondaryColor ?? base.palette.textSecondary,
            neutral: overrides.neutralColor ?? base.palette.neutral
        ),
        gradients: base.gradients,  // Not overrideable for now
        typography: DSTypography(
            family: DSFontFamily(
                regular: overrides.fontFamilyRegular ?? base.typography.family.regular,
                bold: overrides.fontFamilyBold ?? base.typography.family.bold,
                italic: overrides.fontFamilyItalic ?? base.typography.family.italic,
                boldItalic: overrides.fontFamilyBoldItalic ?? base.typography.family.boldItalic
            )
        ),
        motion: DSMotion(preset: overrides.motionPreset ?? base.motion.preset),
        shape: DSShape(
            cardCornerRadius: overrides.cardCornerRadius ?? base.shape.cardCornerRadius,
            glassCornerRadius: overrides.glassCornerRadius ?? base.shape.glassCornerRadius,
            subtleCornerRadius: overrides.subtleCornerRadius ?? base.shape.subtleCornerRadius,
            tooltipCornerRadius: overrides.tooltipCornerRadius ?? base.shape.tooltipCornerRadius,
            heroCornerRadius: overrides.heroCornerRadius ?? base.shape.heroCornerRadius,
            controlCornerRadius: overrides.controlCornerRadius ?? base.shape.controlCornerRadius,
            borderWidth: overrides.borderWidth ?? base.shape.borderWidth,
            borderOpacity: overrides.borderOpacity ?? base.shape.borderOpacity
        ),
        grid: DSGrid(
            cardPadding: overrides.cardPadding ?? base.grid.cardPadding,
            cardPaddingTight: overrides.cardPaddingTight ?? base.grid.cardPaddingTight,
            sectionSpacing: overrides.sectionSpacing ?? base.grid.sectionSpacing,
            listSpacing: overrides.listSpacing ?? base.grid.listSpacing,
            // ... all 28 grid tokens
        ),
        glass: DSGlass(
            strength: overrides.glassStrength ?? base.glass.strength,
            prominentStrength: overrides.glassProminentStrength ?? base.glass.prominentStrength,
            effectStyle: overrides.glassEffectStyle ?? base.glass.effectStyle,
            tintOpacity: overrides.glassTintOpacity ?? base.glass.tintOpacity,
            glowOpacityHigh: overrides.glassGlowOpacityHigh ?? base.glass.glowOpacityHigh,
            glowOpacityLow: overrides.glassGlowOpacityLow ?? base.glass.glowOpacityLow,
            contextSettings: base.glass.contextSettings  // Not overrideable for now
        ),
        elevation: base.elevation  // Not overrideable for now
    )
}
```

### 4. AppHost.swift (Line 10-21)

```swift
@main
struct BabciaTobiaszApp: App {
    @StateObject private var themeOverrides = ThemeOverrides()
    
    var body: some Scene {
        WindowGroup {
            let computedTheme = DesignSystemTheme.withOverrides(themeOverrides)
            BabciaTobiaszAppView()
                .dsTheme(computedTheme)
                .environment(\.font, computedTheme.typography.font(.body))
                .environmentObject(themeOverrides)
        }
    }
}
```

### 5. SettingsView.swift (~Line 36)

Add section after Appearance:

```swift
// Design Tokens Section
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

## ✅ VERIFICATION

```bash
cd /Users/Shared/Developer/BabciaTobiasz
xcodebuild -scheme BabciaTobiaszApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

**Manual testing:**
1. Settings → Theme Tuner loads without crash
2. Adjust a slider → change reflects immediately in UI
3. Kill app, relaunch → override persists
4. Export JSON → file is readable/editable
5. Edit JSON manually, import → values apply correctly
6. Reset → all values return to defaults
7. Import malformed JSON → no crash, silently ignored

---

## 🚫 DO NOT

1. Modify DSPalette, DSGrid, DSShape, DSGlass, DSMotion struct definitions
2. Crash on malformed JSON or UserDefaults data
3. Use force-unwrapping (`!`) anywhere in ThemeOverrides
4. Store complex types directly in UserDefaults (only primitives + strings)
5. Break existing app functionality
