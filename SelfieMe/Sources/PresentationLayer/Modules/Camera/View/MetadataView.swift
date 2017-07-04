//
//  MetadataView.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 27.02.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


/// View for present metadata views such as anchor and grid
final class MetadataView: AutolayoutIgnorableView {
    
    var anchorPointChanged: ((CGPoint) -> Void)?
    
    fileprivate var _anchorPoint: CGPoint? {
        didSet {
            if let _ = anchorPoint {
                let viewPoint = FigureConverter.pointToViewPoint(_anchorPoint!, frame: frame)
                self.anchorView?.center = viewPoint
                anchorPointChanged?(anchorPoint!)
            }
        }
    }
    var anchorPoint: CGPoint? {
        get {
            return self._anchorPoint
        }
        set {
            if let val = newValue {
                var viewPoint = FigureConverter.pointToViewPoint(val, frame: frame)
                if viewPoint.x < (bounds.size.width * 0.2) {
                    viewPoint.x = bounds.size.width * 0.2
                }
                if viewPoint.x > (bounds.size.width * 0.8) {
                    viewPoint.x = bounds.size.width * 0.8
                }
                if viewPoint.y < (bounds.size.height * 0.2) {
                    viewPoint.y = bounds.size.height * 0.2
                }
                if viewPoint.y > (bounds.size.height * 0.8) {
                    viewPoint.y = bounds.size.height * 0.8
                }
                _anchorPoint = FigureConverter.pointToRelativePoint(viewPoint, frame: frame)
            } else {
                _anchorPoint = nil
            }
        }
    }
    
    func hideAnchorPoint(_ animated: Bool, duration: TimeInterval, completion: (() -> Void)?) {
        if animated {
            UIView.animate(withDuration: duration,
                delay: 0,
                options: [UIViewAnimationOptions.curveEaseIn, .allowAnimatedContent],
                animations: { [weak self] () -> Void in
                    self?.anchorView?.bounds = CGRect.zero
                },
                completion: { _ in
                    completion?()
                }
            )
        } else {
            self.anchorView?.bounds = CGRect.zero
            completion?()
        }
    }
    
    func showAnchorPoint() {
        let radius = anchorRadius
        self.anchorRadius = radius
    }
    
    func showAnchorPoint(_ animated: Bool, duration: TimeInterval, delay: TimeInterval) {
        let radius = self.anchorRadius
        if animated {
            UIView.animate(withDuration: duration,
                delay: delay,
                options: [UIViewAnimationOptions.curveEaseOut, .allowAnimatedContent],
                animations: { [weak self] () -> Void in
                    self?.anchorRadius = radius
                },
                completion: nil)
        } else {
            let radius = anchorRadius
            self.anchorRadius = radius
        }
    }
    
    
    
    fileprivate var anchorRadius: CGFloat? {
        didSet {
            if let radius = anchorRadius {
                let convertedRadius = self.percentToViewPixels(radius, viewSide: ViewSide(size: self.frame.size))
                anchorView?.bounds = CGRect(x: 0, y: 0, width: convertedRadius, height: convertedRadius)
            }
        }
    }
    
    
    var anchorView: AnchorView!
    var gridView: GridView!
//    var facesView: FacesView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gridView = GridView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        gridView.drawGrid = false
        addSubview(gridView)
        
        anchorView = AnchorView(frame: CGRect.zero)
        addSubview(anchorView)
        anchorRadius = 0.25
        
//        facesView = FacesView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
//        addSubview(facesView)
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        autoresizesSubviews = true
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setNeedsDisplay()
    }
    
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        
        anchorView?.setNeedsDisplay()
    }
    
    
    override var frame: CGRect {
        didSet {
            if let _ = gridView {
                gridView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        gridView.drawGrid = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        gridView.drawGrid = false
    }
    
}




class AnchorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        layer.masksToBounds = false
        clipsToBounds = false
        
        contentMode = .redraw
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func containsPoint(_ point: CGPoint) -> Bool {
        let contains = frame.contains(point)
        return contains
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let context = UIGraphicsGetCurrentContext() {
            drawAnchorPoint(rect, context: context)
        }
    }
    
    
    fileprivate func drawAnchorPoint(_ rect: CGRect, context: CGContext) {
        let width: CGFloat = 2
        
        context.setStrokeColor(Theme.mainColor.withAlphaComponent(0.6).cgColor)
        context.setLineWidth(width / 2.0)
//        CGContextSetLineCap(context, CGLineCap.Round)
//        CGContextSetLineJoin(context, CGLineJoin.Round)
        
//        let count = 4
//        let r = (rect.size.width / 2.0)
//        let space: CGFloat = width * 2
//        let angle: CGFloat = 360.0 / CGFloat(count)
//        for i in 0..<4 {
//            let start = (CGFloat(i) * angle + space) * CGFloat(M_PI) / 180.0
//            let end = ((CGFloat(i) * angle + angle) - space) * CGFloat(M_PI) / 180.0
//            let path = UIBezierPath(arcCenter: CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)), radius: r - width - width / 2.0, startAngle: start, endAngle: end, clockwise: true)
//            CGContextAddPath(context, path.CGPath)
//            CGContextStrokePath(context)
//        }
        
        
        context.setLineWidth(width)
        let r1 = rect.insetBy(dx: width, dy: width)
        context.strokeEllipse(in: r1)
        
//        CGContextSetLineWidth(context, 1)
//        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor)
//        CGContextStrokeEllipseInRect(context, CGRectInset(r1, width / 2.0, width / 2.0))
        
        
//        CGContextSetStrokeColorWithColor(context, Theme.tintColor.colorWithAlphaComponent(0.6).CGColor)
//        CGContextSetLineWidth(context, 4.0)
//        
//        let start = (CGFloat(0) * angle) * CGFloat(M_PI) / 180.0
//        let end = (CGFloat(1) * angle + angle) * CGFloat(M_PI) / 180.0
//        let path = UIBezierPath(arcCenter: CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)), radius: r, startAngle: start, endAngle: end, clockwise: true)
//        CGContextAddPath(context, path.CGPath)
//        CGContextStrokePath(context)
        
        // Center dot
//        CGContextSetFillColorWithColor(context, Theme.tintColor.colorWithAlphaComponent(1).CGColor)
//        CGContextFillEllipseInRect(context, CGRectInset(rect, rect.size.width / 2.1, rect.size.height / 2.1))
        
        // Center cross
        let divider: CGFloat = 10
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let offset: CGFloat = 0.0
        
        context.setStrokeColor(Theme.tintColor.withAlphaComponent(0.95).cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: center.x - divider, y: center.y - offset))
        context.addLine(to: CGPoint(x: center.x - offset, y: center.y - offset))
        context.move(to: CGPoint(x: center.x + offset, y: center.y + offset))
        context.addLine(to: CGPoint(x: center.x + divider, y: center.y + offset))
        context.strokePath()
        context.move(to: CGPoint(x: center.x - offset, y: center.y - divider))
        context.addLine(to: CGPoint(x: center.x - offset, y: center.y + offset))
        context.move(to: CGPoint(x: center.x + offset, y: center.y + offset))
        context.addLine(to: CGPoint(x: center.x + offset, y: center.y + divider))
        context.strokePath()
        
        
        context.setStrokeColor(UIColor.black.withAlphaComponent(0.95).cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: center.x - divider, y: center.y + offset))
        context.addLine(to: CGPoint(x: center.x - offset, y: center.y + offset))
        context.move(to: CGPoint(x: center.x + offset, y: center.y - offset))
        context.addLine(to: CGPoint(x: center.x + divider, y: center.y - offset))
        context.strokePath()
        context.move(to: CGPoint(x: center.x + offset, y: center.y - divider))
        context.addLine(to: CGPoint(x: center.x + offset, y: center.y - offset))
        context.move(to: CGPoint(x: center.x - offset, y: center.y + offset))
        context.addLine(to: CGPoint(x: center.x - offset, y: center.y + divider))
        context.strokePath()
    }
    
}


class GridView: UIView {
    
    var drawGrid: Bool = false {
        willSet (value) {
            if value != drawGrid {
                if value {
                    needDrawGrid = true
                }
                UIView.animate(withDuration: Animation.shortDuration, animations: { [weak self] () -> Void in
                    self?.alpha = value ? 1 : 0
                }, completion: { [weak self] _ in
                    if !value {
                        self?.needDrawGrid = false
                    }
                }) 
            }
        }
        didSet {
            setNeedsDisplay()
        }
    }
    
    fileprivate var needDrawGrid: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        backgroundColor = UIColor.clear
        layer.masksToBounds = false
        clipsToBounds = false
        
        contentMode = .redraw
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let context = UIGraphicsGetCurrentContext() {
            if needDrawGrid {
                drawGrid(context)
            }
        }
    }
    
    
    fileprivate func drawGrid(_ context: CGContext) {
        context.setStrokeColor(Theme.tintColor.withAlphaComponent(0.2).cgColor)
        context.setLineWidth(0.5)
        
        let verticalLinesCount: CGFloat = 3.0
        let verticalOffset = frame.size.width * 0.2
        let verticalDrawWidth = frame.size.width - (verticalOffset * 2)
        let verticalInterlinesSpace = CGFloat(verticalDrawWidth / (verticalLinesCount - 1))
        
        let horizontalLinesCount: CGFloat = 3.0
        let horizontalOffset = frame.size.height * 0.2
        let horizontalDrawHeight = frame.size.height - (horizontalOffset * 2)
        let horizantalInterlinesSpace = CGFloat(horizontalDrawHeight / (horizontalLinesCount - 1))
        
        
        
        // Draw horizontal shadow lines
        for i in 0..<Int(verticalLinesCount) {
            let x = verticalOffset + CGFloat(i) * verticalInterlinesSpace
            context.move(to: CGPoint(x: x - 0.5, y: 0))
            context.addLine(to: CGPoint(x: x - 0.5, y: frame.size.height))
            context.strokePath()
            context.move(to: CGPoint(x: x + 0.5, y: 0))
            context.addLine(to: CGPoint(x: x + 0.5, y: frame.size.height))
            context.strokePath()
        }
        
        // Draw vertical shadow lines
        for i in 0..<Int(horizontalLinesCount) {
            let y = horizontalOffset + CGFloat(i) * horizantalInterlinesSpace
            context.move(to: CGPoint(x: 0, y: y - 0.5))
            context.addLine(to: CGPoint(x: frame.size.width, y: y - 0.5))
            context.strokePath()
            context.move(to: CGPoint(x: 0, y: y + 0.5))
            context.addLine(to: CGPoint(x: frame.size.width, y: y + 0.5))
            context.strokePath()
        }
        
        
        context.setStrokeColor(Theme.backgroundColor.withAlphaComponent(1).cgColor)
        context.setLineWidth(1)
        
        // Draw horizontal lines
        for i in 0..<Int(verticalLinesCount) {
            let x = verticalOffset + CGFloat(i) * verticalInterlinesSpace
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: frame.size.height))
            context.strokePath()
        }
        
        // Draw vertical lines
        for i in 0..<Int(horizontalLinesCount) {
            let y = horizontalOffset + CGFloat(i) * horizantalInterlinesSpace
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: frame.size.width, y: y))
            context.strokePath()
        }
    }
}




final class FacesView: UIView {

    var faces = [Face]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        backgroundColor = UIColor.clear
        layer.masksToBounds = false
        clipsToBounds = false
        
//        contentMode = .Redraw
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        
        
        context?.setStrokeColor(Theme.tintColor.withAlphaComponent(0.5).cgColor)
        context?.setLineWidth(2)
        
        
        faces.forEach { (face) in
            context?.stroke(face.rect)
        }
    }
    
    

}



