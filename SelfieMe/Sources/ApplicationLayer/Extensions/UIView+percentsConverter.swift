//
//  UIView+percentsConverter.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 24.05.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


enum ViewSide {
    case width
    case height
    
    
    init(size: CGSize) {
        if size.width < size.height {
            self = .width
        } else {
            self = .height
        }
    }
}


extension UIView {

    func percentToViewPixels(_ percent: CGFloat, viewSide: ViewSide) -> CGFloat {
        switch viewSide {
        case .width:
            return percent * self.frame.size.width
        case .height:
            return percent * self.frame.size.height
        }
    }
    
    func percentSizeToViewPixelSize(_ percentSize: CGSize) -> CGSize {
        let width = self.percentToViewPixels(percentSize.width, viewSide: .width)
        let height = self.percentToViewPixels(percentSize.height, viewSide: .height)
        return CGSize(width: width, height: height)
    }

}
