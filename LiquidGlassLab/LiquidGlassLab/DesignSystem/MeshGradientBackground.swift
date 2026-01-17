import SwiftUI

@available(iOS 18.0, *)
struct MeshGradientBackground: View {
    @State private var t: Float = 0.0
    @State private var timer: Timer?

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ],
            colors: [
                .indigo, .purple, .blue,
                .blue, .cyan, .purple,
                .indigo, .teal, .blue
            ]
        )
        .onAppear {
            // Check for MeshGradient availability first
            // Note: In a real implementation we'd animate these points.
            // For this initial pass, we are just establishing the static mesh.
            // Awaiting user confirmation on exact animation speed/complexity preference.
        }
        .ignoresSafeArea()
    }
}
