//
//  UIViewController+Utils.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 29.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation


extension UIViewController {

    func setInterfaceLocked(_ locked: Bool) {
        if locked {
            UIApplication.shared.beginIgnoringInteractionEvents()
        } else {
            if UIApplication.shared.isIgnoringInteractionEvents {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    
    
    func buildSpacer() -> UIBarButtonItem {
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = -11
        return spacer
    }
    
    func buildCloseButton(_ target: AnyObject, selector: Selector) -> UIBarButtonItem {
        if let image = UIImage(named: "closeButtonImage") {
            let button = BarButton(image: image, target: target, action: selector)
            button.width = 44.0
            return button
        }
        return UIBarButtonItem()
    }
    
    func buildGridButton(_ small: Bool, target: AnyObject, selector: Selector) -> UIBarButtonItem {
        let imageName = small ? "galleryButtonImageSmall" : "galleryButtonImage"
        if let image = UIImage(named: imageName) {
            let button = BarButton(image: image, target: target, action: selector)
            button.width = 44
            return button
        }
        return UIBarButtonItem()
    }
    
    func buildEditButton(_ target: AnyObject, selector: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .edit, target: target, action: selector)
    }
    
    func buildDoneButton(_ target: AnyObject, selector: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .done, target: target, action: selector)
    }
    
    func buildSelectButton(_ target: AnyObject, selector: Selector) -> UIBarButtonItem {
        let title = NSLocalizedString("GALLERY_SELECT_ALL", comment: "")
        return UIBarButtonItem(title: title, style: .plain, target: target, action: selector)
    }
    
    
    func buildGalleryButton(_ target: AnyObject, selector: Selector) -> BarButton {
        let image = UIImage(named: "galleryButtonImageSmall")!
        let button = BarButton(image: image, target: target, action: selector)
        button.width = 44.0
        return button
    }
    
    
    func buildCancelButton(_ target: AnyObject, selector: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: target, action: selector)
    }
    
    func buildSaveButton(_ target: AnyObject, selector: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .save, target: target, action: selector)
    }

}
