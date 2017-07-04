//
//  SettingsPickerModel.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 14.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}




class SettingsPickerModel {

    fileprivate var items: [SettingsPickerItem]?
    
    
    init(items: [SettingsPickerItem]) {
        self.items = items
    }

    
    subscript(index: Int) -> SettingsPickerItem? {
        get {
            if items?.count > 0 {
                return items?[index]
            }
            return nil
        }
    }
    
    
    var count: Int {
        return items?.count ?? 0
    }

}
