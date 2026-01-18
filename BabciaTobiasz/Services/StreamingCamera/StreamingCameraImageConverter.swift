//
//  StreamingCameraImageConverter.swift
//  BabciaTobiasz
//

import CoreVideo
import UIKit

enum StreamingCameraImageConverter {
    static func image(from pixelBuffer: CVPixelBuffer) -> UIImage {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return UIImage()
        }
        return UIImage(cgImage: cgImage)
    }
}
