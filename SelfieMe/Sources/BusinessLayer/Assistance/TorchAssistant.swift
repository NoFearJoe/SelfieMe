//
//  TorchAssistant.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 22.06.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import AVFoundation



final class TorchAssistant: NSObject {

    var torchInterface: TorchInterface?
    var enabled: Bool {
        return ApplicationSettings.torchAssistantEnabled()
    }
    
    func lightWithDuration(_ duration: TimeInterval) {
        if enabled {
            self.blinkWithLevel(0.01, duration: duration)
        }
    }
    
    
    func blinkWithLevel(_ level: Float, duration: TimeInterval) {
        torchInterface?.flashlightWithLevel(level)
        if duration != -1 {
            DispatchQueue.main.async(execute: { [weak self] _ in
                if self != nil {
                    Timer.scheduledTimer(timeInterval: duration,
                        target: self!,
                        selector: #selector(TorchAssistant.killBlink),
                        userInfo: nil,
                        repeats: false)
                }
                })
        }
    }
    
    func killBlink() {
        torchInterface?.setTorchMode(.off)
    }

}


extension TorchAssistant: EventRecognizerDelegate {
    
    func eventRecognizer(_ recognizer: EventRecognizer, recognizedEvent: Event) {
        if recognizedEvent == Event.hit {
            lightWithDuration(0.5)
        } else {
            killBlink()
        }
    }
    
}


