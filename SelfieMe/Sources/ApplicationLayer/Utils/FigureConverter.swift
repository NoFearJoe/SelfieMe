//
//  FigureConverter.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 05.02.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

final class FigureConverter {
    
    class func rotateRect(_ rect: CGRect, inParentRect parentRect: CGRect, rotationsCount: Int) -> CGRect {
        var resultRect = rect
        for _ in 0..<rotationsCount {
            let originX = resultRect.origin.x
            resultRect.origin.x = resultRect.origin.y
            resultRect.origin.y = originX
            let width = resultRect.size.width
            resultRect.size.width = resultRect.size.height
            resultRect.size.height = width
        }
        return resultRect
    }
    
    
    // MARK: Функции для конвертации фигур для разных фреймов
    
    class func convertRect(_ rect: CGRect, inParentRect parentRect: CGRect, toTargetRect targetRect: CGRect) -> CGRect {
        let sizeFactors = getRectsSizeFactors(parentRect,rect2: targetRect)
        return CGRect(x: rect.origin.x   * sizeFactors.width, y: rect.origin.y    * sizeFactors.height,
                          width: rect.size.width * sizeFactors.width, height: rect.size.height * sizeFactors.height)
    }
    
    class func convertPoint(_ point: CGPoint, inParentRect parentRect: CGRect, toTargetRect targetRect: CGRect) -> CGPoint {
        let sizeFactors = getRectsSizeFactors(parentRect,rect2: targetRect)
        return CGPoint(x: point.x * sizeFactors.width, y: point.y * sizeFactors.height)
    }
    
    class func getRectsSizeFactors(_ rect1: CGRect, rect2: CGRect) -> (width: CGFloat, height: CGFloat) {
        return (width: CGFloat(rect1.size.width / rect2.size.width), height: CGFloat(rect1.size.height / rect2.size.height))
    }
    
    
    // MARK: Функции для обрезания фрейма
    
    class func getFullSizeFrame(_ parentFrame: CGRect) -> CGRect {
        return parentFrame
    }
    
    class func getSquareCropFrame(_ originalFrame: CGRect) -> CGRect {
        let size = FigureConverter.getTargetSize(originalFrame, withRatio: CGSize(width: 1, height: 1))
        let anchor = FigureConverter.getAnchorPoint(originalFrame, size: size)
        return FigureConverter.getCropFrame(originalFrame, targetSize: size, anchorPoint: anchor)
    }
    
    class func getAnchorPoint(_ originalFrame: CGRect, size: CGSize) -> CGPoint {
        return CGPoint(
            x: originalFrame.origin.x + (originalFrame.size.width - size.width) / 2,
            y: originalFrame.origin.y + (originalFrame.size.height - size.height) / 2)
    }
    
    class func getTargetSize(_ originalFrame: CGRect, withRatio ratio: CGSize) -> CGSize {
        let width = min(originalFrame.size.width, originalFrame.size.height)
        let height = width * ratio.width / ratio.height
        return CGSize(width: width, height: height)
    }
    
    class func getCropFrame(_ originalFrame: CGRect, targetSize: CGSize, anchorPoint: CGPoint) -> CGRect {
        return CGRect(
            x: originalFrame.origin.x + anchorPoint.x,
            y: originalFrame.origin.y + anchorPoint.y,
            width: targetSize.width,
            height: targetSize.height)
    }
    
    
    
    class func clapForCaptureResolution(_ mode: CaptureResolution, originalClap: CGRect) -> CGRect {
        let ratio = mode.getRatioRelativeToRect(originalClap)
        return FrameAdapter.adaptedFrame(CGRect.zero, inContainer: originalClap, withTargetRatio: CGFloat(ratio), center: true)
    }
    
    
    
    class func videoPreviewBoxForGravity(_ gravity: String, withFrameSize frameSize: CGSize, andApertureSize apertureSize: CGSize) -> CGRect {
        let apertureRatio: CGFloat = apertureSize.height / apertureSize.width
        let viewRatio: CGFloat = frameSize.width / frameSize.height
        
        var size: CGSize = CGSize.zero
        if gravity == AVLayerVideoGravityResizeAspectFill {
            if (viewRatio > apertureRatio) {
                size.width = frameSize.width
                size.height = apertureSize.width * (frameSize.width / apertureSize.height)
            } else {
                size.width = apertureSize.height * (frameSize.height / apertureSize.width)
                size.height = frameSize.height
            }
        } else if gravity == AVLayerVideoGravityResizeAspect {
            if (viewRatio > apertureRatio) {
                size.width = apertureSize.height * (frameSize.height / apertureSize.width)
                size.height = frameSize.height
            } else {
                size.width = frameSize.width
                size.height = apertureSize.width * (frameSize.width / apertureSize.height)
            }
        } else if gravity == AVLayerVideoGravityResize {
            size.width = frameSize.width
            size.height = frameSize.height
        }
        
        var videoBox = CGRect.zero
        videoBox.size = size
        if size.width < frameSize.width {
            videoBox.origin.x = (frameSize.width - size.width) / 2
        } else {
            videoBox.origin.x = (size.width - frameSize.width) / 2
        }
        
        if ( size.height < frameSize.height ) {
            videoBox.origin.y = (frameSize.height - size.height) / 2
        } else {
            videoBox.origin.y = (size.height - frameSize.height) / 2
        }
        
        return videoBox
    }
    
    
    class func viewPointToDevicePoint(_ point: CGPoint, gravity: String, withFrameSize frameSize: CGSize, andApertureSize apertureSize: CGSize) -> CGPoint {
        var resultPoint = point;
        
        let horizontalRatio = apertureSize.width / frameSize.width
        let verticalRatio = apertureSize.height / frameSize.height
        
        if gravity == AVLayerVideoGravityResizeAspectFill {
//            if (viewRatio > apertureRatio) {
//                size.width = frameSize.width
//                size.height = apertureSize.width * (frameSize.width / apertureSize.height)
//            } else {
//                size.width = apertureSize.height * (frameSize.height / apertureSize.width)
//                size.height = frameSize.height
//            }
            var x: CGFloat
            var y: CGFloat
            if horizontalRatio < 1.0 {
                x = point.x / horizontalRatio
            } else {
                x = point.x * horizontalRatio
            }
            if verticalRatio < 1.0 {
                y = point.y / verticalRatio
            } else {
                y = point.y * verticalRatio
            }
            
            resultPoint = CGPoint(x: x, y: y)
        } else if gravity == AVLayerVideoGravityResizeAspect {
//            if (viewRatio > apertureRatio) {
//                size.width = apertureSize.height * (frameSize.height / apertureSize.width)
//                size.height = frameSize.height
//            } else {
//                size.width = frameSize.width
//                size.height = apertureSize.width * (frameSize.width / apertureSize.height)
//            }
        } else if gravity == AVLayerVideoGravityResize {
//            size.width = frameSize.width
//            size.height = frameSize.height
        }
        
        return resultPoint
    }
    
    
    class func pointToRelativePoint(_ point: CGPoint, frame: CGRect) -> CGPoint {
        return CGPoint(x: point.x / frame.size.width, y: point.y / frame.size.height)
    }
    
    class func pointToViewPoint(_ point: CGPoint, frame: CGRect) -> CGPoint {
        return CGPoint(x: frame.size.width * point.x, y: frame.size.height * point.y)
    }
    
}



extension CGPoint {

    func rotated(_ degrees: CGFloat, inRect rect: CGRect) -> CGPoint {
        let t1 = CGAffineTransform(translationX: 0, y: rect.size.height)
        let s = CGAffineTransform(scaleX: 1, y: -1)
        let r = CGAffineTransform(rotationAngle: degrees * CGFloat(M_PI) / 180.0)
        let t2 = CGAffineTransform(translationX: 0, y: -rect.size.height)
        
        var p = self
        
        p = p.applying(t1)
        p = p.applying(s)
        p = p.applying(r)
        p = p.applying(t2)
        
        return p
    }
    
    func exchanged() -> CGPoint {
        return CGPoint(x: self.y, y: self.x)
    }

}
