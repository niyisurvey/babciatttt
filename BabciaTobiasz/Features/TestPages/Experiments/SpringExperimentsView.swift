import SwiftUI

/// Consolidated Spring Experiments (adapted from GetStream/swiftui-spring-animations)
/// Showcases smooth, snappy, bouncy, and custom spring behaviors
struct SpringExperimentsView: View {
    @State private var selectedSpring: SpringType = .smooth
    @State private var animate: Bool = false
    @State private var dragOffset: CGSize = .zero
    
    enum SpringType: String, CaseIterable {
        case smooth = "Smooth"
        case snappy = "Snappy"
        case bouncy = "Bouncy"
        case elastic = "Elastic"
    }
    
    var currentAnimation: Animation {
        switch selectedSpring {
        case .smooth: return .smooth(duration: 0.5)
        case .snappy: return .snappy(duration: 0.3, extraBounce: 0.1)
        case .bouncy: return .bouncy(duration: 0.5, extraBounce: 0.3)
        case .elastic: return .interpolatingSpring(stiffness: 100, damping: 5)
        }
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Picker("Spring Type", selection: $selectedSpring) {
                ForEach(SpringType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Spacer()
            
            // Scalable Shape
            Circle()
                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 150, height: 150)
                .scaleEffect(animate ? 1.5 : 1.0)
                .offset(dragOffset)
                .shadow(radius: 10)
                .onTapGesture {
                    withAnimation(currentAnimation) {
                        animate.toggle()
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { _ in
                            withAnimation(currentAnimation) {
                                dragOffset = .zero
                            }
                        }
                )
            
            VStack(spacing: 12) {
                Text("Tap to Scale • Drag to Bounce")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text("Using iOS 17+ Spring Presets")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            // Horizontal moving block
            RoundedRectangle(cornerRadius: 12)
                .fill(.orange.gradient)
                .frame(width: 60, height: 60)
                .offset(x: animate ? 100 : -100)
                .onAppear {
                    withAnimation(currentAnimation.repeatForever(autoreverses: true)) {
                        animate.toggle()
                    }
                }
        }
        .padding()
        .navigationTitle("Spring Experiments")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SpringExperimentsView()
    }
}
