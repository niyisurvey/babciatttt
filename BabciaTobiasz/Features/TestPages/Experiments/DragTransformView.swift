import SwiftUI

/// Drag Transform / Docking (adapted from mikelikesdesign)
/// A draggable container that transforms and docks to screen edges
struct DragTransformView: View {
    @State private var position = CGPoint(x: 200, y: 400)
    @State private var isDragging = false
    @State private var dockedEdge: EdgeType = .bottom
    @State private var containerSize = CGSize(width: 300, height: 80)
    @Namespace private var iconNamespace
    
    let icons = ["plus", "heart.fill", "star.fill", "camera.fill"]
    
    enum EdgeType {
        case bottom, leading, trailing
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("🔄 Drag Transform")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.top, 60)
                    Text("Move the bar to the edges")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                
                // Drop Indicators
                if isDragging {
                    ZStack {
                        indicator(for: .bottom, in: geometry.size)
                        indicator(for: .leading, in: geometry.size)
                        indicator(for: .trailing, in: geometry.size)
                    }
                    .transition(.opacity)
                }
                
                // The Draggable Container
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .frame(width: containerSize.width, height: containerSize.height)
                    
                    if isDragging {
                        // Stacked layout when dragging
                        ZStack {
                            ForEach(Array(icons.enumerated()), id: \.offset) { index, icon in
                                Image(systemName: icon)
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white)
                                    .offset(x: CGFloat(index) * 2, y: CGFloat(index) * -2)
                                    .opacity(1.0 - Double(index) * 0.2)
                            }
                        }
                    } else {
                        // Spread layout when docked
                        if dockedEdge == .bottom {
                            HStack(spacing: 20) {
                                ForEach(icons, id: \.self) { icon in
                                    Image(systemName: icon)
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white)
                                }
                            }
                        } else {
                            VStack(spacing: 20) {
                                ForEach(icons, id: \.self) { icon in
                                    Image(systemName: icon)
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                }
                .position(isDragging ? position : dockedPosition(in: geometry.size))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if !isDragging {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isDragging = true
                                    containerSize = CGSize(width: 80, height: 80)
                                }
                            }
                            position = value.location
                        }
                        .onEnded { value in
                            let edge = closestEdge(for: value.location, in: geometry.size)
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                isDragging = false
                                dockedEdge = edge
                                containerSize = edge == .bottom ? CGSize(width: 300, height: 80) : CGSize(width: 80, height: 300)
                            }
                        }
                )
            }
        }
        .navigationTitle("Drag Transform")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func indicator(for edge: EdgeType, in size: CGSize) -> some View {
        let target = dockedPosition(for: edge, in: size)
        let dist = hypot(position.x - target.x, position.y - target.y)
        let proximity = max(0, min(1, 1 - dist / 200))
        
        return RoundedRectangle(cornerRadius: 30)
            .stroke(.white.opacity(0.1 + proximity * 0.2), lineWidth: 1)
            .background(RoundedRectangle(cornerRadius: 30).fill(.white.opacity(0.05 + proximity * 0.1)))
            .frame(width: edge == .bottom ? 300 : 80, height: edge == .bottom ? 80 : 300)
            .position(target)
            .scaleEffect(0.8 + proximity * 0.2)
    }
    
    private func dockedPosition(in size: CGSize) -> CGPoint {
        dockedPosition(for: dockedEdge, in: size)
    }
    
    private func dockedPosition(for edge: EdgeType, in size: CGSize) -> CGPoint {
        switch edge {
        case .bottom:
            return CGPoint(x: size.width / 2, y: size.height - 100)
        case .leading:
            return CGPoint(x: 60, y: size.height / 2)
        case .trailing:
            return CGPoint(x: size.width - 60, y: size.height / 2)
        }
    }
    
    private func closestEdge(for loc: CGPoint, in size: CGSize) -> EdgeType {
        let db = size.height - loc.y
        let dl = loc.x
        let dr = size.width - loc.x
        let minVal = min(db, dl, dr)
        if minVal == db { return .bottom }
        if minVal == dl { return .leading }
        return .trailing
    }
}

#Preview {
    NavigationStack {
        DragTransformView()
    }
}
