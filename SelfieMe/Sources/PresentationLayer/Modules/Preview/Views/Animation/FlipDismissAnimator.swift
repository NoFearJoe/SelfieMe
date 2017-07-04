//
//  FlipDismissAnimator.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 28.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


final class FlipDismissAnimator: NSObject {

    

}


extension FlipDismissAnimator: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        let portrait = UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)

        let screenBounds = UIScreen.main.bounds
        let point = CGPoint(x: 0, y: screenBounds.height)
        let bottomLeftCorner = portrait ? point : point.exchanged()
        let finalFrame = CGRect(origin: bottomLeftCorner, size: screenBounds.size)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                fromVC.view.frame = finalFrame
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }

}
