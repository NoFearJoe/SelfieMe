//
//  CameraViewController+Utils.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 26.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit



extension CameraViewController {

    func setControlsEnabled(_ controls: [UIView?], enabled: Bool) {
        UIView.animate(withDuration: Animation.defaultDuration, animations: {
            controls.forEach { (control) in
                control?.alpha = enabled ? 1.0 : 0.5
                control?.isUserInteractionEnabled = enabled
            }
        }) 
    }
    
    func setControlsHighlighted(_ controls: [UIView?], highlighted: Bool) {
        UIView.animate(withDuration: Animation.defaultDuration, animations: {
            controls.forEach { (control) in
                control?.layer.shadowColor = Theme.mainColor.cgColor
                control?.layer.shadowRadius = 4.0
                control?.layer.shadowOpacity = highlighted ? 0.5 : 0.0
            }
        }) 
    }
    
    
    func presentViewController(_ controller: UIViewController, animated: Bool) {
        DispatchQueue.main.async { [weak self] _ in
            self?.present(controller, animated: animated, completion: nil)
        }
    }

}
