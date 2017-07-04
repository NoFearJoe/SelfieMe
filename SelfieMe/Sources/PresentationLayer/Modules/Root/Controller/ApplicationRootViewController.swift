//
//  CameraViewContainerController.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 17.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


class ApplicationRootViewController: UINavigationController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (UIApplication.shared.delegate as! AppDelegate).applicationRoutingManager.showRootViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait //Device.iPad ? UIInterfaceOrientationMask.All : UIInterfaceOrientationMask.Portrait
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
}


extension ApplicationRootViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if (operation == UINavigationControllerOperation.push) {
            return FadeInAnimator()
        } else if operation == UINavigationControllerOperation.pop {
            return PopAnimator()
        }
        
        return nil
    }
    
}
