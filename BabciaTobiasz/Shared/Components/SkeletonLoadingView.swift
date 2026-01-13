// SkeletonLoadingView.swift
// BabciaTobiasz

import SwiftUI

/// Full-screen skeleton loading with shimmer animation
struct SkeletonLoadingView: View {
    @State private var shimmerOffset: CGFloat = -1
    @Environment(\.dsTheme) private var theme
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
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
        VStack(spacing: 16) {
            // Location
            SkeletonBox(width: 120, height: 24)
            SkeletonBox(width: 80, height: 14)
            
            HStack(alignment: .top, spacing: 20) {
                // Icon placeholder
                SkeletonBox(width: 80, height: 80)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 8) {
                    // Temperature
                    SkeletonBox(width: 100, height: 60)
                    SkeletonBox(width: 80, height: 20)
                }
            }
            
            SkeletonBox(width: 100, height: 16)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
    
    private var insightSkeleton: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SkeletonBox(width: 24, height: 24)
                    .clipShape(Circle())
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
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(0..<6, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        SkeletonBox(width: 20, height: 20)
                            .clipShape(Circle())
                        SkeletonBox(width: 60, height: 14)
                    }
                    SkeletonBox(width: 80, height: 24)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard(padding: 12)
            }
        }
    }
    
    private var forecastSkeleton: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonBox(width: 120, height: 20)
                .padding(.horizontal, 4)
            
            VStack(spacing: 16) {
                ForEach(0..<5, id: \.self) { _ in
                    HStack {
                        SkeletonBox(width: 50, height: 16)
                        Spacer()
                        SkeletonBox(width: 30, height: 30)
                            .clipShape(Circle())
                        Spacer()
                        SkeletonBox(width: 100, height: 6)
                            .clipShape(Capsule())
                    }
                    .padding(.vertical, 4)
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
            colors: [.clear, .white.opacity(0.2), .clear],
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
            VStack(spacing: 20) {
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
        VStack(spacing: 16) {
            SkeletonBox(width: 100, height: 100)
                .clipShape(Circle())
            
            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    SkeletonBox(width: 60, height: 20)
                    SkeletonBox(width: 50, height: 12)
                }
                
                Rectangle()
                    .fill(.quaternary)
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 4) {
                    SkeletonBox(width: 60, height: 20)
                    SkeletonBox(width: 50, height: 12)
                }
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
    
    private var filterSkeleton: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { _ in
                SkeletonBox(width: nil, height: 32)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(4)
        .background(theme.glass.strength.fallbackMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
    
    private var areaRowsSkeleton: some View {
        LazyVStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { _ in
                HStack(spacing: 12) {
                    SkeletonBox(width: 44, height: 44)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 6) {
                        SkeletonBox(width: 120, height: 18)
                        SkeletonBox(width: 80, height: 14)
                    }
                    
                    Spacer()
                    
                    SkeletonBox(width: 28, height: 28)
                        .clipShape(Circle())
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
        LinearGradient(colors: [.blue.opacity(0.3), .cyan.opacity(0.3)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        SkeletonLoadingView()
    }
}

#Preview("Area Skeleton") {
    ZStack {
        LinearGradient(colors: [.green.opacity(0.3), .teal.opacity(0.3)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        AreaSkeletonLoadingView()
    }
}
