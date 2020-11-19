//
//  UIImage+Extension.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/12/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension UIImage {
    var thumbnail: UIImage? {
        guard let imageData = jpegData(compressionQuality: 1) else {
            return nil
        }

        let scale = CGFloat(0.08)
        let maxPixelSize = max(size.width, size.height) * scale

        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize] as CFDictionary

        guard let source = CGImageSourceCreateWithData(imageData as CFData,
                                                       nil) else {
            return nil
        }

        guard let imageReference = CGImageSourceCreateThumbnailAtIndex(source,
                                                                       0,
                                                                       options) else {
            return nil
        }
        return UIImage(cgImage: imageReference)
    }
}
