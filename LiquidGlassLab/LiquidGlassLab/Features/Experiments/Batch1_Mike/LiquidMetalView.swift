import SwiftUI
import QuartzCore
import UIKit

struct LiquidMetalView: View {
    var body: some View {
        ZStack {
            MetalViewRepresentable()
                .ignoresSafeArea()
                .overlay {
                    // Glass overlay to make it look like it's inside the screen
                    Rectangle()
                        .fill(.ultraThinMaterial.opacity(0.1))
                        .allowsHitTesting(false)
                }
            
            VStack {
                Spacer()
                Text("Touch the Liquid")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding()
                    .glass()
                    .padding(.bottom, 60)
            }
            .allowsHitTesting(false)
        }
    }
}

struct MetalViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> MetalblobView {
        return MetalblobView()
    }
    
    func updateUIView(_ uiView: MetalblobView, context: Context) {}
}

class MetalblobView: UIView {
    private var points: [CGPoint] = []
    private var velocities: [CGPoint] = []
    private var displayLink: CADisplayLink?
    private var metalLayer: CAShapeLayer!
    private var ripplePoints: [(point: CGPoint, age: CGFloat)] = []
    private let numPoints = 150 // Optimized count
    private let radius: CGFloat = 120
    private var time: Double = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMetal()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(pan)
        
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupMetal()
    }
    
    private func setupMetal() {
        backgroundColor = .clear
        metalLayer = CAShapeLayer()
        metalLayer.fillColor = UIColor.white.withAlphaComponent(0.9).cgColor // Liquid Metal color
        metalLayer.shadowColor = UIColor.cyan.cgColor
        metalLayer.shadowOffset = .zero
        metalLayer.shadowRadius = 20
        metalLayer.shadowOpacity = 0.6
        layer.addSublayer(metalLayer)
        
        for i in 0..<numPoints {
            let angle = (2.0 * .pi * Double(i)) / Double(numPoints)
            points.append(CGPoint(
                x: CGFloat(cos(angle)) * radius,
                y: CGFloat(sin(angle)) * radius
            ))
            velocities.append(.zero)
        }
    }
    
    @objc private func update() {
        let centerX = bounds.midX
        let centerY = bounds.midY
        let springStrength: CGFloat = 0.05
        let damping: CGFloat = 0.96
        let rippleStrength: CGFloat = 40
        
        time += 0.016
        let autonomousStrength: CGFloat = 1.5 // More alive
        
        // Remove old ripples
        ripplePoints = ripplePoints.compactMap { point, age in
            let newAge = age + 0.02
            return newAge < 1 ? (point, newAge) : nil
        }
        
        for i in 0..<points.count {
            var velocity = velocities[i]
            var point = points[i]
            
            // Autonomous movement noise
            let noiseX = sin(CGFloat(-time * 1.5 + Double(i) * 0.1)) * autonomousStrength
            let noiseY = cos(CGFloat(-time * 1.5 + Double(i) * 0.1)) * autonomousStrength
            
            let angle = (2.0 * .pi * Double(i)) / Double(numPoints)
            let restX = cos(angle) * radius
            let restY = sin(angle) * radius
            
            var fx = (restX - point.x) * springStrength + noiseX
            var fy = (restY - point.y) * springStrength + noiseY
            
            // Interaction
            for (ripplePoint, age) in ripplePoints {
                let dx = (ripplePoint.x - centerX) - point.x
                let dy = (ripplePoint.y - centerY) - point.y
                let distance = sqrt(dx * dx + dy * dy)
                let rippleFactor = sin(age * .pi * 2) * (1 - age)
                let force = rippleStrength * rippleFactor / (distance + 0.1)
                
                fx += dx * force * 0.02
                fy += dy * force * 0.02
            }
            
            velocity.x = velocity.x * damping + fx
            velocity.y = velocity.y * damping + fy
            point.x += velocity.x
            point.y += velocity.y
            
            points[i] = point
            velocities[i] = velocity
        }
        
        // Draw Path
        let path = UIBezierPath()
        if !points.isEmpty {
            let firstPoint = CGPoint(x: points[0].x + centerX, y: points[0].y + centerY)
            path.move(to: firstPoint)
            
            for i in 0..<points.count {
                let j = (i + 1) % points.count
                let k = (i + 2) % points.count
                
                // let p1 = CGPoint(x: points[i].x + centerX, y: points[i].y + centerY)
                let p2 = CGPoint(x: points[j].x + centerX, y: points[j].y + centerY)
                let p3 = CGPoint(x: points[k].x + centerX, y: points[k].y + centerY)
                
                let cp1 = CGPoint(
                    x: (p2.x + p3.x) / 2, // Midpoint between p2 and p3
                    y: (p2.y + p3.y) / 2
                )
                
                path.addQuadCurve(to: cp1, controlPoint: p2)
            }
            path.close()
        }
        
        metalLayer.path = path.cgPath
        
        // Dynamic Color Shift
        let shift = sin(time) * 0.1
        metalLayer.fillColor = UIColor(hue: 0.5 + shift, saturation: 0.1, brightness: 1.0, alpha: 0.95).cgColor
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        if gesture.state == .began || gesture.state == .changed {
            ripplePoints.append((location, 0))
        }
    }
    
    // Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        // Center the blob if needed, but we rely on bounds.midX in update()
    }
    
    deinit {
        displayLink?.invalidate()
    }
}
