//
//  SettingsItem.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 12.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation



class SettingsItem {
    
    var title: String
    var variable: String
    var touchable: Bool
    
    
    init(title: String, variable: String, touchable: Bool) {
        self.title = title
        self.variable = variable
        self.touchable = touchable
    }
    
}