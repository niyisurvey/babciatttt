import SwiftUI

/// Photo Slingshot (adapted from mikelikesdesign)
/// Drag an image and release to slingshot it across the screen
struct PhotoSlingshotView: View {
    @State private var position: CGPoint = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var velocity: CGSize = .zero
    @State private var isDragging: Bool = false
    
    let imageSize: CGFloat = 120
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("🎯 Slingshot!")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.top, 60)
                    
                    Text("Drag it back and let go")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                
                // The "Photo" (using a rounded rect with gradient)
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: imageSize, height: imageSize)
                    .overlay(
                        Image(systemName: "photo.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white)
                    )
                    .position(x: geometry.size.width/2 + position.x + dragOffset.width,
                              y: geometry.size.height/2 + position.y + dragOffset.height)
                    .shadow(color: isDragging ? .white.opacity(0.3) : .black, radius: isDragging ? 20 : 10)
                    .scaleEffect(isDragging ? 0.9 : 1.0)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                isDragging = false
                                // Slingshot logic: velocity is inverse of drag
                                velocity = CGSize(width: -value.translation.width * 0.2,
                                                height: -value.translation.height * 0.2)
                                dragOffset = .zero
                            }
                    )
            }
            .onReceive(timer) { _ in
                if !isDragging && (abs(velocity.width) > 0.1 || abs(velocity.height) > 0.1) {
                    position.x += velocity.width
                    position.y += velocity.height
                    
                    // Friction
                    velocity.width *= 0.98
                    velocity.height *= 0.98
                    
                    // Bounce off walls
                    let halfWidth = geometry.size.width / 2
                    let halfHeight = geometry.size.height / 2
                    
                    if abs(position.x) > halfWidth - imageSize/2 {
                        velocity.width *= -0.8
                        position.x = position.x > 0 ? halfWidth - imageSize/2 : -(halfWidth - imageSize/2)
                    }
                    
                    if abs(position.y) > halfHeight - imageSize/2 {
                        velocity.height *= -0.8
                        position.y = position.y > 0 ? halfHeight - imageSize/2 : -(halfHeight - imageSize/2)
                    }
                }
            }
        }
        .navigationTitle("Photo Slingshot")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PhotoSlingshotView()
    }
}
