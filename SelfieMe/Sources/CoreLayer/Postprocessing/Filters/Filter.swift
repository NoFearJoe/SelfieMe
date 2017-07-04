//
//  Filter.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 11.02.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit

let filtersPlistFilePath = Bundle.main.path(forResource: "FilterParameters", ofType: "plist")!


final class Filter: NSObject {
    
    var filter: CIFilter?

    
    init(filter: CIFilter?) {
        super.init()
        self.filter = filter
    }
    
    
    var name: String {
        return filter?.name ?? "Original"
    }

    
    func setInputImage(_ image: CIImage) {
        filter?.setValue(image, forKey: kCIInputImageKey)
    }
    
    func setExtent(_ extent: CGRect) {
        if let _ = filter {
            if filter!.attributes.keys.contains(kCIInputExtentKey) {
                let vector = CIVector(cgRect: extent)
                filter!.setValue(vector, forKey: kCIInputExtentKey)
            }
        }
    }
    
    func setCenter(_ center: CGPoint) {
        if let _ = filter {
            if filter!.attributes.keys.contains(kCIInputCenterKey) {
                let vector = CIVector(cgPoint: center)
                filter!.setValue(vector, forKey: kCIInputCenterKey)
            }
        }
    }
    
    
    var localizedName: String {
        if let name = filter?.name {
            return NSLocalizedString(name, comment: name)
        }
        return NSLocalizedString("FILTER_UNKNOWN_NAME", comment: "Unknown")
    }
    
}
