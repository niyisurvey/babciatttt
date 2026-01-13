// LaunchView.swift
// BabciaTobiasz

import SwiftUI

/// Entry point view with splash animation and onboarding
struct LaunchView: View {
    @State private var isAnimationComplete = false
    @State private var splashOpacity: Double = 1.0
    @State private var iconScale: CGFloat = 0.8
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.dsTheme) private var theme
    
    var body: some View {
        ZStack {
            if isAnimationComplete {
                if hasCompletedOnboarding {
                    MainTabView()
                        .transition(.opacity.combined(with: .scale(scale: 1.02)))
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        .transition(.opacity)
                }
            }
            
            if !isAnimationComplete {
                splashContent
                    .opacity(splashOpacity)
            }
        }
        .animation(theme.motion.fadeStandard, value: isAnimationComplete)
        .task { await performLaunchAnimation() }
    }
    
    private var splashContent: some View {
        ZStack {
            LinearGradient(
                colors: theme.gradients.splash,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: theme.grid.iconXL))
                        .symbolRenderingMode(.multicolor)
                        .offset(x: -20, y: -10)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: theme.grid.iconSplashSecondary))
                        .foregroundStyle(.green)
                        .offset(x: 30, y: 20)
                }
                .scaleEffect(iconScale)
                
                VStack(spacing: 8) {
                    Text("The Pierogi Protocol")
                        .dsFont(.largeTitle, weight: .bold)
                    
                    Text("Weather, areas, and bowls")
                        .dsFont(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.primary)
                    .padding(.top, 20)
            }
        }
    }
    
    private func performLaunchAnimation() async {
        try? await Task.sleep(for: .milliseconds(500))
        
        withAnimation(theme.motion.launchSpring) {
            iconScale = 1.0
        }
        
        try? await Task.sleep(for: .milliseconds(1000))
        
        withAnimation(theme.motion.fadeFast) {
            splashOpacity = 0.0
        }
        
        try? await Task.sleep(for: .milliseconds(300))
        isAnimationComplete = true
    }
}

#Preview {
    LaunchView()
        .environment(AppDependencies())
}
