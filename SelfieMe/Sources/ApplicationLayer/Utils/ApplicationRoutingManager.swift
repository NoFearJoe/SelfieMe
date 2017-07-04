//
//  ApplicationRoutingManager.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 28.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


final class ApplicationRoutingManager {
    
    var applicationRootViewController: ApplicationRootViewController!
    
    
    init(applicationRootViewController: ApplicationRootViewController) {
        self.applicationRootViewController = applicationRootViewController
    }
    
    
    fileprivate func rootViewController() -> UIViewController {
        return StoryboardManager.manager.cameraViewController()
    }
    
    
    func showRootViewController() {
        let controller = rootViewController()
        applicationRootViewController.setViewControllers([controller], animated: false)
    }
    
    
    func showEducationViewController(_ animated: Bool) {
        let controller = StoryboardManager.manager.educationViewController()
        applicationRootViewController.setViewControllers([controller], animated: animated)
    }
    
    func showCameraViewController(_ animated: Bool) {
        let controller = StoryboardManager.manager.cameraViewController()
        applicationRootViewController.setViewControllers([controller], animated: animated)
    }
    
}
