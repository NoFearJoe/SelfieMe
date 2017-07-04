//
//  UINavigationBar+Transparent.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 02.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


extension UINavigationBar {
    
    func setTransparentColor(_ color: UIColor) {
        backgroundColor = color
        barTintColor = color
        for view in subviews {
            if let c = NSClassFromString("_UIBarBackground") {
                if view.isKind(of: c) {
                    view.backgroundColor = color
                }
            } else if let c = NSClassFromString("_UINavigationBarBackground") {
                if view.isKind(of: c) {
                    view.backgroundColor = color
                }
            }
        }
    }

}


extension UIToolbar {
    
    func setTransparentColor(_ color: UIColor) {
        self.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        self.setShadowImage(UIImage(), forToolbarPosition: .any)
        backgroundColor = color
        barTintColor = color
        for view in subviews {
            if let c = NSClassFromString("_UIToolbarBackground"), view.isKind(of: c) {
                view.autoresizesSubviews = true
                let v = UIView(frame: view.frame)
                v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                v.backgroundColor = color
                view.addSubview(v)
            }
        }
    }
    
}
