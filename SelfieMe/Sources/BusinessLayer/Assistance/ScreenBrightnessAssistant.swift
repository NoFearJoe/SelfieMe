//
//  ScreenBrightnessAssistant.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 11.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit



class ScreenBrightnessAssistant {

    fileprivate var startBrightness: CGFloat = 0.0
    
    fileprivate let lowerBrightnessBound: CGFloat = 0.2
    fileprivate let higherBrightnessBound: CGFloat = 1.0
    
    func start() {
        startBrightness = UIScreen.main.brightness
        
        setBrightness(lowerBrightnessBound)
    }
    
    
    func stop() {
        setBrightness(startBrightness)
    }
    
    
    func setBrightness(_ value: CGFloat) {
        guard ApplicationSettings.screenAssistantEnabled() else { return }
        
        UIScreen.main.brightness = value
    }

}



extension ScreenBrightnessAssistant: EventRecognizerDelegate {
    
    func eventRecognizer(_ recognizer: EventRecognizer, recognizedEvent: Event) {
        switch recognizedEvent {
        case .moveDirection(_), .unknown, .noFaces, .notEnoughFaces, .opposite, .withinArea:
            setBrightness(lowerBrightnessBound)
            break
        case .hit:
            setBrightness(higherBrightnessBound)
            break
        }
    }
    
}
