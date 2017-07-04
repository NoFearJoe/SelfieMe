//
//  ShareControllerBuilder.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 28.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


class ShareControllerBuilder {
    
    class func buildPhotoShareController(_ items: [AnyObject]?, barButtonItem: UIBarButtonItem?) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: items ?? [UIImage()], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.saveToCameraRoll]
        
        if Device.iPad {
            activityViewController.modalPresentationStyle = .popover
            activityViewController.popoverPresentationController?.permittedArrowDirections = .down
            activityViewController.popoverPresentationController?.barButtonItem = barButtonItem
        }
        
        return activityViewController
    }
    
}
