//
//  Rotatable.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 03.02.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation

protocol Rotatable {

    var preventRotations: Bool { get set }
    
    func rotate(_ angle: Float, animated: Bool)

}
