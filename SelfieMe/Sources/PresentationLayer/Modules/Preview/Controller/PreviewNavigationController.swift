//
//  PreviewNavigationController.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 23.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


class PreviewNavigationController: UINavigationController {
    
    fileprivate var isInterfaceHidden = false
    
    var visible = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isNavigationBarHidden = false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isInterfaceHidden = false
        setNeedsStatusBarAppearanceUpdate()
        
        setNavigationBarHidden(false, animated: false)
        setToolbarHidden(false, animated: false)
        
        navigationBar.barStyle = .black
        toolbar.barStyle = .black
                
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        navigationBar.setTransparentColor(Theme.backgroundColor.withAlphaComponent(0.25))
        toolbar.setTransparentColor(Theme.backgroundColor.withAlphaComponent(0.25))
        
        navigationBar.tintColor = Theme.mainColor
        toolbar.tintColor = Theme.mainColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        visible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        visible = false
        
        super.viewWillDisappear(animated)
        
        isInterfaceHidden = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true //isInterfaceHidden
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .fade
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

    
}
