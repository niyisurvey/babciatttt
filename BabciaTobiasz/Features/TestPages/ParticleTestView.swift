import SwiftUI

/// Test page for experimenting with particle animations (pierogi drops, confetti, etc.)
struct ParticleTestView: View {
    @State private var particleCount = 20
    @State private var particles: [ParticleDrop] = []
    @State private var triggerAnimation = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("🥟 Particle Playground")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                
                // Particle canvas
                GeometryReader { geometry in
                    ZStack {
                        ForEach(particles) { particle in
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: particle.size, height: particle.size)
                                .foregroundStyle(particle.color)
                                .offset(x: particle.position.x, y: particle.position.y)
                                .opacity(particle.opacity)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 400)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .padding()
                
                // Controls
                VStack(spacing: 20) {
                    HStack {
                        Text("Particles: \(particleCount)")
                            .foregroundStyle(.white)
                        Slider(value: Binding(
                            get: { Double(particleCount) },
                            set: { particleCount = Int($0) }
                        ), in: 5...50, step: 5)
                    }
                    .padding(.horizontal)
                    
                    Button {
                        spawnParticles()
                    } label: {
                        Text("RAIN PIEROGIS!")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(.blue.gradient)
                            )
                    }
                    .padding(.horizontal)
                    
                    Button {
                        particles.removeAll()
                    } label: {
                        Text("Clear")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Particle Test")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func spawnParticles() {
        particles.removeAll()
        
        for i in 0..<particleCount {
            let randomX = CGFloat.random(in: -150...150)
            let randomColor = [Color.red, .blue, .green, .yellow, .purple, .pink].randomElement()!
            let randomSize = CGFloat.random(in: 20...40)
            
                                let particle = ParticleDrop(
                position: CGPoint(x: randomX, y: -200),
                size: randomSize,
                color: randomColor
            )
            particles.append(particle)
            
            // Animate each particle dropping
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(i) * 0.05)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].position.y = CGFloat.random(in: 100...350)
                }
            }
        }
    }
}

struct ParticleDrop: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double = 1.0
}

#Preview {
    NavigationStack {
        ParticleTestView()
    }
}
