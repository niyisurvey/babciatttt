import SwiftUI
import UIKit

struct TouchIDInteractionView: View {
    @State private var isTouched = false
    @State private var isDrawingCircle = false
    @State private var isScalingUp = false
    @State private var isDrawingCheckmark = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Button {
                    // Reset
                    if isDrawingCheckmark {
                        withAnimation {
                            isTouched = false
                            isDrawingCircle = false
                            isScalingUp = false
                            isDrawingCheckmark = false
                        }
                        return
                    }
                    
                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                    impact.impactOccurred()
                    
                    withAnimation(.easeInOut(duration: 1.0)) {
                        isDrawingCircle = true
                    }
                    
                    withAnimation(.easeInOut(duration: 1.0).delay(0.25)) {
                        isTouched = true
                    }
                    
                    withAnimation(.bouncy(duration: 0.8, extraBounce: 0.12).delay(1.25)) {
                        isScalingUp = true
                    }
                    
                    withAnimation(.easeInOut(duration: 0.8).delay(1.5)) {
                        isDrawingCheckmark = true
                    }
                    
                } label: {
                    ZStack {
                        // Background Glass
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 180, height: 180)
                            .glass()
                        
                        Circle() // Inactive
                            .stroke(.white.opacity(0.1), style: StrokeStyle(lineWidth: 6))
                            .frame(width: 120, height: 120)
                        
                        Circle() // Active ring drawing
                            .trim(from: 0.0, to: isDrawingCircle ? 1.0 : 0.0)
                            .stroke(.cyan, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                        
                        ZStack {
                            Image(systemName: "touchid") // Inactive
                                .font(.system(size: 90))
                                .foregroundStyle(.white.opacity(0.2))
                            
                            Image(systemName: "touchid") // Active
                                .font(.system(size: 90))
                                .foregroundStyle(.pink)
                                .clipShape(
                                    Rectangle()
                                        .offset(x: 0.0, y: isTouched ? 0.0 : 120.0)
                                )
                        }
                        
                        Circle() // Fill up
                            .frame(width: 120, height: 120)
                            .foregroundStyle(.cyan.gradient)
                            .scaleEffect(isScalingUp ? 1.0 : 0.0)
                        
                        Image(systemName: "checkmark") // Checkmark
                            .font(.system(size: 60, weight: .bold))
                            .foregroundStyle(.white)
                            .scaleEffect(isDrawingCheckmark ? 1 : 0.5)
                            .opacity(isDrawingCheckmark ? 1 : 0)
                            .animation(.bouncy.delay(1.6), value: isDrawingCheckmark)
                    }
                    .shadow(color: isTouched ? .pink.opacity(0.3) : .clear, radius: 20)
                }
                .buttonStyle(.plain)
                
                Text(isDrawingCheckmark ? "Authenticated" : "Tap to Scan")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.top, 40)
                    .padding(.bottom, 60)
            }
        }
    }
}
