//
//  FiltersFlyweight.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 11.02.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit

//enum FilterType: String {
//    case Original = "Original"
//    case Sepia = "CISepiaTone"
//    case Mono = "CIPhotoEffectMono"
//    case Fade = "CIPhotoEffectFade"
//    
//    static var all: [FilterType] {
//        return [FilterType.Original, .Fade, .Mono, .Sepia]
//    }
//    
//    static func typeForFilterName(name: String) -> FilterType? {
//        switch name {
//        case FilterType.Original.rawValue: return .Original
//        case FilterType.Sepia.rawValue: return .Sepia
//        case FilterType.Mono.rawValue: return .Mono
//        case FilterType.Fade.rawValue: return .Fade
//        default: return nil
//        }
//    }
//}


enum FilterCategory: String {
    case Favourite = "Favourite"
    case Blur = "CICategoryBlur"
    case ColorAdjustment = "CICategoryColorAdjustment"
    case ColorEffect = "CICategoryColorEffect"
    case CompositeOperation = "CICategoryCompositeOperation"
    case DistortionEffect = "CICategoryDistortionEffect"
    case HalftoneEffect = "CICategoryHalftoneEffect"
    case Stylize = "CICategoryStylize"
    case TileEffect = "CICategoryTileEffect"
    
    static var all: [FilterCategory] {
        return [.Favourite, .Blur, .ColorAdjustment, .ColorEffect, .CompositeOperation, .DistortionEffect, .HalftoneEffect, .Stylize, .TileEffect]
    }
}


final class FiltersFlyweightFactory {
    
    fileprivate lazy var filters = [FilterCategory: [Filter]]()
    
//    func filterByType(type: FilterType) -> Filter? {
//        if filters.keys.contains(type) {
//            return filters[type]!
//        }
//        let filter = Filter(type: type)
//        filters[type] = filter
//        return filter
//    }
    
    static let sharedInstance = FiltersFlyweightFactory()
    
    func filtersByCategory(_ category: FilterCategory) -> [Filter] {
        if filters.keys.contains(category) {
            return filters[category]!
        }
        
        let filterNames = CIFilter.filterNames(inCategory: category.rawValue)
        var filtersArray = [Filter]()
        
        filtersArray.append(Filter(filter: CIFilter(name: "Original")))
        
        for name in filterNames {
            if let ciFilter = CIFilter(name: name) {
                ciFilter.setDefaults()
                let filter = Filter(filter: ciFilter)
                filtersArray.append(filter)
            }
        }
        
        return filtersArray
    }
    
}
