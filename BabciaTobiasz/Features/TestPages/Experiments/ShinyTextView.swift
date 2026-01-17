import SwiftUI

/// Shiny Text / Shimmer (adapted from mikelikesdesign)
/// A view that adds a shimmer / shiny effect to text
struct ShinyTextView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("BABCIA")
                    .font(.system(size: 80, weight: .black))
                    .foregroundStyle(.white)
                    .shimmer()
                
                Text("TOBIASZ")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                    .shimmer()
                
                Button(action: {}) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(.white)
                                .shimmer(duration: 2.5)
                        )
                }
                
                Spacer()
            }
            .padding(.top, 100)
        }
        .navigationTitle("Shiny Text")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Local implementation of Shimmer effect to avoid dependency issues
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration: Double = 1.5
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .white.opacity(0.8), location: 0.5),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer(duration: Double = 1.5) -> some View {
        modifier(ShimmerModifier(duration: duration))
    }
}

#Preview {
    NavigationStack {
        ShinyTextView()
    }
}
