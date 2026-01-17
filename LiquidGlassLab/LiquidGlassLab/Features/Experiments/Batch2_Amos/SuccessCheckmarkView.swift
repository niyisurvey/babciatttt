import SwiftUI

struct SuccessCheckmarkView: View {
    @State private var isSuccess = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Button {
                    isSuccess = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isSuccess = true
                    }
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 120, height: 120)
                            .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                            .shadow(color: .black.opacity(0.2), radius: 20)
                        
                        if isSuccess {
                            // Circle Draw
                            Circle()
                                .trim(from: 0, to: 1)
                                .stroke(Color.green, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .transition(.identity) // Keep it simple
                                .animation(.easeOut(duration: 0.6), value: isSuccess) // Actually need custom transition for trim? 
                                // Simplified approach: just change trim state
                        }
                        
                        CheckmarkShape()
                            .trim(from: 0, to: isSuccess ? 1 : 0)
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                            .frame(width: 60, height: 60)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.2), value: isSuccess)
                    }
                }
                .padding(.bottom, 60)
                
                Text(isSuccess ? "Success!" : "Tap to Verify")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))
                    .animation(.default, value: isSuccess)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            isSuccess = true
        }
    }
}

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Draw checkmark
        path.move(to: CGPoint(x: rect.width * 0.1, y: rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width * 0.4, y: rect.height * 0.8))
        path.addLine(to: CGPoint(x: rect.width * 0.9, y: rect.height * 0.1))
        return path
    }
}
