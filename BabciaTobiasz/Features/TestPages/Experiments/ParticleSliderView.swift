import SwiftUI

/// Particle Slider (adapted from mikelikesdesign)
/// Interactive trackpad that controls particle speed and dispersion
struct ParticleSliderView: View {
    @State private var sliderPosition: CGPoint = CGPoint(x: 200, y: 100)
    @State private var dragOffset: CGSize = .zero
    @State private var particles: [Particle] = []
    @State private var isKnobEnlarged: Bool = false
    @State private var trackpadRotation: (x: CGFloat, y: CGFloat) = (0, 0)
    
    let trackpadHeight: CGFloat = 300
    let knobSize: CGFloat = 40
    let knobEnlargementFactor: CGFloat = 1.5

    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Particle System
                ZStack {
                    ForEach(particles) { particle in
                        Circle()
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size)
                            .position(particle.position)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height - trackpadHeight - 100)
                .onReceive(timer) { _ in
                    updateParticles(size: CGSize(width: geometry.size.width, height: geometry.size.height - trackpadHeight - 100))
                }
                
                Spacer(minLength: 20)
                
                // Track pad
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(white: 0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(white: 0.95), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10)
                        .rotation3DEffect(.degrees(trackpadRotation.x), axis: (x: 1, y: 0, z: 0))
                        .rotation3DEffect(.degrees(trackpadRotation.y), axis: (x: 0, y: 1, z: 0))
                    
                    VStack {
                        Text("Faster").padding(.top, 12).foregroundColor(.gray)
                        Spacer()
                        Text("Slower").padding(.bottom, 12).foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Gather")
                            .rotationEffect(.degrees(-90))
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        Spacer()
                        Text("Disperse")
                            .rotationEffect(.degrees(90))
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: isKnobEnlarged ? knobSize * knobEnlargementFactor : knobSize, 
                               height: isKnobEnlarged ? knobSize * knobEnlargementFactor : knobSize)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                        .position(limitPositionToTrackpad(sliderPosition, in: geometry.size))
                        .offset(dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        updateSliderPosition(value, in: geometry.size)
                                        isKnobEnlarged = true
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        dragOffset = .zero
                                        isKnobEnlarged = false
                                    }
                                }
                        )
                }
                .frame(height: trackpadHeight)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            let size = CGSize(width: 400, height: 400)
            particles = (0..<150).map { _ in Particle(bounds: size) }
        }
        .navigationTitle("Particle Slider")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func updateParticles(size: CGSize) {
        let normalized = CGPoint(x: sliderPosition.x / 400, y: sliderPosition.y / trackpadHeight)
        let speed = (1 - normalized.y) * 5
        let dispersion = normalized.x * 2
        
        for i in particles.indices {
            particles[i].update(speed: speed, dispersion: dispersion, bounds: size)
        }
    }
    
    private func updateSliderPosition(_ value: DragGesture.Value, in size: CGSize) {
        sliderPosition = limitPositionToTrackpad(value.location, in: size)
        let limited = limitPositionToTrackpad(value.location, in: size)
        dragOffset = CGSize(width: value.location.x - limited.x, height: value.location.y - limited.y)
        
        trackpadRotation.y = (sliderPosition.x / size.width * 2 - 1) * 5
        trackpadRotation.x = -(sliderPosition.y / trackpadHeight * 2 - 1) * 5
    }
    
    private func limitPositionToTrackpad(_ position: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(
            x: min(max(position.x, knobSize), size.width - knobSize),
            y: min(max(position.y, knobSize), trackpadHeight - knobSize)
        )
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var color: Color
    var size: CGFloat
    
    init(bounds: CGSize) {
        position = CGPoint(x: .random(in: 0...bounds.width), y: .random(in: 0...bounds.height))
        velocity = CGVector(dx: .random(in: -1...1), dy: .random(in: -1...1))
        color = Color(hue: .random(in: 0...1), saturation: 0.8, brightness: 1)
        size = .random(in: 2...6)
    }
    
    mutating func update(speed: CGFloat, dispersion: CGFloat, bounds: CGSize) {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let dx = position.x - center.x
        let dy = position.y - center.y
        let dist = max(1, sqrt(dx*dx + dy*dy))
        
        let factor = dispersion - 1
        velocity.dx += dx / dist * factor
        velocity.dy += dy / dist * factor
        
        position.x += velocity.dx * speed
        position.y += velocity.dy * speed
        
        position.x = (position.x + bounds.width).truncatingRemainder(dividingBy: bounds.width)
        position.y = (position.y + bounds.height).truncatingRemainder(dividingBy: bounds.height)
        
        velocity.dx *= 0.98
        velocity.dy *= 0.98
    }
}

#Preview {
    NavigationStack {
        ParticleSliderView()
    }
}
