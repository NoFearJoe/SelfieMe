//
//  SettingsButtonItem.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 12.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation



class SettingsButtonItem: SettingsItem {
    
    var action: voidClosure?
    
    init(title: String) {
        super.init(title: title, variable: "", touchable: true)
    }
    
}