import SwiftUI

struct DownloadButtonView: View {
    @State private var downloadState: DownloadState = .idle
    @State private var progress: CGFloat = 0.0
    
    enum DownloadState {
        case idle, downloading, finished
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Button {
                    guard downloadState == .idle else { return }
                    
                    // Start Download
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        downloadState = .downloading
                    }
                    
                    // Simulate Progress
                    Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                        if progress < 1.0 {
                            progress += 0.02
                        } else {
                            timer.invalidate()
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                downloadState = .finished
                            }
                            
                            // Reset
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    downloadState = .idle
                                    progress = 0
                                }
                            }
                        }
                    }
                    
                } label: {
                    ZStack {
                        // Background Capsule -> Circle
                        RoundedRectangle(cornerRadius: downloadState == .idle ? 16 : 30)
                            .fill(downloadState == .finished ? Color.green : Color.blue)
                            .frame(width: downloadState == .idle ? 200 : 60, height: 60)
                            .shadow(color: (downloadState == .finished ? Color.green : Color.blue).opacity(0.4), radius: 10, y: 5)
                        
                        // Text: Download
                        Text("Download")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .opacity(downloadState == .idle ? 1 : 0)
                            .scaleEffect(downloadState == .idle ? 1 : 0.5)
                        
                        // Progress Indicator
                        if downloadState == .downloading {
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(-90))
                        }
                        
                        // Checkmark
                        if downloadState == .finished {
                            Image(systemName: "checkmark")
                                .font(.title)
                                .foregroundStyle(.white)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: downloadState)
                }
                .padding(.bottom, 60)
            }
        }
    }
}
