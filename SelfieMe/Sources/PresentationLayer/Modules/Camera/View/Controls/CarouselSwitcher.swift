//
//  CarouselSwitcher.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 19.01.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit

enum SwitchDirection {
    case forward
    case backward
}

protocol CarouselSwitcherDelegate {
    func carouselSwitcher(_ switcher: CarouselSwitcher, willChangeItemIndex index:UInt)
    func carouselSwitcher(_ switcher: CarouselSwitcher, didChangeItemIndex index:UInt)
}

@IBDesignable class CarouselSwitcher: UIView {
    
    var delegate: CarouselSwitcherDelegate?
    
    @IBInspectable var labelFont: UIFont = UIFont.systemFont(ofSize: 13)
    @IBInspectable var activeItemColor: UIColor = Theme.mainColor
    @IBInspectable var inactiveItemColor: UIColor = Theme.tintColor
    @IBInspectable var visibleItemsCount: UInt = 3
    
    var items: [String]?
    fileprivate lazy var labels = [UILabel]()
    
    var preventRotations = Device.iPad ? false : true
    
    fileprivate var activeItemIndex: UInt = 1
    var activeItem: String? {
        get {
            if let i = items {
                return i[Int(activeItemIndex)]
            }
            
            return nil
        }
    }
    
    fileprivate var hasAnimation = false
    
    func switchToNextItem() {
        guard !hasAnimation else { return }
        if let i = items {
            if Int(activeItemIndex) + 1 < i.count {
                activeItemIndex += 1
                switchToItemAtIndex(activeItemIndex, direction: .forward, animated: true)
            }
        }
    }
    
    func switchToPreviousItem() {
        guard !hasAnimation else { return }
        if let _ = items{
            if Int(activeItemIndex) - 1 >= 0 {
                activeItemIndex -= 1
                switchToItemAtIndex(activeItemIndex, direction: .backward, animated: true)
            }
        }
    }
    
    
    fileprivate func switchToItemAtIndex(_ index: UInt, direction: SwitchDirection, animated: Bool) {
        delegate?.carouselSwitcher(self, willChangeItemIndex: index)
        
        calibrateFrame(activeItemIndex, direction: .forward, animated: true) { [weak self] () -> Void in
            self?.delegate?.carouselSwitcher(self!, didChangeItemIndex: UInt(index))
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CarouselSwitcher.onDeviceOrientationChanged(_:)), name: NSNotification.Name(rawValue: DeviceOrientationDidChangeNotificationKey), object: nil)
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(CarouselSwitcher.switchToPreviousItem))
        rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(CarouselSwitcher.switchToNextItem))
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CarouselSwitcher.onSingleTap(_:)))
        
        self.addGestureRecognizer(rightSwipeGestureRecognizer)
        self.addGestureRecognizer(leftSwipeGestureRecognizer)
        self.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func build() {
        self.layoutIfNeeded()
        
        if let i = items {
            for index in 0..<i.count {
                let centerDistance: Double = Double(index - Int(activeItemIndex))

                let label = UILabel()
                label.text = i[index]
                label.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                label.frame = rectForLabel(label, withCenterDistance: Int(centerDistance))
                label.textColor = index == Int(activeItemIndex) ? activeItemColor : inactiveItemColor
                label.font = labelFont
                label.textAlignment = NSTextAlignment.center
                
                self.addSubview(label)
                
                labels.append(label)
            }
            
            if !preventRotations {
                rotate(false)
            }
        }
    }
    
    fileprivate func calibrateFrame(_ index: UInt, direction: SwitchDirection, animated: Bool, completion: (() -> Void)?) {
        let itemWidth = self.frame.size.width / CGFloat(visibleItemsCount)
        
        for i in 0..<labels.count {
            var newFrame = labels[i].frame
            
            switch direction {
            case .forward:
                newFrame.origin.x -= itemWidth
                break
            case .backward:
                newFrame.origin.x += itemWidth
                break
            }
            
            UIView.animate(withDuration: animated ? Animation.defaultDuration : 0.0,
                delay: 0.0,
                options: UIViewAnimationOptions(),
                animations: { [weak self] () -> Void in
                    if self != nil {
                        self!.hasAnimation = true
                        
                        let centerDistance = i - Int(index)
                        self!.labels[i].frame = self!.rectForLabel(self!.labels[i], withCenterDistance: centerDistance)
                    }
                },
                completion: { [weak self] (success) -> Void in
                    if self != nil {
                        self!.hasAnimation = false
                    
                        self!.labels[i].textColor = Int(index) == i ? self!.activeItemColor : self!.inactiveItemColor
                    }
                    
                    completion?()
                }
            )
        }

    }
    
    func onDeviceOrientationChanged(_ notification: Notification) {
        if !preventRotations {
            rotate(true)
        }
        
        calibrateFrame(activeItemIndex, direction: .forward, animated: false, completion: nil)
    }
    
    func rotate(_ animated: Bool) {
        let degrees = Utils.angleForCurrentDeviceOrientation()
        
        guard degrees != -1.0 else { return }
        
        let angle = Utils.degreesToRadians(degrees)
        
        rotate(angle, animated: animated)
    }
    
    fileprivate func rectForLabel(_ label: UILabel, withCenterDistance distance: Int) -> CGRect {
        let center = self.frame.size.width / 2
        let itemWidth = self.frame.size.width / CGFloat(visibleItemsCount)
        
        let rect = CGRect(x: center + CGFloat(distance) * itemWidth - itemWidth / 2, y: 0.0, width: itemWidth, height: self.frame.size.height)
        
        return rect
    }
    
    
    func onSingleTap(_ recognizer: UITapGestureRecognizer) {
        guard Int(activeItemIndex) < labels.count else { return }
        
        let tapPointX = recognizer.location(in: self).x
        let currentLabelStartX = labels[Int(activeItemIndex)].frame.origin.x
        let currentLabelEndX = currentLabelStartX + labels[Int(activeItemIndex)].frame.size.width
        if tapPointX < currentLabelStartX {
            switchToPreviousItem()
        } else if tapPointX > currentLabelEndX {
            switchToNextItem()
        }
    }
    
}


extension CarouselSwitcher: Rotatable {

    func rotate(_ angle: Float, animated: Bool) {
        let rotation = CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
        
        for label in self.labels {
            if animated {
                UIView.animate(withDuration: Animation.defaultDuration,
                    delay: 0.0,
                    options: UIViewAnimationOptions(),
                    animations: { [weak self] () -> Void in
                        self?.hasAnimation = true
                        
                        label.layer.transform = rotation
                    },
                    completion: { [weak self] (success) -> Void in
                        self?.calibrateFrame(self!.activeItemIndex, direction: .forward, animated: false, completion: nil)
                        
                        self?.hasAnimation = false
                    }
                )
            } else {
                label.layer.transform = rotation
                calibrateFrame(activeItemIndex, direction: .forward, animated: false, completion: nil)
            }
        }
    }

}

