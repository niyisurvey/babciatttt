//
//  StreamingCameraMonitor.swift
//  BabciaTobiasz
//

import Foundation
import UIKit

@MainActor
final class StreamingCameraMonitor {
    private var task: Task<Void, Never>?
    private(set) var isMonitoring: Bool = false

    func start(
        interval: TimeInterval,
        manager: StreamingCameraManager,
        onFrame: @escaping (StreamingCameraConfig, UIImage) -> Void
    ) {
        stop()
        guard interval > 0 else { return }
        isMonitoring = true
        task = Task { @MainActor in
            while !Task.isCancelled {
                let cameras = manager.configs
                for camera in cameras {
                    if Task.isCancelled { break }
                    do {
                        let frame = try await manager.captureFrame(for: camera)
                        onFrame(camera, frame)
                    } catch {
                        continue
                    }
                }
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        isMonitoring = false
    }
}
