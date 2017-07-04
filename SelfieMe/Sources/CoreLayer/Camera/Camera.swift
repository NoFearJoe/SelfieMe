//
//  Camera.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 23.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa
import Metal


enum CameraPosition {
    case front, back, unspecified
    
    init(avPosition: AVCaptureDevicePosition) {
        switch avPosition {
        case .unspecified:
            self = .unspecified
        case .back:
            self = .back
        case .front: 
            self = .front
        }
    }
    
    var avPosition: AVCaptureDevicePosition {
        switch self {
        case .unspecified:
            return .unspecified
        case .back:
            return .back
        case .front:
            return .front
        }
    }
    
}


enum CameraQuality {
    case low
    case medium
    case high
    case ultra
    
    
    func sessionPreset() -> String {
        switch self {
        case .low:
            return AVCaptureSessionPresetLow
        case .medium:
            return AVCaptureSessionPresetMedium
        case .high:
            return AVCaptureSessionPresetHigh
        case .ultra: 
            return AVCaptureSessionPresetPhoto
        }
    }
    
}

enum CameraInput {
    case device
//    case Metadata
}

enum CameraOutput {
    case stillImage
    case videoData
    case metadata
    
    var avType: AVCaptureOutput.Type {
        switch self {
        case .stillImage:
            return AVCaptureStillImageOutput.self
        case .videoData:
            return AVCaptureVideoDataOutput.self
        case .metadata:
            return AVCaptureMetadataOutput.self
        }
    }
    
}


/// Класс для управления камерой и сессией
class Camera: NSObject {

    fileprivate var device: CaptureDeviceProxy
    
    fileprivate var session: AVCaptureSession
    
    
    fileprivate var captureResolution = CaptureResolutions._undefined
    
    
    var running: Observable<Bool?>?
    var interrupted: Observable<Bool?>?
    
    var capturing: Observable<Bool?>?
    
    
    /**
     Инициализация экземпляра
     
     - parameter position: Позиция камеры
     
     - returns: Экземпляр класса
     */
    init(position: CameraPosition) {
        device = CaptureDeviceProxy(position: position.avPosition)
        session = AVCaptureSession()
        
        super.init()
     
        addObservers()
    }
    
}


private extension Camera {

    struct Queues {
        static let sessionQueue = DispatchQueue(label: "camera.stream.manager.session.queue", attributes: [])
        static let processQueue = DispatchQueue(label: "camera.stream.manager.process.queue", attributes: [])
    }

}



// MARK: Session

extension Camera {

    /**
     Запуск съемки
     */
    func start() {
        Queues.sessionQueue.async { [weak self] () -> Void in
            if self?.session.isRunning == false {
                self?.session.startRunning()
            }
        }
    }
    
    /**
     Остановка съемки
     */
    func stop() {
        Queues.sessionQueue.async { [weak self] () -> Void in
            if self?.session.isRunning == true {
                self?.session.stopRunning()
            }
        }
    }
    
    /**
     Установка качества съемки
     
     - parameter quality: Качество
     */
    func setQuality(_ quality: CameraQuality) {
        Queues.sessionQueue.async { [weak self] () -> Void in
            let preset = quality.sessionPreset()
            if self?.session.canSetSessionPreset(preset) == true {
                self?.session.sessionPreset = preset
            }
        }
    }
    
    /**
     Добавление входа в сессию
     
     - parameter type: Вход
     */
    func addInput(_ type: CameraInput) {
        Queues.sessionQueue.async { [weak self] () -> Void in
            switch type {
            case .device:
                if let input = self?.device.deviceInput {
                    if self?.session.canAddInput(input) == true {
                        self?.session.addInput(input)
                    }
                }
                break
            }
        }
    }
    
    /**
     Добавление выхода в сессию
     
     - parameter type: Выход
     */
    func addOutput(_ type: CameraOutput) {
        Queues.sessionQueue.async { [weak self] () -> Void in
            switch type {
            case .stillImage:
                if let output = self?.device.stillImageOutput {
                    if self?.session.canAddOutput(output) == true {
                        self?.session.addOutput(output)
                    }
                }
                break
            case .videoData:
                if let output = self?.device.videoDataOutput {
                    if self?.session.canAddOutput(output) == true {
                        self?.session.addOutput(output)
                    }
                }
                break
            case .metadata:
                if #available(iOS 9.0, *) {
                    if let output = self?.device.metadataOutput {
                        if self?.session.canAddOutput(output) == true {
                            self?.session.addOutput(output)
                            
                            let output = self?.metadataOutput()
                            if (output?.availableMetadataObjectTypes as? [NSString])?.contains(AVMetadataObjectTypeFace as NSString) == true {
                                output?.metadataObjectTypes = [AVMetadataObjectTypeFace]
                            }
                        }
                    }
                }
                break
            }
        }
    }
    
    /**
     Получение заданного выхода
     
     - parameter output: Тип выхода
     
     - returns: Выход
     */
    func getOutput(_ output: CameraOutput) -> AVCaptureOutput? {
        return session.outputs.filter() { out in
            return (out as AnyObject).isKind(of: output.avType)
        }.first as? AVCaptureOutput
    }
    
    /**
     Получение подключения для заданного выхода
     
     - parameter output: Выход
     
     - returns: Подключение
     */
    func getConnection(_ output: CameraOutput) -> AVCaptureConnection? {
        switch output {
        case .stillImage:
            return stillImageOutput()?.connection(withMediaType: AVMediaTypeVideo)
        case .videoData:
            return videoDataOutput()?.connection(withMediaType: AVMediaTypeVideo)
        case .metadata:
            if #available(iOS 9.0, *) {
                return metadataOutput()?.connection(withMediaType: AVMediaTypeMetadataObject)
            }
            return nil
        }
    }
    
    /**
     Включение/выключение заданного выхода
     
     - parameter output:     Выход
     - parameter enabled:    Включено/выключено
     - parameter completion: Завершение
     */
    func setOutput(_ output: CameraOutput, enabled: Bool, completion: voidClosure? = nil) {
        Queues.sessionQueue.async { [weak self] () -> Void in
            self?.getConnection(output)?.isEnabled = enabled
            completion?()
        }
    }
    
    /**
     Установка ориентации заданного выхода
     
     - parameter output:      Выход
     - parameter orientation: Ориентация
     */
    func setOutput(_ output: CameraOutput, orientation: AVCaptureVideoOrientation) {
        Queues.sessionQueue.async { [weak self] () -> Void in
            if let connection = self?.getConnection(output) , connection.isVideoOrientationSupported {
                connection.videoOrientation = orientation
            }
        }
    }
    
    
    func stillImageOutput() -> AVCaptureStillImageOutput? {
        return getOutput(CameraOutput.stillImage) as? AVCaptureStillImageOutput
    }
    
    func videoDataOutput() -> AVCaptureVideoDataOutput? {
        return getOutput(CameraOutput.videoData) as? AVCaptureVideoDataOutput
    }
    
    func metadataOutput() -> AVCaptureMetadataOutput? {
        return getOutput(CameraOutput.metadata) as? AVCaptureMetadataOutput
    }

}


// MARK: Functionality

extension Camera {

    func setExposureMode(_ mode: AVCaptureExposureMode) {
        device.setExposureMode(mode)
    }
    
    func setWhiteBalanceMode(_ mode: AVCaptureWhiteBalanceMode) {
        device.setWhiteBalanceMode(mode)
    }
    
    func setFocusMode(_ mode: AVCaptureFocusMode) {
        device.setFocusMode(mode)
    }
    
    func setLowLightBoostEnabled(_ enabled: Bool) {
        device.setLowLightBoostEnabled(enabled)
    }
    
    func setCaptureResolution(_ resolution: CaptureResolution) {
        captureResolution = resolution
    }
    
    func setFlashMode(_ mode: AVCaptureFlashMode) {
        device.setFlashMode(mode)
    }
    
    func setTorchMode(_ mode: AVCaptureTorchMode) {
        device.setTorchMode(mode)
    }
    
}


// MARK: Booleans

extension Camera {

    var hasFlash: Bool {
        return device.hasFlash
    }
    
    var hasTorch: Bool {
        return device.hasTorch
    }

}



extension Camera {
    
    /**
     Конфигурация Preview layer с текущей сессией
     
     - parameter layer: Preview layer
     */
    func addSessionToPreviewLayer(_ layer: AVCaptureVideoPreviewLayer) {
        Queues.sessionQueue.async { [weak self] () -> Void in
            layer.session = self?.session
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill
            layer.masksToBounds = true
        }
    }
    
}


// MARK: Capturing photo

extension Camera {

    /**
     Делает фото
     
     - parameter count:      Количество фото
     - parameter onComplete: Завершение съемки всех фото
     - parameter onSave:     Завершение сохранения всех фото
     - parameter onFailure:  Неудача
     */
    func takePhoto(_ count: Int, onComplete: voidClosure?, onSave: voidClosure?, onFailure: voidClosure?) {
        guard count > 0 else {
            onFailure?()
            return
        }
        
        Queues.sessionQueue.async { [weak self] () -> Void in
            if let connection = self?.getConnection(CameraOutput.stillImage) {
                var photoCounter = count
                var savedPhotoCounter = count
                
                if let output = self?.getOutput(CameraOutput.stillImage) as? AVCaptureStillImageOutput {
                    for _ in 0..<count {
                        output.captureStillImageAsynchronously(from: connection,
                              completionHandler: { [weak self] (buffer, error) -> Void in
                                photoCounter -= 1
                                if photoCounter <= 0 {
                                    onComplete?()
                                }
                                
                                if error == nil {
                                    self?.captureImageAndSaveToPhotoLibrary(buffer!) { (success) -> () in
                                        savedPhotoCounter -= 1
                                        if savedPhotoCounter <= 0 {
                                            onSave?()
                                        }
                                    }
                                } else {
                                    onFailure?()
                                }
                            }
                        )
                    }
                }
            }
        }
    }
    
    
    fileprivate func captureImageAndSaveToPhotoLibrary(_ buffer: CMSampleBuffer, completion: boolClosure?) {
        Queues.processQueue.async { [weak self] _ in
            if let imageData = self?.imageDataForCaptureResolution(AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
                                                                   mode: self?.captureResolution ?? CaptureResolutions._undefined) {
                
                PhotoLibraryManager.sharedManager.savePhotoToApplicationAlbum(imageData) { (success) -> Void in
                    completion?(success)
                }
            }
        }
    }
    
    
    fileprivate func imageDataForCaptureResolution(_ imageData: Data, mode: CaptureResolution) -> Data? {
        if let image = UIImage(data: imageData) {
            let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            let ratio = mode.getRatioRelativeToRect(imageRect)
            let rect = FrameAdapter.adaptedFrame(imageRect, inContainer: imageRect, withTargetRatio: CGFloat(ratio), center: true)
            let img = image.croppedByFrame(rect)
            return UIImageJPEGRepresentation(img, 1.0)
        }
        return nil
    }

}


// MARK: Key-Value observing

extension Camera {

    fileprivate func addObservers() {
        running = session.rx.observe(Bool.self, "running")
        interrupted = session.rx.observe(Bool.self, "interrupted")
        
        capturing = getOutput(CameraOutput.stillImage)?.rx.observe(Bool.self, "capturingStillImage")
    }

}


