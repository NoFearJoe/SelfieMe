//
//  CaptureResolution.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 04.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


/**
 *  Структура, содержащая возможные разрешения камеры
 */
struct CaptureResolutions: Sequence {
    
    static let _undefined   = CaptureResolution(id: -1,    name: localized("CAMERA_MODE_UNDEFINED"),   w: 0, h: 0)
    static let _3x4         = CaptureResolution(id: 2,     name: localized("CAMERA_MODE_3x4"),         w: 3, h: 4)
    static let _1x1         = CaptureResolution(id: 1,     name: localized("CAMERA_MODE_1x1"),         w: 1, h: 1)
    static let _3x2         = CaptureResolution(id: 3,     name: localized("CAMERA_MODE_3x2"),         w: 2, h: 3)
    
    fileprivate static let allValues = [_1x1, _3x4, _3x2]
    
    fileprivate static func cameraModeWithID(_ id: Int) -> CaptureResolution {
        return (CaptureResolutions.allValues.filter() { $0.id == id }).first ?? CaptureResolutions._undefined
    }
    
    subscript(id: Int) -> CaptureResolution {
        get {
            return CaptureResolutions.cameraModeWithID(id)
        }
    }
    
    func names() -> [String] {
        return CaptureResolutions.allValues.map() { return $0.name }
    }
    
    
    func makeIterator() -> AnyIterator<CaptureResolution> {
        var nextIndex = CaptureResolutions.allValues.count - 1
        return AnyIterator {
            if nextIndex < 0 {
                return nil
            }
            nextIndex -= 1
            return CaptureResolutions.allValues[nextIndex]
        }
    }
    
}


/**
 *  Структура, описывающая разрешение съемки
 */
struct CaptureResolution: Equatable {
    
    let id: Int
    let name: String
    let w: Double
    let h: Double
    
    /**
     Возвращает отношение сторон переданного прямоугольника (3:4, 1:1, ...)
     
     - parameter rect: Прямоугольник
     
     - returns: Отношение сторон
     */
    func getRatioRelativeToRect(_ rect: CGRect) -> Double {
        if rect.size.width > rect.size.height {
            return h / w
        } else {
            return w / h
        }
    }
        
}

func ==(lhs: CaptureResolution, rhs: CaptureResolution) -> Bool {
    return lhs.id == rhs.id
}
