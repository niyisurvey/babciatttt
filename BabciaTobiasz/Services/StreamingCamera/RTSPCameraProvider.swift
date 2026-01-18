//
//  RTSPCameraProvider.swift
//  BabciaTobiasz
//

import AVFoundation
import UIKit

final class RTSPCameraProvider: StreamingCameraProvider {
    let id: UUID
    let name: String
    let providerType: CameraProviderType = .rtsp

    private let url: URL
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var videoOutput: AVPlayerItemVideoOutput?

    init(id: UUID, name: String, url: URL) {
        self.id = id
        self.name = name
        self.url = url
    }

    func connect() async throws {
        if player != nil { return }

        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let output = AVPlayerItemVideoOutput(
            pixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
        )
        item.add(output)

        let player = AVPlayer(playerItem: item)
        player.automaticallyWaitsToMinimizeStalling = true
        player.play()

        self.player = player
        self.playerItem = item
        self.videoOutput = output

        try await waitForReady(item: item)
    }

    func disconnect() async {
        player?.pause()
        player = nil
        playerItem = nil
        videoOutput = nil
    }

    func captureFrame() async throws -> UIImage {
        if player == nil {
            try await connect()
        }

        guard let item = playerItem, let output = videoOutput else {
            throw StreamingCameraError.connectionFailed
        }

        let maxAttempts = 10
        for _ in 0..<maxAttempts {
            let itemTime = item.currentTime()
            if output.hasNewPixelBuffer(forItemTime: itemTime),
               let buffer = output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) {
                return StreamingCameraImageConverter.image(from: buffer)
            }
            try? await Task.sleep(nanoseconds: 150_000_000)
        }

        throw StreamingCameraError.frameUnavailable
    }

    func streamURL() -> URL? {
        url
    }

    private func waitForReady(item: AVPlayerItem) async throws {
        let maxAttempts = 20
        for _ in 0..<maxAttempts {
            if item.status == .readyToPlay {
                return
            }
            if item.status == .failed {
                throw StreamingCameraError.connectionFailed
            }
            try? await Task.sleep(nanoseconds: 150_000_000)
        }
    }
}
