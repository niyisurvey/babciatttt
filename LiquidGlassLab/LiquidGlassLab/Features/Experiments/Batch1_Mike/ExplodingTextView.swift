import SwiftUI
import SpriteKit
import CoreText

struct ExplodingTextView: View {
    let scene = LetterScene()
    
    var body: some View {
        ZStack {
            // SpriteView for Physics
            SpriteView(scene: scene, options: [.allowsTransparency])
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Text("Tap text to explode")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding()
                    .glass()
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            scene.scaleMode = .resizeFill
            scene.backgroundColor = .clear
        }
    }
}

class LetterScene: SKScene {
    private var particles: [SKShapeNode] = []
    private var targetPositions: [CGPoint] = []
    private let textString = "Liquid Glass"
    private let fontSize: CGFloat = 64
    private let particleSize: CGFloat = 2
    private let particleSpacing: CGFloat = 4
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        // Delay to allow layout to settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupParticles()
        }
    }
    
    private func setupParticles() {
        removeAllChildren()
        particles.removeAll()
        targetPositions.removeAll()
        
        let path = CGMutablePath()
        let font = UIFont.systemFont(ofSize: fontSize, weight: .black)
        let attrString = NSAttributedString(string: textString, attributes: [.font: font])
        let line = CTLineCreateWithAttributedString(attrString)
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        
        let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
        let xOffset = (size.width - bounds.width) / 2
        let yOffset = (size.height - bounds.height) / 2
        
        for run in runs {
            let count = CTRunGetGlyphCount(run)
            let glyphs = UnsafeMutablePointer<CGGlyph>.allocate(capacity: count)
            let positions = UnsafeMutablePointer<CGPoint>.allocate(capacity: count)
            CTRunGetGlyphs(run, CFRange(), glyphs)
            CTRunGetPositions(run, CFRange(), positions)
            
            for i in 0..<count {
                if let letter = CTFontCreatePathForGlyph(font, glyphs[i], nil) {
                    let transform = CGAffineTransform(translationX: positions[i].x + xOffset, y: positions[i].y + yOffset)
                    path.addPath(letter, transform: transform)
                }
            }
            glyphs.deallocate()
            positions.deallocate()
        }
        
        let pathBounds = path.boundingBox
        // Safety check
        if pathBounds.width == 0 || pathBounds.height == 0 { return }
        
        for x in stride(from: pathBounds.minX, through: pathBounds.maxX, by: particleSpacing) {
            for y in stride(from: pathBounds.minY, through: pathBounds.maxY, by: particleSpacing) {
                let point = CGPoint(x: x, y: y)
                if path.contains(point) {
                    targetPositions.append(point)
                    
                    let particle = SKShapeNode(circleOfRadius: particleSize)
                    particle.fillColor = .white
                    particle.strokeColor = .clear
                    // Start scrambled
                    particle.position = CGPoint(
                        x: CGFloat.random(in: 0...size.width),
                        y: CGFloat.random(in: 0...size.height)
                    )
                    particle.alpha = 0.8
                    particles.append(particle)
                    addChild(particle)
                }
            }
        }
        
        assembleText()
    }
    
    private func assembleText(isInitial: Bool = true) {
        for (index, particle) in particles.enumerated() {
            let target = targetPositions[index]
            let duration = Double.random(in: 1.0...2.0)
            let move = SKAction.move(to: target, duration: duration)
            move.timingMode = .easeOut
            particle.run(move)
        }
    }
    
    // Physics Interaction
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        explode(at: location)
    }
    
    private func explode(at point: CGPoint) {
        for particle in particles {
            let dx = particle.position.x - point.x
            let dy = particle.position.y - point.y
            let dist = hypot(dx, dy)
            
            if dist < 200 { // Blast radius
                let angle = atan2(dy, dx)
                let force = max(0, 500 - dist) // Explosion force
                
                let vector = CGVector(dx: cos(angle) * force, dy: sin(angle) * force)
                particle.run(SKAction.move(by: vector, duration: 0.5))
            }
        }
        
        // Reassemble after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.assembleText(isInitial: false)
        }
    }
}
