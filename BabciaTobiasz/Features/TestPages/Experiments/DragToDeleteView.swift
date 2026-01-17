import SwiftUI

/// Drag to Delete (adapted from mikelikesdesign)
/// Drag an item towards a trash icon to delete it with interactive scaling
struct DragToDeleteView: View {
    @State private var imageSize: CGFloat = 320
    @State private var showCircle = false
    @State private var circleSize: CGFloat = 64
    @State private var showImage = true
    @State private var initialCircleGrowth = false
    @State private var dragPosition: CGPoint = .zero
    @State private var shrinkCircle = false
    @State private var hasInitialized = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Content Information
                VStack {
                    Text("🗑️ Drag to Delete")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.top, 60)
                    Text("Drag the card into the trash")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                
                // Trash Circle
                VStack {
                    Spacer()
                    if showCircle {
                        ZStack {
                            Circle()
                                .fill(.red.gradient)
                                .frame(width: circleSize, height: circleSize)
                                .scaleEffect(initialCircleGrowth ? 0 : 1)
                                .scaleEffect(shrinkCircle ? 0 : 1)
                            
                            Image(systemName: "trash.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                        }
                        .padding(.bottom, 40)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                
                // Draggable Item
                if showImage {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: imageSize, height: imageSize)
                        .overlay(
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.white.opacity(0.8))
                                Text("DRAG ME")
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(.white)
                            }
                        )
                        .position(dragPosition)
                        .shadow(radius: 20)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragPosition = value.location
                                    
                                    if !showCircle {
                                        withAnimation(.spring()) {
                                            showCircle = true
                                            initialCircleGrowth = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            initialCircleGrowth = false
                                        }
                                    }
                                    
                                    let dragY = value.location.y
                                    let circleY = geometry.size.height - 80
                                    let dist = circleY - dragY
                                    
                                    if dist > 0 {
                                        let prop = min(1, max(0, dist / circleY))
                                        circleSize = 64 + (40 * (1 - prop))
                                        imageSize = 80 + (240 * prop)
                                    } else {
                                        circleSize = 104
                                        imageSize = 80
                                    }
                                }
                                .onEnded { _ in
                                    if circleSize > 90 {
                                        withAnimation(.spring()) {
                                            showImage = false
                                            shrinkCircle = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            showCircle = false
                                            reset(in: geometry.size)
                                        }
                                    } else {
                                        withAnimation(.spring()) {
                                            reset(in: geometry.size)
                                        }
                                    }
                                }
                        )
                }
            }
            .onAppear {
                if !hasInitialized {
                    reset(in: geometry.size)
                    hasInitialized = true
                }
            }
        }
        .navigationTitle("Drag to Delete")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func reset(in size: CGSize) {
        imageSize = 320
        showCircle = false
        circleSize = 64
        showImage = true
        initialCircleGrowth = false
        shrinkCircle = false
        dragPosition = CGPoint(x: size.width / 2, y: 300)
    }
}

#Preview {
    NavigationStack {
        DragToDeleteView()
    }
}
