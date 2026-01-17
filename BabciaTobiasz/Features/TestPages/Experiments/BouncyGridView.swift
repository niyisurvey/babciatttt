import SwiftUI

/// Bouncy Grid / Elastic Lines (adapted from mikelikesdesign)
/// A grid of lines that react elastically to touch and release
struct BouncyGridView: View {
    @State private var touchLocation: CGPoint?
    @State private var area: CGPoint? = nil
    @State private var duration: Date? = nil
    
    let numHorizontalLines = 30
    let numVerticalLines = 15
    let maxEffectRadius: CGFloat = 120
    let resetAfterRelease: Double = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                let width = geometry.size.width
                let height = geometry.size.height
                
                let verticalSpacing = numHorizontalLines > 1 ? height / CGFloat(numHorizontalLines - 1) : height
                let horizontalSpacing = numVerticalLines > 1 ? width / CGFloat(numVerticalLines - 1) : width

                ForEach(0..<numHorizontalLines, id: \.self) { rowIndex in
                    let yPos = numHorizontalLines > 1 ? CGFloat(rowIndex) * verticalSpacing : height / 2
                    ElasticLine(
                        startPoint: CGPoint(x: 0, y: yPos),
                        endPoint: CGPoint(x: width, y: yPos),
                        touchLocation: touchLocation,
                        area: area,
                        duration: duration,
                        maxEffectRadius: maxEffectRadius
                    )
                }
                
                ForEach(0..<numVerticalLines, id: \.self) { colIndex in
                    let xPos = numVerticalLines > 1 ? CGFloat(colIndex) * horizontalSpacing : width / 2
                    ElasticLine(
                        startPoint: CGPoint(x: xPos, y: 0),
                        endPoint: CGPoint(x: xPos, y: height),
                        touchLocation: touchLocation,
                        area: area,
                        duration: duration,
                        maxEffectRadius: maxEffectRadius
                    )
                }
                
                VStack {
                    Text("🎹 Elastic Grid")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.top, 60)
                    Text("Sweep your finger across")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    touchLocation = value.location
                    area = nil
                    duration = nil
                }
                .onEnded { value in
                    area = value.location
                    duration = Date()
                    touchLocation = nil
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + resetAfterRelease) {
                        if let currentReleaseTime = duration, currentReleaseTime <= Date().addingTimeInterval(-resetAfterRelease) {
                            area = nil
                            duration = nil
                        }
                    }
                }
        )
        .navigationTitle("Bouncy Grid")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ElasticLine: View {
    let startPoint: CGPoint
    let endPoint: CGPoint
    let touchLocation: CGPoint?
    let area: CGPoint?
    let duration: Date?
    let maxEffectRadius: CGFloat
    
    @State private var opacity: Double = Double.random(in: 0.3...0.7)

    private func distanceBetween(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }

    private func closestPointOnLine(from point: CGPoint, start: CGPoint, end: CGPoint) -> CGPoint {
        let dx = end.x - start.x
        let dy = end.y - start.y
        if dx == 0 && dy == 0 { return start }
        let t = max(0, min(1, ((point.x - start.x) * dx + (point.y - start.y) * dy) / (dx * dx + dy * dy)))
        return CGPoint(x: start.x + t * dx, y: start.y + t * dy)
    }

    private func computeEffect() -> (thickness: CGFloat, displacement: CGFloat) {
        if let touch = touchLocation {
            let closest = closestPointOnLine(from: touch, start: startPoint, end: endPoint)
            let dist = distanceBetween(touch, closest)
            if dist < maxEffectRadius {
                let norm = dist / maxEffectRadius
                return (0.4 + norm * 0.6, -70.0 * (1.0 - norm))
            }
        }
        
        if let releasePoint = area, let releaseTime = duration {
            let closest = closestPointOnLine(from: releasePoint, start: startPoint, end: endPoint)
            let dist = distanceBetween(releasePoint, closest)
            if dist < maxEffectRadius {
                let time = Date().timeIntervalSince(releaseTime)
                let initialDisp = -70.0 * (1.0 - dist / maxEffectRadius)
                
                if time <= 0.15 {
                    let progress = time / 0.15
                    let eased = sin(progress * .pi / 2)
                    return (0.4 + 0.6 * eased, initialDisp * (1.0 - eased))
                } else if time <= 0.95 {
                    let oscTime = (time - 0.15) / 0.8
                    let osc = sin(oscTime * 22.0) * exp(-oscTime * 3.5)
                    return (1.0 + abs(osc) * 0.2, 0.6 * -initialDisp * osc)
                }
            }
        }
        return (1.0, 0.0)
    }

    var body: some View {
        TimelineView(.animation) { _ in
            let effect = computeEffect()
            Path { path in
                path.move(to: startPoint)
                if effect.displacement != 0 {
                    let mid = CGPoint(x: (startPoint.x + endPoint.x)/2, y: (startPoint.y + endPoint.y)/2)
                    let dX = endPoint.x - startPoint.x
                    let dY = endPoint.y - startPoint.y
                    let len = sqrt(dX*dX + dY*dY)
                    if len > 0 {
                        let perpX = -dY / len
                        let perpY = dX / len
                        let control = CGPoint(x: mid.x + effect.displacement * perpX, y: mid.y + effect.displacement * perpY)
                        path.addQuadCurve(to: endPoint, control: control)
                    } else { path.addLine(to: endPoint) }
                } else { path.addLine(to: endPoint) }
            }
            .stroke(Color.white, lineWidth: 2.0 * effect.thickness)
            .opacity(opacity)
        }
    }
}

#Preview {
    NavigationStack {
        BouncyGridView()
    }
}
