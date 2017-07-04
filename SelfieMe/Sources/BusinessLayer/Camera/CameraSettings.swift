//
//  CameraSettings.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 28.02.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


enum SettingState: Int {
    case off = 0
    case on = 1
    case auto = 2
}

enum SettingBurstMode: Int {
    case _Single = 1
    case _3 = 3
    case _5 = 5
    
    init(index: Int) {
        switch index {
        case 0:
            self = ._Single
            break
        case 1:
            self = ._3
            break
        case 2:
            self = ._5
            break
        default:
            self = ._Single
            break
        }
    }
}

enum SettingTimerState: Int {
    case _1s = 1
    case _2s = 2
    case _4s = 4
    
    init(index: Int) {
        switch index {
        case 0:
            self = ._1s
            break
        case 1:
            self = ._2s
            break
        case 2:
            self = ._4s
            break
        default:
            self = ._1s
            break
        }
    }
}

enum SettingFacesState: Int {
    case _Infinite = 0
    case _1 = 1
    case _2 = 2
    case _3 = 3
    
    init(index: Int) {
        switch index {
        case 0:
            self = ._Infinite
            break
        case 1:
            self = ._1
            break
        case 2:
            self = ._2
            break
        case 3:
            self = ._3
            break
        default:
            self = ._Infinite
            break
        }
    }
}



final class CameraSettings {
    
    static let settings = CameraSettings.defaultSettings()
    
    /**
        Точка, в которой должны быть расположены лица
    */
    var anchorPoint: CGPoint?
    
    /**
        Радиус якоря (anchorPoint). Если лица попадают в заданный радиус, то
        их положение считается подходящим
    */
    var anchorRadius: CGFloat!
    
    
    /**
        Текущий режим съемки
        По-умолчанию .Default
    */
    var cameraMode: CaptureResolution!
    
    
    /**
        Задержка перед съемкой
        По-умолчанию равно 1 секунде
    */
    var timerState: SettingTimerState!
    
    /**
        Требуемое количество лиц в кадре
        По-умолчанию 0 (Любое количество лиц)
    */
    var facesState: SettingFacesState!
    
    
    var burstMode: SettingBurstMode!
    
    
    /**
        Состояние HDR
        По-умолчанию false (выключен)
    */
//    var hdrState: SettingState!
    
    /**
        Состояние вспышки
        По-умолчанию false (выключена)
    */
    var flashState: SettingState!
    
    /**
        Состояние фонарика
        По-умолчанию false (выключен)
    */
    var torchState: SettingState!
    
    
    /**
        Текущий фильтр
        По-умолчанию фильтр не выставлен
    */
    var filter: Filter?
    
    
    // MARK: Constants
    
    /**
        Минимальный радиус якоря
    */
    static let minimumAnchorRadius: CGFloat = 0.5
    
    /**
        Множитель для вычисления радиуса якоря на основе масштаба
    */
    static let anchorRaidusMultiplier: CGFloat = 0.0
    
    
    class fileprivate func defaultSettings() -> CameraSettings {
        let s = CameraSettings()
        s.anchorRadius = minimumAnchorRadius
        s.cameraMode = ApplicationSettings.cameraMode() //CaptureResolutions._3x4
        s.timerState = ApplicationSettings.timerState() //SettingTimerState._1s
        s.facesState = SettingFacesState._Infinite
        
//        s.hdrState   = ApplicationSettings.HDRState()   //SettingState.Auto
        s.burstMode  = SettingBurstMode._Single
        s.flashState = ApplicationSettings.flashState() //SettingState.Auto
        s.torchState = SettingState.off
        
        s.filter = nil
        
        return s
    }
    
    
    class func maximumRadiusForRect(_ rect: CGRect) -> CGFloat {
        return max(rect.size.width, rect.size.height)
    }
    
}
