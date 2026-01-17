import SwiftUI

struct SpringHeroHeaderView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    let global = proxy.frame(in: .global)
                    let minY = global.minY
                    // Stretchy logic
                    let height = 300 + (minY > 0 ? minY : 0)
                    
                    ZStack {
                        Image(systemName: "bubbles.and.sparkles.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: proxy.size.width, height: height)
                            .clipped()
                            .foregroundStyle(LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom))
                            .offset(y: minY > 0 ? -minY : 0)
                        
                        Text("Stretchy Header")
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .foregroundStyle(.white)
                            .offset(y: minY > 0 ? -minY/2 : 0) // Parallax
                    }
                }
                .frame(height: 300)
                
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(0..<10) { i in
                        HStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 50, height: 50)
                            VStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.3))
                                    .frame(width: 200, height: 20)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.1))
                                    .frame(width: 150, height: 16)
                            }
                        }
                        .padding()
                        .glass()
                    }
                }
                .padding()
            }
        }
    }
}
