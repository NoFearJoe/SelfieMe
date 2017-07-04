//
//  CaptureDeviceProxy.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 02.02.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa


fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}



extension AVCaptureDevicePosition {

    static func oppositeDevicePosition(_ position: AVCaptureDevicePosition) -> AVCaptureDevicePosition {
        return position == .back ? .front : .back
    }
    
}


protocol TorchInterface {
    func flashlightWithLevel(_ level: Float)
    func setTorchMode(_ mode: AVCaptureTorchMode)
}



/// Посредник для осуществления взаимодействия с записывающим устройством
final class CaptureDeviceProxy: TorchInterface {
    
    /**
        Записывающее устройство (камера)
    */
    fileprivate var device: AVCaptureDevice?
    
    
    
    init(position: AVCaptureDevicePosition) {
        device =
            findVideoCaptureDeviceByPosition(position) ?? findVideoCaptureDeviceByPosition(AVCaptureDevicePosition.oppositeDevicePosition(position))
    }
    
    
    /**
        Функция для поиска камеры по заданной позиции
     
        - parameter position: Требуемая позиция камеры
     
        - returns: Записывающее устройство
    */
    fileprivate func findVideoCaptureDeviceByPosition(_ position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice]
        
        for device in devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    
}


// MARK: Public properties and functions

extension CaptureDeviceProxy {

    var deviceInput: AVCaptureDeviceInput? {
        if let device = device {
            return try? AVCaptureDeviceInput(device: device)
        }
        return nil
    }
    
//    @available(iOS 9.0, *)
//    var metadataInput: AVCaptureMetadataInput {
//        let decription = CMMetadataFormatDescription()
//        return AVCaptureMetadataInput(formatDescription: description, clock: nil)
//    }

}



extension CaptureDeviceProxy {

    var stillImageOutput: AVCaptureStillImageOutput {
        let output = AVCaptureStillImageOutput()
        output.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if output.isStillImageStabilizationSupported == true {
            output.automaticallyEnablesStillImageStabilizationWhenAvailable = true
        }
        output.isHighResolutionStillImageOutputEnabled = true
        return output
    }
    
    var videoDataOutput: AVCaptureVideoDataOutput {
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        return output
    }
    
    @available(iOS 9.0, *)
    var metadataOutput: AVCaptureMetadataOutput {
        let output = AVCaptureMetadataOutput()
        return output
    }

}


// MARK: Reactive interface

extension CaptureDeviceProxy {

    var rxFlash: Observable<AVCaptureFlashMode?>? {
        return device?.rx.observe(AVCaptureFlashMode.self, "flashMode")
    }
    
    var rxTorch: Observable<AVCaptureTorchMode?>? {
        return device?.rx.observe(AVCaptureTorchMode.self, "torchMode")
    }

}




// MARK: Device properties setters

extension CaptureDeviceProxy {

    typealias CaptureDeviceConfigurationClosure = () -> Void
    typealias CaptureDeviceConditionClosure = () -> Bool
    typealias CaptureDeviceErrorClosure = (_ error: String) -> Void
    
    
    /**
        Функция, обеспечивающая безопасное изменение конфигурации камеры

        - parameter configurationBlock: Замыкание, в котором происходит изменение конфигурации камеры
    */
    fileprivate func performSafeConfiguration(_ configuraionBlock: CaptureDeviceConfigurationClosure) {
        lockDevice() { _ in return }
        configuraionBlock()
        unlockDevice()
    }
    
    
    /**
        Осуществляет блокировку камеры для изменения конфигурации
     
        - parameter failureBlock: Замыкание, вызываемое при ошибке, произошедшей во время блокировки устройства
    */
    fileprivate func lockDevice(_ failureBlock: CaptureDeviceErrorClosure) {
        do {
            try device?.lockForConfiguration()
        } catch {
            failureBlock("CaptureDeviceProxy: Can't lock device")
        }
    }
    
    
    /**
        Разблокирывает камеру после конфигурации
    */
    fileprivate func unlockDevice() {
        device?.unlockForConfiguration()
    }
    
    
    /**
        Производит попытку изменения конфигурации камеры
     
        - paramter setterBlock: замыкание, в котором осуществляется установка свойства
        - paramter conditionBlock: замыкание, в котором выполняется проверка возможности установки свойства
    */
    fileprivate func tryToSetProperty(_ setter: CaptureDeviceConfigurationClosure, condition: CaptureDeviceConditionClosure) {
        if condition() {
            performSafeConfiguration() {
                setter()
            }
        }
    }

    
    
    // MARK: Setters
    
    func setSmoothAutoFocusEnabled(_ enabled: Bool) {
        tryToSetProperty(
            { [weak self] in self?.device?.isSmoothAutoFocusEnabled = enabled },
            condition: { [weak self] in return self?.isSmoothAutoFocusSupported == true })
    }
    
    
    func setTorchMode(_ mode: AVCaptureTorchMode) {
        tryToSetProperty(
            { [weak self] in self?.device?.torchMode = mode },
            condition: { [weak self] in return self?.isTorchModeSupported(mode) == true })
    }
    
    
    func setFlashMode(_ mode: AVCaptureFlashMode) {
        tryToSetProperty(
            { [weak self] in self?.device?.flashMode = mode },
            condition: { [weak self] in return self?.isFlashModeSupported(mode) == true })
    }
    
    
    func setLowLightBoostEnabled(_ enabled: Bool) {
        tryToSetProperty(
            { [weak self] in self?.device?.automaticallyEnablesLowLightBoostWhenAvailable = enabled },
            condition: { [weak self] in return self?.isLowLightBoostSupported == true })
    }
    
    
    func setAutoAbjustingVideoHDREnabled(_ enabled: Bool) {
        tryToSetProperty(
            { [weak self] in self?.device?.automaticallyAdjustsVideoHDREnabled = enabled },
            condition: { [weak self] in return self?.isVideoHDRSupported == true })
    }
    
    
    func setFocusMode(_ mode: AVCaptureFocusMode) {
        tryToSetProperty(
            { [weak self] in self?.device?.focusMode = mode },
            condition: { [weak self] in return self?.isFocusModeSupported(mode) == true })
    }
    
    
    func setWhiteBalanceMode(_ mode: AVCaptureWhiteBalanceMode) {
        tryToSetProperty(
            { [weak self] in self?.device?.whiteBalanceMode = mode },
            condition: { [weak self] in return self?.isWhiteBalanceModeSupported(mode) == true })
    }
    
    
    func setCustomWhiteBalance(_ gains: AVCaptureWhiteBalanceGains) {
        tryToSetProperty(
            { [weak self] in self?.device?.setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains(gains, completionHandler: nil) },
            condition: { [weak self] in return self?.isWhiteBalanceModeSupported(.locked) == true })
    }
    
    
    func setCustomWhiteBalance(_ temperature: Float, tint: Float) {
        if let gains = device?.deviceWhiteBalanceGains(for: AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: temperature, tint: tint)) {
            setCustomWhiteBalance(gains)
        }
    }
    
    
    func setExposureMode(_ mode: AVCaptureExposureMode) {
        tryToSetProperty(
            { [weak self] in self?.device?.exposureMode = mode },
            condition: { [weak self] in return self?.isExposureModeSupported(mode) == true })
    }
    
    
    
    func flashlightWithLevel(_ level: Float) {
        tryToSetProperty(
            { [weak self] in _ = try? self?.device?.setTorchModeOnWithLevel(level)},
            condition: { [weak self] in return self?.hasTorch == true })
    }
    

}



// MARK: Device properties getters

extension CaptureDeviceProxy {

    var lensAperture: Float {
        return device?.lensAperture ?? 0
    }
    
    var lensPosition: Float {
        return device?.lensPosition ?? 0
    }
    
    var isSmoothAutoFocusEnabled: Bool {
        return device?.isSmoothAutoFocusEnabled ?? false
    }
    
    var focusMode: AVCaptureFocusMode {
        return device?.focusMode ?? .locked
    }
    
    var exposureDuration: CMTime {
        return device?.exposureDuration ?? CMTime()
    }
    
    var minExposureDuration: CMTime {
        return device?.activeFormat.minExposureDuration ?? CMTime()
    }
    
    var maxExposureDuration: CMTime {
        return device?.activeFormat.maxExposureDuration ?? CMTime()
    }
    
    var ISO: Float {
        return device?.iso ?? 0
    }
    
    var minISO: Float {
        return device?.activeFormat.minISO ?? 0
    }
    
    var maxISO: Float {
        return device?.activeFormat.maxISO ?? 0
    }
    
    var exposureTargetOffset: Float {
        return device?.exposureTargetOffset ?? 0
    }
    
    var exposureTargetBias: Float {
        return device?.exposureTargetBias ?? 0
    }
    
    var minExposureTargetBias: Float {
        return device?.minExposureTargetBias ?? 0
    }
    
    var maxExposureTargetBias: Float {
        return device?.maxExposureTargetBias ?? 0
    }
    
    var exposureMode: AVCaptureExposureMode {
        return device?.exposureMode ?? .locked
    }
    
    var whiteBalanceGains: AVCaptureWhiteBalanceGains {
        return device?.deviceWhiteBalanceGains ?? AVCaptureWhiteBalanceGains()
    }
    
    var whiteBalanceTemperatureAndTint: AVCaptureWhiteBalanceTemperatureAndTintValues {
        return device?.temperatureAndTintValues(forDeviceWhiteBalanceGains: whiteBalanceGains) ?? AVCaptureWhiteBalanceTemperatureAndTintValues()
    }
    
    var whiteBalanceMode: AVCaptureWhiteBalanceMode {
        return device?.whiteBalanceMode ?? .locked
    }
    
    var torchMode: AVCaptureTorchMode {
        return device?.torchMode ?? .off
    }
    
    var flashMode: AVCaptureFlashMode {
        return device?.flashMode ?? .off
    }
    
    var doesAutomaticallyAdjustVideoHDR: Bool {
        return device?.automaticallyAdjustsVideoHDREnabled ?? false
    }
    
    var isVideoHDREnabled: Bool {
        return device?.isVideoHDREnabled ?? false
    }
    
    var highResolutionStillImageDimensions: CMVideoDimensions {
        return device?.activeFormat.highResolutionStillImageDimensions ?? CMVideoDimensions()
    }
    
    var leastOfTheHighResolutionStillImageDimensions: Int32 {
        let dimensions = highResolutionStillImageDimensions
        return dimensions.width < dimensions.height ? dimensions.width : dimensions.height
    }
    
    var mostOfTheHighResolutionStillImageDimensions: Int32 {
        let dimensions = highResolutionStillImageDimensions
        return dimensions.width > dimensions.height ? dimensions.width : dimensions.height
    }
    
    var leastAndMostOfTheHighResolutionStillImageDimensions: (least: Int32, most: Int32) {
        
        let dimensions = highResolutionStillImageDimensions
        
        if dimensions.width < dimensions.height {
            return (least: dimensions.width, most: dimensions.height)
        } else {
            return (least: dimensions.height, most: dimensions.width)
        }
    }


}


// MARK: Capture device modes support check

extension CaptureDeviceProxy {

    func isWhiteBalanceModeSupported(_ mode: AVCaptureWhiteBalanceMode) -> Bool {
        return device?.isWhiteBalanceModeSupported(mode) ?? false
    }
    
    func isWhiteBalanceGainValid(_ gain: Float) -> Bool {
        return (gain >= 1.0) && (gain <= device?.maxWhiteBalanceGain)
    }
    
    func areWhiteBalanceGainsValid(_ gains: AVCaptureWhiteBalanceGains) -> Bool {
        return isWhiteBalanceGainValid(gains.blueGain) && isWhiteBalanceGainValid(gains.greenGain) && isWhiteBalanceGainValid(gains.redGain)
    }
    
    func isExposureModeSupported(_ mode: AVCaptureExposureMode) -> Bool {
        return device?.isExposureModeSupported(mode) ?? false
    }
    
    func isExposureDurationSupported(_ exposureDuration: Double) -> Bool {
        return (exposureDuration >= device?.activeFormat.minExposureDuration.seconds) && (exposureDuration <= device?.activeFormat.maxExposureDuration.seconds)
    }
    
    func isISOSupported(_ ISO: Float) -> Bool {
        return (ISO >= device?.activeFormat.minISO) && (ISO <= device?.activeFormat.maxISO)
    }
    
    func areExposureValuesSupported(_ exposureDuration: Double, ISO: Float) -> Bool {
        return isExposureDurationSupported(exposureDuration) && isISOSupported(ISO)
    }
    
    func isExposureTargetBiasSupported(_ exposureTargetBias: Float) -> Bool {
        return (exposureTargetBias >= device?.minExposureTargetBias) && (exposureTargetBias <= device?.maxExposureTargetBias)
    }
    
    func isFocusModeSupported(_ mode: AVCaptureFocusMode) -> Bool {
        return device?.isFocusModeSupported(mode) ?? false
    }
    
    func isLensPositionValid(_ lensPosition: Float) -> Bool {
        return (lensPosition >= 0) && (lensPosition <= 1)
    }
    
    var isSmoothAutoFocusSupported: Bool {
        return device?.isSmoothAutoFocusSupported ?? false
    }
    
    var hasTorch: Bool {
        return device?.hasTorch ?? false
    }
    
    func isTorchModeSupported(_ mode: AVCaptureTorchMode) -> Bool {
        return device?.isTorchModeSupported(mode) ?? false
    }
    
    var hasFlash: Bool {
        return device?.hasFlash ?? false
    }
    
    func isFlashModeSupported(_ mode: AVCaptureFlashMode) -> Bool {
        return device?.isFlashModeSupported(mode) ?? false
    }
    
    var isLowLightBoostSupported: Bool {
        return device?.isLowLightBoostSupported ?? false
    }
    
    var isVideoHDRSupported: Bool {
        return device?.activeFormat.isVideoHDRSupported ?? false
    }
    
    // TODO: Спросить в Эпл, как исправить этот костыль
    var isPhotoHDRSupported: Bool {
        return device?.position == .back
    }

}
