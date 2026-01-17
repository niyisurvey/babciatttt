import SwiftUI

struct LockKeyView: View {
    @Binding var isOpening: Bool
    let easeInOutBack = Animation.timingCurve(0.68, -0.6, 0.32, 1.6).delay(0.25)
    
    var body: some View {
        VStack {
            VStack {
                RoundedRectangle(cornerRadius: 9)
                    .trim(from: 0.3, to: 1)
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 18, height: 24)
                    .offset(y: isOpening ? -10 : 0) // Moves up when opening
                    .animation(easeInOutBack, value: isOpening)
                
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 24, height: 24)
            }
            .foregroundStyle(.white)
        }
    }
}
