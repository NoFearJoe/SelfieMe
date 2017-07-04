//
//  CameraStreamViewContainer.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 20.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


/// Container view for CameraStreamView and MetadataView
class CameraStreamViewContainer: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        translatesAutoresizingMaskIntoConstraints = false
        autoresizesSubviews = false
    }
    
    override func updateConstraints() {
        super.updateConstraints()

        let prototypingConstraints = constraints.flatMap() { constraint -> NSLayoutConstraint? in
            if constraint.classForCoder == NSClassFromString("NSIBPrototypingLayoutConstraint")! {
                return constraint
            }
            return nil
        }
        
        removeConstraints(prototypingConstraints)
    }
    
}