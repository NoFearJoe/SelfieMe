//
//  MultiStateButton.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 14.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit



@IBDesignable final class MultiStateButton: UIButton {
    
    @IBInspectable var iconInactiveStateColor: UIColor = Theme.tintColor
    @IBInspectable var iconActiveStateColor: UIColor = Theme.mainColor
    @IBInspectable var textLabelInactiveStateColor: UIColor = Theme.tintColor
    @IBInspectable var textLabelActiveStateColor: UIColor = Theme.mainColor
    
    
    var preventRotations: Bool = Device.iPad ? false : false
    
    
    fileprivate var staticTitleLabel: UILabel!
    
    
    var buttonState: MultiStateButtonState? {
        didSet {
            if let _ = buttonState {
                setImage(buttonState!.icon.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
                
                staticTitleLabel.text = buttonState!.title
                staticTitleLabel.font = UIFont.systemFont(ofSize: frame.size.height / 2.0 - 1)
                staticTitleLabel.sizeToFit()
                let y = (frame.size.height - staticTitleLabel.frame.size.height) / 2.0
                let size = max(staticTitleLabel.frame.size.width, staticTitleLabel.frame.size.height)
                staticTitleLabel.frame = CGRect(x: -size - 6, y: y, width: size, height: size)
                staticTitleLabel.center = CGPoint(x: -size - 6 + staticTitleLabel.frame.size.width / 2.0, y: frame.size.height / 2.0)
                
                if let _ = staticTitleLabel.text , staticTitleLabel.text!.characters.count != 0 {
                    tintColor = iconInactiveStateColor
                    staticTitleLabel.textColor = textLabelActiveStateColor
                } else {
                    let color = buttonState!.isActive ? iconActiveStateColor : iconInactiveStateColor
                    tintColor = color
                }
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
        
        staticTitleLabel = UILabel()
        staticTitleLabel.textAlignment = .center
        staticTitleLabel.clipsToBounds = false
        addSubview(staticTitleLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        clipsToBounds = false
        
        staticTitleLabel = UILabel()
        staticTitleLabel.textAlignment = .center
        staticTitleLabel.clipsToBounds = false
        addSubview(staticTitleLabel)
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
            selector: #selector(MultiStateButton.onApplicationWillEnterForeground(_:)),
            name: NSNotification.Name.UIApplicationWillEnterForeground,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(MultiStateButton.onApplicationWillResignActive(_:)),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(MultiStateButton.onApplicationDidEnterBackground(_:)),
            name: NSNotification.Name.UIApplicationDidEnterBackground,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(MultiStateButton.onApplicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }
    
    fileprivate func removeAllObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    fileprivate func addDeviceOrientationObserver() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(MultiStateButton.onDeviceOrientationChanged(_:)),
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

extension MultiStateButton: Rotatable {

    func rotate(_ angle: Float, animated: Bool) {
        let rotation = CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
        
        if animated {
            UIView.animate(withDuration: Animation.defaultDuration,
                delay: 0.0,
                options: UIViewAnimationOptions(),
                animations: { [weak self] () -> Void in
                    self?.imageView?.layer.transform = rotation
                    self?.staticTitleLabel.layer.transform = rotation
                },
                completion: nil
            )
        } else {
            self.imageView?.layer.transform = rotation
            self.staticTitleLabel.layer.transform = rotation
        }
    }

}




struct MultiStateButtonState: Hashable {

    let icon: UIImage
    let title: String
    let isActive: Bool

    var hashValue: Int {
        return title.hashValue + isActive.hashValue
    }
    
}

func ==(lhs: MultiStateButtonState, rhs: MultiStateButtonState) -> Bool {
    return lhs.icon == rhs.icon && lhs.title == rhs.title
}
