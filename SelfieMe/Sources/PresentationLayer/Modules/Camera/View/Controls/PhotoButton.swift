//
//  PhotoButton.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 31.01.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit

enum PhotoButtonState {
    case none
    case process
    case blocked
    case disabled
}


@IBDesignable final class PhotoButton: RotatableButton {
    
    @IBInspectable var outerShapeColor: UIColor = Theme.secondaryTintColor
    @IBInspectable var innerShapeColor: UIColor = Theme.mainColor
    
    @IBInspectable var innerShapeProportion: CGFloat = 0.75
    @IBInspectable var outerShapeOffset: CGFloat = 2.0
    
    @IBInspectable var indicatorColor: UIColor = Theme.secondaryTintColor
    
    @IBInspectable var progressIndicatorMarkersCount: Int = 8
    @IBInspectable var blockIndicatorMarkersCount: Int = 8
    
    fileprivate var buttonState: PhotoButtonState = .none
    
    var isDisabled = false
    
    fileprivate var progressMarkerLayer: CALayer!
    fileprivate var progressReplicatorLayer: CAReplicatorLayer!
    fileprivate var blockMarkerLayer: CALayer!
    fileprivate var blockReplicatorLayer: CAReplicatorLayer!
    
    
    required init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.drawsAsynchronously = true
        clearsContextBeforeDrawing = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    fileprivate func addProgressIndicatorLayer() {
        progressReplicatorLayer?.removeFromSuperlayer()
        
        let height = ((frame.size.width * (1.0 - innerShapeProportion) - outerShapeOffset) * 0.45) * 0.75
        
        progressMarkerLayer = CALayer()
        progressMarkerLayer.bounds = CGRect(x: 0.0, y: 0.0, width: height * 2, height: height)
        progressMarkerLayer.cornerRadius = height * 0.5
        progressMarkerLayer.backgroundColor = indicatorColor.cgColor
        progressMarkerLayer.opacity = 0.0
        progressMarkerLayer.position = CGPoint(x: frame.size.width / 2, y: height / 2)
        
        progressReplicatorLayer = CAReplicatorLayer()
        progressReplicatorLayer.bounds = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
        progressReplicatorLayer.backgroundColor = UIColor.clear.cgColor
        progressReplicatorLayer.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        
        progressReplicatorLayer.instanceCount = Int(progressIndicatorMarkersCount)
        
        let angle = CGFloat(M_PI * 2) / CGFloat(progressIndicatorMarkersCount)
        let transform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
        
        progressReplicatorLayer.instanceTransform = transform
        
        progressReplicatorLayer.addSublayer(progressMarkerLayer)
        
        self.layer.addSublayer(progressReplicatorLayer)
    }
    
    fileprivate func addBlockIndicatorLayer() {
        blockReplicatorLayer?.removeFromSuperlayer()
        
        let height = (frame.size.width * innerShapeProportion) * 0.25
        
        blockMarkerLayer = CALayer()
        blockMarkerLayer.bounds = CGRect(x: 0.0, y: 0.0, width: 3.0, height: height)
        blockMarkerLayer.cornerRadius = blockMarkerLayer.bounds.size.width / 2.0
        blockMarkerLayer.backgroundColor = indicatorColor.cgColor
        blockMarkerLayer.opacity = 0.0
        blockMarkerLayer.position = CGPoint(x: frame.size.width / 2, y: frame.size.height * 0.7)
        
        blockReplicatorLayer = CAReplicatorLayer()
        blockReplicatorLayer.bounds = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
        blockReplicatorLayer.backgroundColor = UIColor.clear.cgColor
        blockReplicatorLayer.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        
        blockReplicatorLayer.instanceCount = Int(blockIndicatorMarkersCount)
        
        let angle = CGFloat(M_PI * 2) / CGFloat(blockIndicatorMarkersCount)
        let transform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
        
        blockReplicatorLayer.instanceTransform = transform
        
        blockReplicatorLayer.addSublayer(blockMarkerLayer)
        
        self.layer.addSublayer(blockReplicatorLayer)
    }
    
    
    func setButtonState(_ state: PhotoButtonState) {
        guard !isDisabled else { return }
        
        self.buttonState = state
        
        
        switch state {
        case .none:
            isUserInteractionEnabled = true
            setProgressIndicatorVisible(false)
            setBlockIndicatorVisible(false)
            break
        case .process:
            isUserInteractionEnabled = true
            setProgressIndicatorVisible(true)
            setBlockIndicatorVisible(false)
            break
        case .blocked:
            isUserInteractionEnabled = false
            setProgressIndicatorVisible(false)
            setBlockIndicatorVisible(true)
            break
        case .disabled:
            isUserInteractionEnabled = false
            setProgressIndicatorVisible(false)
            setBlockIndicatorVisible(false)
        }
        
        setNeedsDisplay()
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        
        if let _ = context {
            if buttonState != .blocked && buttonState != .disabled {
                drawInnerShape(rect, inContext: context!)
            }
            if buttonState != .process {
                drawOuterShape(rect, inContext: context!)
            }
        }
    }
    
    
    fileprivate func drawInnerShape(_ rect: CGRect, inContext context: CGContext) {
        let diameter = rect.size.width * innerShapeProportion

        let circleRect = CGRect(
            x: rect.origin.x + ((rect.size.width - diameter) / 2.0),
            y: rect.origin.y + ((rect.size.height - diameter) / 2.0),
            width: diameter, height: diameter)
        
        context.setFillColor(innerShapeColor.cgColor)
        
        context.fillEllipse(in: circleRect)
    }
    
    fileprivate func drawOuterShape(_ rect: CGRect, inContext context: CGContext) {
        let width = (rect.size.width * (1.0 - innerShapeProportion) - outerShapeOffset) / 2
        let diameter = rect.size.width - width
        let shapeRect = CGRect(
            x: rect.origin.x + ((rect.size.width - diameter) / 2.0),
            y: rect.origin.y + ((rect.size.height - diameter) / 2.0),
            width: diameter, height: diameter)
                
        if buttonState == .blocked || buttonState == .disabled {
            // TODOODODOD: цвет поменять
            context.setStrokeColor(innerShapeColor.withAlphaComponent(0.25).cgColor)
        } else {
            context.setStrokeColor(outerShapeColor.cgColor)
        }
        

        let path = UIBezierPath(ovalIn: shapeRect)
        path.lineWidth = width
        path.stroke()
    }
    
    
    fileprivate func setProgressIndicatorVisible(_ visible: Bool) {
        addProgressIndicatorLayer()

        if visible {
            let duration = 1.0
            
            let fade = CABasicAnimation(keyPath: "opacity")
            fade.fromValue = 0.4
            fade.toValue =  0.8
            fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            fade.repeatCount = Float.infinity
            fade.duration = duration
            
            let speed = CGFloat(duration) / CGFloat(progressIndicatorMarkersCount)
            progressReplicatorLayer.instanceDelay = Double(speed)
            
            progressMarkerLayer.add(fade, forKey: nil)
        } else {
            progressMarkerLayer.removeAllAnimations()
            progressReplicatorLayer.removeFromSuperlayer()
        }
    }
    
    fileprivate func setBlockIndicatorVisible(_ visible: Bool) {
        addBlockIndicatorLayer()

        if visible {
            let duration = Animation.defaultDuration
            
            let fade = CABasicAnimation(keyPath: "opacity")
            fade.fromValue = 0.8
            fade.toValue = 0.2
            fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            fade.repeatCount = Float.infinity
            fade.duration = duration
            
            let speed = CGFloat(duration) / CGFloat(blockIndicatorMarkersCount)
            blockReplicatorLayer.instanceDelay = Double(speed)
            
            blockMarkerLayer.add(fade, forKey: nil)
        } else {
            blockMarkerLayer.removeAllAnimations()
            blockReplicatorLayer.removeFromSuperlayer()
        }
    }
    
}
