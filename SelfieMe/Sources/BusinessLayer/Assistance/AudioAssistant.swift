//
//  AudioAssistant.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 30.01.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation



final class AudioAssistant: NSObject {

    
    fileprivate var audioSetManager: AudioSetManager!
    
    
    fileprivate var currentEvent: Event = .unknown
    
    
    fileprivate var timer: Timer?
    
    
    init(audioSetManager: AudioSetManager) {
        super.init()
        self.audioSetManager = audioSetManager
    }
    
    
    fileprivate func startTimer() {
        DispatchQueue.main.async { [weak self] _ in
            let needsRepeat = self?.currentEvent != .hit
            self?.timer = Timer.scheduledTimer(timeInterval: 2,
                                                           target: self!,
                                                           selector: #selector(AudioAssistant.handleCurrentEvent),
                                                           userInfo: nil,
                                                           repeats: needsRepeat)
            self?.timer?.fire()
            if !needsRepeat {
                self?.stop()
            }
        }
    }
    
    func stop() {
        DispatchQueue.main.async { [weak self] _ in
            self?.timer?.invalidate()
            self?.timer = nil
        }
    }
    
    func reset() {
        currentEvent = .unknown
        stop()
    }
    
    
    
    func handleCurrentEvent() {
        switch currentEvent {
        case .moveDirection(let direction):
            sayDirection(direction)
            break
        case .noFaces:
//            sayNoFaces()
            break
        case .notEnoughFaces:
//            sayNotEnoughFaces()
            break
        case .hit:
            sayHit()
            break
        case .opposite:
//            sayOpposite()
            break
        case .withinArea:
//            sayWithinArea()
            break
        case .unknown: break
        }
    }
    
    
    
    func sayStart() {
        self.audioSetManager.playSound(VoiceAlertAudioType.Start)
    }
    
    func sayStop() {
        self.audioSetManager.playSound(VoiceAlertAudioType.Stop)
    }
    
    
    fileprivate func sayHit() {
        self.audioSetManager.playSound(VoiceAlertAudioType.Hit)
        if ApplicationSettings.vibrationEnabled() {
            self.audioSetManager.vibrate()
        }
    }
    
    fileprivate func sayDirection(_ direction: Direction) {
        switch direction {
        case .unknown:
            break
        case .left:
            self.audioSetManager.playSound(VoiceAlertAudioType.Left)
            break
        case .right:
            self.audioSetManager.playSound(VoiceAlertAudioType.Right)
            break
        case .up:
            self.audioSetManager.playSound(VoiceAlertAudioType.Up)
            break
        case .down:
            self.audioSetManager.playSound(VoiceAlertAudioType.Down)
            break
        }
    }
    
    fileprivate func sayNoFaces() {
        self.audioSetManager.playSound(VoiceAlertAudioType.NoFaces)
    }
    
    fileprivate func sayNotEnoughFaces() {
        self.audioSetManager.playSound(VoiceAlertAudioType.NotEnoughFaces)
    }
    
    fileprivate func sayOpposite() {
        self.audioSetManager.playSound(VoiceAlertAudioType.Closer)
    }
    
    fileprivate func sayWithinArea() {

    }
    
    func vibrate() {
        if ApplicationSettings.vibrationEnabled() {
            self.audioSetManager.vibrate()
        }
    }


}



extension AudioAssistant: EventRecognizerDelegate {

    func eventRecognizer(_ recognizer: EventRecognizer, recognizedEvent: Event) {
        currentEvent = recognizedEvent
        stop()
        startTimer()
    }

}
