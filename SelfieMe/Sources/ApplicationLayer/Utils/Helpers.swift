//
//  Extensions.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 07.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation




func unique<S: Sequence, E: Hashable>(_ source: S) -> [E] where E == S.Iterator.Element {
    var seen = [E: Bool]()
    return source.filter { seen.updateValue(true, forKey: $0) == nil }
}


func rand(_ from: UInt32, to: UInt32) -> UInt32 {
    return arc4random_uniform(to) + from
}
