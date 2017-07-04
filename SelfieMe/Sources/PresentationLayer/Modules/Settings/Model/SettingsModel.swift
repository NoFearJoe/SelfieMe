//
//  SettingsModel.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 12.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation



class SettingsModel {
    
    var sections = [SettingsSection]()
    
    var onShare: voidClosure?
    var onRate: voidClosure?
    
    var onBuy: voidClosure?
    var onTwitter: voidClosure?
    var onMail: voidClosure?
    
    init() {
        
    }
    
    init(plistURL: URL, onShare: voidClosure?, onRate: voidClosure?, onBuy: voidClosure?, onTwitter: voidClosure?, onMail: voidClosure?) {
        let dictionary = NSDictionary(contentsOf: plistURL) as! [String: AnyObject]
        self.onShare = onShare
        self.onRate = onRate
        self.onBuy = onBuy
        self.onTwitter = onTwitter
        self.onMail = onMail
        sections = buildSections(dictionary)
    }
    
    
    fileprivate func buildSections(_ dictionary: [String: AnyObject]) -> [SettingsSection] {
        var sections = [SettingsSection]()
        
        let shareButtonItem = SettingsButtonItem(title: localized("SETTINGS_SHARE"))
        shareButtonItem.action = onShare
        let rateButtonItem = SettingsButtonItem(title: localized("SETTINGS_RATE"))
        rateButtonItem.action = onRate
        let mailButtonItem = SettingsButtonItem(title: localized("STRING_MAIL"))
        mailButtonItem.action = onMail
        
//        let pickerItems = [
//            localized("STRING_FACEBOOK"): SettingsPickerItem(text: localized("STRING_FACEBOOK"), detail: nil, action: onBuy),
//            localized("STRING_TWITTER"): SettingsPickerItem(text: localized("STRING_TWITTER"), detail: nil, action: onTwitter),
//            localized("STRING_MAIL"): SettingsPickerItem(text: localized("STRING_MAIL"), detail: nil, action: onMail)
//        ]
//        let connectionItem = SettingsMultipleItem(title: localized("SETTINGS_CONNECTION"), variable: "", items: pickerItems)
//        connectionItem.detailed = false
        
        let shareItems = ApplicationSettings.isRated() ? [shareButtonItem, mailButtonItem] : [shareButtonItem, rateButtonItem, mailButtonItem]
        let shareSection = SettingsSection(title: localized("SETTINGS_SECTION_SHARE"),
                                           subtitle: localized("SETTINGS_SECTION_SHARE_SUBTITLE"),
                                           items: shareItems)
        
        sections.append(shareSection)
        
        
        #if SELFIE_ME
        let buySelfieMePlusitem = SettingsButtonItem(title: "SelfieMe+")
        buySelfieMePlusitem.action = onBuy
        
        let buySection = SettingsSection(title: "", subtitle: "", items: [buySelfieMePlusitem])
        
        sections.append(buySection)
        #endif
        
        let generalSection = SettingsSection(title: localized("settings_general"), subtitle: "", items: [])
        sections.append(generalSection)
        
        if let preferenceItems = dictionary["PreferenceSpecifiers"] as? [AnyObject] {
            for item in preferenceItems {
                let dictionaryItem = item as! [String : AnyObject]
                if let itemClass = classForDictionaryItem(dictionaryItem) {
                    let title = localized(dictionaryItem["Title"]! as! String)
                    if itemClass == SettingsSection.self {
                        let currentSection = SettingsSection(title: title, subtitle: "", items: [])
                        sections.append(currentSection)
                    } else if itemClass == SettingsToggleItem.self {
                        let key = dictionaryItem["Key"]! as! String
                        let enabled = ApplicationSettings.isEnabled(key)
                        let help = dictionaryItem["Help"] as? String
                        let toggleItem = SettingsToggleItem(title: title, variable: key, enabled: enabled, help: help)
                        sections.last?.items.append(toggleItem)
                    } else if itemClass == SettingsMultipleItem.self {
                        let key = dictionaryItem["Key"]! as! String
                        let defaultValue = dictionaryItem["DefaultValue"]!
                        let titles = dictionaryItem["Titles"]! as! [String]
                        let values = dictionaryItem["Values"]! as! [AnyObject]
                        let items = NSDictionary(objects: values, forKeys: titles as [NSCopying]) as! [String: AnyObject]
                        var pickerItems = [String: SettingsPickerItem]()
                        for (key, value) in items {
                            pickerItems[key] = SettingsPickerItem(text: value as! String, detail: nil, action: nil)
                        }
                        let multipleItem = SettingsMultipleItem(title: title, variable: key, items: pickerItems)
                        multipleItem.defaultValue = titles[(values as NSArray).index(of: defaultValue)] as AnyObject?
                        sections.last?.items.append(multipleItem)
                    }
                }
            }
        }
        
        return sections
    }
    
    
    fileprivate func classForDictionaryItem(_ dictionary: [String: AnyObject]) -> AnyClass? {
        if dictionary.keys.contains("Type") {
            if let value = dictionary["Type"] as? String {
                switch value {
                case "PSGroupSpecifier": return SettingsSection.self
                case "PSToggleSwitchSpecifier": return SettingsToggleItem.self
                case "PSMultiValueSpecifier": return SettingsMultipleItem.self
                default: return nil
                }
            }
        }
        return nil
    }
    
}
