//
//  StoryboardManager.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 23.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import Photos


struct SegueIdentifiers {
    static let navigationControllerPreviewControllerSegueIdentifier = "presentPreviewControllerSegue"
    static let navigationControllerSettingsControllerSegueIdentifier = "presentSettingsControllerSegue"
    
    static let settingsPickerTableViewControllerSegueIdentifier = "presentPickerTableControllerSegue"
}

struct ViewControllerIdentifiers {
    static let cameraViewControllerIdentifier = "CameraViewController"
    
    static let navigationContainerControllerIdentifier = "PreviewNavigationController"
    
    static let photoPreviewViewControllerIdentifier = "PhotoPreviewViewController"
    static let galleryViewControllerIdentifier = "GalleryViewController"
    
    static let settingsViewControllerIdentifier = "SettingsViewController"
    
    static let educationContentViewController = "EducationContentViewController"
    static let educationPopoverViewController = "EducationPopoverViewController"
}


class StoryboardManager {
    
    static let manager = StoryboardManager()
    
    fileprivate func mainStoryboard() -> UIStoryboard {
        let name = Device.iPad ? "MainStoryboard_iPad" : "MainStoryboard_iPhone"
        return UIStoryboard(name: name, bundle: Bundle.main)
    }
    
    fileprivate func educationStoryboard() -> UIStoryboard {
        let name = Device.iPad ? "EducationStoryboard_iPad" : "EducationStoryboard_iPhone"
        return UIStoryboard(name: name, bundle: Bundle.main)
    }
    
    
    
    func cameraViewController() -> CameraViewController {
        return mainStoryboard().instantiateViewController(withIdentifier: ViewControllerIdentifiers.cameraViewControllerIdentifier) as! CameraViewController
    }
    
    
    
    func navigationContainerController() -> PreviewNavigationController {
        return mainStoryboard().instantiateViewController(withIdentifier: ViewControllerIdentifiers.navigationContainerControllerIdentifier) as! PreviewNavigationController
    }
    
    
    func photoPreviewViewController() -> PhotoPreviewViewController {
        return mainStoryboard().instantiateViewController(withIdentifier: ViewControllerIdentifiers.photoPreviewViewControllerIdentifier) as! PhotoPreviewViewController
    }
    
    func photoPreviewViewControllerWithAssetIndex(_ index: Int) -> PhotoPreviewViewController {
        let controller = mainStoryboard().instantiateViewController(withIdentifier: ViewControllerIdentifiers.photoPreviewViewControllerIdentifier) as! PhotoPreviewViewController
        controller.model.currentAssetIndex = index
        return controller
    }
    
    
    
    
    func galleryViewController() -> GalleryViewController {
        return mainStoryboard().instantiateViewController(withIdentifier: ViewControllerIdentifiers.galleryViewControllerIdentifier) as! GalleryViewController
    }
    
    
    func settingsViewController() -> SettingsViewController {
        return mainStoryboard().instantiateViewController(withIdentifier: ViewControllerIdentifiers.settingsViewControllerIdentifier) as! SettingsViewController
    }
    
    
    
    func educationViewController() -> EducationViewController {
        return educationStoryboard().instantiateInitialViewController() as! EducationViewController
    }
    
    func educationContentViewController() -> EducationContentViewController {
        return educationStoryboard().instantiateViewController(withIdentifier: ViewControllerIdentifiers.educationContentViewController) as! EducationContentViewController
    }
    
    func educationPopoverController() -> EducationPopoverViewController {
        return educationStoryboard().instantiateViewController(withIdentifier: ViewControllerIdentifiers.educationPopoverViewController) as! EducationPopoverViewController
    }
    
}
