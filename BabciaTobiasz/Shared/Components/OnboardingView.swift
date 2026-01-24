// OnboardingView.swift
// BabciaTobiasz

import SwiftUI

/// First-launch onboarding with feature descriptions
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @AppStorage("primaryPersonaRaw") private var primaryPersonaRaw: String = BabciaPersona.classic.rawValue
    @AppStorage("needsFirstArea") private var needsFirstArea = false
    @AppStorage("needsFirstScan") private var needsFirstScan = false
    @AppStorage(AppIntentRoute.storageKey) private var appIntentRoute: String = AppIntentRoute.none.rawValue
    @State private var currentPage = 0
    @State private var selectedPersona = BabciaPersona.classic
    @Environment(\.dsTheme) private var theme
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "camera.fill",
            title: String(localized: "onboarding.page.weather.title"),
            description: String(localized: "onboarding.page.weather.description"),
            accentColor: DesignSystemTheme.default.palette.primary
        ),
        OnboardingPage(
            icon: "checklist",
            title: String(localized: "onboarding.page.areas.title"),
            description: String(localized: "onboarding.page.areas.description"),
            accentColor: DesignSystemTheme.default.palette.success
        ),
        OnboardingPage(
            icon: "star.fill",
            title: String(localized: "onboarding.page.insights.title"),
            description: String(localized: "onboarding.page.insights.description"),
            accentColor: DesignSystemTheme.default.palette.secondary
        ),
        OnboardingPage(
            icon: "checkmark.seal.fill",
            title: String(localized: "onboarding.page.verdict.title"),
            description: String(localized: "onboarding.page.verdict.description"),
            accentColor: DesignSystemTheme.default.palette.warning
        )
    ]
    
    var body: some View {
        let steps = onboardingSteps
        ZStack {
            // Background
            backgroundGradient
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(String(localized: "onboarding.skip")) {
                        completeOnboarding()
                    }
                    .dsFont(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(theme.palette.textSecondary)
                    .padding()
                }
                
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(steps.indices, id: \.self) { index in
                        steps[index].view
                            .tag(index)
                    }
                }
                #if !os(macOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                
                // Page indicator and button
                VStack(spacing: theme.grid.sectionSpacing + theme.grid.listSpacing) {
                    // Custom page indicator
                    HStack(spacing: theme.grid.cardPaddingTight / 1.5) {
                        ForEach(steps.indices, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? steps[currentPage].accentColor : theme.palette.textSecondary.opacity(theme.glass.glowOpacityLow))
                                .frame(width: index == currentPage ? theme.grid.buttonHorizontalPadding : theme.grid.cardPaddingTight / 1.5, height: theme.grid.cardPaddingTight / 1.5)
                                .animation(theme.motion.pressSpring, value: currentPage)
                        }
                    }
                    
                    // Action button
                    Button {
                        if currentPage < steps.count - 1 {
                            withAnimation(theme.motion.listSpring) {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        Text(currentPage < steps.count - 1
                             ? String(localized: "onboarding.continue")
                             : String(localized: "onboarding.getStarted"))
                            .dsFont(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, theme.grid.cardPadding)
                    }
                    .buttonStyle(.nativeGlassProminent)
                    .padding(.horizontal, theme.grid.sectionSpacing * 1.6)
                }
                .padding(.bottom, theme.grid.iconError)
            }
        }
        .onAppear {
            selectedPersona = BabciaPersona(rawValue: primaryPersonaRaw) ?? .classic
        }
        .onChange(of: selectedPersona) { _, newValue in
            primaryPersonaRaw = newValue.rawValue
        }
    }
    
    private var backgroundGradient: some View {
        TimelineView(.animation(minimumInterval: theme.motion.meshAnimationInterval)) { timeline in
            let steps = onboardingSteps
            MeshGradient(
                width: 3,
                height: 3,
                points: animatedMeshPoints(for: timeline.date),
                colors: [
                    steps[currentPage].accentColor.opacity(theme.elevation.shimmerOpacity),
                    theme.palette.primary.opacity(theme.elevation.shimmerOpacity / 1.5),
                    steps[currentPage].accentColor.opacity(theme.elevation.shimmerOpacity / 1.5),
                    theme.palette.secondary.opacity(theme.elevation.shimmerOpacity / 2),
                    steps[currentPage].accentColor.opacity(theme.elevation.shimmerOpacity / 2),
                    theme.palette.tertiary.opacity(theme.elevation.shimmerOpacity / 1.5),
                    theme.palette.primary.opacity(theme.elevation.shimmerOpacity / 1.5),
                    theme.palette.secondary.opacity(theme.elevation.shimmerOpacity / 2),
                    steps[currentPage].accentColor.opacity(theme.elevation.shimmerOpacity * 0.8)
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
            primaryPersonaRaw = selectedPersona.rawValue
            needsFirstArea = true
            needsFirstScan = true
            hasCompletedOnboarding = true
        }
        appIntentRoute = AppIntentRoute.areas.rawValue
        // Haptic feedback
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }

    private var onboardingSteps: [OnboardingStep] {
        let pageSteps = pages.map { page in
            OnboardingStep(
                accentColor: page.accentColor,
                view: AnyView(OnboardingPageView(page: page))
            )
        }
        let personaStep = OnboardingStep(
            accentColor: theme.palette.warmAccent,
            view: AnyView(BabciaPersonaSelectionView(selectedPersona: $selectedPersona))
        )
        var steps = pageSteps + [personaStep]

        if AppConfigService.shared.tutorialShowCameraSetup {
            steps.append(
                OnboardingStep(
                    accentColor: theme.palette.primary,
                    view: AnyView(OnboardingCameraSetupStepView())
                )
            )
        }

        if AppConfigService.shared.tutorialShowThemeSelection {
            steps.append(
                OnboardingStep(
                    accentColor: theme.palette.tertiary,
                    view: AnyView(OnboardingThemeSelectionStepView())
                )
            )
        }

        return steps
    }
}

// MARK: - Step Model

struct OnboardingStep: Identifiable {
    let id = UUID()
    let accentColor: Color
    let view: AnyView
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
        VStack(spacing: theme.grid.iconSplashSecondary) {
            Spacer()
            
            SparkleIconView(
                systemName: page.icon,
                size: theme.grid.iconXXL,
                color: page.accentColor,
                sparkleColor: page.accentColor
            )
            
            // Text content
            VStack(spacing: theme.grid.cardPadding) {
                Text(page.title)
                    .dsFont(.title, weight: .bold)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .dsFont(.body)
                    .foregroundStyle(theme.palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, theme.grid.buttonHorizontalPadding * 1.33)
            }
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
