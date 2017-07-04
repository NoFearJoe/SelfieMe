//
//  SettingsButtonCell.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 13.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


class SettingsButtonCell: SettingsCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override var settingsItem: SettingsItem? {
        didSet {
            if let item  = settingsItem as? SettingsButtonItem {
                titleLabel.text = item.title
            }
        }
    }
    
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
