//
//  UIColor+RGB.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 25.06.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {

    static func r(_ r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) -> UIColor {
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
}
