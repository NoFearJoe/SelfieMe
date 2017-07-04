//
//  AutolayoutIgnorableView.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 20.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


/// This application use auto layout, but not always. CameraStreamView and MetadataView not use auto layout. Because of it, view resizes when appear. This class will block all attemt to set zero frame, and also attemt to set bounds and center.
class AutolayoutIgnorableView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            if !newValue.size.equalTo(CGSize.zero) {
                super.frame = newValue
            }
        }
    }
    
    override var bounds: CGRect {
        get {
            return super.bounds
        }
        set {
            
        }
    }
    
    override var center: CGPoint {
        get {
            return super.center
        }
        set {
            
        }
    }
    
}
