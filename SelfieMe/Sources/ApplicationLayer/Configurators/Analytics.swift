//
//  Analytics.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 28.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import Google.Analytics


enum AnalyticsCategory: String {
    case Camera = "Экран камеры"
    case Preview = "Экран просмотра фото"
    case Gallery = "Экран галереи"
    case Settings = "Экран настроек"
    case Ads = "Реклама"
}

enum AnalyticsAction: String {
    case Open = "Открытие"
    case Tap = "Нажатие"
    case Delete = "Удаление"
    case Share = "Поделиться"
    case Answer = "Ответ"
    case Setup = "Установка"
}

enum AnalyticsLabel: String {
    case None = ""
    case Flash = "Вспышка"
    case Timer = "Таймер"
    case Faces = "Ограничение количества лиц"
    case Burst = "Серия фото"
    case Photo = "Фотография"
    case Photos = "Фотографии"
    case Message = "Сообщение дерег"
    case Rate = "Оценка приложения"
    case NotNow = "Не сейчас"
}


final class Analytics {

    static let instance = Analytics()
    
    fileprivate var configured = false
    
    fileprivate let trackingID = "UA-81512108-1"
    
    init() {
        if !configured {
            configure()
        }
    }
    
    func configure() {
        var error: NSError?
        GGLContext.sharedInstance().configureWithError(&error)
        
        if error == nil {
            let gai = GAI.sharedInstance()
            gai?.trackUncaughtExceptions = true
            gai?.logger.logLevel = GAILogLevel.verbose
            
            configured = true
        }
    }
    
    func send(_ category: AnalyticsCategory, action: AnalyticsAction, label: AnalyticsLabel, value: NSNumber) {
        send(category, action: action, label: label.rawValue, value: value)
    }
    
    func send(_ category: AnalyticsCategory, action: AnalyticsAction, label: String, value: NSNumber) {
        if configured {
            let tracker = GAI.sharedInstance().tracker(withTrackingId: trackingID)
            if let dictionary = (GAIDictionaryBuilder.createEvent(withCategory: category.rawValue,
                                                                 action: action.rawValue,
                                                                 label: label,
                                                                 value: value).build() as NSDictionary) as? [AnyHashable: Any] {
                tracker?.send(dictionary)
            }
        }
    }

}
