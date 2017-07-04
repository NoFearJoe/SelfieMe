//
//  BarButton.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 28.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


class BarButton: UIBarButtonItem {
    
    fileprivate var button: UIButton
    
    
    override var image: UIImage? {
        didSet {
            if let img = image?.withRenderingMode(.alwaysTemplate) {
                button.setImage(img, for: UIControlState.normal)
            }
        }
    }
    
    
    init(image: UIImage, target: AnyObject, action: Selector) {
        button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.setImage(image.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        super.init()
        
        customView = button
    }
    
    required init?(coder aDecoder: NSCoder) {
        button = UIButton(type: .custom)
        
        super.init(coder: aDecoder)
    }
    
}
