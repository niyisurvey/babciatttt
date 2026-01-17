import SwiftUI

/// Waves Animation (adapted from mikelikesdesign)
/// Complex sine waves with interactive deformation
struct WavesView: View {
    @State private var phase: CGFloat = 0
    @State private var pressLocation: CGPoint? = nil
    @State private var pressDepth: CGFloat = 0.0
    @State private var isPressed: Bool = false
    
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            WaveShape(amplitude: 120, frequency: 1.2, phase: phase, pressLocation: pressLocation, pressDepth: pressDepth)
                .stroke(Color.white.opacity(0.8), lineWidth: 1)
                .blur(radius: 0.2)
            
            VStack {
                Text("🌊 Waves")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.top, 60)
                Text("Tap and drag to deform")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    pressLocation = value.location
                    if !isPressed {
                        isPressed = true
                        withAnimation(.easeOut(duration: 0.1)) {
                            pressDepth = 100
                        }
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    withAnimation(.interpolatingSpring(mass: 0.6, stiffness: 120, damping: 10, initialVelocity: 0)) {
                        pressDepth = 0
                    }
                }
        )
        .onReceive(timer) { _ in
            phase += 0.015
        }
        .navigationTitle("Waves")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WaveShape: Shape {
    var amplitude: CGFloat
    var frequency: CGFloat
    var phase: CGFloat
    var pressLocation: CGPoint?
    var pressDepth: CGFloat
    let lineCount = 15 // Reduced for performance
    
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
            let deformFactor = (cos(normalizedDistance * .pi) + 1) / 2.0
            
            let dx = point.x - pLoc.x
            let dy = point.y - pLoc.y
            let horizontalDeform = (dx / (distance + 0.1)) * pressDepth * deformFactor * 0.2
            let verticalDeform = pressDepth * deformFactor * (1.0 + abs(dy / (distance + 0.1)) * 0.3)
            
            return CGPoint(
                x: point.x + horizontalDeform, 
                y: point.y + verticalDeform
            )
        }
        return point
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let height = rect.height
        let width = rect.width
        let midHeight = height / 2
        let spacing = amplitude / CGFloat(lineCount)
        
        for line in 0..<lineCount {
            let yOffset = spacing * CGFloat(line)
            let lineVariation = CGFloat(line) / CGFloat(lineCount)
            let lineFreq = frequency + lineVariation * 0.5
            let lineAmp = amplitude * (0.8 + lineVariation * 0.4)
            let phaseWithVariation = phase + lineVariation
            
            // Draw horizontal waves
            var subPath = Path()
            let startX: CGFloat = -10
            let startBaseAngle = 2 * .pi * lineFreq * (startX / width) + phaseWithVariation
            let startVal = sin(startBaseAngle) + sin(startBaseAngle * 2.3) * 0.3
            subPath.move(to: deform(CGPoint(x: startX, y: midHeight + yOffset + lineAmp * startVal)))
            
            for x in stride(from: 0, through: width, by: 4) {
                let angle = 2 * .pi * lineFreq * (x / width) + phaseWithVariation
                let val = sin(angle) + sin(angle * 2.3) * 0.3
                subPath.addLine(to: deform(CGPoint(x: x, y: midHeight + yOffset + lineAmp * val)))
            }
            path.addPath(subPath)
            
            // Mirror wave
            var mirrorPath = Path()
            mirrorPath.move(to: deform(CGPoint(x: startX, y: midHeight - yOffset + lineAmp * startVal)))
            for x in stride(from: 0, through: width, by: 4) {
                let angle = 2 * .pi * lineFreq * (x / width) + phaseWithVariation
                let val = sin(angle) + sin(angle * 2.3) * 0.3
                mirrorPath.addLine(to: deform(CGPoint(x: x, y: midHeight - yOffset + lineAmp * val)))
            }
            path.addPath(mirrorPath)
        }
        return path
    }
}

#Preview {
    NavigationStack {
        WavesView()
    }
}
