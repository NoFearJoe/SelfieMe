//
//  EducationViewController.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 28.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


final class EducationViewController: UIPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let controller = viewControllerAtIndex(0) {
            setViewControllers([controller], direction: .forward, animated: false, completion: nil)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = Theme.mainColor
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .all
    }
    
}


extension EducationViewController: UIPageViewControllerDataSource {

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 6
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! EducationContentViewController).data?.index ?? 0
        return viewControllerAtIndex(index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! EducationContentViewController).data?.index ?? 0
        return viewControllerAtIndex(index + 1)
    }
    
    
    func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        if index < 0 || index >= 6 {
            return nil
        }
        let controller = StoryboardManager.manager.educationContentViewController()
        let text = NSLocalizedString("EDUCATION_PAGE_\(index)_TEXT", comment: "")
        let image = UIImage(named: "educationPage\(index)DeviceImage") ?? UIImage()
        controller.data = (index: index, text: text, deviceImage: image, isLast: index == 5)
        return controller
    }

}


extension EducationViewController: UIPageViewControllerDelegate {

    func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
        return .portrait
    }

}
