//
//  Face.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 21.01.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit

final class Face {
    
    var id: Int32 = -1
    
    var rect: CGRect = CGRect.zero
    
    var leftEyePosition: CGPoint = CGPoint.zero
    var rightEyePosition: CGPoint = CGPoint.zero
    var mouthPosition: CGPoint = CGPoint.zero
    
    var faceAngle: Float = 0.0
    
    var leftEyeClosed: Bool = false
    var rightEyeClosed: Bool = false
    var hasSmile: Bool = false
    
    init(feature: CIFeature) {
        let faceFeature = feature as! CIFaceFeature
        
        if faceFeature.hasTrackingID {
            id = faceFeature.trackingID
        }
        
        rect = faceFeature.bounds
        
        if faceFeature.hasMouthPosition {
            mouthPosition = faceFeature.mouthPosition
        }
        
        if faceFeature.hasLeftEyePosition {
            leftEyePosition = faceFeature.leftEyePosition
        }
        
        if faceFeature.hasRightEyePosition {
            rightEyePosition = faceFeature.rightEyePosition
        }
        
        if faceFeature.hasFaceAngle {
            faceAngle = faceFeature.faceAngle
        }
        
        leftEyeClosed = faceFeature.leftEyeClosed
        rightEyeClosed = faceFeature.rightEyeClosed
        
        hasSmile = faceFeature.hasSmile
    }
    
    
    init(rect: CGRect) {
        self.rect = rect
    }
    
    
}
