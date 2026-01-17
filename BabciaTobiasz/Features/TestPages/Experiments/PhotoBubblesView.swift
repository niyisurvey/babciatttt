import SwiftUI

/// Photo Bubbles (adapted from mikelikesdesign)
/// Floating bubbles that react to touch and movement
struct PhotoBubblesView: View {
    @State private var bubbles: [BubbleData] = []
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                ForEach(bubbles) { bubble in
                    Circle()
                        .fill(RadialGradient(colors: [bubble.color.opacity(0.6), .clear], center: .center, startRadius: 0, endRadius: bubble.size/2))
                        .frame(width: bubble.size, height: bubble.size)
                        .position(bubble.position)
                        .blur(radius: 2)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                .frame(width: bubble.size, height: bubble.size)
                                .position(bubble.position)
                        )
                }
                
                VStack {
                    Text("🫧 Bubbles")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.top, 60)
                    Spacer()
                }
            }
            .onAppear {
                bubbles = (0..<20).map { _ in
                    BubbleData(
                        position: CGPoint(x: .random(in: 0...geometry.size.width), y: .random(in: 0...geometry.size.height)),
                        velocity: CGVector(dx: .random(in: -1...1), dy: .random(in: -1...1)),
                        size: .random(in: 40...100),
                        color: [.blue, .purple, .cyan, .pink].randomElement()!
                    )
                }
            }
            .onReceive(timer) { _ in
                for i in bubbles.indices {
                    bubbles[i].position.x += bubbles[i].velocity.dx
                    bubbles[i].position.y += bubbles[i].velocity.dy
                    
                    // Bounce
                    if bubbles[i].position.x < 0 || bubbles[i].position.x > geometry.size.width {
                        bubbles[i].velocity.dx *= -1
                    }
                    if bubbles[i].position.y < 0 || bubbles[i].position.y > geometry.size.height {
                        bubbles[i].velocity.dy *= -1
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        for i in bubbles.indices {
                            let dx = bubbles[i].position.x - value.location.x
                            let dy = bubbles[i].position.y - value.location.y
                            let dist = sqrt(dx*dx + dy*dy)
                            if dist < 150 {
                                let force = (150 - dist) * 0.05
                                bubbles[i].velocity.dx += dx / dist * force
                                bubbles[i].velocity.dy += dy / dist * force
                            }
                        }
                    }
            )
        }
        .navigationTitle("Photo Bubbles")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BubbleData: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var size: CGFloat
    var color: Color
}

#Preview {
    NavigationStack {
        PhotoBubblesView()
    }
}
