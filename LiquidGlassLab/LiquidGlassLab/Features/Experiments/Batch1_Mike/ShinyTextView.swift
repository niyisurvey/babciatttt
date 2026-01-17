import SwiftUI
import SceneKit
import UIKit

struct ShinyTextView: View {
    var body: some View {
        ZStack {
            GlobeView()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Glassy Shimmer Button
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }) {
                    Text("Generating Your Ideas")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.3), lineWidth: 0.5)
                        )
                        .modifier(GlassShimmer()) // Custom Shimmer
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Custom Shimmer
struct GlassShimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .white.opacity(0.4), .clear]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width / 2)
                        .offset(x: -geometry.size.width + (phase * (geometry.size.width * 2.5)))
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    phase = 1.0
                }
            }
    }
}

// MARK: - SceneKit Globe
struct GlobeView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = createGlobeScene()
        scnView.backgroundColor = .clear // Transparent for Glass effect
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        
        // Continuous rotation
        let rotateAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 20))
        scnView.scene?.rootNode.childNodes.first?.runAction(rotateAction)
        
        // Texture update timer
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Optimizing: Only update if needed for animation effect
            // For now, let's keep the static texture creation to save battery
             scnView.scene?.rootNode.childNodes.first?.geometry?.firstMaterial?.diffuse.contents = self.createTextTexture()
        }
        
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) { }
    
    private func createGlobeScene() -> SCNScene {
        let scene = SCNScene()
        let globeNode = SCNNode(geometry: SCNSphere(radius: 2)) // Scaled for SCNView default camera
        globeNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.clear
        material.emission.contents = createTextTexture() // Make it glow?
        material.transparent.contents = UIColor.white // Base transparency
        
        // Let's try to make it look like a wireframe or text cloud
        globeNode.geometry?.materials = [material]
        
        scene.rootNode.addChildNode(globeNode)
        return scene
    }
    
    // Generates the text mashup texture
    private func createTextTexture() -> UIImage {
        let size = CGSize(width: 1024, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            // Clear background
            ctx.cgContext.setFillColor(UIColor.clear.cgColor)
            ctx.cgContext.fill(CGRect(origin: .zero, size: size))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            // Draw random text
            for _ in 0..<500 { // Reduced count for perf
                let randomString = String((0..<1).map{ _ in "01XYZ".randomElement()! }) // Techy string
                let randomX = CGFloat.random(in: 0..<size.width)
                let randomY = CGFloat.random(in: 0..<size.height)
                
                let opacity = CGFloat.random(in: 0.3...1.0)
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.monospacedSystemFont(ofSize: 18, weight: .bold),
                    .paragraphStyle: paragraphStyle,
                    .foregroundColor: UIColor.white.withAlphaComponent(opacity)
                ]
                
                randomString.draw(at: CGPoint(x: randomX, y: randomY), withAttributes: attrs)
            }
        }
    }
}
