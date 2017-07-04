//
//  SettingsSection.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 12.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation



class SettingsSection {
    
    var title: String
    var subtitle: String
    
    var items: [SettingsItem]
    
    
    init(title: String, subtitle: String, items: [SettingsItem]) {
        self.title = title
        self.subtitle = subtitle
        self.items = items
    }
    
}