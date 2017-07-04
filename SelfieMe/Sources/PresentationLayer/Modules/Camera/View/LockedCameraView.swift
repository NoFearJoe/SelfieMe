//
//  LockedCameraView.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 11.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


/// View for present locked camera state
final class LockedCameraView: UIView {
    
    @IBOutlet weak var cameraLensImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    var singleTapClosure: (voidClosure)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        backgroundColor = Theme.backgroundColor
        
        cameraLensImageView.image = cameraLensImageView.image?.withRenderingMode(.alwaysTemplate)
        cameraLensImageView.tintColor = Theme.secondaryTintColor.withAlphaComponent(0.25)
        
        descriptionLabel.text = localized("TOUCH_TO_ENABLE_CAMERA")
        descriptionLabel.textColor = Theme.mainColor
    }
    
    
    @IBAction func onSingleTap(_ sender: UITapGestureRecognizer) {
        singleTapClosure?()
    }
    
}
