import SwiftUI

struct PulseRipplesView: View {
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            ForEach(0..<4) { i in
                Circle()
                    .stroke(.white.opacity(0.5), lineWidth: 1)
                    .background(Circle().fill(.ultraThinMaterial.opacity(0.1)))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isPulsing ? 4 : 1)
                    .opacity(isPulsing ? 0 : 1)
                    .animation(
                        .easeOut(duration: 4)
                        .repeatForever(autoreverses: false)
                        .delay(Double(i) * 1.0),
                        value: isPulsing
                    )
            }
            
            // Center Core
            Circle()
                .fill(.white)
                .frame(width: 20, height: 20)
                .shadow(color: .white, radius: 10)
                .glass()
            
            VStack {
                Spacer()
                Text("Sonar Pulse")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 80)
            }
        }
        .onAppear {
            isPulsing = true
        }
    }
}
