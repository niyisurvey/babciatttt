// WeatherView.swift
// BabciaTobiasz

import SwiftUI

typealias WeatherHeaderCardBuilder = (WeatherData) -> AnyView

/// Main weather display with current conditions and 7-day forecast
struct WeatherView: View {
    @Bindable var viewModel: WeatherViewModel
    var title: String = "Home"
    var headerCardBuilder: WeatherHeaderCardBuilder? = nil

    var body: some View {
        WeatherScreen(
            viewModel: viewModel,
            title: title,
            headerCardBuilder: headerCardBuilder
        )
    }
}

// MARK: - Main Screen (Simplified body to avoid type recursion)

private struct WeatherScreen: View {
    @Bindable var viewModel: WeatherViewModel
    let title: String
    let headerCardBuilder: WeatherHeaderCardBuilder?
    @Environment(\.dsTheme) private var theme

    var body: some View {
        NavigationStack {
            WeatherScreenContent(
                viewModel: viewModel,
                headerCardBuilder: headerCardBuilder
            )
            .navigationTitle("")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            #endif
            .refreshable {
                hapticFeedback(.medium)
                await viewModel.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .dsFont(.title2, weight: .bold)
                        .lineLimit(1)
                }
            }
            .task {
                if viewModel.needsRefresh {
                    await viewModel.refresh()
                }
            }
            .alert("Weather Error", isPresented: $viewModel.showError) {
                Button("OK") { viewModel.dismissError() }
                Button("Retry") {
                    Task { await viewModel.refresh() }
                }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }
}

// MARK: - Screen Content (Extracted to break type chain)

private struct WeatherScreenContent: View {
    @Bindable var viewModel: WeatherViewModel
    let headerCardBuilder: WeatherHeaderCardBuilder?
    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack {
            WeatherBackgroundView(colors: viewModel.backgroundColors)
            
            ScrollView(showsIndicators: false) {
                WeatherScrollContent(
                    viewModel: viewModel,
                    headerCardBuilder: headerCardBuilder
                )
                    .padding()
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Scroll Content (Further extraction)

private struct WeatherScrollContent: View {
    @Bindable var viewModel: WeatherViewModel
    let headerCardBuilder: WeatherHeaderCardBuilder?
    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(spacing: 20) {
            if let weather = viewModel.currentWeather {
                WeatherDataContent(
                    weather: weather,
                    viewModel: viewModel,
                    headerCardBuilder: headerCardBuilder
                )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else if viewModel.isLoading {
                SkeletonLoadingView()
                    .transition(.opacity)
            } else {
                WeatherEmptyStateCard {
                    hapticFeedback(.medium)
                    Task { await viewModel.refresh() }
                }
                .transition(.opacity)
            }
        }
        .animation(theme.motion.listSpring, value: viewModel.currentWeather != nil)
    }
}

// MARK: - Weather Data Content

private struct WeatherDataContent: View {
    let weather: WeatherData
    @Bindable var viewModel: WeatherViewModel
    let headerCardBuilder: WeatherHeaderCardBuilder?
    @State private var showInsightTooltip = false
    @Environment(\.dsTheme) private var theme

    var body: some View {
        if let headerCardBuilder {
            headerCardBuilder(weather)
        } else {
            CurrentWeatherCard(weather: weather)
        }
        SmartInsightCard(weather: weather, showTooltip: $showInsightTooltip)
        WeatherDetailsGrid(weather: weather)

        if !viewModel.forecast.isEmpty {
            ForecastSection(forecast: viewModel.forecast)
        } else if viewModel.isForecastLoading {
            ForecastLoadingView()
        }
    }
}

// MARK: - Search Button

// MARK: - Background

private struct WeatherBackgroundView: View {
    let colors: [Color]
    @Environment(\.dsTheme) private var theme

    var body: some View {
        TimelineView(.animation(minimumInterval: theme.motion.meshAnimationInterval)) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: animatedMeshPoints(for: timeline.date),
                colors: colors + colors.suffix(from: max(0, colors.count - 3))
            )
        }
        .ignoresSafeArea()
    }

    private func animatedMeshPoints(for date: Date) -> [SIMD2<Float>] {
        let time = Float(date.timeIntervalSince1970)
        let interval = Float(max(theme.motion.meshAnimationInterval, 0.1))
        let baseSpeed = 1.0 / interval
        let offset = sin(time * (baseSpeed * 0.5)) * 0.2
        let offset2 = cos(time * (baseSpeed * 0.35)) * 0.14
        return [
            [0.0, 0.0], [0.5 + offset2, 0.0], [1.0, 0.0],
            [0.0, 0.5], [0.5 + offset, 0.5 - offset], [1.0, 0.5],
            [0.0, 1.0], [0.5 - offset2, 1.0], [1.0, 1.0]
        ]
    }
}

// MARK: - Current Weather Card

private struct CurrentWeatherCard: View {
    let weather: WeatherData
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text(weather.locationName)
                        .dsFont(.title2, weight: .bold)
                }

                HStack(alignment: .top, spacing: 20) {
                    Image(systemName: weather.conditionIconName)
                        .font(.system(size: theme.grid.iconXXL))
                        .symbolRenderingMode(.multicolor)
                        .symbolEffect(.breathe, options: .repeating)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(weather.temperatureFormatted)
                            .font(theme.typography.custom(size: 72))
                            .contentTransition(.numericText())

                        Text(weather.conditionDescription)
                            .dsFont(.title3)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(weather.highLowFormatted)
                    .dsFont(.headline)
                    .foregroundStyle(.secondary)

                if abs(weather.temperature - weather.feelsLike) > 2 {
                    Text("Feels like \(weather.feelsLikeFormatted)")
                        .dsFont(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 20)
        }
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.8)
                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                .blur(radius: phase.isIdentity ? 0 : 2)
        }
    }
}

// MARK: - Smart Insight Card

private struct SmartInsightCard: View {
    let weather: WeatherData
    @Binding var showTooltip: Bool
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.yellow)
                        .font(.system(size: theme.grid.iconTitle3))
                        .symbolEffect(.pulse, options: .repeating)
                    Text("Smart Insight")
                        .dsFont(.headline)
                    Spacer()

                    Button {
                        withAnimation(theme.motion.pressSpring) {
                            showTooltip.toggle()
                        }
                        hapticFeedback(.light)
                    } label: {
                        Image(systemName: "info.circle")
                            .dsFont(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(insightText)
                    .dsFont(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .overlay {
            if showTooltip {
                FeatureTooltip(
                    title: "Smart Insights",
                    description: "Personalized suggestions based on current weather to help you plan outdoor activities and areas.",
                    icon: "sparkles",
                    isVisible: $showTooltip
                )
                .transition(.scale.combined(with: .opacity))
                .offset(y: -80)
            }
        }
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.8)
                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                .blur(radius: phase.isIdentity ? 0 : 2)
        }
    }

    private var insightText: String {
        if weather.conditionDescription.localizedCaseInsensitiveContains("rain") ||
           weather.conditionDescription.localizedCaseInsensitiveContains("drizzle") {
            return "It's raining outside. Perfect weather to focus on indoor bowls like tidying or resetting a room."
        } else if weather.temperature > 28 {
            return "It's quite warm! Stay hydrated and consider early morning or late evening for outdoor activities."
        } else if weather.temperature < 10 {
            return "It's chilly! Bundle up if you're heading out for a walk or run."
        } else {
            return "Great weather for outdoor activities! Try to get your steps in today."
        }
    }
}

// MARK: - Weather Details Grid

private struct WeatherDetailsGrid: View {
    let weather: WeatherData
    @Environment(\.dsTheme) private var theme

    var body: some View {
        let smallHeight = theme.grid.detailCardHeightSmall
        let largeHeight = theme.grid.detailCardHeightLarge

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            WeatherDetailCard(icon: "humidity.fill", title: "Humidity", value: "\(weather.humidity)%", color: .cyan, height: smallHeight)
            WeatherDetailCard(icon: "wind", title: "Wind", value: weather.windSpeedFormatted, color: .mint, height: smallHeight)
            WeatherDetailCard(icon: "sun.max.fill", title: "UV Index", value: "\(weather.uvIndex)", subtitle: uvIndexDescription(weather.uvIndex), color: .orange, height: largeHeight)
            WeatherDetailCard(icon: "eye.fill", title: "Visibility", value: String(format: "%.0f km", weather.visibility), color: .purple, height: largeHeight)
            WeatherDetailCard(icon: "gauge.medium", title: "Pressure", value: "\(weather.pressure) hPa", color: .indigo, height: smallHeight)

            if let sunrise = weather.sunrise, let sunset = weather.sunset {
                WeatherDetailCard(
                    icon: isDaytime(sunrise: sunrise, sunset: sunset) ? "sunset.fill" : "sunrise.fill",
                    title: isDaytime(sunrise: sunrise, sunset: sunset) ? "Sunset" : "Sunrise",
                    value: formatTime(isDaytime(sunrise: sunrise, sunset: sunset) ? sunset : sunrise),
                    color: .yellow,
                    height: smallHeight
                )
            }
        }
    }

    private func uvIndexDescription(_ index: Int) -> String {
        switch index {
        case 0...2: return "Low"
        case 3...5: return "Moderate"
        case 6...7: return "High"
        case 8...10: return "Very High"
        default: return "Extreme"
        }
    }

    private func isDaytime(sunrise: Date, sunset: Date) -> Bool {
        let now = Date()
        return now > sunrise && now < sunset
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Weather Detail Card

private struct WeatherDetailCard: View {
    let icon: String
    let title: String
    let value: String
    var subtitle: String? = nil
    let color: Color
    let height: CGFloat

    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .dsFont(.headline)
                        .foregroundStyle(color)
                    Text(title)
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(value)
                    .dsFont(.title2, weight: .bold)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: height, alignment: .topLeading)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Forecast Section

private struct ForecastSection: View {
    let forecast: [WeatherForecast]
    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7-Day Forecast")
                .dsFont(.headline, weight: .bold)
                .padding(.horizontal, 4)

            GlassCardView {
                VStack(spacing: 0) {
                    ForEach(Array(forecast.enumerated()), id: \.element.id) { index, item in
                        ForecastRow(forecast: item)
                        if index < forecast.count - 1 {
                            Divider().padding(.vertical, 8)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Forecast Row

private struct ForecastRow: View {
    let forecast: WeatherForecast
    @Environment(\.dsTheme) private var theme

    var body: some View {
        HStack {
            Text(forecast.shortDayName)
                .dsFont(.body)
                .frame(width: 60, alignment: .leading)

            if forecast.precipitationProbability > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .dsFont(.caption)
                        .foregroundStyle(.cyan)
                    Text(forecast.precipitationFormatted)
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 50)
            } else {
                Spacer().frame(width: 50)
            }

            Spacer()

            Image(systemName: forecast.conditionIconName)
                .font(.system(size: theme.grid.iconTitle3))
                .symbolRenderingMode(.multicolor)
                .frame(width: 40)

            HStack(spacing: 16) {
                Text(forecast.lowFormatted)
                    .dsFont(.body)
                    .foregroundStyle(.secondary)
                    .frame(width: 35, alignment: .trailing)

                TemperatureBar(low: forecast.temperatureMin, high: forecast.temperatureMax)
                    .frame(width: 80)

                Text(forecast.highFormatted)
                    .dsFont(.body)
                    .frame(width: 35, alignment: .trailing)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Temperature Bar

private struct TemperatureBar: View {
    let low: Double
    let high: Double

    var body: some View {
        GeometryReader { geo in
            let minTemp: Double = -10
            let maxTemp: Double = 40
            let range = maxTemp - minTemp
            let lowPos = max(0, (low - minTemp) / range) * geo.size.width
            let highPos = min(1, (high - minTemp) / range) * geo.size.width

            ZStack(alignment: .leading) {
                Capsule().fill(.quaternary).frame(height: 6)
                Capsule()
                    .fill(LinearGradient(colors: [.cyan, .yellow, .orange], startPoint: .leading, endPoint: .trailing))
                    .frame(width: highPos - lowPos, height: 6)
                    .offset(x: lowPos)
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Forecast Loading View

private struct ForecastLoadingView: View {
    var body: some View {
        GlassCardView {
            VStack(spacing: 16) {
                ProgressView()
                Text("Loading forecast...")
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(height: 100)
        }
    }
}

// MARK: - Empty State Card

private struct WeatherEmptyStateCard: View {
    let onRefresh: () -> Void
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(spacing: 20) {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: theme.grid.iconXL))
                    .symbolRenderingMode(.multicolor)

                Text("Weather Unavailable")
                    .dsFont(.headline, weight: .bold)

                Text("Pull to refresh or check your internet connection")
                    .dsFont(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    onRefresh()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .dsFont(.headline)
                }
                .buttonStyle(.nativeGlassProminent)
            }
            .padding(.vertical, 40)
        }
    }
}

#Preview {
    WeatherView(viewModel: WeatherViewModel())
        .environment(AppDependencies())
}
