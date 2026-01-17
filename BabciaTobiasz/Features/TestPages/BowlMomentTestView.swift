import SwiftUI

/// Test page for experimenting with Bowl Moment celebration animations
struct BowlMomentTestView: View {
    @State private var showSheet = false
    @State private var pointsEarned = 50
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("🥣 Bowl Moment Test")
                    .font(.largeTitle)
                    .bold()
                
                // Points slider
                VStack(spacing: 10) {
                    Text("Points: \(pointsEarned)")
                        .font(.title2)
                    
                    Slider(value: Binding(
                        get: { Double(pointsEarned) },
                        set: { pointsEarned = Int($0) }
                    ), in: 10...200, step: 10)
                        .padding(.horizontal)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal)
                
                Spacer()
                
                // Trigger buttons
                VStack(spacing: 20) {
                    Button {
                        showSheet = true
                    } label: {
                        Text("Show Bottom Sheet")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(.green.gradient)
                            )
                    }
                    
                    Button {
                        withAnimation(.spring(response: 0.5)) {
                            showConfetti.toggle()
                        }
                    } label: {
                        Text("Toggle Confetti")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(.orange.gradient)
                            )
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            
            // Confetti overlay
            if showConfetti {
                GeometryReader { geometry in
                    ForEach(0..<20, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.title)
                            .offset(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: showConfetti ? geometry.size.height : -50
                            )
                            .rotationEffect(.degrees(Double.random(in: 0...360)))
                            .animation(.spring(response: 1.0).delay(Double(i) * 0.05), value: showConfetti)
                    }
                }
                .allowsHitTesting(false)
            }
        }
        .navigationTitle("Bowl Moment Test")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSheet) {
            BowlCelebrationSheet(pointsEarned: pointsEarned)
        }
    }
}

struct BowlCelebrationSheet: View {
    let pointsEarned: Int
    @Environment(\.dismiss) var dismiss
    @State private var pierogiOffsets: [CGFloat] = []
    @State private var showBadge = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                // Bowl icon
                Image(systemName: "fork.knife")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                    .padding(.top, 40)
                
                // Points badge
                if showBadge {
                    Text("+\(pointsEarned) points!")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.green)
                        .padding()
                        .background(
                            Capsule()
                                .fill(.green.opacity(0.2))
                        )
                        .scaleEffect(showBadge ? 1.0 : 0.5)
                        .animation(.spring(response: 0.5), value: showBadge)
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 20) {
                    Button("Awesome!") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    
                    Button("Keep Going") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.bottom, 40)
            }
            
            // Falling pierogis
            ForEach(pierogiOffsets.indices, id: \.self) { index in
                Image(systemName: "circle.fill")
                    .font(.title2)
                    .foregroundStyle(.orange.gradient)
                    .offset(
                        x: CGFloat(index * 60) - 120,
                        y: pierogiOffsets[index]
                    )
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            // Initialize pierogi positions
            pierogiOffsets = Array(repeating: -200, count: 5)
            
            // Animate pierogis dropping
            for i in 0..<5 {
                withAnimation(.spring(response: 0.6).delay(Double(i) * 0.1)) {
                    pierogiOffsets[i] = 100
                }
            }
            
            // Show badge after pierogis land
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.5)) {
                    showBadge = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BowlMomentTestView()
    }
}
