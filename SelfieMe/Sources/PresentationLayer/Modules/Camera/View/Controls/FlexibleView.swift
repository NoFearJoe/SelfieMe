//
//  FlexibleView.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 27.01.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable final class FlexibleView: UIView {
    
    @IBInspectable var sideInset: CGFloat = 8.0
    @IBInspectable var verticalInset: CGFloat = 6.0
    @IBInspectable var minimumInteritemSpacing: CGFloat = 16.0
    
    fileprivate var needUpdateConstraints = false
    fileprivate var oldConstraints = [NSLayoutConstraint]()
    fileprivate var oldViewConstraints = [NSLayoutConstraint]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        let frameWidth = frame.size.width
        let subviewsCount = CGFloat(subviews.count)
        let height = frame.size.height - verticalInset * 2
        let width = height
        let offset: CGFloat = 16.0
        let interitemSpace: CGFloat = ((frameWidth - offset * 2) - (width * subviewsCount)) / (subviewsCount - 1.0)
        
        var counter = 0
        for view in subviews {
            let x = CGFloat(counter) * (width + interitemSpace)
            view.frame = CGRect(x: offset + x, y: verticalInset, width: width, height: height)
            counter += 1
        }
    }
    
    
    func removeAllSubviews() {
        subviews.forEach { (view) -> () in
            view.removeFromSuperview()
        }
    }
    
}
