//
//  SettingsMultipleCell.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 13.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


class SettingsMultipleCell: SettingsCell {
    
    override var settingsItem: SettingsItem? {
        didSet {
            if let item = settingsItem as? SettingsMultipleItem {
                textLabel?.text = item.title
                if let value = item.defaultValue {
                    detailTextLabel?.text = item.detailed ? localized("\(value)") : ""
                }
            }
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        textLabel?.textColor = Theme.tintColor
        detailTextLabel?.textColor = Theme.secondaryTintColor
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
