//
//  RecognitionDirector.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 05.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


struct RelativePosition: OptionSet, Hashable {
    let rawValue: Int
    
    static let Within = RelativePosition(rawValue: 0)
    static let Under = RelativePosition(rawValue: 1 << 0)
    static let Above = RelativePosition(rawValue: 1 << 1)
    static let Left = RelativePosition(rawValue: 1 << 2)
    static let Right = RelativePosition(rawValue: 1 << 4)
    static let Outside = RelativePosition(rawValue: 1 << 5)
    static let Unknown = RelativePosition(rawValue: 1 << 9)
    
    var hashValue: Int {
        return rawValue
    }
    
    
    func positionForOrientation(_ orientation: AVCaptureVideoOrientation) -> RelativePosition {
        switch orientation {
        case .portrait:
            return self
        case .portraitUpsideDown:
            switch self {
            case RelativePosition.Within:
                return RelativePosition.Within
            case RelativePosition.Under:
                return RelativePosition.Above
            case RelativePosition.Above:
                return RelativePosition.Under
            case RelativePosition.Left:
                return RelativePosition.Right
            case RelativePosition.Right:
                return RelativePosition.Left
            default:
                return RelativePosition.Unknown
            }
        case .landscapeRight:
            switch self {
            case RelativePosition.Within:
                return RelativePosition.Within
            case RelativePosition.Under:
                return RelativePosition.Right
            case RelativePosition.Above:
                return RelativePosition.Left
            case RelativePosition.Left:
                return RelativePosition.Under
            case RelativePosition.Right:
                return RelativePosition.Above
            default:
                return RelativePosition.Unknown
            }
        case .landscapeLeft: 
            switch self {
            case RelativePosition.Within:
                return RelativePosition.Within
            case RelativePosition.Under:
                return RelativePosition.Left
            case RelativePosition.Above:
                return RelativePosition.Right
            case RelativePosition.Left:
                return RelativePosition.Above
            case RelativePosition.Right:
                return RelativePosition.Under
            default:
                return RelativePosition.Unknown
            }
        }
    }
    
}

func ==(lhs: RelativePosition, rhs: RelativePosition) -> Bool {
    return lhs.rawValue == rhs.rawValue
}



/**
 *  Recognition director delegate
 */
protocol RecognitionDirectorDelegate {
    
//    /**
//     Informs, that all faces within frame bounds
//     
//     - parameter director:     RecognitionDirector object
//     - parameter faces:        Array of faces
//     - parameter withinBounds: A boolean value that determine hitting faces in frame bounds
//     */
//    func recognitionDirector(director: RecognitionDirector, faces: [Face], withinBounds: Bool)
//    
//    /**
//     Informs abount count of visible faces count in frame and required faces count
//     
//     - parameter director:           RecognitionDirector object
//     - parameter visibleFacesCount:  Visible faces count
//     - parameter requiredFacesCount: Required faces count
//     */
//    func recognitionDirector(director: RecognitionDirector, visibleFacesCount: Int, requiredFacesCount: Int)
//    
//    /**
//     Informs, that all faces within anchor bounds
//     
//     - parameter director:     RecognitionDirector object
//     - parameter faces:        Array of faces
//     - parameter withinAnchor: A boolean value that determine hitting faces in anchor bounds
//     */
//    func recognitionDirector(director: RecognitionDirector, faces: [Face], withinAnchor: Bool)
//    
//    /**
//     Informs, that faces is opposite to each other
//     
//     - parameter director:            RecognitionDirector object
//     - parameter faces:               Array of faces
//     - parameter oppositeToEachOther: A boolean value that determine opposite state
//     */
//    func recognitionDirector(director: RecognitionDirector, faces: [Face], oppositeToEachOther: Bool)
//    
//    /**
//     Informs about the position of faces
//     
//     - parameter director:   RecognitionDirector object
//     - parameter faces:      Array of faces
//     - parameter positioned: Array of positions
//     */
//    func recognitionDirector(director: RecognitionDirector, faces: [Face], positioned: [RelativePosition])
//    
//    /**
//     Informs, that all faces matched to satisfactory position with percents
//     
//     - parameter director:              RecognitionDirector object
//     - parameter faces:                 Array of faces
//     - parameter matchedWithPercentage: Mathing percentage (0...1)
//     */
//    func recognitionDirector(director: RecognitionDirector, faces: [Face], matchedWithPercentage: Double)
    
    /**
     Informs, that recognition director recognized faces with info
     
     - parameter director:           RecognitionDirector object
     - parameter recognizedWithInfo: Recognition info
     */
    func recognitionDirector(_ director: RecognitionDirector, recognizedWithInfo: RecognitionInfo)
    
}


struct RecognitionInfo {
    
    let faces: [Face]
    
    let requiredFacesCount: Int
    
    let frameBounds: CGRect
    
    let position: [RelativePosition]
    
    let mathingPercentage: Double
    
    let withinBounds: Bool
    
    let matched: Bool
    
//    let withinAnchor: Bool
    
//    let oppositeToEachOther: Bool
    
}



final class RecognitionDirector {
    
    static let minSatisfactoryMathingPercentage: CGFloat = 0.90
    static let maxSatisfactoryMathingPercentage: CGFloat = 0.95
    
    
    var delegate: RecognitionDirectorDelegate?
    
    
    /**
     Process given information abount faces, frame and anchor
     
     - parameter faces:              Array of Face objects
     - parameter requiredFacesCount: Required faces count
     - parameter frameBounds:        Frame bounds
     - parameter anchorPoint:        Anchor point
     - parameter anchorRadius:       Anchor radius
     */
    func handleFaces(_ faces: [Face], requiredFacesCount: Int, frameBounds: CGRect, anchorPoint: CGPoint, layerOrientation orientation: AVCaptureVideoOrientation) {//, anchorRadius: CGFloat) {
        let strategy = RecognitionDirector.recognitionStrategyForFacesCount(faces.count, requiredFacesCount: requiredFacesCount)
    
        switch strategy {
        case .unknown:
            break
        case .centerDistance:
            handleCenterDistanceForFaces(faces,
                                         requiredFacesCount: requiredFacesCount,
                                         frameBounds: frameBounds,
                                         anchorPoint: anchorPoint,
                                         orientation: orientation)
            break
        case .circularIntersection:
            handleCircularIntersectionForFaces(faces,
                                               requiredFacesCount: requiredFacesCount,
                                               frameBounds: frameBounds,
                                               anchorPoint: anchorPoint,
                                               orientation: orientation)
            break
        }
    }
    
    
    func handleNoFaces() {
        let info = RecognitionInfo(faces: [Face](), requiredFacesCount: 0, frameBounds: CGRect.zero, position: [RelativePosition.Unknown], mathingPercentage: 0, withinBounds: false, matched: false)
        self.delegate?.recognitionDirector(self, recognizedWithInfo: info)
    }
    
    
    /**
     Choose recognition strategy based on faces count and required faces count
     
     - parameter faces:              Faces count
     - parameter requiredFacesCount: Required faces count
     
     - returns: Recognition strategy
     */
    fileprivate class func recognitionStrategyForFacesCount(_ faces: Int, requiredFacesCount: Int) -> RecognitionStrategy {
        switch (faces, requiredFacesCount) {
        case (1, _):
            return RecognitionStrategy.centerDistance
        case (0, _):
            return RecognitionStrategy.unknown
        default:
            return RecognitionStrategy.circularIntersection
        }
    }
    
    
    /**
     Check faces within anchor area
     
     - parameter faces:       Faces array
     - parameter frame:       Frame bounds
     - parameter anchorPoint: Anchor point
     - parameter radius:      Anchor radius
     
     - returns: Faces count within area
     */
//    private class func checkFaces(faces: [Face], inFrame frame: CGRect, withinAnchorPoint anchorPoint: CGPoint, withRadius radius: CGFloat) -> Int {
//        var count = 0
//        for face in faces {
//            let distance = RecognitionDirector.calculateDistance(anchorPoint, frame: frame, faceRects: [face.rect])
//            if distance.distance <= radius {
//                count += 1
//            }
//        }
//        return count
//    }
    
    
    /**
     Handle center distance strategy for given faces
     
     - parameter faces:              Faces array
     - parameter requiredFacesCount: Required faces count
     - parameter frameBounds:        Frame bounds
     - parameter anchorPoint:        Anchor point
     - parameter anchorRadius:       Anchor radius
     */
    fileprivate func handleCenterDistanceForFaces(_ faces: [Face],
                                              requiredFacesCount: Int,
                                              frameBounds: CGRect,
                                              anchorPoint: CGPoint,
                                              orientation: AVCaptureVideoOrientation) {
        let faceRects = faces.map() { $0.rect }
        
        let facesWithinBounds = RecognitionDirector.countFaces(faces,
                                                               withinBounds: frameBounds,
                                                               requiredFacesCount: requiredFacesCount)
        
        let isFacesWithinBounds = facesWithinBounds == faces.count
        
        let satisfactoryMathingPercentage = RecognitionDirector.minSatisfactoryMathingPercentage//max(RecognitionDirector.minSatisfactoryMathingPercentage, min(RecognitionDirector.maxSatisfactoryMathingPercentage, (1 - ((faceRects.first?.size.width ?? 0) / frameBounds.size.width) * 2)))

        // Определение расстояния между центром якоря до центра лица
        let matchingPercentage = RecognitionDirector.matchingPercentage(anchorPoint,
//                                                                       anchorRadius: anchorRadius,
                                                                       frame: frameBounds,
                                                                       faceRects: faceRects,
                                                                       strategy: RecognitionStrategy.centerDistance)
        
        
        let distances = RecognitionDirector.calculateDistance(anchorPoint, frame: frameBounds, faceRects: faceRects)
        let radius = distances.maxDistance * (1 - satisfactoryMathingPercentage)
    
        
        // Определение местоположения лиц относительно положения центра якоря
        let position = RecognitionDirector.recognizePosition(anchorPoint,
                                                             anchorRadius: radius,
                                                             faceRects: faceRects,
                                                             strategy: .centerDistance,
                                                             orientation: orientation)
        
        let matched = matchingPercentage >= RecognitionDirector.minSatisfactoryMathingPercentage
        
        let info = RecognitionInfo(faces: faces,
                                   requiredFacesCount: requiredFacesCount,
                                   frameBounds: frameBounds,
                                   position: position,
                                   mathingPercentage: Double(matchingPercentage),
                                   withinBounds: isFacesWithinBounds,
                                   matched: matched)
//                                   withinAnchor: false,
//                                   oppositeToEachOther: false)
        
        self.delegate?.recognitionDirector(self, recognizedWithInfo: info)
    }
    
    
    /**
     Handle circular intersection strategy for given faces
     
     - parameter faces:              Faces array
     - parameter requiredFacesCount: Required faces count
     - parameter frameBounds:        Frame bounds
     - parameter anchorPoint:        Anchor point
     - parameter anchorRadius:       Anchor radius
     */
    fileprivate func handleCircularIntersectionForFaces(_ faces: [Face],
                                                    requiredFacesCount: Int,
                                                    frameBounds: CGRect,
                                                    anchorPoint: CGPoint,
                                                    orientation: AVCaptureVideoOrientation) {
        let faceRects = faces.map() { $0.rect }
        
        // Проверка на то, что все лица находятся в указанной области
        let facesWithinBounds = RecognitionDirector.countFaces(faces,
                                                               withinBounds: frameBounds,
                                                               requiredFacesCount: requiredFacesCount)
        
        let isFacesWithinBounds = facesWithinBounds == faces.count
        
//        // Проверка на то, что все лица находятся в зоне якоря
//        let facesWithinAnchor = RecognitionDirector.checkFaces(faces,
//                                                               inFrame: frameBounds,
//                                                               withinAnchorPoint: anchorPoint,
//                                                               withRadius: anchorRadius)
//        
//        let isFacesWithinAnchor = facesWithinAnchor == faces.count
//        
//        if isFacesWithinAnchor {
        
        let satisfactoryMathingPercentage = RecognitionDirector.minSatisfactoryMathingPercentage//max(RecognitionDirector.minSatisfactoryMathingPercentage, min(RecognitionDirector.maxSatisfactoryMathingPercentage, (1 - ((faceRects.first?.size.width ?? 0) / frameBounds.size.width) * 2)))
        
        let distances = RecognitionDirector.calculateDistance(anchorPoint, frame: frameBounds, faceRects: faceRects)
        let radius = distances.maxDistance * (1 - satisfactoryMathingPercentage)
        
        // Определение местоположения лиц относительно положения центра якоря
        let position = RecognitionDirector.recognizePosition(anchorPoint,
                                                             anchorRadius: radius, // TODO: Проверить. Или оставить anchorRadius
                                                             faceRects: faceRects,
                                                             strategy: RecognitionStrategy.circularIntersection,
                                                             orientation: orientation)
            
        let matchingPercentage = RecognitionDirector.matchingPercentage(anchorPoint,
//                                                                            anchorRadius: anchorRadius,
                                                                        frame: frameBounds,
                                                                        faceRects: faceRects,
                                                                        strategy: RecognitionStrategy.circularIntersection)
        
        let matched = matchingPercentage >= RecognitionDirector.minSatisfactoryMathingPercentage

        
        let info = RecognitionInfo(faces: faces,
                                   requiredFacesCount: requiredFacesCount,
                                   frameBounds: frameBounds,
                                   position: position,
                                   mathingPercentage: Double(matchingPercentage),
                                   withinBounds: isFacesWithinBounds,
                                   matched: matched)
                                   //withinAnchor: isFacesWithinAnchor,
//                                       oppositeToEachOther: false)
        
        self.delegate?.recognitionDirector(self, recognizedWithInfo: info)
//        } else {
//            // Определение позиции лиц для выбора оповещения ("БЛИЖЕ" - если лица находятся по разные стороны границ якоря, или "ПОЛОЖЕНИЕ" - если лица находятся за пределами якоря на одной стороне)
//            var positions = [[RelativePosition]]()
//            
//            for face in faces {
//                // Определение местоположения лицa относительно положения центра якоря
//                let position = RecognitionDirector.recognizePosition(anchorPoint,
//                                                                     anchorRadius: anchorRadius,
//                                                                     faceRects: [face.rect],
//                                                                     strategy: RecognitionStrategy.CircularIntersection)
//                positions.append(position)
//            }
//
//            let uniquePositions = unique(positions.flatMap() { $0 })
//            
//            let isOpposite = uniquePositions.count > positions.count
//            
//            // Определение местоположения лиц относительно положения центра якоря
//            let position = RecognitionDirector.recognizePosition(anchorPoint,
//                                                                 anchorRadius: 0, // TODO: Проверить. Или оставить anchorRadius
//                                                                 faceRects: faceRects,
//                                                                 strategy: RecognitionStrategy.CircularIntersection)
//            
//            let info = RecognitionInfo(faces: faces,
//                                       requiredFacesCount: requiredFacesCount,
//                                       frameBounds: frameBounds,
//                                       position: position,
//                                       mathingPercentage: 0,
//                                       withinBounds: isFacesWithinBounds,
//                                       withinAnchor: isFacesWithinAnchor,
//                                       oppositeToEachOther: isOpposite)
//            
//            self.delegate?.recognitionDirector(self, recognizedWithInfo: info)
//        }
    }
    
    
    /**
     Count faces within given bounds
     
     - parameter faces:  Array of faces
     - parameter bounds: Bounds
     - parameter count:  Required faces count
     
     - returns: Count of faces within bounds
     */
    class func countFaces(_ faces: [Face], withinBounds bounds: CGRect, requiredFacesCount count: Int) -> Int {
        return (faces.filter { (face) -> Bool in
            return bounds.contains(face.rect)
            }).count
    }
    
    
    /**
     Recognize position of face rects
     
     - parameter anchorPoint:  Anchor point
     - parameter anchorRadius: Anchor radius
     - parameter faceRects:    Array of face rects
     - parameter strategy:     Calculation strategy
     
     - returns: Array of positions
     */
    class func recognizePosition(_ anchorPoint: CGPoint, anchorRadius: CGFloat, faceRects: [CGRect], strategy: RecognitionStrategy, orientation: AVCaptureVideoOrientation) -> [RelativePosition] {
        let facesCenter = centerPoinForRects(faceRects)
//        let distance = Utils.euclidianDistance(facesCenter, point2: anchorPoint)
        let position = getPointPosition(facesCenter,
                                        relativeToAnchorPoint: anchorPoint,
                                        radius: anchorRadius,
                                        orientation: orientation)
        return position
    }
    
    /**
     Calculate matching percentage of faces relative to anchor
     
     - parameter anchorPoint:  Anchor point
     - parameter anchorRadius: Anchor radius
     - parameter frame:        Frame bounds
     - parameter faceRects:    Array of face rects
     - parameter strategy:     Calculation strategy
     
     - returns: Matching percentage in range 0...1
     */
    class func matchingPercentage(_ anchorPoint: CGPoint, /*anchorRadius: CGFloat,*/ frame: CGRect, faceRects: [CGRect], strategy: RecognitionStrategy) -> CGFloat {
        switch strategy {
        case .centerDistance:
            let distances = RecognitionDirector.calculateDistance(anchorPoint, frame: frame, faceRects: faceRects)
            let percentage = (distances.maxDistance - distances.distance) / distances.maxDistance
            return percentage
        case .circularIntersection:
            let distances = RecognitionDirector.calculateDistance(anchorPoint, frame: frame, faceRects: faceRects)
            let percentage = (distances.maxDistance - distances.distance) / distances.maxDistance
//            let percentage = max(0, 1.0 - (distances.distance / anchorRadius)) + 0.5
            return percentage
        case .unknown:
            return 0
        }
    }
    
    
    /**
     Calculate distance between anchor and face rects
     
     - parameter anchorPoint: Anchor point
     - parameter frame:       Frame bounds
     - parameter faceRects:   Array of face rects
     
     - returns: Tuple - (distance, max distance)
     */
    class func calculateDistance(_ anchorPoint: CGPoint, frame: CGRect, faceRects: [CGRect]) -> (distance: CGFloat, maxDistance: CGFloat) {
        let facesCenter = RecognitionDirector.centerPoinForRects(faceRects)
        let distance = Utils.euclidianDistance(anchorPoint, point2: facesCenter)
        
        let topLeftDistance = Utils.euclidianDistance(anchorPoint, point2: CGPoint(x: frame.origin.x, y: frame.origin.y))
        let topRightDistance = Utils.euclidianDistance(anchorPoint, point2: CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y))
        let bottomLeftDistance = Utils.euclidianDistance(anchorPoint, point2: CGPoint(x: frame.origin.x, y: frame.origin.y + frame.size.height))
        let bottomRightDistance = Utils.euclidianDistance(anchorPoint, point2: CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y + frame.size.height))
        let maxDistance = max(topLeftDistance, max(topRightDistance, max(bottomLeftDistance, bottomRightDistance)))
        
        return (distance: distance, maxDistance: maxDistance)
    }
    
    
    /**
     Calculate center point for given rects
     
     - parameter rects: Array of rects
     
     - returns: Center point
     */
    fileprivate class func centerPoinForRects(_ rects: [CGRect]) -> CGPoint {
        var centers = [CGPoint]()
        
        for rect in rects {
            centers.append(CGPoint(x: rect.midX, y: rect.midY))
        }
        
        let left = centers.min { (p1, p2) -> Bool in
            return p1.x < p2.x
        } ?? CGPoint(x: 0, y: 0)
        let top = centers.min { (p1, p2) -> Bool in
            return p1.y < p2.y
        } ?? CGPoint(x: 0, y: 0)
        let right = centers.max { (p1, p2) -> Bool in
            return p1.x < p2.x
        } ?? CGPoint(x: 0, y: 0)
        let bottom = centers.max { (p1, p2) -> Bool in
            return p1.y < p2.y
        } ?? CGPoint(x: 0, y: 0)
        
        let rect = CGRect(x: left.x, y: top.y, width: right.x - left.x, height: bottom.y - top.y)
        let point = CGPoint(x: rect.midX, y: rect.midY)
        
        return point
    }
    
    
    /**
     Calculate point position relative to anchor point (or any point)
     
     - parameter point:    Point
     - parameter anchor:   Anchor point
     - parameter radius:   Anchor radius
     - parameter distance: Distance between points
     
     - returns: Array of positions
     */
    fileprivate class func getPointPosition(_ point: CGPoint, relativeToAnchorPoint anchor: CGPoint, radius: CGFloat, orientation: AVCaptureVideoOrientation) -> [RelativePosition] {
        var horizontalPosition: RelativePosition = .Unknown
        if point.x < anchor.x - radius {
            horizontalPosition = .Left
        } else if point.x > anchor.x + radius {
            horizontalPosition = .Right
        } else {
            horizontalPosition = .Within
        }
        
        var verticalPosition: RelativePosition = .Unknown
        if point.y < anchor.y - radius {
            verticalPosition = .Above
        } else if point.y > anchor.y + radius {
            verticalPosition = .Under
        } else {
            verticalPosition = .Within
        }
        
        horizontalPosition = horizontalPosition.positionForOrientation(orientation)
        verticalPosition = verticalPosition.positionForOrientation(orientation)
        
        return [horizontalPosition, verticalPosition]
    }
    
}
