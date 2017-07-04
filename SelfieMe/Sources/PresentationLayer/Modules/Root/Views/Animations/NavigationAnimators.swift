//
//  NavigationAnimators.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 26.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


class PushAnimator: NSObject {
    
}

extension PushAnimator: UIViewControllerAnimatedTransitioning {
    
    @objc func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Animation.transitionDuration
    }
    
    @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {

            transitionContext.containerView.addSubview(toViewController.view)
            
            let duration = self.transitionDuration(using: transitionContext)
            let frameHeight = fromViewController.view.frame.size.height
            
            fromViewController.view.transform = CGAffineTransform.identity
            toViewController.view.transform = CGAffineTransform(translationX: 0, y: -frameHeight)
            
            UIView.animate(withDuration: duration,
                animations: {
                    toViewController.view.transform = CGAffineTransform(translationX: 0, y: 0)
                    fromViewController.view.transform = CGAffineTransform(translationX: 0, y: frameHeight)
                },
                completion: { (complete) in
                    transitionContext.completeTransition(complete)
                }
            )
        }
    }

}



class PopAnimator: NSObject {
    
}

extension PopAnimator: UIViewControllerAnimatedTransitioning {
    
    @objc func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Animation.transitionDuration
    }
    
    @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
            
            transitionContext.containerView.addSubview(toViewController.view)
            
            let duration = self.transitionDuration(using: transitionContext)
            let frameHeight = fromViewController.view.frame.size.height
            
            fromViewController.view.transform = CGAffineTransform.identity
            toViewController.view.transform = CGAffineTransform(translationX: 0, y: frameHeight)
            
            UIView.animate(withDuration: duration,
                                       animations: {
                                        toViewController.view.transform = CGAffineTransform(translationX: 0, y: 0)
                                        fromViewController.view.transform = CGAffineTransform(translationX: 0, y: -frameHeight)
                },
                                       completion: { (complete) in
                                        transitionContext.completeTransition(complete)
                }
            )
        }
    }
    
//    @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
//        if let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
//            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {
//            
//            transitionContext.containerView()?.insertSubview(toViewController.view, belowSubview: fromViewController.view)
//            
//            let duration = self.transitionDuration(transitionContext)
//            
////            toViewController.view.alpha = 0.0
//            
//            UIView.animateWithDuration(duration,
//                animations: {
//                    fromViewController.view.alpha = 0.0
//                },
//                completion: { (complete) in
//                    transitionContext.completeTransition(complete)
//                }
//            )
//        }
//    }
    
}




class FadeInAnimator: NSObject {
    
}

extension FadeInAnimator: UIViewControllerAnimatedTransitioning {
    
    @objc func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Animation.transitionDuration
    }
    
    @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let _ = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
            
            transitionContext.containerView.addSubview(toViewController.view)
            
            let duration = self.transitionDuration(using: transitionContext)
            
            toViewController.view.alpha = 0.0
            
            UIView.animate(withDuration: duration,
                animations: {
                    toViewController.view.alpha = 1.0
                },
                completion: { (complete) in
                    transitionContext.completeTransition(complete)
                }
            )
        }
    }
    
}

class FadeOutAnimator: NSObject {
    
}

extension FadeOutAnimator: UIViewControllerAnimatedTransitioning {
    
    @objc func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Animation.transitionDuration
    }
    
    @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let _ = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
            
            transitionContext.containerView.addSubview(toViewController.view)
            
            let duration = self.transitionDuration(using: transitionContext)
            
            toViewController.view.alpha = 1.0
            
            UIView.animate(withDuration: duration,
                                       animations: {
                                        toViewController.view.alpha = 0.0
                },
                                       completion: { (complete) in
                                        transitionContext.completeTransition(complete)
                }
            )
        }
    }
    
}
