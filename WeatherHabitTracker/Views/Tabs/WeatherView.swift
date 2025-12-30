//
//  WeatherView.swift
//  WeatherHabitTracker
//
//  The main weather display view showing current conditions and 7-day forecast.
//  Uses Apple's Liquid Glass design with glassMaterial backgrounds and effects.
//

import SwiftUI

/// The weather tab view displaying current weather and forecast.
/// Features Liquid Glass design elements and modern SwiftUI patterns.
struct WeatherView: View {
    
    // MARK: - Properties
    
    @Bindable var viewModel: WeatherViewModel
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Weather Section
                    if let weather = viewModel.currentWeather {
                        currentWeatherCard(weather)
                    } else if viewModel.isLoading {
                        LoadingIndicatorView(message: "Loading weather...")
                            .frame(height: 300)
                    } else {
                        emptyStateView
                    }
                    
                    // Weather Details Section
                    if let weather = viewModel.currentWeather {
                        weatherDetailsGrid(weather)
                    }
                    
                    // Forecast Section
                    if !viewModel.forecast.isEmpty {
                        forecastSection
                    } else if viewModel.isForecastLoading {
                        forecastLoadingView
                    }
                }
                .padding()
            }
            .background(weatherBackground)
            .navigationTitle("Weather")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                if viewModel.needsRefresh {
                    await viewModel.refresh()
                }
            }
            .alert("Weather Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.dismissError()
                }
                Button("Retry") {
                    Task {
                        await viewModel.refresh()
                    }
                }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }
    
    // MARK: - Background
    
    /// Dynamic gradient background based on weather conditions using MeshGradient
    private var weatherBackground: some View {
        TimelineView(.animation(minimumInterval: 3)) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: animatedMeshPoints(for: timeline.date),
                colors: viewModel.backgroundColors + viewModel.backgroundColors.suffix(from: max(0, viewModel.backgroundColors.count - 3))
            )
        }
        .ignoresSafeArea()
    }
    
    /// Animated mesh points for subtle background movement
    private func animatedMeshPoints(for date: Date) -> [SIMD2<Float>] {
        let time = Float(date.timeIntervalSince1970)
        let offset = sin(time * 0.1) * 0.05
        return [
            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
            [0.0, 0.5], [0.5 + offset, 0.5 - offset], [1.0, 0.5],
            [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
        ]
    }
    
    // MARK: - Current Weather Card
    
    /// Main weather display card with Liquid Glass effect
    /// - Parameter weather: The current weather data to display
    private func currentWeatherCard(_ weather: WeatherData) -> some View {
        GlassCardView {
            VStack(spacing: 16) {
                // Location and time
                VStack(spacing: 4) {
                    Text(weather.locationName)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if let lastRefresh = viewModel.lastRefreshFormatted {
                        Text(lastRefresh)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Main temperature display
                HStack(alignment: .top, spacing: 20) {
                    // Weather icon
                    Image(systemName: weather.conditionIconName)
                        .font(.system(size: 80))
                        .symbolRenderingMode(.multicolor)
                    
                    // Temperature
                    VStack(alignment: .leading, spacing: 4) {
                        Text(weather.temperatureFormatted)
                            .font(.system(size: 72, weight: .thin, design: .rounded))
                        
                        Text(weather.conditionDescription)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // High/Low temperatures
                Text(weather.highLowFormatted)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                // Feels like
                if abs(weather.temperature - weather.feelsLike) > 2 {
                    Text("Feels like \(weather.feelsLikeFormatted)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 20)
        }
    }
    
    // MARK: - Weather Details Grid
    
    /// Grid showing detailed weather information
    /// - Parameter weather: The weather data to display
    private func weatherDetailsGrid(_ weather: WeatherData) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            // Humidity
            weatherDetailCard(
                icon: "humidity.fill",
                title: "Humidity",
                value: "\(weather.humidity)%",
                color: .cyan
            )
            
            // Wind
            weatherDetailCard(
                icon: "wind",
                title: "Wind",
                value: weather.windSpeedFormatted,
                color: .mint
            )
            
            // UV Index
            weatherDetailCard(
                icon: "sun.max.fill",
                title: "UV Index",
                value: "\(weather.uvIndex)",
                subtitle: uvIndexDescription(weather.uvIndex),
                color: .orange
            )
            
            // Visibility
            weatherDetailCard(
                icon: "eye.fill",
                title: "Visibility",
                value: String(format: "%.0f km", weather.visibility),
                color: .purple
            )
            
            // Pressure
            weatherDetailCard(
                icon: "gauge.medium",
                title: "Pressure",
                value: "\(weather.pressure) hPa",
                color: .indigo
            )
            
            // Sunrise/Sunset
            if let sunrise = weather.sunrise, let sunset = weather.sunset {
                weatherDetailCard(
                    icon: isDaytime(sunrise: sunrise, sunset: sunset) ? "sunset.fill" : "sunrise.fill",
                    title: isDaytime(sunrise: sunrise, sunset: sunset) ? "Sunset" : "Sunrise",
                    value: formatTime(isDaytime(sunrise: sunrise, sunset: sunset) ? sunset : sunrise),
                    color: .yellow
                )
            }
        }
    }
    
    /// Individual weather detail card with glass effect
    private func weatherDetailCard(
        icon: String,
        title: String,
        value: String,
        subtitle: String? = nil,
        color: Color
    ) -> some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.headline)
                        .foregroundStyle(color)
                    
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Forecast Section
    
    /// 7-day forecast section with horizontal scroll
    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7-Day Forecast")
                .font(.headline)
                .padding(.horizontal, 4)
            
            GlassCardView {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.forecast.enumerated()), id: \.element.id) { index, forecast in
                        forecastRow(forecast)
                        
                        if index < viewModel.forecast.count - 1 {
                            Divider()
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
    }
    
    /// Individual forecast row
    /// - Parameter forecast: The forecast data to display
    private func forecastRow(_ forecast: WeatherForecast) -> some View {
        HStack {
            // Day name
            Text(forecast.shortDayName)
                .font(.body)
                .frame(width: 60, alignment: .leading)
            
            // Precipitation probability
            if forecast.precipitationProbability > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                    Text(forecast.precipitationFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 50)
            } else {
                Spacer()
                    .frame(width: 50)
            }
            
            Spacer()
            
            // Weather icon
            Image(systemName: forecast.conditionIconName)
                .font(.title3)
                .symbolRenderingMode(.multicolor)
                .frame(width: 40)
            
            // Temperature range
            HStack(spacing: 16) {
                Text(forecast.lowFormatted)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(width: 35, alignment: .trailing)
                
                // Temperature bar
                temperatureBar(low: forecast.temperatureMin, high: forecast.temperatureMax)
                    .frame(width: 80)
                
                Text(forecast.highFormatted)
                    .font(.body)
                    .frame(width: 35, alignment: .trailing)
            }
        }
        .padding(.vertical, 4)
    }
    
    /// Visual temperature range bar
    private func temperatureBar(low: Double, high: Double) -> some View {
        GeometryReader { geometry in
            let minTemp: Double = -10
            let maxTemp: Double = 40
            let range = maxTemp - minTemp
            
            let lowPosition = max(0, (low - minTemp) / range) * geometry.size.width
            let highPosition = min(1, (high - minTemp) / range) * geometry.size.width
            
            ZStack(alignment: .leading) {
                // Background
                Capsule()
                    .fill(.quaternary)
                    .frame(height: 6)
                
                // Temperature range
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: highPosition - lowPosition, height: 6)
                    .offset(x: lowPosition)
            }
        }
        .frame(height: 6)
    }
    
    /// Loading view for forecast
    private var forecastLoadingView: some View {
        GlassCardView {
            VStack(spacing: 16) {
                ProgressView()
                Text("Loading forecast...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(height: 100)
        }
    }
    
    // MARK: - Empty State
    
    /// Empty state when no weather data is available
    private var emptyStateView: some View {
        GlassCardView {
            VStack(spacing: 20) {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 60))
                    .symbolRenderingMode(.multicolor)
                
                Text("Weather Unavailable")
                    .font(.headline)
                
                Text("Pull to refresh or check your internet connection")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    Task {
                        await viewModel.refresh()
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 40)
        }
    }
    
    // MARK: - Helper Functions
    
    /// Returns UV index description
    private func uvIndexDescription(_ index: Int) -> String {
        switch index {
        case 0...2: return "Low"
        case 3...5: return "Moderate"
        case 6...7: return "High"
        case 8...10: return "Very High"
        default: return "Extreme"
        }
    }
    
    /// Checks if it's currently daytime
    private func isDaytime(sunrise: Date, sunset: Date) -> Bool {
        let now = Date()
        return now > sunrise && now < sunset
    }
    
    /// Formats a date as time string
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    WeatherView(viewModel: WeatherViewModel())
        .environment(AppDependencies())
}
