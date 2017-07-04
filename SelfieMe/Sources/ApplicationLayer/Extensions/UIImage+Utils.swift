//
//  UIImage+Cropping.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 10.02.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import ImageIO


extension UIImage {

//    func croppedByFrame(frame: CGRect) -> UIImage {
//        if let _ = self.CGImage {
//            if let cgImage = CGImageCreateWithImageInRect(self.CGImage!, frame) {
//                return UIImage(CGImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
//            }
//        }
//        return self
//    }
    
    func scaled() -> UIImage {
        return self
    }
    
    class func imageWithImage(_ image: UIImage, scaledToSize size: CGSize, inRect rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale);
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func scaledToFitToSize(_ size: CGSize) -> UIImage {
        if self.size.width < size.width && self.size.height < size.height {
            return self
        }
        
        let widthScale: CGFloat = size.width / self.size.width;
        let heightScale: CGFloat = size.height / self.size.height;
        
        var scaleFactor: CGFloat = 0.0
        
        widthScale < heightScale ? (scaleFactor = widthScale) : (scaleFactor = heightScale);
        let scaledSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor);
        
        return UIImage.imageWithImage(self, scaledToSize: scaledSize, inRect: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
    }
    
    
    
    func croppedByFrame(_ rect: CGRect) -> UIImage {
        let cgImage = self.cgImage!.cropping(to: rect.applying(fixedOrientationTransform()))
        if cgImage != nil {
            return UIImage(cgImage: cgImage!, scale: self.scale, orientation: self.imageOrientation)
        }
        
        return self
    }
    
    func fixedOrientationImage() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if let _ = self.cgImage {
        let cgImage = self.cgImage!.cropping(to: rect.applying(fixedOrientationTransform()))
            if cgImage != nil {
                return UIImage(cgImage: cgImage!, scale: self.scale, orientation: self.imageOrientation)
            }
        }
        return self
    }
    
    func fixedOrientationTransform() -> CGAffineTransform {
        func rad(_ degrees: CGFloat) -> CGFloat {
            return degrees / 180.0 * CGFloat(M_PI)
        }
        
        var rectTransform: CGAffineTransform!
        switch (self.imageOrientation) {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -self.size.height)
            break
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -self.size.width, y: 0)
            break
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -self.size.width, y: -self.size.height)
            break
        default:
            rectTransform = CGAffineTransform.identity
        }
        rectTransform = rectTransform.scaledBy(x: self.scale, y: self.scale)
        
        return rectTransform
    }
    
    
    func rotatedByAngle(_ degrees: CGFloat) -> UIImage {
        func rad(_ degrees: CGFloat) -> CGFloat {
            return degrees / 180.0 * CGFloat(M_PI)
        }
        
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let t = CGAffineTransform(rotationAngle: rad(degrees))
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
        
        bitmap?.rotate(by: rad(degrees))
        
        bitmap?.scaleBy(x: 1.0, y: -1.0)
        if let i = cgImage {
            bitmap?.draw(i, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch self.imageOrientation {
        case UIImageOrientation.up:
            return CGImagePropertyOrientation.up
        case .upMirrored:
            return .upMirrored
        case .down:
            return .down
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        case .right:
            return .right
        case .rightMirrored:
            return .rightMirrored
        case .left:
            return .left
        }
    }
    
    
    class func imageEXIFOrientation() -> Int {
        let curDeviceOrientation = DeviceOrientationRecognizer.sharedInstance.deviceOrientation
        var exifOrientation = 6
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:
            exifOrientation = 8
            break
        case UIDeviceOrientation.landscapeLeft:
            exifOrientation = 1 // Для передней камеры это значение равно 3
            break
        case UIDeviceOrientation.landscapeRight:
            exifOrientation = 3 // Для передней камеры это значение равно 1
            break
        case UIDeviceOrientation.portrait:
            exifOrientation = 6
            break
        default:
            exifOrientation = 6
            break
        }
        
        return exifOrientation
    }
    
    
    func isEqualToImage(_ image: UIImage) -> Bool {
        if let data1: Data = UIImagePNGRepresentation(self), let data2: Data = UIImagePNGRepresentation(image) {
            return (data1 == data2)
        }
        return false
    }

    
    
    func imageWithWatermarkImage(watermarkImage image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, true, 0.0)
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let minSide = min(self.size.width, self.size.height)
        
        let scale: CGFloat = 0.1
        let margin: CGFloat = minSide * scale / 4.0
        let width = minSide * scale
        let height = minSide * scale
        
        let x = self.size.width - width - margin
        let y = self.size.height - height - margin
        
        image.draw(in: CGRect(x: x, y: y, width: width, height: height), blendMode: CGBlendMode.normal, alpha: 0.25)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resultImage!
    }
    
}

