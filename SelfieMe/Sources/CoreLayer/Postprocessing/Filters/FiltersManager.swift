//
//  FiltersManager.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 11.02.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit

final class FiltersManager {
    
    var currentCategory: FilterCategory = FilterCategory.Favourite
    var currentCategoryLocalizedName: String {
        return NSLocalizedString(currentCategory.rawValue, comment: "")
    }
    var currentCategoryImage: UIImage {
        return UIImage(named: currentCategory.rawValue)!
    }
    
    
    static let manager = FiltersManager()
    
    
    func filters() -> [Filter] {
        let allFilters = FiltersFlyweightFactory.sharedInstance.filtersByCategory(currentCategory)
        let excludedFilters = FiltersManager.excludedFilters[currentCategory]!
        let availableFilters = allFilters.filter { (filter) -> Bool in
            let name = filter.name
            if !excludedFilters.contains(name) {
                return true
            }
            return false
        }
        
        return availableFilters
    }

    
    func categoryImages() -> [UIImage] {
        return FilterCategory.all.flatMap() { category in
            return UIImage(named: category.rawValue) ?? UIImage()
        }
    }
    
    
    fileprivate static let excludedFilters = [
        FilterCategory.Favourite: [],
        FilterCategory.Blur: ["CIZoomBlur"],
        FilterCategory.ColorAdjustment: ["CILinearToSRGBToneCurve", "CISRGBToneCurveToLinear"],
        FilterCategory.ColorEffect: [""],
        FilterCategory.CompositeOperation: [""],
        FilterCategory.DistortionEffect: [""],
        FilterCategory.HalftoneEffect: [""],
        FilterCategory.Stylize: [""],
        FilterCategory.TileEffect: [""]
    ]
    
}
