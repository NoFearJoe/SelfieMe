//
//  SettingsToggleItem.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 12.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation



class SettingsToggleItem: SettingsItem {
    
    var enabled: Bool = false
    var help: String?
    
    init(title: String, variable: String, enabled: Bool = false, help: String? = nil) {
        super.init(title: title, variable: variable, touchable: false)
        self.enabled = enabled
        self.help = help
    }
    
    
}