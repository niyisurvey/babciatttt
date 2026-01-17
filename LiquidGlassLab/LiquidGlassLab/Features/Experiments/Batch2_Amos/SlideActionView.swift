import SwiftUI

struct SlideActionView: View {
    @State private var isUnlocked = false
    @State private var dragOffset: CGFloat = 0
    let maxWidth: CGFloat = 280
    let handleWidth: CGFloat = 60
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                // Track
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .frame(width: maxWidth, height: handleWidth + 10)
                        .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
                    
                    // Shimmer Text
                    Text("Slide to Unlock")
                        .font(.body.bold())
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .mask {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .white, .white.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .rotationEffect(.degrees(30))
                                .offset(x: -150)
                                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isUnlocked) // Continuous shimmer?
                        }
                        .opacity(isUnlocked ? 0 : 1)
                    
                    // Handle
                    HStack {
                        ZStack {
                            Circle()
                                .fill(isUnlocked ? Color.green : Color.white)
                                .shadow(radius: 5)
                            
                            if isUnlocked {
                                Image(systemName: "lock.open.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .transition(.scale)
                            } else {
                                Image(systemName: "lock.fill")
                                    .font(.title2)
                                    .foregroundStyle(.black)
                            }
                        }
                        .frame(width: handleWidth, height: handleWidth)
                        .offset(x: dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    guard !isUnlocked else { return }
                                    let translation = value.translation.width
                                    // Limit drag
                                    if translation >= 0 && translation <= (maxWidth - handleWidth - 10) {
                                        dragOffset = translation
                                    }
                                }
                                .onEnded { value in
                                    guard !isUnlocked else { return }
                                    // Threshold
                                    if dragOffset > (maxWidth - handleWidth - 10) * 0.8 {
                                        // Unlock
                                        let impact = UIImpactFeedbackGenerator(style: .heavy)
                                        impact.impactOccurred()
                                        
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                            dragOffset = maxWidth - handleWidth - 10
                                            isUnlocked = true
                                        }
                                        
                                        // Reset after delay
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation(.spring) {
                                                isUnlocked = false
                                                dragOffset = 0
                                            }
                                        }
                                    } else {
                                        // Snap back
                                        withAnimation(.spring) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                        Spacer()
                    }
                    .padding(5)
                }
                .glass()
                .padding(.bottom, 60)
            }
        }
    }
}
