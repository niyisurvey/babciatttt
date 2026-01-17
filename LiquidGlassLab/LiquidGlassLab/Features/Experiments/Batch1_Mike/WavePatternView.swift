import SwiftUI

struct WavePatternView: View {
    @State private var phase: CGFloat = 0
    @State private var pressLocation: CGPoint? = nil
    @State private var pressDepth: CGFloat = 0.0
    @State private var isPressed: Bool = false
    
    // Timer for continuous wave
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background is Pager's Mesh, so we just layer the grid
            
            // Primary Grid (White, Sharp)
            HexagonalGridShape(
                amplitude: 8,
                frequency: 2,
                phase: phase,
                pressLocation: pressLocation,
                pressDepth: pressDepth
            )
            .stroke(.white.opacity(0.8), lineWidth: 1.5)
            .blur(radius: 0.3)
            
            // Secondary Glow (Diffused)
            HexagonalGridShape(
                amplitude: 8,
                frequency: 2,
                phase: phase,
                pressLocation: pressLocation,
                pressDepth: pressDepth
            )
            .stroke(.cyan.opacity(0.4), lineWidth: 3)
            .blur(radius: 4)
            
            VStack {
                Spacer()
                Text("Touch & Hold Grid")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding()
                    .glass()
                    .padding(.bottom, 60)
            }
            .allowsHitTesting(false) // Pass touches to grid
        }
        .contentShape(Rectangle()) // Capture touches everywhere
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    pressLocation = value.location
                    if !isPressed {
                        isPressed = true
                        withAnimation(.easeOut(duration: 0.2)) {
                            pressDepth = 150 // Deep press
                        }
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    withAnimation(.interpolatingSpring(mass: 0.4, stiffness: 80, damping: 10, initialVelocity: 0)) {
                        pressDepth = 0
                    }
                }
        )
        .onReceive(timer) { _ in
            phase += 0.03
        }
    }
}

// MARK: - Hexagonal Grid Shape
struct HexagonalGridShape: Shape {
    var amplitude: CGFloat
    var frequency: CGFloat
    var phase: CGFloat
    var pressLocation: CGPoint?
    var pressDepth: CGFloat
    let hexSize: CGFloat = 30
    
    var animatableData: CGFloat {
        get { pressDepth }
        set { pressDepth = newValue }
    }
    
    func hexgonVertices(center: CGPoint, size: CGFloat) -> [CGPoint] {
        var points: [CGPoint] = []
        for i in 0...6 {
            let angle = CGFloat(i) * .pi / 3
            let x = center.x + size * cos(angle)
            let y = center.y + size * sin(angle)
            points.append(CGPoint(x: x, y: y))
        }
        return points
    }
    
    // Deform a point based on press location (Black Hole effect)
    func deform(_ point: CGPoint) -> CGPoint {
        guard let pLoc = pressLocation, pressDepth != 0 else { return point }
        let maxRadius: CGFloat = 250.0
        let distance = hypot(point.x - pLoc.x, point.y - pLoc.y)
        
        if distance < maxRadius {
            let normalizedDistance = distance / maxRadius
            // Ripple pulse
            let pulseFactor = sin(normalizedDistance * .pi * 2 - phase * 4) * 0.5 + 0.5
            let deformFactor = (cos(normalizedDistance * .pi) + 1) / 2.0 * pulseFactor
            
            let angle = atan2(point.y - pLoc.y, point.x - pLoc.x)
            let spiralOffset = angle + phase * 2
            
            let dx = cos(spiralOffset) * pressDepth * deformFactor * 0.4
            let dy = sin(spiralOffset) * pressDepth * deformFactor * 0.4
            
            return CGPoint(
                x: point.x + dx,
                y: point.y + dy
            )
        }
        return point
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let hexHeight = hexSize * sqrt(3)
        let hexWidth = hexSize * 2
        let verticalSpacing = hexHeight
        let horizontalSpacing = hexWidth * 0.75
        
        let cols = Int(rect.width / horizontalSpacing) + 2
        let rows = Int(rect.height / verticalSpacing) + 2
        
        for row in -1...rows {
            for col in -1...cols {
                let x = CGFloat(col) * horizontalSpacing
                let y = CGFloat(row) * verticalSpacing + (col % 2 == 1 ? verticalSpacing / 2 : 0)
                
                let center = CGPoint(x: x, y: y)
                
                // Base wave movement
                let distanceFromCenter = hypot(x - rect.width/2, y - rect.height/2)
                let waveOffset = sin(distanceFromCenter * 0.02 + phase) * amplitude
                
                // Breathe effect
                let pulseSize = hexSize + waveOffset * 0.5
                
                // First deform the center
                let deformedCenter = deform(center)
                
                // Then draw the hexagon around the deformed center, deforming vertices too
                let vertices = hexgonVertices(center: deformedCenter, size: pulseSize)
                let deformedVertices = vertices.map { deform($0) }
                
                path.move(to: deformedVertices[0])
                for i in 1..<deformedVertices.count {
                    path.addLine(to: deformedVertices[i])
                }
            }
        }
        
        return path
    }
}
