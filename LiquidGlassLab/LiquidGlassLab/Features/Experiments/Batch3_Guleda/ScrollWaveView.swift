import SwiftUI

struct ScrollWaveView: View {
    @State private var phase: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background
            Color.clear
            
            TimelineView(.animation) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                ZStack {
                    // Back Wave
                    WaveShape(waveHeight: 40, phase: Angle(degrees: time * 50))
                        .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .top, endPoint: .bottom))
                        .opacity(0.3)
                        .offset(y: 50)
                        .blur(radius: 10)
                    
                    // Middle Wave
                    WaveShape(waveHeight: 35, phase: Angle(degrees: time * 70 + 90))
                        .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom))
                        .opacity(0.5)
                        .blur(radius: 5)
                    
                    // Front Wave
                    WaveShape(waveHeight: 25, phase: Angle(degrees: time * 90 + 180))
                        .fill(LinearGradient(colors: [.white, .cyan], startPoint: .top, endPoint: .bottom))
                        .opacity(0.2)
                        .offset(y: -30)
                }
            }
            .mask(
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: 300, height: 400)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
                    .frame(width: 300, height: 400)
            )
            .glass()
            
            VStack {
                Spacer()
                Text("Abstract Waves")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 80)
            }
        }
    }
}

struct WaveShape: Shape {
    var waveHeight: CGFloat
    var phase: Angle
    
    var animatableData: Double {
        get { phase.degrees }
        set { phase = Angle(degrees: newValue) }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY)) // Bottom Left
        
        for x in stride(from: 0, through: rect.width, by: 2) {
            let relativeX: CGFloat = x / 40 // wavelength
            let sine = CGFloat(sin(relativeX + CGFloat(phase.radians)))
            let y = rect.midY + waveHeight * sine
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Bottom Right
        path.closeSubpath()
        
        return path
    }
}
