//
//  DeviceOrientationRecognizer.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 19.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit


let DeviceOrientationDidChangeNotificationKey = "DeviceOrientationWillChangeNotificationKey"

final class DeviceOrientationRecognizer: NSObject {

    fileprivate var motionQueue: OperationQueue!
    fileprivate var motionManager: CMMotionManager!
    
    var deviceOrientation: UIDeviceOrientation = .portrait {
        didSet {
            notifyDeviceOrientationDidChange(deviceOrientation)
        }
    }
    
    static let sharedInstance: DeviceOrientationRecognizer = DeviceOrientationRecognizer()
    
    fileprivate override init() {
        motionQueue = OperationQueue()
        motionQueue.maxConcurrentOperationCount = 1
        
        motionManager = CMMotionManager()
        
        super.init()
    }
    
    
    func startRecognition() {
        motionQueue = OperationQueue()
        
        if !self.motionManager.isDeviceMotionActive {
            self.motionManager.accelerometerUpdateInterval = 0.1
            self.motionManager.startAccelerometerUpdates(to: self.motionQueue, withHandler: { [weak self] (data, error) -> Void in
                if let _ = data {
                    self!.recognizeDeviceOrientationWithAccelerometerData(data!)
                }
            })
//            self.motionManager.startDeviceMotionUpdates()
//            self.motionManager.accelerometerUpdateInterval = 60
//            self.motionManager.startDeviceMotionUpdatesToQueue(self.motionQueue, withHandler: { [weak self] (motion, error) -> Void in
//                if let _ = motion {
//                    self!.recognizeDeviceOrientationWithDeviceMotion(motion!)
//                }
//            })
        }
    }
    
    func stopRecognition() {
        if self.motionManager.isAccelerometerActive {
            self.motionManager.stopAccelerometerUpdates()
        }
        if self.motionManager.isDeviceMotionActive {
            self.motionManager.stopDeviceMotionUpdates()
        }
    }
    
    
    fileprivate func recognizeDeviceOrientationWithDeviceMotion(_ motion: CMDeviceMotion) {
        let x = motion.gravity.x
        let y = motion.gravity.y
        
        let angle = atan2(y, x)
        
        if  angle >= -2.25 && angle <= -0.25
        {
            if self.deviceOrientation != UIDeviceOrientation.portrait {
                self.deviceOrientation = .portrait
            }
        }
        else if angle >= -1.75 && angle <= 0.75
        {
            if self.deviceOrientation != UIDeviceOrientation.landscapeRight {
                self.deviceOrientation = .landscapeRight
            }
        }
        else if angle >= 0.75 && angle <= 2.25
        {
            if self.deviceOrientation != UIDeviceOrientation.portraitUpsideDown {
                self.deviceOrientation = .portraitUpsideDown
            }
        }
        else if angle <= -2.25 || angle >= 2.25
        {
            if self.deviceOrientation != UIDeviceOrientation.landscapeLeft {
                self.deviceOrientation = .landscapeLeft
            }
        }
    }
    
    fileprivate func recognizeDeviceOrientationWithAccelerometerData(_ data: CMAccelerometerData) {
        let x = -data.acceleration.x
        let y = data.acceleration.y
        let z = data.acceleration.z
        
        let angle = atan2(y, x)
        let absZ = fabs(z)
        
        if absZ > 0.8 {
            if z > 0.0 {
                if deviceOrientation != .faceDown {
                    deviceOrientation = .faceDown
                }
            } else {
                if deviceOrientation != .faceUp {
                    deviceOrientation = .faceUp
                }
            }
        } else if angle >= -2.25 && angle <= -0.75 {
            if deviceOrientation != .portrait {
                deviceOrientation = .portrait
            }
        } else if angle >= -0.5 && angle <= 0.5 {
            if deviceOrientation != .landscapeLeft {
                deviceOrientation = .landscapeLeft
            }
        } else if angle >= 1.0 && angle <= 2.0 {
            if deviceOrientation != .portraitUpsideDown {
                deviceOrientation = .portraitUpsideDown
            }
        } else if angle <= -2.5 || angle >= 2.5 {
            if deviceOrientation != .landscapeRight {
                deviceOrientation = .landscapeRight
            }
        } else {
            if deviceOrientation != .portrait {
                deviceOrientation = .portrait
            }
        }
    }
    
    
    func postCurrentDeviceOrientation() {
        notifyDeviceOrientationDidChange(self.deviceOrientation)
    }
    
    
    fileprivate func notifyDeviceOrientationDidChange(_ orientation: UIDeviceOrientation) {
        DispatchQueue.main.async { () -> Void in
            let notification = Notification(name: Notification.Name(rawValue: DeviceOrientationDidChangeNotificationKey), object: orientation.rawValue)
            NotificationCenter.default.post(notification)
        }
    }
    
}
