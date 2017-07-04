//
//  FrameAdapter.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 03.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit



final class FrameAdapter {
    
    
    /**
        Метод, преобразующий исходный прямоугольник в прямогольник с заданным соотношением сторон
        - parameter frame: Исходный прямоугольник
        - parameter container: Контейнер в который надо вписать прямоугольник
        - parameter ratio: Соотношение сторон. Определяет как ширина относится к высоте.
        - parameter center: Указывает, нужно ли центровать прямоугольник в контейнере
     
        - returns: Возвращает получившийся прямоугольник
    */
    class func adaptedFrame(_ frame: CGRect, inContainer container: CGRect, withTargetRatio ratio: CGFloat, center: Bool) -> CGRect {
        let r = CGRect(x: 0, y: 0, width: 1 * ratio, height: 1.0)
        var target = FrameAdapter.aspectFitRect(r, inContainer: container)
        
        if center {
            let hHalfSpace = (container.size.width - target.size.width) / 2.0
            let vHalfSpace = (container.size.height - target.size.height) / 2.0
            
            target.origin.x = hHalfSpace
            target.origin.y = vHalfSpace
        }
        
        return target
    }
    
    
    class func aspectFitRect(_ rect: CGRect, inContainer container: CGRect) -> CGRect {
        let s: CGFloat = FrameAdapter.scaleToAspectFitRect(rect, inContainer: container);
        let w: CGFloat = rect.width * s;
        let h: CGFloat = rect.height * s;
        let x: CGFloat = container.midX - w / 2;
        let y: CGFloat = container.midY - h / 2;
        return CGRect(x: x, y: y, width: w, height: h);
    }
    
    class func scaleToAspectFitRect(_ rect: CGRect, inContainer container: CGRect) -> CGFloat {
        let s: CGFloat = container.width / rect.width;
        if (rect.height * s <= container.height) {
            return s;
        }
        return container.height / rect.height;
    }
    
}
