//
//  FilterApplyOperation.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 30.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import GPUImage


class FilterApplyOperation: Operation {
    
    var filter: GPUImageOutput
    var image: UIImage
    
    var onComplete: ((UIImage?) -> Void)?
    
    override var isAsynchronous: Bool {
        return true
    }
    
    init(filter: GPUImageOutput, image: UIImage, onComplete: ((UIImage?) -> Void)? = nil) {
        self.filter = filter
        self.image = image
        self.onComplete = onComplete
        
        super.init()
    }
    
    
    override func main() {
        if self.isCancelled {
            return
        }
        
        let filteredImage = filter.image(byFilteringImage: image)
        
        onComplete?(filteredImage)
    }
    
}
