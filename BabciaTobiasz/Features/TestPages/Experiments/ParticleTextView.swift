import SwiftUI
import SpriteKit

/// Particle Text (adapted from mikelikesdesign)
/// Exploding and reassembling text particles
struct ParticleTextView: View {
    let scene: LetterScene = {
        let scene = LetterScene()
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        return scene
    }()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            SpriteView(scene: scene, options: [.allowsTransparency])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            scene.handleTouch(at: gesture.location)
                        }
                )
        }
        .navigationTitle("Particle Text")
        .navigationBarTitleDisplayMode(.inline)
    }
}

class LetterScene: SKScene {
    private var particles: [SKShapeNode] = []
    private var targetPositions: [CGPoint] = []
    private let text = "BABCIA"
    private let fontSize: CGFloat = 80
    private let particleSize: CGFloat = 2
    private let particleSpacing: CGFloat = 4
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        setupParticles()
    }
    
    private func setupParticles() {
        let path = CGMutablePath()
        let font = UIFont.systemFont(ofSize: fontSize, weight: .black)
        let textString = NSAttributedString(string: text, attributes: [.font: font])
        let line = CTLineCreateWithAttributedString(textString)
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
                    let t = CGAffineTransform(translationX: positions[i].x + xOffset, y: yOffset)
                    path.addPath(letter, transform: t)
                }
            }
            glyphs.deallocate()
            positions.deallocate()
        }
        
        let pBounds = path.boundingBox
        for x in stride(from: pBounds.minX, through: pBounds.maxX, by: particleSpacing) {
            for y in stride(from: pBounds.minY, through: pBounds.maxY, by: particleSpacing) {
                let p = CGPoint(x: x, y: y)
                if path.contains(p) {
                    targetPositions.append(p)
                    let node = SKShapeNode(circleOfRadius: particleSize)
                    node.fillColor = .white
                    node.strokeColor = .clear
                    node.position = CGPoint(x: .random(in: 0...size.width), y: .random(in: 0...size.height))
                    particles.append(node)
                    addChild(node)
                }
            }
        }
        assemble()
    }
    
    func handleTouch(at point: CGPoint) {
        let p = convertPoint(fromView: point)
        for node in particles {
            let dx = node.position.x - p.x
            let dy = node.position.y - p.y
            let d = hypot(dx, dy)
            if d < 50 {
                let force = (50 - d) * 5
                let angle = atan2(dy, dx)
                node.run(SKAction.move(by: CGVector(dx: cos(angle) * force, dy: sin(angle) * force), duration: 0.3))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.reassemble(node) }
            }
        }
    }
    
    private func assemble() {
        for (i, node) in particles.enumerated() {
            node.run(SKAction.move(to: targetPositions[i], duration: .random(in: 1...2)))
        }
    }
    
    private func reassemble(_ node: SKShapeNode) {
        if let i = particles.firstIndex(of: node) {
            node.run(SKAction.move(to: targetPositions[i], duration: 1.0))
        }
    }
}

#Preview {
    NavigationStack {
        ParticleTextView()
    }
}
