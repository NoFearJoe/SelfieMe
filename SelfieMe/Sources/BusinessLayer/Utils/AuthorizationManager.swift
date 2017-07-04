//
//  AuthorizationManager.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 10.02.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import AVFoundation
import Photos


/**
 Типы авторизации
 
 - Video:   Авторизация для камеры
 - Gallery: Авторизация для галереи
 */
enum AuthorizationType {
    case video
    case gallery
}

/**
    Универсальные статусы авторизации. Для того чтобы объединить все разнотипные статусы в один
 
    - Authorized: Авторизован
    - Denied: Авторизация была отменена пользователем
    - NotDetermined: Авторизация еще не приходила
    - Restricted: Пользователь не имеет доступа
*/
enum AuthorizationStatus {
    case authorized
    case denied
    case notDetermined
    case restricted
    
    /**
     Конвертация AVAuthorizationStatus в AuthorizationStatus
     
     - parameter status: AVAuthorizationStatus
     
     - returns: AuthorizationStatus
     */
    static func statusForVideo(_ status: AVAuthorizationStatus) -> AuthorizationStatus {
        switch status {
        case .authorized: return AuthorizationStatus.authorized
        case .denied: return AuthorizationStatus.denied
        case .restricted: return AuthorizationStatus.restricted
        case .notDetermined: return AuthorizationStatus.notDetermined
        }
    }
    
    /**
     Конвертация PHAuthorizationStatus в AuthorizationStatus
     
     - parameter status: PHAuthorizationStatus
     
     - returns: AuthorizationStatus
     */
    static func statusForGallery(_ status: PHAuthorizationStatus) -> AuthorizationStatus {
        switch status {
        case .authorized: return AuthorizationStatus.authorized
        case .denied: return AuthorizationStatus.denied
        case .restricted: return AuthorizationStatus.restricted
        case .notDetermined: return AuthorizationStatus.notDetermined
        }
    }
}


/**
    Класс, управляющий запросами для получения доступа к требуемым функциям
*/
final class AuthorizationManager {
    
    typealias AuthorizationRequestCompletionBlock = ((AuthorizationStatus) -> Void)
    
    /**
        Возвращает статус авторизации для заданного типа
     
        - parameter type: Тип авторизации
     
        - returns: Статус авторизации
    */
    class func authorizationStatusFor(_ type: AuthorizationType) -> AuthorizationStatus {
        switch type {
        case .video: return AuthorizationStatus.statusForVideo(AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo))
        case .gallery:
            let status = PHPhotoLibrary.authorizationStatus()
            return AuthorizationStatus.statusForGallery(status)
        }
    }
    
    
    /**
        Возвращает true, если пользователь авторизован для переданного типа
     
        - parameter type: Тип авторизации
     
        - returns: Результат авторизации
    */
    class func isAuhorizedForType(_ type: AuthorizationType) -> Bool {
        return AuthorizationManager.authorizationStatusFor(type) == .authorized
    }
    
    
    /**
        Посылает запрос на авторизацию для конкретного типа
     
        - parameter type: Тип авторизации
        - parameter lockableQueue: Очередь, которая будет заблокирована. Как правило, это очередь, в которой осуществляется
                                   работа с сессией
        - parameter completionBlock: Замыкание, которое будет вызвано после завершения запроса
    */
    class func requestAuthorizationForType(_ type: AuthorizationType, lockableQueue: DispatchQueue, completionBlock: AuthorizationRequestCompletionBlock?) {
        switch type {
        case .video: requestAuthorizationForVideo(lockableQueue, completionBlock: completionBlock)
        case .gallery: requestAuthorizationForGallery(lockableQueue, completionBlock: completionBlock)
        }
    }
    
    
    /**
     Посылает запрос на авторизацию для камеры
     
     - parameter lockableQueue: Очередь, которая будет заблокирована. Как правило, это очередь, в которой осуществляется
                                работа с сессией
     - parameter completionBlock: Замыкание, которое будет вызвано после завершения запроса
     */
    class func requestAuthorizationForVideo(_ lockableQueue: DispatchQueue, completionBlock: AuthorizationRequestCompletionBlock?) {
        lockableQueue.suspend()
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (granted) -> Void in
            lockableQueue.resume()
            completionBlock?(AuthorizationManager.authorizationStatusFor(.video))
        }
    }
    
    
    /**
     Посылает запрос на авторизацию для галереи
     
     - parameter lockableQueue: Очередь, которая будет заблокирована. Как правило, это очередь, в которой осуществляется
     работа с сессией
     - parameter completionBlock: Замыкание, которое будет вызвано после завершения запроса
     */
    class func requestAuthorizationForGallery(_ lockableQueue: DispatchQueue, completionBlock: AuthorizationRequestCompletionBlock?) {
        lockableQueue.suspend()
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            lockableQueue.resume()
            completionBlock?(AuthorizationStatus.statusForGallery(status))
        }
    }
    
}
