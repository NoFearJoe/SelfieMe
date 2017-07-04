//
//  RotatableButton.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 21.01.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit

class RotatableButton: UIButton {
    
    var preventRotations = Device.iPad ? false : false
    
    fileprivate var hasAnimation: Bool = false
    
    override required init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        addApplicationObservers()
    }
    
    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        removeAllObservers()
    }
    
    
    fileprivate func addApplicationObservers() {
        addDeviceOrientationObserver()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(RotatableButton.onApplicationWillEnterForeground(_:)),
            name: NSNotification.Name.UIApplicationWillEnterForeground,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(RotatableButton.onApplicationWillResignActive(_:)),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(RotatableButton.onApplicationDidEnterBackground(_:)),
            name: NSNotification.Name.UIApplicationDidEnterBackground,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(RotatableButton.onApplicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }
    
    fileprivate func removeAllObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    fileprivate func addDeviceOrientationObserver() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(RotatableButton.onDeviceOrientationChanged(_:)),
            name: NSNotification.Name(rawValue: DeviceOrientationDidChangeNotificationKey),
            object: nil)
    }
    
    fileprivate func removeDeviceOrientationObserver() {
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name(rawValue: DeviceOrientationDidChangeNotificationKey),
            object: nil)
    }
    
    
    func onApplicationWillEnterForeground(_ notification: Notification) {
        addDeviceOrientationObserver()
    }
    
    func onApplicationWillResignActive(_ notification: Notification) {
        removeDeviceOrientationObserver()
    }
    
    func onApplicationDidEnterBackground(_ notification: Notification) {
        removeDeviceOrientationObserver()
    }
    
    func onApplicationDidBecomeActive(_ notification: Notification) {
        addDeviceOrientationObserver()
    }
    
    
    fileprivate func rotate(_ animated: Bool) {
        let degrees = Utils.angleForCurrentDeviceOrientation()
        
        guard degrees != -1.0 else { return }
        
        let angle = Utils.degreesToRadians(degrees)
        
        rotate(angle, animated: animated)
    }
    
    func onDeviceOrientationChanged(_ notification: Notification) {
        if !preventRotations {
            rotate(true)
        }
    }
    
}


extension RotatableButton: Rotatable {
    
    func rotate(_ angle: Float, animated: Bool) {
        let rotation = CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
        
        if animated {
            UIView.animate(withDuration: Animation.defaultDuration,
                delay: 0.0,
                options: UIViewAnimationOptions(),
                animations: { [weak self] () -> Void in
                    self?.hasAnimation = true
                    
                    self?.layer.transform = rotation
                },
                completion: { [weak self] (success) -> Void in
                    self?.hasAnimation = false
                }
            )
        } else {
            self.layer.transform = rotation
        }
    }

}
