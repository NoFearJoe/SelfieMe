//
//  AudioManager.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 30.01.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import AVFoundation


//enum SelfieAudioHelperAudioType: String {
//    case Hit = "hit"
//    case Miss = "miss"
//    case Start = "start"
//    case Stop = "stop"
//    
//    static let stringArray: [String] = [Hit.rawValue, Miss.rawValue, Start.rawValue, Stop.rawValue]
//}

enum VoiceAlertAudioType: String {
    case Hit = "hit"
    case Left = "left"
    case Right = "right"
    case Up = "up"
    case Down = "down"
    case Closer = "closer"
    case NoFaces = "no_faces"
    case NotEnoughFaces = "not_enough_faces"
    case Start = "start"
    case Stop = "stop"
    
    static let stringArray = [Hit.rawValue, Left.rawValue, Right.rawValue, Up.rawValue, Down.rawValue, Closer.rawValue, NoFaces.rawValue, NotEnoughFaces.rawValue, Start.rawValue, Stop.rawValue]
}


final class AudioSetManager {
    
    fileprivate let pathToAudioFolder = "Audio/Sets/"
    fileprivate let audioFileDefaultType = "caf"
    
    fileprivate var sounds = [String: [Sound]]()
    
    
    init(setName: String, language: String) {
        var existingLanguageDirectory = "/" + (language.components(separatedBy: "-").first ?? "")
        if Bundle.main.path(forResource: "hit_0", ofType: audioFileDefaultType, inDirectory: pathToAudioFolder + setName + existingLanguageDirectory) == nil {
            existingLanguageDirectory = "/Base"
        }
        prepareSounds(setName + existingLanguageDirectory)
    }
    
    func playSound(_ name: VoiceAlertAudioType) {
        stop()
        if let sounds = sounds[name.rawValue] , sounds.count > 0 {
            let randomIndex: Int = Int(rand(0, to: UInt32(sounds.count)))
            let sound = sounds[randomIndex]
            sound.play()
        }
    }
    
    func stop() {
        self.sounds.forEach() { $0.1.forEach() { $0.stop(); $0.currentTime = 0 } }
    }
    
    func vibrate() {
        if Device.iPhone {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        } else {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
    }
    
    fileprivate func prepareSounds(_ setName: String) {
        for name in VoiceAlertAudioType.stringArray {
            let URLs = pathURLsForSound(name, inDirectory: setName)
            sounds[name] = URLs.flatMap() { Sound(contentsOf: $0) }
            sounds[name]?.forEach() { $0.prepareToPlay() }
        }
    }
    
    
    fileprivate func fixedSoundFileName(_ fileName: String) -> String {
        var fixedSoundFileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        var soundFileComponents = fixedSoundFileName.components(separatedBy: ".")
        if soundFileComponents.count == 1 {
            fixedSoundFileName = "\(soundFileComponents[0]).\(audioFileDefaultType)"
        }
        return fixedSoundFileName
    }
    
    fileprivate func pathsForSound(_ fileName: String, inDirectory directory: String) -> [String] {
        let fixedSoundFileName = self.fixedSoundFileName(fileName)
        let components = fixedSoundFileName.components(separatedBy: ".")
        let paths = Bundle.main.paths(forResourcesOfType: components[1], inDirectory: pathToAudioFolder + directory)
        let predicate = NSPredicate(format: "SELF BEGINSWITH[cd] %@", components[0])
        let filteredPaths = paths.filter() { predicate.evaluate(with: ($0 as NSString).lastPathComponent) }
        return filteredPaths
    }
    
    fileprivate func pathURLsForSound(_ fileName: String, inDirectory directory: String) -> [URL] {
        var URLs = [URL]()
        let paths = pathsForSound(fileName, inDirectory: directory)
        for path in paths {
            let URL = Foundation.URL(fileURLWithPath: path)
            URLs.append(URL)
        }
        return URLs
    }
    
}
