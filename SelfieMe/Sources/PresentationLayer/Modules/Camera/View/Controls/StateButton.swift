//
//  StateButton.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 21.01.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class StateButton: RotatableButton {
    
    @IBInspectable var inactiveStateColor: UIColor = UIColor.white
    @IBInspectable var activeStateColor: UIColor = UIColor.orange
    
    @IBAction func toggle() {
        isOn = !isOn
    }
    
    
    required init(frame: CGRect) {
        super.init(frame: frame)
        
        activateStateChange()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        activateStateChange()
    }
    
    func activateStateChange() {
        if let _ = imageView, let image = imageView?.image {
            imageView!.image = image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        }
        
        addTarget(self, action: #selector(StateButton.toggle), for: UIControlEvents.touchUpInside)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var isOn: Bool = false {
        didSet {
            let color = isOn ? activeStateColor : inactiveStateColor
            
            if let _ = imageView, let _ = imageView?.image {
                setImageViewTintColor(color)
                tintColor = color
            }
            if let _ = titleLabel {
                setTitleColor(color, for: UIControlState.normal)
            }
        }
    }
    
}
