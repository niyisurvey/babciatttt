import SwiftUI

@main
struct LiquidGlassApp: App {
    var body: some Scene {
        WindowGroup {
            LiquidGlassPager()
                .preferredColorScheme(.dark) // Default to dark for that premium glass look
        }
    }
}
