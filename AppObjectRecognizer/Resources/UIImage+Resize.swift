//
//  PredictionModel.swift
//  AppObjectRecognizer
//
//  Created by APPLE on 10/06/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit

// MARK: - UIImage Extension
/// Esta extension de UIImage encapsula metodos para el redimensionamiento

extension UIImage {
    /// Metodo de UIImage que recibe un tamaño y se autoredimensiona a éste
    func resize(_ maxSize: CGFloat = 500) -> UIImage {
        return UIGraphicsImageRenderer(size: CGSize(width: maxSize, height: maxSize)).image(actions: { _ in
            self.draw(in: CGRect(origin: .zero, size: CGSize(width: maxSize, height: maxSize)))
        })
    }
    
    /// Propiedad compuetada que nos devuelve el tipo CVPixelBuffer de una UIImage
    var pixelBuffer: CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else { return nil }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
