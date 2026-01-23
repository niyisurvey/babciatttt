// ScalingHeaderScrollView.swift
// BabciaTobiasz

import SwiftUI

private let scalingHeaderScrollSpace = "ScalingHeaderScrollView"

private struct ScalingHeaderScrollOffsetKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct ScalingHeaderScrollOffsetReader: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: ScalingHeaderScrollOffsetKey.self, value: proxy.frame(in: .named(scalingHeaderScrollSpace)).minY)
        }
    }
}

struct ScalingHeaderScrollView<Header: View, Content: View>: View {
    enum SnapMode {
        case none
        case immediately
        case afterAcceleration
    }

    let maxHeight: CGFloat
    let minHeight: CGFloat
    let snapMode: SnapMode
    @Binding var progress: CGFloat
    let onRefresh: (() async -> Void)?
    let header: (CGFloat) -> Header
    let content: () -> Content

    @State private var scrollOffset: CGFloat = 0

    init(
        maxHeight: CGFloat,
        minHeight: CGFloat,
        snapMode: SnapMode = .none,
        progress: Binding<CGFloat>,
        onRefresh: (() async -> Void)? = nil,
        @ViewBuilder header: @escaping (CGFloat) -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.maxHeight = maxHeight
        self.minHeight = minHeight
        self.snapMode = snapMode
        self._progress = progress
        self.onRefresh = onRefresh
        self.header = header
        self.content = content
    }

    var body: some View {
        ScrollViewReader { proxy in
            scrollView
                .simultaneousGesture(
                    DragGesture().onEnded { _ in
                        snapIfNeeded(using: proxy)
                    }
                )
        }
    }

    @ViewBuilder
    private var scrollView: some View {
        let scrollContent = ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerContainer
                content()
            }
        }
        .scrollClipDisabled()
        .   coordinateSpace(name: scalingHeaderScrollSpace)
        .onPreferenceChange(ScalingHeaderScrollOffsetKey.self) { offset in
            scrollOffset = offset
            let range = max(maxHeight - minHeight, 1)
            let rawProgress = min(max(-offset / range, 0), 1)
            if progress != rawProgress {
                progress = rawProgress
            }
        }
        
        #if compiler(>=6.0)
        if #available(iOS 26.0, *) {
            let base = scrollContent.scrollEdgeEffectHidden(true, for: .top)
            if let onRefresh {
                base.refreshable { await onRefresh() }
            } else {
                base
            }
        } else {
            if let onRefresh {
                scrollContent.refreshable { await onRefresh() }
            } else {
                scrollContent
            }
        }
        #else
        if let onRefresh {
            scrollContent.refreshable { await onRefresh() }
        } else {
            scrollContent
        }
        #endif
    }



    private var headerContainer: some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named(scalingHeaderScrollSpace)).minY
            let range = max(maxHeight - minHeight, 1)
            let collapse = min(max(-minY / range, 0), 1)
            let stretch = max(minY, 0)
            let height = maxHeight + stretch
            let stretchScale = 1 + min(stretch / max(maxHeight, 1), 0.35)
            let offset: CGFloat = minY > 0 ? -minY : 0

            ZStack(alignment: .top) {
                header(collapse)
                    .frame(height: height)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(stretchScale, anchor: .top)
                    .offset(y: offset)

                Color.clear
                    .frame(height: 1)
                    .id(Anchor.expanded)

                Color.clear
                    .frame(height: 1)
                    .offset(y: collapseRange)
                    .id(Anchor.collapsed)
            }
            .background(
                Color.clear
                    .preference(key: ScalingHeaderScrollOffsetKey.self, value: minY)
            )
        }
        .frame(height: maxHeight)
    }

    private var collapseRange: CGFloat {
        max(maxHeight - minHeight, 0)
    }

    private func snapIfNeeded(using proxy: ScrollViewProxy) {
        guard snapMode != .none else { return }
        let range = max(maxHeight - minHeight, 1)
        let shouldCollapse = (-scrollOffset) > range * 0.5
        let target: Anchor = shouldCollapse ? .collapsed : .expanded
        let snap = {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(target, anchor: .top)
            }
        }

        switch snapMode {
        case .none:
            break
        case .immediately:
            snap()
        case .afterAcceleration:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                snap()
            }
        }
    }

    private enum Anchor: String {
        case expanded
        case collapsed
    }

}
