//
//  PhotoPreviewAssembly.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 28.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


final class PhotoPreviewAssembly {

    class func createModule(_ closeDelegate: CloseDelegate?) -> UINavigationController {
        let navigationController = StoryboardManager.manager.navigationContainerController()
        let controller = StoryboardManager.manager.photoPreviewViewController()
        
        controller.closeDelegate = closeDelegate
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .crossDissolve
        navigationController.setViewControllers([controller], animated: true)
        
        return navigationController
    }

}
