import SwiftUI

struct MetaballBlobView: View {
    @State private var offset1 = CGPoint(x: 100, y: 100)
    @State private var offset2 = CGPoint(x: 250, y: 300)
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let date = timeline.date.timeIntervalSinceReferenceDate
            let angle1 = date
            let angle2 = date * 1.5 + 2.0
            
            let center = CGPoint(x: 200, y: 300)
            let radius1 = 80.0
            let radius2 = 100.0
            
            let p1 = CGPoint(
                x: center.x + cos(angle1) * radius1,
                y: center.y + sin(angle1) * radius1
            )
            
            let p2 = CGPoint(
                x: center.x + cos(angle2) * radius2,
                y: center.y + sin(angle2) * radius2
            )
            
            Canvas { context, size in
                // Metaball Filter Layer
                context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                context.addFilter(.blur(radius: 30))
                
                // Draw Symbols (Circles)
                context.drawLayer { ctx in
                    // Blob 1
                    ctx.fill(
                        Circle().path(in: CGRect(x: p1.x - 60, y: p1.y - 60, width: 120, height: 120)),
                        with: .color(.white)
                    )
                    
                    // Blob 2
                    ctx.fill(
                        Circle().path(in: CGRect(x: p2.x - 70, y: p2.y - 70, width: 140, height: 140)),
                        with: .color(.white)
                    )
                    
                    // Center Anchor
                    ctx.fill(
                        Circle().path(in: CGRect(x: size.width/2 - 50, y: size.height/2 - 50, width: 100, height: 100)),
                        with: .color(.white)
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Colorize the result
            .overlay(
                LinearGradient(colors: [.cyan, .blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask {
                        Canvas { context, size in
                            context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                            context.addFilter(.blur(radius: 30))
                            
                            context.drawLayer { ctx in
                                ctx.fill(
                                    Circle().path(in: CGRect(x: p1.x - 60, y: p1.y - 60, width: 120, height: 120)),
                                    with: .color(.white)
                                )
                                ctx.fill(
                                    Circle().path(in: CGRect(x: p2.x - 70, y: p2.y - 70, width: 140, height: 140)),
                                    with: .color(.white)
                                )
                                ctx.fill(
                                    Circle().path(in: CGRect(x: size.width/2 - 50, y: size.height/2 - 50, width: 100, height: 100)),
                                    with: .color(.white)
                                )
                            }
                        }
                    }
            )
            
            VStack {
                Spacer()
                Text("Metaball Blobs")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 80)
            }
        }
    }
}
