import SwiftUI

/// Wave Pattern (adapted from mikelikesdesign)
/// Hexagonal grid with sine wave pulse and interactive spiral deformation
struct WavePatternView: View {
    @State private var phase: CGFloat = 0
    @State private var pressLocation: CGPoint? = nil
    @State private var pressDepth: CGFloat = 0.0
    @State private var isPressed: Bool = false
    
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            HexagonalGrid(
                amplitude: 8,
                frequency: 2,
                phase: phase,
                pressLocation: pressLocation,
                pressDepth: pressDepth
            )
            .stroke(Color.white, lineWidth: 1.5)
            .blur(radius: 0.3)
            
            VStack {
                Text("🕸️ Wave Pattern")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.top, 60)
                Spacer()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    pressLocation = value.location
                    if !isPressed {
                        isPressed = true
                        withAnimation(.easeOut(duration: 0.2)) {
                            pressDepth = 120
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
            phase += 0.025
        }
        .navigationTitle("Wave Pattern")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HexagonalGrid: Shape {
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
    
    func deform(_ point: CGPoint) -> CGPoint {
        guard let pLoc = pressLocation, pressDepth != 0 else { return point }
        let maxRadius: CGFloat = 200.0
        let distance = hypot(point.x - pLoc.x, point.y - pLoc.y)
        
        if distance < maxRadius {
            let normalizedDistance = distance / maxRadius
            let pulseFactor = sin(normalizedDistance * .pi * 2 - phase * 4) * 0.5 + 0.5
            let deformFactor = (cos(normalizedDistance * .pi) + 1) / 2.0 * pulseFactor
            
            let angle = atan2(point.y - pLoc.y, point.x - pLoc.x)
            let spiralOffset = angle + phase * 2
            
            let dx = cos(spiralOffset) * pressDepth * deformFactor * 0.3
            let dy = sin(spiralOffset) * pressDepth * deformFactor * 0.3
            
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
                let distFromCenter = hypot(x - rect.width/2, y - rect.height/2)
                let waveOffset = sin(distFromCenter * 0.02 + phase) * amplitude
                let pulseSize = hexSize + waveOffset + sin(phase * 2) * 3
                
                let defCenter = deform(center)
                for i in 0...6 {
                    let angle = CGFloat(i) * .pi / 3
                    let vx = defCenter.x + pulseSize * cos(angle)
                    let vy = defCenter.y + pulseSize * sin(angle)
                    let vertex = deform(CGPoint(x: vx, y: vy))
                    
                    if i == 0 { path.move(to: vertex) }
                    else { path.addLine(to: vertex) }
                }
            }
        }
        return path
    }
}

#Preview {
    NavigationStack {
        WavePatternView()
    }
}
