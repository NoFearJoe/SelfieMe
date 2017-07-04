//
//  FlipDismissInteractor.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 28.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


final class FlipDismissInteractor: NSObject {

    let interactor = Interactor()
    
    
    
    func interactWith(panGestureRecognizer recognizer: UIPanGestureRecognizer, onClose: voidClosure?, onCancel: voidClosure?) {
        let treshold: CGFloat = 0.25
        
        let translation = recognizer.translation(in: recognizer.view)
        let verticalMovement = translation.y / (recognizer.view?.bounds.height ?? 1)
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
//        guard let interactor = interactor else { return }
        
        switch recognizer.state {
        case .began:
            interactor.hasStarted = true
            onClose?()
        case .changed:
            interactor.shouldFinish = progress > treshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
            onCancel?()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
            onCancel?()
        default:
            break
        }
    }
    
    
    
    internal class Interactor: UIPercentDrivenInteractiveTransition {
        var hasStarted = false
        var shouldFinish = false
    }

}


extension FlipDismissInteractor: UIViewControllerTransitioningDelegate {
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FlipDismissAnimator()
    }
    
}


