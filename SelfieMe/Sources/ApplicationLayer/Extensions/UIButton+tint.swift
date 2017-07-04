//
//  UIButton+tint.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 12.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit



extension UIButton {

    
    func setImageViewTintColor(_ color: UIColor) {
        setImage(imageView?.image?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        imageView?.tintColor = color
    }


}
