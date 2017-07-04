//
//  RecognitionStrategy.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 04.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


/**
 Enum of recognition strategies
 
 - Unknown:              Uses if recognition director can't determine algorithm
 - CenterDistance:       Calculate distance between centers of anchor and face rects
 - CircularIntersection: Calculate percent of intersection between anchor circle and face circles
 */
enum RecognitionStrategy {

    case unknown
    case centerDistance
    case circularIntersection

}
