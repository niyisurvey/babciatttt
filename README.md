# WeatherHabitTracker

![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0+-green.svg)
![SwiftData](https://img.shields.io/badge/SwiftData-1.0+-purple.svg)
![License](https://img.shields.io/badge/License-MIT-gray.svg)

An iOS app combining **weather tracking** with **habit management**, built with Swift 6+, SwiftUI, and SwiftData. 

<p align="center">
  <img src="screenshots/weather.png" width="250" alt="Weather View"/>
  <img src="screenshots/weathersearch.png" width="250" alt="Weather Search"/>
  <img src="screenshots/habits.png" width="250" alt="Habits View"/>
  <img src="screenshots/addhabits.png" width="250" alt="Add Habits"/>
  <img src="screenshots/habit-detail.png" width="250" alt="Habit Detail"/>
  <img src="screenshots/settings.png" width="250" alt="Settings"/>
</p>

## Features

### Weather System
- **Current Weather**: Real-time temperature, conditions, and location
- **7-Day Forecast**: Detailed daily forecasts with high/low temperatures
- **Weather Details**: Humidity, wind speed, UV index, visibility, and pressure
- **Offline Caching**: Weather data cached locally with SwiftData
- **Location-Based**: Automatic weather based on user location

### Habit Tracker
- **Create & Manage Habits**: Add, edit, and delete habits easily
- **Daily Tracking**: Mark habits complete with optional notes
- **Streak Tracking**: Visualize your consistency with streak counts
- **Multi-Target Habits**: Support for habits done multiple times daily
- **Statistics Dashboard**: Overview of completion rates and streaks
- **Local Notifications**: Customizable daily reminders

### Design
- **Dark Mode Support**: Full support for light and dark themes
- **Smooth Animations**: Delightful micro-interactions

## 🏗️ Architecture

This project follows a **feature-based modular architecture** inspired by modern iOS practices (e.g., [isowords](https://github.com/pointfreeco/isowords)):

```
WeatherHabitTracker/
├── App/                      # App entry point & navigation
│   ├── WeatherHabitTrackerApp.swift
│   ├── AppDependencies.swift
│   ├── LaunchView.swift
│   └── MainTabView.swift
│
├── Features/                 # Feature modules (self-contained)
│   ├── Weather/              # Weather feature
│   │   ├── WeatherView.swift
│   │   ├── WeatherViewModel.swift
│   │   ├── WeatherData.swift
│   │   ├── WeatherForecast.swift
│   │   └── WeatherDTOs.swift
│   │
│   └── Habits/               # Habits feature
│       ├── HabitListView.swift
│       ├── HabitDetailView.swift
│       ├── HabitFormView.swift
│       ├── HabitRowView.swift
│       ├── HabitViewModel.swift
│       └── Habit.swift
│
├── Core/                     # Core infrastructure
│   ├── Networking/
│   │   └── WeatherService.swift
│   ├── Persistence/
│   │   └── PersistenceService.swift
│   ├── Location/
│   │   └── LocationService.swift
│   └── Notifications/
│       └── NotificationService.swift
│
├── Shared/                   # Shared utilities & components
│   ├── Components/           # Reusable UI components
│   │   ├── GlassCardView.swift
│   │   ├── LoadingIndicatorView.swift
│   │   └── ErrorView.swift
│   ├── Styles/
│   │   └── LiquidGlassStyle.swift
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── View+Extensions.swift
│   │   └── Color+Extensions.swift
│   └── Constants.swift
│
├── Resources/                # Assets & configuration
│   ├── Assets.xcassets/
│   ├── Secrets.plist
│   └── Localization/
│
└── Info.plist
```

### Key Patterns Used
- **Dependency Injection**: Services injected via environment
- **Protocol-Oriented Design**: Easy mocking for tests
- **Async/Await**: Modern Swift concurrency throughout
- **@Observable**: Swift 5.9+ macro for reactive state

## 🚀 Getting Started

### Prerequisites
- **Xcode 16+** (or Xcode 17/26 for latest Swift 6 features)
- **iOS 17.0+** deployment target
- **macOS Sonoma** or later recommended

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/melkor/WeatherHabitTracker.git
   cd WeatherHabitTracker
   ```

2. **Open in Xcode**
   ```bash
   open WeatherHabitTracker.xcodeproj
   ```

3. **Configure Weather API Key** (Required for weather features)
   
   The app uses OpenWeatherMap API. Get a free API key at [openweathermap.org](https://openweathermap.org/api).
   
   Open `Services/WeatherService.swift` and replace:
   ```swift
   static let apiKey = "YOUR_OPENWEATHERMAP_API_KEY"
   ```

4. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### Permissions Required
- **Location**: For weather based on your current location
- **Notifications**: For habit reminder notifications (optional)

## 🧪 Testing

### Run Unit Tests
```bash
xcodebuild test \
  -project WeatherHabitTracker.xcodeproj \
  -scheme WeatherHabitTracker \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Run UI Tests
```bash
xcodebuild test \
  -project WeatherHabitTracker.xcodeproj \
  -scheme WeatherHabitTrackerUITests \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Test Coverage
The project includes comprehensive tests:
- **WeatherServiceTests**: API parsing, caching, error handling
- **HabitViewModelTests**: CRUD operations, streak calculations, filtering
- **PersistenceServiceTests**: SwiftData operations
- **UI Tests**: End-to-end user flow testing

## 🎨 Design Decisions

### Why Liquid Glass UI?
The Liquid Glass design language (introduced in iOS 26/visionOS) provides:
- **Visual Depth**: Multi-layered glass materials create depth
- **Consistency**: Follows Apple's Human Interface Guidelines
- **Adaptability**: Looks great in both light and dark modes
- **Modern Feel**: Premium, polished user experience

### Why SwiftData over Core Data?
- **Swift Native**: Type-safe, uses modern Swift syntax
- **Declarative**: Uses `@Model` macro for cleaner code
- **CloudKit Ready**: Easy future migration to sync across devices
- **Simpler API**: Less boilerplate than Core Data

### Why MVVM?
- **Separation of Concerns**: Clear boundaries between UI and logic
- **Testability**: ViewModels can be unit tested without UI
- **SwiftUI Native**: Works naturally with `@Observable` and `@Bindable`

## 🔮 Future Enhancements

### CloudKit Sync
The app is designed for easy CloudKit integration:
```swift
// In WeatherHabitTrackerApp.swift, change:
cloudKitDatabase: .none
// To:
cloudKitDatabase: .automatic
```

### Planned Features
- [ ] Apple Watch companion app
- [ ] Widgets for home screen
- [ ] Weather-based habit suggestions
- [ ] Weekly/monthly reports
- [ ] Data export functionality
- [ ] Siri Shortcuts integration

