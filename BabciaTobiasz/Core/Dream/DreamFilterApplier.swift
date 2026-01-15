//
//  DreamFilterApplier.swift
//  BabciaTobiasz
//
//  Added 2026-01-14 22:55 GMT
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

enum DreamFilterApplier {
    private static let context = CIContext()

    static func apply(filterId: String?, to imageData: Data) -> Data {
        guard let filterId else { return imageData }
        guard let image = UIImage(data: imageData),
              let ciImage = CIImage(image: image) else {
            return imageData
        }

        let output: CIImage
        switch filterId {
        case "dream-honey":
            output = applyColorControls(ciImage, saturation: 1.15, brightness: 0.05, contrast: 1.05)
        case "glass-moss":
            output = applyColorControls(ciImage, saturation: 0.9, brightness: 0.0, contrast: 1.1)
        case "pierogi-gold":
            output = applyColorControls(ciImage, saturation: 1.25, brightness: 0.08, contrast: 1.1)
        default:
            output = ciImage
        }

        guard let cgImage = context.createCGImage(output, from: output.extent) else {
            return imageData
        }

        let filtered = UIImage(cgImage: cgImage)
        return filtered.jpegData(compressionQuality: 0.9) ?? imageData
    }

    private static func applyColorControls(
        _ input: CIImage,
        saturation: Float,
        brightness: Float,
        contrast: Float
    ) -> CIImage {
        let controls = CIFilter.colorControls()
        controls.inputImage = input
        controls.saturation = saturation
        controls.brightness = brightness
        controls.contrast = contrast
        return controls.outputImage ?? input
    }
}
