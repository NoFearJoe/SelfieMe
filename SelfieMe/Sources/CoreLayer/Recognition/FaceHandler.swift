//
//  FaceHandler.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 21.01.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit

final class FaceHandler {
    
    lazy var faces: [Face] = [Face]()
    
    init(features: [CIFeature]) {
        for feature in features {
            faces.append(Face(feature: feature))
        }
    }
    
    init(rects: [CGRect]) {
        for rect in rects {
            faces.append(Face(rect: rect))
        }
    }
    
    
    func normalizeFacesWithClap(_ clap: CGRect) {
        for face in faces {
            face.rect.origin.y = clap.size.height - (face.rect.origin.y + face.rect.size.height)
            face.leftEyePosition.y = clap.size.height - face.leftEyePosition.y
            face.rightEyePosition.y = clap.size.height - face.rightEyePosition.y
            face.mouthPosition.y = clap.size.height - face.mouthPosition.y
        }
    }
    
}
