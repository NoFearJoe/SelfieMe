//
//  NavigationControllerAnimatorProvider.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 29.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


final class NavigationControllerAnimatorProvider: NSObject, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if (operation == UINavigationControllerOperation.push) {
            return PushAnimator()
        } else if operation == UINavigationControllerOperation.pop {
            return PopAnimator()
        }
        
        return nil
    }
    
}
