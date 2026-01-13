// OnboardingView.swift
// BabciaTobiasz

import SwiftUI

/// First-launch onboarding with feature descriptions
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @Environment(\.dsTheme) private var theme
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "cloud.sun.fill",
            title: "Weather at a Glance",
            description: "Get real-time weather updates with beautiful visuals. Know what's coming so you can plan your day.",
            accentColor: .blue
        ),
        OnboardingPage(
            icon: "checklist",
            title: "Areas & Bowls",
            description: "Name your areas, start a bowl, and get up to five tasks to finish.",
            accentColor: .green
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "Smart Insights",
            description: "Get personalized suggestions based on weather to plan your day.",
            accentColor: .purple
        ),
        OnboardingPage(
            icon: "checkmark.seal.fill",
            title: "Babcia's Verdict",
            description: "Request verification and earn Blue or Golden totals for completed bowls.",
            accentColor: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .dsFont(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding()
                }
                
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                #if !os(macOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                
                // Page indicator and button
                VStack(spacing: 30) {
                    // Custom page indicator
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? pages[currentPage].accentColor : .secondary.opacity(0.3))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(theme.motion.pressSpring, value: currentPage)
                        }
                    }
                    
                    // Action button
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation(theme.motion.listSpring) {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                            .dsFont(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.nativeGlassProminent)
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    private var backgroundGradient: some View {
        TimelineView(.animation(minimumInterval: theme.motion.meshAnimationInterval)) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: animatedMeshPoints(for: timeline.date),
                colors: [
                    pages[currentPage].accentColor.opacity(0.3),
                    theme.palette.primary.opacity(0.2),
                    pages[currentPage].accentColor.opacity(0.2),
                    theme.palette.secondary.opacity(0.15),
                    pages[currentPage].accentColor.opacity(0.15),
                    theme.palette.tertiary.opacity(0.2),
                    theme.palette.primary.opacity(0.2),
                    theme.palette.secondary.opacity(0.15),
                    pages[currentPage].accentColor.opacity(0.25)
                ]
            )
        }
        .ignoresSafeArea()
        .animation(theme.motion.fadeStandard, value: currentPage)
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
    
    private func completeOnboarding() {
        withAnimation(theme.motion.listSpring) {
            hasCompletedOnboarding = true
        }
        // Haptic feedback
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }
}

// MARK: - Data Model

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
}

// MARK: - Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    @Environment(\.dsTheme) private var theme
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                Image(systemName: page.icon)
                    .font(.system(size: theme.grid.iconXL))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(page.accentColor)
            }
            .liquidGlass(cornerRadius: theme.shape.heroCornerRadius)
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .dsFont(.title, weight: .bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .dsFont(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
