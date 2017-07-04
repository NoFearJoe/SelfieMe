//
//  ControlsFactory.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 27.01.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


enum ControlButtonType: Int {
    case hdr = 1
    case flash = 2
    case torch = 3
    case livePhoto = 4
    case timer = 5
    case faces = 6
    case burst = 7
    
    case photoMode = 10
}


/**
    Класс для создания кнопок настроек камеры. Реализует паттерн Приспособленец(Flyweight)
*/
final class ControlsFactory {
    
    fileprivate lazy var buttons = [ControlButtonType: MultiStateView]()
    
    static let sharedInstance = ControlsFactory()
    
    func getControlButton(_ type: ControlButtonType, delegate: MultiStateViewDelegate?) -> MultiStateView {
        if buttons.keys.contains(type) {
            return buttons[type]!
        }
        
        var button: MultiStateView!
        
        switch type {
        case .hdr: button = buildHDRButton(delegate)
        case .flash: button = buildFlashButton(delegate)
        case .timer: button = buildTimerButton(delegate)
        case .torch: button = buildTorchButton(delegate)
        case .faces: button = buildFacesButton(delegate)
        case .livePhoto: button = buildLivePhotoButton(delegate)
        case .burst: button = buildBurstButton(delegate)
            
        case .photoMode: button = buildPhotoModeButton(delegate)
        }
        
        buttons[type] = button
        
        return button
    }
    
    
    func buildHDRButton(_ delegate: MultiStateViewDelegate?) -> MultiStateView {
        let frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let states = [
            MultiStateButtonState(icon: UIImage(named: "hdrButtonImageOff") ?? UIImage(), title: "", isActive: false),
            MultiStateButtonState(icon: UIImage(named: "hdrButtonImageOn") ?? UIImage(), title: "", isActive: true),
            MultiStateButtonState(icon: UIImage(named: "hdrButtonImageAuto") ?? UIImage(), title: "", isActive: false)
        ]
        let view = MultiStateView(frame: frame, states: states)
        view.stateDelegate = delegate
        view.tag = ControlButtonType.hdr.rawValue
        view.currentIndex = 2 //CameraSettings.settings.hdrState?.rawValue ?? 2
        ControlsFactory.setupStateColors(view)
        
        return view
    }
    
    func buildFlashButton(_ delegate: MultiStateViewDelegate?) -> MultiStateView {
        let frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let states = [
            MultiStateButtonState(icon: UIImage(named: "flashButtonImageOff") ?? UIImage(), title: "", isActive: false),
            MultiStateButtonState(icon: UIImage(named: "flashButtonImageOn") ?? UIImage(), title: "", isActive: true),
            MultiStateButtonState(icon: UIImage(named: "flashButtonImageAuto") ?? UIImage(), title: "", isActive: true)
        ]
        let view = MultiStateView(frame: frame, states: states)
        view.stateDelegate = delegate
        view.tag = ControlButtonType.flash.rawValue
        view.currentIndex = CameraSettings.settings.flashState?.rawValue ?? 2
        ControlsFactory.setupStateColors(view)
        
        return view
    }
    
    func buildTimerButton(_ delegate: MultiStateViewDelegate?) -> MultiStateView {
        let secondsShortString = localized("STRING_SECONDS_SHORT")
        
        let frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let image = UIImage(named: "timerButtonImage") ?? UIImage()
        let states = [
            MultiStateButtonState(icon: image, title: "\(SettingTimerState(index: 0).rawValue)\(secondsShortString)", isActive: true),
            MultiStateButtonState(icon: image, title: "\(SettingTimerState(index: 1).rawValue)\(secondsShortString)", isActive: true),
            MultiStateButtonState(icon: image, title: "\(SettingTimerState(index: 2).rawValue)\(secondsShortString)", isActive: true)
        ]
        let view = MultiStateView(frame: frame, states: states)
        view.stateDelegate = delegate
        view.tag = ControlButtonType.timer.rawValue
        ControlsFactory.setupStateColors(view)
        
        return view
    }
    
    func buildTorchButton(_ delegate: MultiStateViewDelegate?) -> MultiStateView {
        let frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let states = [
            MultiStateButtonState(icon: UIImage(named: "torchButtonImageAuto") ?? UIImage(), title: "", isActive: true),
            MultiStateButtonState(icon: UIImage(named: "torchButtonImageOff") ?? UIImage(), title: "", isActive: false),
            MultiStateButtonState(icon: UIImage(named: "torchButtonImageOn") ?? UIImage(), title: "", isActive: true),
        ]
        let view = MultiStateView(frame: frame, states: states)
        view.stateDelegate = delegate
        view.tag = ControlButtonType.torch.rawValue
        ControlsFactory.setupStateColors(view)
        
        return view
    }

    func buildFacesButton(_ delegate: MultiStateViewDelegate?) -> MultiStateView {
        let frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let image = UIImage(named: "facesButtonImage") ?? UIImage()
        let states = [
            MultiStateButtonState(icon: image, title: "∞", isActive: true),
            MultiStateButtonState(icon: image, title: "1", isActive: true),
            MultiStateButtonState(icon: image, title: "2", isActive: true),
            MultiStateButtonState(icon: image, title: "3", isActive: true)
        ]
        let view = MultiStateView(frame: frame, states: states)
        view.stateDelegate = delegate
        view.tag = ControlButtonType.faces.rawValue
        ControlsFactory.setupStateColors(view)
        
        return view
    }

    func buildLivePhotoButton(_ delegate: MultiStateViewDelegate?) -> MultiStateView {
        let frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let states = [
            MultiStateButtonState(icon: UIImage(named: "liveButtonImageOff") ?? UIImage(), title: "", isActive: true),
            MultiStateButtonState(icon: UIImage(named: "liveButtonImageOn") ?? UIImage(), title: "", isActive: true),
        ]
        let view = MultiStateView(frame: frame, states: states)
        view.stateDelegate = delegate
        view.tag = ControlButtonType.livePhoto.rawValue
        ControlsFactory.setupStateColors(view)
        
        return view
    }
    
    
    func buildBurstButton(_ delegate: MultiStateViewDelegate?) -> MultiStateView {
        let frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let states = [
            MultiStateButtonState(icon: UIImage(named: "photoModeButtonImageSingle") ?? UIImage(), title: "", isActive: false),
            MultiStateButtonState(icon: UIImage(named: "photoModeButtonImageBurst") ?? UIImage(), title: "\(SettingBurstMode.init(index: 1).rawValue)", isActive: true),
            MultiStateButtonState(icon: UIImage(named: "photoModeButtonImageBurst") ?? UIImage(), title: "\(SettingBurstMode.init(index: 2).rawValue)", isActive: true)
        ]
        let view = MultiStateView(frame: frame, states: states)
        view.stateDelegate = delegate
        view.tag = ControlButtonType.burst.rawValue
        ControlsFactory.setupStateColors(view)
        
        return view
    }
    
    
    
    func buildPhotoModeButton(_ delegate: MultiStateViewDelegate?) -> MultiStateView {
        let frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let states = [
            MultiStateButtonState(icon: UIImage(named: "photoModeButtonImageSingle") ?? UIImage(), title: "", isActive: true),
            MultiStateButtonState(icon: UIImage(named: "photoModeButtonImageBurst") ?? UIImage(), title: "", isActive: true),
        ]
        let view = MultiStateView(frame: frame, states: states)
        view.stateDelegate = delegate
        view.tag = ControlButtonType.livePhoto.rawValue
        ControlsFactory.setupStateColors(view)
        
        return view
    }
    
    
    // TODO: Сделать протокол, в котором описана кнопка с активным и не активным цветом
    fileprivate class func setupStateColors(_ view: MultiStateView) {
        view.inactiveStateColor = Theme.tintColor
        view.activeStateColor = Theme.mainColor
    }
    
    
}
