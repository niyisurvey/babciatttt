import SwiftUI

struct ParticleSliderView: View {
    @State private var sliderPosition: CGPoint = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var particles: [Particle] = []
    @State private var isKnobEnlarged: Bool = false
    @State private var trackpadRotation: (x: CGFloat, y: CGFloat) = (0, 0)
    
    // Config
    let trackpadHeight: CGFloat = 300
    let knobSize: CGFloat = 40
    let knobEnlargementFactor: CGFloat = 1.5
    
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Particle System Area
                ZStack {
                    ForEach(particles) { particle in
                        Circle()
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size)
                            .position(particle.position)
                    }
                }
                .frame(width: geometry.size.width, height: max(0, geometry.size.height - trackpadHeight - 40))
                .contentShape(Rectangle())
                .clipped()
                .onReceive(timer) { _ in
                    let particleAreaSize = CGSize(
                        width: geometry.size.width,
                        height: max(0, geometry.size.height - trackpadHeight - 40)
                    )
                    updateParticles(size: particleAreaSize)
                }
                
                Spacer(minLength: 20)
                
                // Track pad
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.2), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 0)
                        
                    // Labels
                    VStack {
                        Text("Faster")
                            .padding(.top, 12)
                            .foregroundStyle(.white.opacity(0.8))
                        Spacer()
                        Text("Slower")
                            .padding(.bottom, 12)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .font(.caption.weight(.medium))
                    
                    HStack {
                        RotatedText(text: "Gather", angle: -90)
                            .padding(.leading, 12)
                            .foregroundStyle(.white.opacity(0.8))
                        Spacer()
                        RotatedText(text: "Disperse", angle: 90)
                            .padding(.trailing, 12)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .font(.caption.weight(.medium))
                    
                    // The Knob
                    Circle()
                        .fill(.white.opacity(0.9))
                        .frame(width: isKnobEnlarged ? knobSize * knobEnlargementFactor : knobSize,
                               height: isKnobEnlarged ? knobSize * knobEnlargementFactor : knobSize)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        .position(limitPositionToTrackpad(sliderPosition, in: CGSize(width: geometry.size.width - 32, height: trackpadHeight)))
                        .offset(dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        let trackpadSize = CGSize(width: geometry.size.width - 32, height: trackpadHeight)
                                        updateSliderPosition(value, in: trackpadSize)
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
                .rotation3DEffect(
                    .degrees(trackpadRotation.x),
                    axis: (x: 1, y: 0, z: 0)
                )
                .rotation3DEffect(
                    .degrees(trackpadRotation.y),
                    axis: (x: 0, y: 1, z: 0)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .onAppear {
                // Initial Center Position relative to estimated screen
                // We'll trust Layout to adjust, but set defaults
                sliderPosition = CGPoint(x: geometry.size.width / 2, y: trackpadHeight / 2)
                
                let particleAreaSize = CGSize(
                    width: geometry.size.width,
                    height: max(0, geometry.size.height - trackpadHeight - 40)
                )
                particles = (0..<200).map { _ in Particle(bounds: particleAreaSize) }
            }
        }
    }
    
    private func updateParticles(size: CGSize) {
        // Guard against zero size
        guard size.width > 0, size.height > 0 else { return }
        
        // Normalize based on trackpad interaction
        // Y: Top = Faster (1.0), Bottom = Slower (0.0) -> But UI shows Top Faster?
        // Let's check original: "Faster" is Top. sliderPosition Y=0 is Top.
        // normalized Y: 0 (top) to 1 (bottom).
        // Speed = (1 - Y) * 5. So Top = 5, Bottom = 0. Correct.
        
        let normalizedY = sliderPosition.y / trackpadHeight
        let speed = (1 - normalizedY) * 8 // Boosted speed a bit
        
        // X: Left = Gather, Right = Disperse
        let normalizedX = sliderPosition.x / (UIScreen.main.bounds.width - 32)
        let dispersion = normalizedX * 2 // 0 to 2
        
        for i in particles.indices {
            particles[i].update(speed: speed, dispersion: dispersion, bounds: size)
        }
    }
    
    private func updateSliderPosition(_ value: DragGesture.Value, in size: CGSize) {
        let newPosition = value.location
        sliderPosition = limitPositionToTrackpad(newPosition, in: size)
        
        // Tilt effect
        let maxRotation: CGFloat = 5
        let normalizedX = (sliderPosition.x / size.width) * 2 - 1
        let normalizedY = (sliderPosition.y / trackpadHeight) * 2 - 1
        trackpadRotation.y = normalizedX * maxRotation
        trackpadRotation.x = -normalizedY * maxRotation
    }
    
    private func limitPositionToTrackpad(_ position: CGPoint, in size: CGSize) -> CGPoint {
        return CGPoint(
            x: min(max(position.x, knobSize/2), size.width - knobSize/2),
            y: min(max(position.y, knobSize/2), trackpadHeight - knobSize/2)
        )
    }
}

// MARK: - Models

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var color: Color
    var size: CGFloat
    
    init(bounds: CGSize) {
        // Handle case where bounds might be zero initially
        let w = bounds.width > 0 ? bounds.width : 300
        let h = bounds.height > 0 ? bounds.height : 400
        
        position = CGPoint(x: CGFloat.random(in: 0...w), y: CGFloat.random(in: 0...h))
        velocity = CGVector(dx: CGFloat.random(in: -1...1), dy: CGFloat.random(in: -1...1))
        
        // HSL colors for more vibrancy
        color = Color(hue: Double.random(in: 0.5...0.9), saturation: 0.8, brightness: 1.0)
        size = CGFloat.random(in: 3...6)
    }
    
    mutating func update(speed: CGFloat, dispersion: CGFloat, bounds: CGSize) {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let directionFromCenter = CGVector(dx: position.x - center.x, dy: position.y - center.y)
        let len = sqrt(directionFromCenter.dx * directionFromCenter.dx + directionFromCenter.dy * directionFromCenter.dy)
        let distanceFromCenter = max(len, 0.1) // avoid div by zero
        
        // Apply dispersion (Gather < 1 < Disperse)
        let factor = dispersion - 1
        velocity.dx += directionFromCenter.dx / distanceFromCenter * factor
        velocity.dy += directionFromCenter.dy / distanceFromCenter * factor
        
        // Apply speed
        position.x += velocity.dx * speed
        position.y += velocity.dy * speed
        
        // Wrap
        if bounds.width > 0 && bounds.height > 0 {
            position.x = (position.x + bounds.width).truncatingRemainder(dividingBy: bounds.width)
            position.y = (position.y + bounds.height).truncatingRemainder(dividingBy: bounds.height)
        }
        
        // Random drift
        velocity.dx += CGFloat.random(in: -0.1...0.1)
        velocity.dy += CGFloat.random(in: -0.1...0.1)
        
        // Limit velocity
        let maxVelocity: CGFloat = 8
        let currentVelocity = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        if currentVelocity > maxVelocity {
            velocity.dx = velocity.dx / currentVelocity * maxVelocity
            velocity.dy = velocity.dy / currentVelocity * maxVelocity
        }
    }
}

struct RotatedText: View {
    let text: String
    let angle: Double
    
    var body: some View {
        Text(text)
            .rotationEffect(.degrees(angle))
            .fixedSize()
            .frame(width: 20)
    }
}
