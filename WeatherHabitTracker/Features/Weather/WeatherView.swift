// WeatherView.swift
// WeatherHabitTracker

import SwiftUI

/// Main weather display with current conditions and 7-day forecast
struct WeatherView: View {
    @Bindable var viewModel: WeatherViewModel
    @State private var showInsightTooltip = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                weatherBackground
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if let weather = viewModel.currentWeather {
                            // Weather content with fade-in animation
                            weatherContent(weather)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else if viewModel.isLoading {
                            // Full-screen skeleton loading
                            SkeletonLoadingView()
                                .transition(.opacity)
                        } else {
                            emptyStateView
                                .transition(.opacity)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .animation(.spring(response: 0.4), value: viewModel.currentWeather != nil)
                }
            }
            .navigationTitle("Weather")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            #endif
            .refreshable {
                hapticFeedback(.medium)
                await viewModel.refresh()
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
    
    /// Assembled weather content sections
    @ViewBuilder
    private func weatherContent(_ weather: WeatherData) -> some View {
        currentWeatherCard(weather)
        smartInsightCard(weather)
        weatherDetailsGrid(weather)
        
        if !viewModel.forecast.isEmpty {
            forecastSection
        } else if viewModel.isForecastLoading {
            forecastLoadingView
        }
    }
    
    // MARK: - Background
    
    /// Dynamic MeshGradient background based on weather
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
    
    /// Subtle animated mesh points
    private func animatedMeshPoints(for date: Date) -> [SIMD2<Float>] {
        let time = Float(date.timeIntervalSince1970)
        let offset = sin(time * 0.1) * 0.05
        return [
            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
            [0.0, 0.5], [0.5 + offset, 0.5 - offset], [1.0, 0.5],
            [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
        ]
    }
    
    // MARK: - Current Weather
    
    /// Main weather card with glass effect
    private func currentWeatherCard(_ weather: WeatherData) -> some View {
        GlassCardView {
            VStack(spacing: 16) {
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
                
                HStack(alignment: .top, spacing: 20) {
                    Image(systemName: weather.conditionIconName)
                        .font(.system(size: 80))
                        .symbolRenderingMode(.multicolor)
                        .symbolEffect(.breathe, options: .repeating)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(weather.temperatureFormatted)
                            .font(.system(size: 72, weight: .thin, design: .rounded))
                            .contentTransition(.numericText())
                        
                        Text(weather.conditionDescription)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(weather.highLowFormatted)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                if abs(weather.temperature - weather.feelsLike) > 2 {
                    Text("Feels like \(weather.feelsLikeFormatted)")
                        .font(.subheadline)
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
    
    // MARK: - Smart Insight
    
    /// AI-style insight card with tooltip support
    private func smartInsightCard(_ weather: WeatherData) -> some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.yellow)
                        .font(.title3)
                        .symbolEffect(.pulse, options: .repeating)
                    Text("Smart Insight")
                        .font(.headline)
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            showInsightTooltip.toggle()
                        }
                        hapticFeedback(.light)
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(insightText(for: weather))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .overlay {
            if showInsightTooltip {
                FeatureTooltip(
                    title: "Smart Insights",
                    description: "Personalized suggestions based on current weather to help you plan outdoor activities and habits.",
                    icon: "sparkles",
                    isVisible: $showInsightTooltip
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
    
    private func insightText(for weather: WeatherData) -> String {
        if weather.conditionDescription.localizedCaseInsensitiveContains("rain") ||
           weather.conditionDescription.localizedCaseInsensitiveContains("drizzle") {
            return "It's raining outside. Perfect weather to focus on indoor habits like Reading or Meditation."
        } else if weather.temperature > 28 {
            return "It's quite warm! Stay hydrated and consider early morning or late evening for outdoor activities."
        } else if weather.temperature < 10 {
            return "It's chilly! Bundle up if you're heading out for a walk or run."
        } else {
            return "Great weather for outdoor activities! Try to get your steps in today."
        }
    }
    
    // MARK: - Weather Details
    
    /// Grid of weather detail cards
    private func weatherDetailsGrid(_ weather: WeatherData) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            weatherDetailCard(icon: "humidity.fill", title: "Humidity", value: "\(weather.humidity)%", color: .cyan)
            weatherDetailCard(icon: "wind", title: "Wind", value: weather.windSpeedFormatted, color: .mint)
            weatherDetailCard(icon: "sun.max.fill", title: "UV Index", value: "\(weather.uvIndex)", subtitle: uvIndexDescription(weather.uvIndex), color: .orange)
            weatherDetailCard(icon: "eye.fill", title: "Visibility", value: String(format: "%.0f km", weather.visibility), color: .purple)
            weatherDetailCard(icon: "gauge.medium", title: "Pressure", value: "\(weather.pressure) hPa", color: .indigo)
            
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
    
    /// Individual detail card
    private func weatherDetailCard(icon: String, title: String, value: String, subtitle: String? = nil, color: Color) -> some View {
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
    
    // MARK: - Forecast
    
    /// 7-day forecast list
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
                            Divider().padding(.vertical, 8)
                        }
                    }
                }
            }
        }
    }
    
    /// Single forecast row
    private func forecastRow(_ forecast: WeatherForecast) -> some View {
        HStack {
            Text(forecast.shortDayName)
                .font(.body)
                .frame(width: 60, alignment: .leading)
            
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
                Spacer().frame(width: 50)
            }
            
            Spacer()
            
            Image(systemName: forecast.conditionIconName)
                .font(.title3)
                .symbolRenderingMode(.multicolor)
                .frame(width: 40)
            
            HStack(spacing: 16) {
                Text(forecast.lowFormatted)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(width: 35, alignment: .trailing)
                
                temperatureBar(low: forecast.temperatureMin, high: forecast.temperatureMax)
                    .frame(width: 80)
                
                Text(forecast.highFormatted)
                    .font(.body)
                    .frame(width: 35, alignment: .trailing)
            }
        }
        .padding(.vertical, 4)
    }
    
    /// Temperature range visualization
    private func temperatureBar(low: Double, high: Double) -> some View {
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
    
    /// Forecast loading placeholder
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
    
    /// Shown when no weather data available
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
                    hapticFeedback(.medium)
                    Task { await viewModel.refresh() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .font(.headline)
                }
                .buttonStyle(.nativeGlassProminent)
            }
            .padding(.vertical, 40)
        }
    }
    
    // MARK: - Helpers
    
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

#Preview {
    WeatherView(viewModel: WeatherViewModel())
        .environment(AppDependencies())
}
