//
//  Globals.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 01.02.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit

struct Device {
    
    static let iPad = UIDevice.current.userInterfaceIdiom == .pad
    static let iPhone = UIDevice.current.userInterfaceIdiom == .phone
    
}


struct Animation {
    
    static let defaultDuration = 0.5
    static let shortDuration = 0.25
    static let transitionDuration = 0.75
    static let longDuration = 2.0
    
}



struct Theme {
    static let mainColor = UIColor(red: 5.0/255.0, green: 165.0/255.0, blue: 90.0/255.0, alpha: 1) // Цвет активных элементов (активные иконки, фон обучения, круг селектора)
    static let lightTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    static let tintColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1) // Цвет надписей и не активных элементов (выключенная вспышка, центр селектора)
    static let darkTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    static let secondaryTintColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
    static let thirdlyTintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)

    static let backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1) // Цвет фона во всех вьюхах
    static let opaqueBackgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75) // Цвет navigation bar и tool bar
    static let secondaryBackgroundColor = UIColor(red: 20.0/255.0, green: 21.0/255.0, blue: 20.0/255.0, alpha: 1)
    static let thirdlyBackgroundColor = UIColor(red: 25.0/255.0, green: 25.0/255.0, blue: 25.0/255.0, alpha: 1.0)
    static let backgroundColor75 = UIColor(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.75)
    
    static let settingsBackgroundColor = UIColor(red: 90.0/255.0, green: 90.0/255.0, blue: 90.0/255.0, alpha: 1) // Цвет заднего фона в настройках
    static let settingsTintColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1) // Цвет надписей в настройках (КРОМЕ КНОПОК)
    static let settingsCellColor = UIColor(red: 120.0/255.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1) // Цвет ячейки в настройках
    
    
    static let buyButtonTextColor = UIColor(red: 0.9902, green: 0.7274, blue: 0.1612, alpha: 1.0)
    static let buyButtonBackgroundColor = UIColor(red: 0.0997, green: 0.0731, blue: 0.0342, alpha: 1.0)
}



struct PhotoLibrary {
    
    static let albumTitle = "SelfieMe"
    
}


struct Strings {

    #if SELFIE_ME
    static let appID = "1142317858"
    static let otherAppID = "1126247967"
    #else
    static let appID = "1126247967"
    static let otherAppID = "1142317858"
    #endif
    
    
    static let facebook = "www.facebook.com/selfie_me_app"
    static let twitter = "www.twitter.com/selfie_me_app"
    static let mail = "mesterra.co@gmail.com"

}


struct Trackers {

    static let rateTracker = "rate_tracker"
    static let adTracker   = "ad_tracker"

}
