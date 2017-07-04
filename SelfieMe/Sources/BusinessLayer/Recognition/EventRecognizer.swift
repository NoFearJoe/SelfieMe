//
//  EventRecognizer.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 07.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation


enum Direction {
    case unknown
    case left
    case right
    case up
    case down
}


enum Event: Equatable {
    case unknown
    case noFaces
    case notEnoughFaces
    case hit
    case moveDirection(direction: Direction)
    case opposite
    case withinArea
    
    var rawValue: Int {
        switch self {
        case .unknown: return 0
        case .noFaces: return 1
        case .notEnoughFaces: return 2
        case .hit: return 3
        case .opposite: return 4
        case .withinArea: return 5
        case .moveDirection(let direction):
            switch direction {
            case .unknown: return 6
            case .down: return 7
            case .left: return 8
            case .right: return 9
            case .up: return 10
            }
        }
    }
}

func ==(lhs: Event, rhs: Event) -> Bool {
    return lhs.rawValue == rhs.rawValue
}




protocol EventRecognizerDelegate {
    
    func eventRecognizer(_ recognizer: EventRecognizer, recognizedEvent: Event)
    
}


class EventRecognizer: RecognitionDirectorDelegate {
    
    var listeners = [EventRecognizerDelegate]()
    
    var lastEvent: Event = .unknown
    
    func recognitionDirector(_ director: RecognitionDirector, recognizedWithInfo info: RecognitionInfo) {
        if info.faces.count == 0 {
            if lastEvent != Event.noFaces {
                lastEvent = Event.noFaces
                self.listeners.forEach() { $0.eventRecognizer(self, recognizedEvent: .noFaces) }
            }
        } else if info.requiredFacesCount != SettingFacesState._Infinite.rawValue && info.faces.count < info.requiredFacesCount {
            if lastEvent != Event.notEnoughFaces {
                lastEvent = Event.notEnoughFaces
                self.listeners.forEach() { $0.eventRecognizer(self, recognizedEvent: .notEnoughFaces) }
            }
//        } else if info.oppositeToEachOther {
//            if lastEvent != Event.Opposite {
//                lastEvent = Event.Opposite
//                self.listeners.forEach() { $0.eventRecognizer(self, recognizedEvent: .Opposite) }
//            }
        } else if info.matched {
            if lastEvent != Event.hit {
                lastEvent = Event.hit
                self.listeners.forEach() { $0.eventRecognizer(self, recognizedEvent: .hit) }
            }
        } else {
            if let position = (info.position.filter() { $0 != .Within }).first {
                var direction: Direction
                if position == .Left {
                    direction = .right
                } else if position == .Right {
                    direction = .left
                } else if position == .Above {
                    direction = .up
                } else if position == .Under {
                    direction = .down
                } else {
                    direction = .unknown
                }
                if lastEvent != Event.moveDirection(direction: direction) {
                    lastEvent = Event.moveDirection(direction: direction)
                    self.listeners.forEach() { $0.eventRecognizer(self, recognizedEvent: .moveDirection(direction: direction)) }
                }
            }
        }
    }
    
    
    func addListener(_ listener: EventRecognizerDelegate) {
        listeners.append(listener)
    }
    
    func removeListeners() {
        listeners.removeAll()
    }
    
    
    func reset() {
        lastEvent = .unknown
    }
}
