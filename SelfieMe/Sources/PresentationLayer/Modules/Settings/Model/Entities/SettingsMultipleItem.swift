//
//  SettingsMultipleItem.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 12.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation



class SettingsMultipleItem: SettingsItem {
    
    var items = [String: SettingsPickerItem]()
    var defaultValue: AnyObject?
    var detailed: Bool = true
    
    
    init(title: String, variable: String, items: [String: SettingsPickerItem]) {
        super.init(title: title, variable: variable, touchable: true)
        self.items = items
        self.defaultValue = items.first?.0 as AnyObject?
    }
    
    
}
