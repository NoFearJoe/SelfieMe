//
//  UInt+Random.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 29.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation


extension UInt {

    static func randRange(_ lower: UInt, upper: UInt) -> UInt {
        return lower + UInt(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    func randTo(_ upper: UInt) -> UInt {
        return UInt.randRange(self, upper: upper)
    }
    
}
