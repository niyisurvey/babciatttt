// SkeletonLoadingView.swift
// BabciaTobiasz

import SwiftUI

/// Full-screen skeleton loading with shimmer animation
struct SkeletonLoadingView: View {
    @State private var shimmerOffset: CGFloat = -1
    @Environment(\.dsTheme) private var theme
    
    var body: some View {
        ScrollView(showsIndicators: false) {
        VStack(spacing: theme.grid.sectionSpacing) {
                // Weather card skeleton
                weatherCardSkeleton
                
                // Insight skeleton
                insightSkeleton
                
                // Details grid skeleton
                detailsGridSkeleton
                
                // Forecast skeleton
                forecastSkeleton
            }
            .padding()
        }
        .onAppear { startShimmer() }
    }
    
    // MARK: - Weather Card Skeleton
    
    private var weatherCardSkeleton: some View {
        VStack(spacing: theme.grid.cardPadding) {
            // Location
            SkeletonBox(width: 120, height: 24)
            SkeletonBox(width: 80, height: 14)
            
            HStack(alignment: .top, spacing: theme.grid.sectionSpacing) {
                // Icon placeholder
                SkeletonBox(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius, style: .continuous))
                
                VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                    // Temperature
                    SkeletonBox(width: 100, height: 60)
                    SkeletonBox(width: 80, height: 20)
                }
            }
            
            SkeletonBox(width: 100, height: 16)
        }
        .padding(.vertical, theme.grid.sectionSpacing)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
    
    private var insightSkeleton: some View {
        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
            HStack {
                SkeletonBox(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius / 2, style: .continuous))
                SkeletonBox(width: 100, height: 18)
                Spacer()
            }
            SkeletonBox(width: .infinity, height: 40)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
    
    private var detailsGridSkeleton: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: theme.grid.cardPadding) {
            ForEach(0..<6, id: \.self) { _ in
                VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                    HStack {
                        SkeletonBox(width: 20, height: 20)
                            .clipShape(RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius / 2, style: .continuous))
                        SkeletonBox(width: 60, height: 14)
                    }
                    SkeletonBox(width: 80, height: 24)
                }
                .padding(.vertical, theme.grid.listSpacing)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard(padding: 12)
            }
        }
    }
    
    private var forecastSkeleton: some View {
        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
            SkeletonBox(width: 120, height: 20)
                .padding(.horizontal, theme.grid.cardPaddingTight / 3)
            
            VStack(spacing: theme.grid.cardPadding) {
                ForEach(0..<5, id: \.self) { _ in
                    HStack {
                        SkeletonBox(width: 50, height: 16)
                        Spacer()
                        SkeletonBox(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius / 2, style: .continuous))
                        Spacer()
                        SkeletonBox(width: 100, height: 6)
                            .clipShape(Capsule())
                    }
                    .padding(.vertical, theme.grid.cardPaddingTight / 3)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .glassCard()
        }
    }
    
    private func startShimmer() {
        withAnimation(.linear(duration: theme.motion.shimmerLongDuration).repeatForever(autoreverses: false)) {
            shimmerOffset = 1
        }
    }
}

/// Individual skeleton box with shimmer effect
struct SkeletonBox: View {
    var width: CGFloat?
    var height: CGFloat
    
    @State private var phase: CGFloat = 0
    @Environment(\.dsTheme) private var theme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.quaternary)
            .frame(width: width, height: height)
            .frame(maxWidth: width == .infinity ? .infinity : nil)
            .overlay {
                GeometryReader { geo in
                    shimmerGradient
                        .frame(width: geo.size.width * 2)
                        .offset(x: -geo.size.width + (phase * geo.size.width * 2))
                }
                .clipped()
            }
            .onAppear {
                withAnimation(.linear(duration: theme.motion.shimmerDuration).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
    
    private var shimmerGradient: some View {
        LinearGradient(
            colors: [.clear, theme.palette.onPrimary.opacity(theme.elevation.shimmerOpacity), .clear],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Area Skeleton

struct AreaSkeletonLoadingView: View {
    @Environment(\.dsTheme) private var theme
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: theme.grid.sectionSpacing) {
                // Stats skeleton
                statsCardSkeleton
                
                // Filter skeleton
                filterSkeleton
                
                // Area rows skeleton
                areaRowsSkeleton
            }
            .padding()
        }
    }
    
    private var statsCardSkeleton: some View {
        VStack(spacing: theme.grid.cardPadding) {
            SkeletonBox(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius, style: .continuous))
            
            HStack(spacing: 30) {
                VStack(spacing: theme.grid.cardPaddingTight / 3) {
                    SkeletonBox(width: 60, height: 20)
                    SkeletonBox(width: 50, height: 12)
                }
                
                Rectangle()
                    .fill(.quaternary)
                    .frame(width: 1, height: 40)
                
                VStack(spacing: theme.grid.cardPaddingTight / 3) {
                    SkeletonBox(width: 60, height: 20)
                    SkeletonBox(width: 50, height: 12)
                }
            }
        }
        .padding(.vertical, theme.grid.cardPaddingTight)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
    
    private var filterSkeleton: some View {
        HStack(spacing: theme.grid.listSpacing) {
            ForEach(0..<3, id: \.self) { _ in
                SkeletonBox(width: nil, height: 32)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(theme.grid.cardPaddingTight / 3)
        .background(theme.glass.strength.fallbackMaterial, in: RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius / 1.5))
    }
    
    private var areaRowsSkeleton: some View {
        LazyVStack(spacing: theme.grid.listSpacing) {
            ForEach(0..<4, id: \.self) { _ in
                HStack(spacing: theme.grid.listSpacing) {
                    SkeletonBox(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius / 1.2, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: theme.grid.cardPaddingTight / 2) {
                        SkeletonBox(width: 120, height: 18)
                        SkeletonBox(width: 80, height: 14)
                    }
                    
                    Spacer()
                    
                    SkeletonBox(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius / 1.5, style: .continuous))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()
            }
        }
    }
}

#Preview("Weather Skeleton") {
    ZStack {
        let theme = DesignSystemTheme.default
        LinearGradient(colors: [theme.palette.primary.opacity(theme.elevation.overlayDim), theme.palette.tertiary.opacity(theme.elevation.overlayDim)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        SkeletonLoadingView()
    }
}

#Preview("Area Skeleton") {
    ZStack {
        let theme = DesignSystemTheme.default
        LinearGradient(colors: [theme.palette.success.opacity(theme.elevation.overlayDim), theme.palette.coolAccent.opacity(theme.elevation.overlayDim)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        AreaSkeletonLoadingView()
    }
}
