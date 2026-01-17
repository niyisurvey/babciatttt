import SwiftUI

struct LikeInteractionView: View {
    @State private var numberOfLikes: Int = 120
    @State private var isLiked = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        withAnimation {
                            isLiked.toggle()
                            if isLiked { numberOfLikes += 1 } else { numberOfLikes -= 1 }
                        }
                    } label: {
                        ZStack {
                            // The Heart
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 40))
                                .foregroundStyle(isLiked ? Color.red.gradient : Color.white.opacity(0.6).gradient)
                                .scaleEffect(isLiked ? 1.0 : 1.0)
                                .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: isLiked)
                            
                            // Ring Explosion
                            Circle()
                                .strokeBorder(lineWidth: isLiked ? 0 : 35)
                                .animation(.easeInOut(duration: 0.5).delay(0.1), value: isLiked)
                                .frame(width: 80, height: 80)
                                .foregroundColor(Color.red.opacity(0.6))
                                .hueRotation(.degrees(isLiked ? 300 : 200))
                                .scaleEffect(isLiked ? 1.5 : 0)
                                .opacity(isLiked ? 0 : 1)
                                .animation(.easeOut(duration: 0.5), value: isLiked)
                            
                            // Particles
                            SplashView()
                                .opacity(isLiked ? 0 : 1)
                                .scaleEffect(isLiked ? 1.8 : 0)
                                .animation(.easeOut(duration: 0.5).delay(0.1), value: isLiked)
                            
                            SplashView()
                                .rotationEffect(.degrees(90))
                                .opacity(isLiked ? 0 : 1)
                                .scaleEffect(isLiked ? 1.8 : 0)
                                .animation(.easeOut(duration: 0.5).delay(0.2), value: isLiked)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .glass()
                    
                    // Counter
                    Text("\(numberOfLikes)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(isLiked ? .red : .white.opacity(0.6))
                        .contentTransition(.numericText())
                        .animation(.spring, value: numberOfLikes)
                }
                .padding(.bottom, 60)
            }
        }
    }
}
