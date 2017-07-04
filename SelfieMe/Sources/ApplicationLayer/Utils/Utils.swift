//
//  Utils.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 19.01.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

final class Utils {
    
    class func angleForCurrentDeviceOrientation() -> Float {
        let orientation = DeviceOrientationRecognizer.sharedInstance.deviceOrientation
        
        switch orientation {
        case .faceUp: return -1.0
        case .faceDown: return -1.0
        case .portrait: return 0.0
        case .portraitUpsideDown: return 180.0
        case .landscapeLeft: return 90.0
        case .landscapeRight: return 270.0
        case .unknown: return 0.0
        }
    }
    
    class func angleForCurrentInterfaceOrientation() -> Float {
        let orientation = UIApplication.shared.statusBarOrientation
        
        switch orientation {
        case .portrait: return 0.0
        case .portraitUpsideDown: return 180.0
        case .landscapeLeft: return 90.0
        case .landscapeRight: return 270.0
        case .unknown: return 0.0
        }
    }
    
    class func degreesToRadians(_ degrees: Float) -> Float {
        return degrees * Float(M_PI) / 180.0
    }
    
    class func radiansToDegrees(_ radians: Float) -> Float {
        return radians * 180.0 / Float(M_PI)
    }
    
    class func enlargePointToRect(_ point: CGPoint, size: CGSize) -> CGRect {
        return CGRect(x: point.x - size.width / 2, y: point.y - size.height / 2, width: size.width, height: size.height)
    }
    
    
    
    
    class func deviceOrientationToCaptureVideoOrientation(_ orientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        switch (orientation) {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown;
        case .landscapeLeft: return .landscapeRight;
        case .landscapeRight: return .landscapeLeft;
        default: return .portrait;
        }
    }
    
    
    class func euclidianDistance(_ point1: CGPoint, point2: CGPoint) -> CGFloat {
        return sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2))
    }
    
    
    
    class func videoOrientationToImageOrientation(_ orientation: AVCaptureVideoOrientation) -> UIImageOrientation {
        switch orientation {
        case .portrait: return .up
        case .portraitUpsideDown: return .down
        case .landscapeLeft: return .left
        case .landscapeRight: return .right
        }
    }
    
    class func interfaceOrientationToImageOrientation(_ orientation: UIInterfaceOrientation) -> UIImageOrientation {
        switch orientation {
        case .portrait: return .up
        case .portraitUpsideDown: return .down
        case .landscapeLeft: return .left
        case .landscapeRight: return .right
        case .unknown: return .up
        }
    }
    
    class func deviceOrientationToImageOrientation(_ orientation: UIDeviceOrientation) -> UIImageOrientation {
        switch orientation {
        case .unknown: fallthrough
        case .faceDown: fallthrough
        case .faceUp: fallthrough
        case .portrait: return .up
        case .portraitUpsideDown: return .down
        case .landscapeLeft: return .left
        case .landscapeRight: return .right
        }
    }
    
}
