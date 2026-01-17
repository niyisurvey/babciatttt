import SwiftUI

struct PhotoSlingshotView: View {
    // SF Symbol replacements for original images
    let mainIcon = "person.crop.rectangle.fill"
    let avatarIcons = ["person.crop.circle.fill", "star.circle.fill", "heart.circle.fill"]
    let avatarColors: [Color] = [.blue, .purple, .pink]
    
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var itemOpacity = 1.0
    @State private var currentIconIndex = 0
    
    // Rotating main icons for slingshot effect
    let mainIcons = [
        "photo.artframe",
        "gamecontroller.fill",
        "headphones",
        "airplane",
        "bolt.fill",
        "flame.fill"
    ]

    var body: some View {
        ZStack {
            // Main Slingshot Item
            VStack {
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .frame(width: 200, height: 260)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(.white.opacity(0.4), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
                    
                    Image(systemName: mainIcons[currentIconIndex % mainIcons.count])
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(colors: [.white, .white.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: .white.opacity(0.5), radius: 20)
                }
                .opacity(itemOpacity)
                .scaleEffect(isDragging ? 0.9 : 1.0)
                .rotation3DEffect(.degrees(Double(dragOffset.width / 10)), axis: (x: 0, y: 1, z: 0))
                .rotation3DEffect(.degrees(Double(-dragOffset.height / 20)), axis: (x: 1, y: 0, z: 0))
                .offset(isDragging ? dragOffset : .zero)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // Add resistance
                            let resistance: CGFloat = 0.6
                            dragOffset = CGSize(
                                width: value.translation.width * resistance,
                                height: value.translation.height * resistance
                            )
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                                isDragging = true
                            }
                        }
                        .onEnded { value in
                            let screenHeight = UIScreen.main.bounds.height
                            // Threshold to "shoot" is pulling DOWN (positive height) or UP?
                            // Original logic: if dragOffset.height > dragThreshold (Pulling DOWN shoots UP?)
                            // Wait, original logic:  dragOffset = CGSize(..., height: -screenHeight)
                            // So pulling DOWN triggers a shoot UP.
                            
                            let dragThreshold: CGFloat = 100
                            
                            if value.translation.height > dragThreshold {
                                // FIRE!
                                let impact = UIImpactFeedbackGenerator(style: .heavy)
                                impact.impactOccurred()
                                
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                    // Shoot up off screen
                                    dragOffset = CGSize(width: dragOffset.width * 0.5, height: -screenHeight * 1.5)
                                    itemOpacity = 0
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    // Reset invisible
                                    dragOffset = .zero
                                    isDragging = false
                                    currentIconIndex += 1
                                    
                                    // Reload
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        itemOpacity = 1.0
                                    }
                                }
                            } else {
                                // Snap back
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    dragOffset = .zero
                                    isDragging = false
                                }
                            }
                        }
                )
                
                Spacer()
                
                Text(isDragging ? "Release to Send" : "Pull Down to Shoot")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 40)
                    .glass()
            }
            
            // Avatar Targets (Top)
            HStack(spacing: 20) {
                ForEach(0..<avatarIcons.count, id: \.self) { index in
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 60, height: 60)
                            .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))
                        
                        Image(systemName: avatarIcons[index])
                            .font(.title)
                            .foregroundStyle(avatarColors[index].gradient)
                    }
                    // React to projectile passing near
                    .scaleEffect(
                        isDragging && dragOffset.height < -100 && abs(dragOffset.width + CGFloat(index - 1) * 80) < 50
                        ? 1.2 : 1.0
                    )
                    .offset(y: isDragging ? 0 : -200) // Slide in/out or just stay? Original slid them.
                    .animation(.spring, value: isDragging)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 60)
        }
    }
}
