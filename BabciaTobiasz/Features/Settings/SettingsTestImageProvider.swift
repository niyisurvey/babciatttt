//
//  SettingsTestImageProvider.swift
//  BabciaTobiasz
//
//  Loads a small test image for API key validation.
//

import Foundation
import UIKit

enum SettingsTestImageProvider {
    static func loadJPEGData() -> Data? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 64, height: 64))
        let image = renderer.image { context in
            UIColor.systemGray.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: 64, height: 64)))
        }
        if let data = image.jpegData(compressionQuality: 0.7) {
            return data
        }

        if let fallback = UIImage(named: "DreamRoom_Test_1200x1600"),
           let data = fallback.jpegData(compressionQuality: 0.7) {
            return data
        }

        return nil
    }
}
