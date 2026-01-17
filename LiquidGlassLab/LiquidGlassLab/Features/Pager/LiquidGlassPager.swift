import SwiftUI

struct LiquidGlassPager: View {
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            if #available(iOS 18.0, *) {
                MeshGradientBackground()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            TabView {
                ForEach(0..<20) { index in
                    VStack {
                        if index == 0 {
                            ParticleSliderView()
                        } else if index == 1 {
                            PixelAnimationView()
                        } else if index == 2 {
                            ShinyTextView()
                        } else if index == 3 {
                            ExplodingTextView()
                        } else if index == 4 {
                            PhotoSlingshotView()
                        } else if index == 5 {
                            WavePatternView()
                        } else if index == 6 {
                            BouncyGridView()
                        } else if index == 7 {
                            LiquidMetalView()
                        } else if index == 8 {
                            LikeInteractionView()
                        } else if index == 9 {
                            SlideActionView()
                        } else if index == 10 {
                            DownloadButtonView()
                        } else if index == 11 {
                            SuccessCheckmarkView()
                        } else if index == 12 {
                            ScrollWaveView()
                        } else if index == 13 {
                            PulseRipplesView()
                        } else if index == 14 {
                            MetaballBlobView()
                        } else if index == 15 {
                            TouchIDInteractionView()
                        } else if index == 16 {
                            CardSwipeView()
                        } else if index == 17 {
                            SpringHeroHeaderView()
                        } else {
                            Text("Experiment #\(index + 1)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text("Coming Soon")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding()
                                .glass()
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .overlay(alignment: .topTrailing) {
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding()
                        .glass()
                }
                .padding()
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet()
            }
        }
    }
}
