//
//  EducationPopoverViewController.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 19.05.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit




final class EducationPopoverViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    var text: String?
    
    var containerView: UIView?
    var sourceView: UIView? {
        didSet {
//            sourceView?.addObserver(self, forKeyPath: "frame", options: .New, context: nil)
//            sourceView?.addObserver(self, forKeyPath: "center", options: .New, context: nil)
//            sourceView?.addObserver(self, forKeyPath: "bounds", options: .New, context: nil)
        }
    }
    var sourceRect: CGRect? {
        didSet {
            if let frame = sourceView?.frame {
                if let rightViewOrigin = sourceView?.convert(sourceView?.frame.origin ?? CGPoint.zero, to: nil) {
                    let viewCenter = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2)
                    let rect = CGRect(x: rightViewOrigin.x + viewCenter.x - (preferredContentSize.width / 2.0),
                                            y: rightViewOrigin.y + (sourceRect?.origin.y ?? 0),
                                            width: preferredContentSize.width,
                                            height: preferredContentSize.height)
                    view.frame = rect
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.masksToBounds = false
        view.layer.zPosition = 500
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = Theme.lightTintColor
        
        label.text = text
    }
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" || keyPath == "center" || keyPath == "bounds" {
            if let _ = change?[NSKeyValueChangeKey.newKey] as? CGRect {
                let rect = sourceRect
                sourceRect = rect
            }
        }
    }
    
    
//    deinit {
//        self.removeObserver(self, forKeyPath: "frame")
//    }
    
}
