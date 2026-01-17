import SwiftUI

struct CardSwipeView: View {
    @State private var offset = CGSize.zero
    @State private var color: Color = .black
    @State private var showHeart = false
    @State private var showDislike = false
    @State private var isDraggingLeft = false
    @State private var isDraggingRight = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                ZStack {
                    // Card
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .frame(width: 320, height: 420)
                        .glass()
                        .shadow(radius: 20)
                        .hueRotation(.degrees(isDraggingRight ? 220 : 0))
                        .rotation3DEffect(
                            .degrees(isDraggingRight ? -30 : 0), axis: (x: -45, y: 45.0, z: -15.0),
                            perspective: 0.5
                        )
                        .blur(radius: isDraggingLeft ? 5 : 0)
                        .overlay(
                            VStack {
                                Image(systemName: "person.crop.rectangle.fill")
                                    .font(.system(size: 100))
                                    .foregroundStyle(.white.opacity(0.5))
                                Text("Drag Me")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.top)
                            }
                        )
                    
                    HStack {
                        if isDraggingLeft {
                            Image(systemName: "hand.thumbsdown.fill")
                                .font(.system(size: 80))
                                .bold()
                                .foregroundColor(.red)
                                .scaleEffect(showDislike ? 1 : 0)
                                .animation(.snappy, value: showDislike)
                        } else {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 80))
                                .bold()
                                .foregroundColor(.green)
                                .scaleEffect(showHeart ? 1 : 0)
                                .animation(.bouncy, value: showHeart)
                        }
                    }
                }
                .offset(x: offset.width, y: 0)
                .rotationEffect(.degrees(Double(offset.width / 20)))
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = gesture.translation
                            withAnimation {
                                showHeart = offset.width > 50
                                showDislike = offset.width < -50
                                isDraggingLeft = offset.width < -50
                                isDraggingRight = offset.width > 50
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.bouncy(duration: 0.5, extraBounce: 0.5)) {
                                offset = .zero
                                showHeart = false
                                showDislike = false
                                isDraggingLeft = false
                                isDraggingRight = false
                            }
                        }
                )
                
                Spacer()
                Text("Spring Physics Swipe")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 60)
            }
        }
    }
}
