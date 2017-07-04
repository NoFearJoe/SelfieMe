//
//  SettingsToggleCell.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 13.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


class SettingsToggleCell: SettingsCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggle: UISwitch!
    
    var onToggleBlock: boolClosure?
    
    override var settingsItem: SettingsItem? {
        didSet {
            if let item = settingsItem as? SettingsToggleItem {
                titleLabel.text = item.title
                toggle.isOn = item.enabled
                accessoryType =  item.help == nil ? .none : .detailButton
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction func onToggle(_ sender: UISwitch) {
        onToggleBlock?(sender.isOn)
    }
    
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        titleLabel.textColor = Theme.tintColor
        
        toggle.onTintColor = Theme.tintColor
        toggle.thumbTintColor = Theme.mainColor
        toggle.tintColor = Theme.secondaryTintColor
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
