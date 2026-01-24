//
//  PierogiDropView.swift
//  BabciaTobiasz
//
//  Verification tier reveal ceremony with draggable pierogis.
//

import SwiftUI

struct PierogiDropView: View {
    let tier: BowlVerificationTier
    let autoReveal: Bool
    let onComplete: (BowlVerificationTier) -> Void

    @Environment(\.dsTheme) private var theme
    @State private var pierogis: [PierogiDropItem] = []
    @State private var droppedCount = 0
    @State private var isFloating = false
    @State private var showBoil = false
    @State private var showReveal = false
    @State private var hasCompleted = false
    @State private var hasAutoDropped = false

    private let pierogiCount = 5
    private enum PierogiAsset {
        static let normal = "Pierogi_Clay_Normal"
        static let golden = "Pierogi_Clay_Golden"
        static let bowlNatural = "Bowl_Clay_Natural"
        static let bowlBlue = "Bowl_Clay_Blue"
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let safeInsets = proxy.safeAreaInsets
            let potCenter = CGPoint(x: size.width / 2, y: size.height / 2)
            let dropRadius = (theme.grid.pierogiPotSize / 2) + theme.grid.cardPaddingTight

            ZStack {
                LiquidGlassBackground(style: .default)

                VStack(spacing: theme.grid.sectionSpacing) {
                    VStack(spacing: theme.grid.cardPaddingTight) {
                        Text(String(localized: autoReveal ? "pierogiDrop.reveal.title" : "pierogiDrop.title"))
                            .dsFont(.title2, weight: .bold)
                        Text(String(localized: autoReveal ? "pierogiDrop.reveal.subtitle" : "pierogiDrop.subtitle"))
                            .dsFont(.subheadline)
                            .foregroundStyle(theme.palette.textSecondary)
                        if !autoReveal {
                            Text(
                                String(
                                    format: String(localized: "pierogiDrop.progress"),
                                    droppedCount,
                                    pierogiCount
                                )
                            )
                            .dsFont(.caption)
                            .foregroundStyle(theme.palette.textSecondary)
                        }
                    }
                    .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, safeInsets.top + theme.grid.sectionSpacing)
                .padding(.horizontal, theme.grid.cardPadding)

                potView(center: potCenter)

                ForEach(pierogis) { item in
                    pierogiView(
                        item,
                        center: potCenter,
                        dropRadius: dropRadius,
                        container: size,
                        safeInsets: safeInsets
                    )
                }
            }
            .coordinateSpace(name: "PierogiDrop")
            .onAppear {
                if pierogis.count != pierogiCount {
                    pierogis = makePierogis(in: size, safeInsets: safeInsets, center: potCenter, dropRadius: dropRadius)
                }
                withAnimation(theme.motion.fadeStandard.repeatForever(autoreverses: true)) {
                    isFloating = true
                }
                if autoReveal && !hasAutoDropped {
                    hasAutoDropped = true
                    Task { @MainActor in
                        await autoDropSequence(center: potCenter)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    private func potView(center: CGPoint) -> some View {
        let baseSize = theme.grid.pierogiPotSize
        let growth = CGFloat(droppedCount) * (theme.grid.pierogiPotGrowStep / theme.grid.pierogiPotSize)
        let scale = 1 + growth
        let glowColor = tierGlowColor

        return ZStack {
            Image(potAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: baseSize, height: baseSize)
                .shadow(color: theme.palette.glassTint.opacity(0.2), radius: theme.grid.iconSmall, x: 0, y: theme.grid.iconSmall / 2)

            if showBoil {
                boilEffect(color: glowColor)
            }

            if showReveal {
                RoundedRectangle(cornerRadius: theme.shape.controlCornerRadius, style: .continuous)
                    .stroke(glowColor, lineWidth: theme.grid.iconTiny)
                    .frame(width: baseSize + theme.grid.iconLarge, height: baseSize + theme.grid.iconLarge)
                    .shadow(color: glowColor.opacity(theme.glass.glowOpacityHigh), radius: theme.grid.iconMedium)

                TierBadgeView(tier: tier)
            }
        }
        .scaleEffect(scale)
        .position(center)
        .animation(theme.motion.listSpring, value: droppedCount)
        .animation(theme.motion.fadeStandard, value: showReveal)
    }

    private func boilEffect(color: Color) -> some View {
        let pulseRatio = theme.grid.pierogiPotGrowStep / theme.grid.pierogiPotSize
        return RoundedRectangle(cornerRadius: theme.shape.controlCornerRadius, style: .continuous)
            .stroke(color.opacity(theme.glass.glowOpacityHigh), lineWidth: theme.grid.iconTiny)
            .frame(width: theme.grid.pierogiPotSize + theme.grid.iconXL, height: theme.grid.pierogiPotSize + theme.grid.iconXL)
            .scaleEffect(showBoil ? 1 + pulseRatio : 1 - pulseRatio)
            .opacity(showBoil ? theme.glass.glowOpacityHigh : theme.glass.glowOpacityLow)
            .animation(
                theme.motion.fadeStandard.repeatForever(autoreverses: true),
                value: showBoil
            )
    }

    private func pierogiView(
        _ item: PierogiDropItem,
        center: CGPoint,
        dropRadius: CGFloat,
        container: CGSize,
        safeInsets: EdgeInsets
    ) -> some View {
        let floatOffset = floatingOffset(for: item)
        return Image(pierogiAssetName)
            .resizable()
            .scaledToFit()
            .frame(width: theme.grid.pierogiSize, height: theme.grid.pierogiSize)
            .position(item.position)
            .offset(item.isDropped ? .zero : floatOffset)
            .opacity(item.isDropped ? 0 : 1)
            .animation(theme.motion.fadeStandard, value: isFloating)
            .animation(theme.motion.fadeStandard, value: item.isDropped)
            .gesture((item.isDropped || autoReveal) ? nil : dragGesture(for: item, center: center, dropRadius: dropRadius, container: container, safeInsets: safeInsets))
    }

    private func dragGesture(
        for item: PierogiDropItem,
        center: CGPoint,
        dropRadius: CGFloat,
        container: CGSize,
        safeInsets: EdgeInsets
    ) -> some Gesture {
        DragGesture(minimumDistance: theme.grid.buttonVerticalPadding, coordinateSpace: .named("PierogiDrop"))
            .onChanged { value in
                updatePierogi(item.id) { pierogi in
                    pierogi.position = clampedPosition(value.location, container: container, safeInsets: safeInsets)
                }
            }
            .onEnded { _ in
                let currentPosition = pierogis.first(where: { $0.id == item.id })?.position ?? item.position
                let distance = hypot(currentPosition.x - center.x, currentPosition.y - center.y)
                if distance <= dropRadius {
                    dropPierogi(item.id, at: center)
                } else {
                    withAnimation(theme.motion.listSpring) {
                        updatePierogi(item.id) { pierogi in
                            pierogi.position = clampedPosition(currentPosition, container: container, safeInsets: safeInsets)
                        }
                    }
                }
            }
    }

    private func dropPierogi(_ id: UUID, at center: CGPoint) {
        withAnimation(theme.motion.pressSpring) {
            updatePierogi(id) { pierogi in
                pierogi.position = center
                pierogi.isDropped = true
            }
        }
        updateDroppedCount()
    }

    private func updateDroppedCount() {
        droppedCount = pierogis.filter(\.isDropped).count
        if droppedCount == pierogiCount && !hasCompleted {
            hasCompleted = true
            beginRevealSequence()
        }
    }

    private func beginRevealSequence() {
        showBoil = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(theme.motion.shimmerDuration))
            withAnimation(theme.motion.fadeStandard) {
                showReveal = true
            }
            hapticFeedback(tier == .golden ? .success : .medium)
            try? await Task.sleep(for: .seconds(theme.motion.shimmerDuration))
            onComplete(tier)
        }
    }

    private var potAssetName: String {
        tier == .blue ? PierogiAsset.bowlBlue : PierogiAsset.bowlNatural
    }

    private var pierogiAssetName: String {
        tier == .golden ? PierogiAsset.golden : PierogiAsset.normal
    }

    @MainActor
    private func autoDropSequence(center: CGPoint) async {
        let ids = pierogis.map(\.id)
        for id in ids {
            withAnimation(theme.motion.pressSpring) {
                updatePierogi(id) { pierogi in
                    pierogi.position = center
                    pierogi.isDropped = true
                }
            }
            updateDroppedCount()
            hapticFeedback(.light)
            try? await Task.sleep(for: .seconds(0.12))
        }
    }

    private func makePierogis(
        in size: CGSize,
        safeInsets: EdgeInsets,
        center: CGPoint,
        dropRadius: CGFloat
    ) -> [PierogiDropItem] {
        var items: [PierogiDropItem] = []
        for _ in 0..<pierogiCount {
            let position = randomPosition(in: size, safeInsets: safeInsets, center: center, dropRadius: dropRadius)
            let floatOffset = CGSize(
                width: theme.grid.iconTiny * CGFloat.random(in: -1...1),
                height: theme.grid.iconTiny * CGFloat.random(in: -1...1)
            )
            items.append(PierogiDropItem(position: position, floatOffset: floatOffset))
        }
        return items
    }

    private func randomPosition(
        in size: CGSize,
        safeInsets: EdgeInsets,
        center: CGPoint,
        dropRadius: CGFloat
    ) -> CGPoint {
        let inset = theme.grid.cardPadding
        let minX = safeInsets.leading + inset + theme.grid.pierogiSize / 2
        let maxX = size.width - safeInsets.trailing - inset - theme.grid.pierogiSize / 2
        let minY = safeInsets.top + inset + theme.grid.pierogiSize / 2
        let maxY = size.height - safeInsets.bottom - inset - theme.grid.pierogiSize / 2

        var attempt = CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )

        var tries = 0
        while hypot(attempt.x - center.x, attempt.y - center.y) < dropRadius + theme.grid.pierogiSize,
              tries < pierogiCount * 2 {
            attempt = CGPoint(
                x: CGFloat.random(in: minX...maxX),
                y: CGFloat.random(in: minY...maxY)
            )
            tries += 1
        }
        return attempt
    }

    private func clampedPosition(_ position: CGPoint, container: CGSize, safeInsets: EdgeInsets) -> CGPoint {
        let inset = theme.grid.cardPadding
        let minX = safeInsets.leading + inset + theme.grid.pierogiSize / 2
        let maxX = container.width - safeInsets.trailing - inset - theme.grid.pierogiSize / 2
        let minY = safeInsets.top + inset + theme.grid.pierogiSize / 2
        let maxY = container.height - safeInsets.bottom - inset - theme.grid.pierogiSize / 2
        return CGPoint(
            x: min(max(position.x, minX), maxX),
            y: min(max(position.y, minY), maxY)
        )
    }

    private func floatingOffset(for item: PierogiDropItem) -> CGSize {
        guard isFloating else { return .zero }
        return item.floatOffset
    }

    private func updatePierogi(_ id: UUID, update: (inout PierogiDropItem) -> Void) {
        guard let index = pierogis.firstIndex(where: { $0.id == id }) else { return }
        update(&pierogis[index])
    }

    private var tierGlowColor: Color {
        tier == .golden ? theme.palette.warmAccent : theme.palette.tertiary
    }
}

private struct PierogiDropItem: Identifiable {
    let id: UUID
    var position: CGPoint
    var isDropped: Bool
    let floatOffset: CGSize

    init(position: CGPoint, floatOffset: CGSize) {
        self.id = UUID()
        self.position = position
        self.isDropped = false
        self.floatOffset = floatOffset
    }
}

private struct TierBadgeView: View {
    let tier: BowlVerificationTier
    @Environment(\.dsTheme) private var theme

    private var title: String {
        tier == .golden
            ? String(localized: "pierogiDrop.tier.golden")
            : String(localized: "pierogiDrop.tier.blue")
    }

    private var tint: Color {
        tier == .golden ? theme.palette.warmAccent : theme.palette.tertiary
    }

    var body: some View {
        Text(title)
            .dsFont(.headline, weight: .bold)
            .foregroundStyle(tint)
            .padding(.horizontal, theme.grid.cardPadding)
            .padding(.vertical, theme.grid.cardPaddingTight)
            .background(.ultraThinMaterial, in: Capsule())
    }
}

#Preview {
    PierogiDropView(tier: .blue, autoReveal: false, onComplete: { _ in })
        .dsTheme(.default)
}
