//
//  CameraModel.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 01.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import AVFoundation

/// Camera view controller model
class CameraModel: NSObject {
    
    let camera = CameraAssembly.createCamera()
    var recognizer: Recognizer?
    
    // Assistants
    var audioAssistant: AudioAssistant?
    var screenAssistant: ScreenBrightnessAssistant?
    var torchAssistant: TorchAssistant?
    
    var performPhotoBlock: voidClosure?
    
    var takePhotoTimer: Timer?
    var tickTimer: Timer?
    var targetTicksConut: Int = 0
    var currentTicksCount: Int = 0
    
    var configured: Bool = false
    
    var detectionInProgress = false
    
    
    /**
     Initialize camera stream manager, runs capture session and initialize audio assistant
     
     - parameter previewLayer: Preview layer
     */
    func configure(_ previewLayer: AVCaptureVideoPreviewLayer) {
        recognizer = RecognizerAssembly.createRecognizer(camera, previewLayer: previewLayer)
        
        createAssitants()
        
        recognizer?.addListener(self)
        recognizer?.addListener(audioAssistant)
        recognizer?.addListener(screenAssistant)
        recognizer?.addListener(torchAssistant)
        
        configured = true
        
        camera.start()
    }
    
    
    fileprivate func createAssitants() {
        let setName = ApplicationSettings.soundSet()
        let language = Locale.preferredLanguages[0]
        let audioSetManager = AudioSetManager(setName: setName, language: language)
        self.audioAssistant = AudioAssistant(audioSetManager: audioSetManager)
        
        self.screenAssistant = ScreenBrightnessAssistant()
        
        self.torchAssistant = TorchAssistant()
    }
    
    
    /**
     Restart current session
     
     - parameter completionBlock: Completion block
     */
    func restartSession() {
//        if true {
            self.camera.start()
//        } else {
//            setupCameraStreamManager(self.cameraStreamManager!.delegate, photoDelegate: self.cameraStreamManager!.photoDelegate, completionBlock: completionBlock)
//        }
    }
    
    
    func performPhoto() {
        performPhotoBlock?()
    }
    
    
    /**
     Kills blink -> takes photo -> destroys audio assistant
     */
    func takePhoto(_ onSave: voidClosure?) {
        camera.takePhoto(CameraSettings.settings.burstMode.rawValue, onComplete: { [weak self] _ in
            self?.audioAssistant?.vibrate()
            IKTrackerPool.sharedInstance[Trackers.adTracker]?.commit()
        }, onSave: onSave,
           onFailure: nil)
    }
    
    
    func toggleDetection(_ enabled: Bool, silently: Bool, completion: voidClosure?) {
        var output = CameraOutput.videoData
        if #available(iOS 9, *) {
            output = CameraOutput.metadata
        }
        camera.setOutput(output, enabled: enabled) { _ in
            if enabled {
                if !silently {
                    self.audioAssistant?.sayStart()
                }
                self.screenAssistant?.start()
            } else {
                self.disableTakePhotoTimer(nil)
                if !silently {
                    self.audioAssistant?.sayStop()
                }
                self.audioAssistant?.reset()
                self.screenAssistant?.stop()
                self.recognizer?.reset()
            }
            
            completion?()
        }
    }
    
    
    /**
     Set new camera mode
     
     - parameter mode: Camera mode
     */
    func setCaptureResolution(_ resolution: CaptureResolution) {
        CameraSettings.settings.cameraMode = resolution
        camera.setCaptureResolution(resolution)
        recognizer?.captureResolution = resolution
    }
    
    /**
     Set HDR state
     
     - parameter state: State. Default is Auto
     */
    func setHDRState(_ state: SettingState) {
//        CameraSettings.settings.hdrState = state
    }
    
    /**
     Set flash state
     
     - parameter state: State. Default is Auto
     */
    func setFlashState(_ state: SettingState) {
        CameraSettings.settings.flashState = state
        camera.setFlashMode(AVCaptureFlashMode(rawValue: state.rawValue) ?? .auto)
    }
    
    /**
     Set torch state
     
     - parameter state: State. Default is Off
     */
    func setTorchState(_ state: SettingState) {
        CameraSettings.settings.torchState = state
        camera.setTorchMode(AVCaptureTorchMode(rawValue: state.rawValue) ?? .off)
    }
    
    /**
     Set timer state
     
     - parameter state: State. Default is 1s
     */
    func setTimerState(_ state: SettingTimerState) {
        CameraSettings.settings.timerState = state
    }
    
    /**
     Set faces state
     
     - parameter state: State. Default is infinite
     */
    func setFacesState(_ state: SettingFacesState) {
        CameraSettings.settings.facesState = state
    }
    
    
    func setBurstMode(_ mode: SettingBurstMode) {
        CameraSettings.settings.burstMode = mode
    }
    
    
    /**
     Set video orientation based on current device orientation
     */
    func setVideoOrientation() {
        let deviceOrientation = DeviceOrientationRecognizer.sharedInstance.deviceOrientation
        let orientation = Utils.deviceOrientationToCaptureVideoOrientation(deviceOrientation)
        camera.setOutput(CameraOutput.stillImage, orientation: orientation)
    }
    
    
    
    func enableTakePhotoTimer() {
        DispatchQueue.main.async { [weak self] _ in
            let interval: TimeInterval = Double(CameraSettings.settings.timerState.rawValue)
//            self?.enableTickTimer(CameraSettings.settings.timerState.rawValue)
            self?.takePhotoTimer = Timer.scheduledTimer(timeInterval: interval,
                                                                          target: self!,
                                                                          selector: #selector(CameraModel.performPhoto),
                                                                          userInfo: nil,
                                                                          repeats: false)
        }
    }
    
    func disableTakePhotoTimer(_ completion: (() -> Void)?) {
        DispatchQueue.main.async { [weak self] _ in
            self?.takePhotoTimer?.invalidate()
            self?.takePhotoTimer = nil
            
            completion?()
        }
    }
    
    
//    func enableTickTimer(ticksCount: Int) {
//        guard ticksCount > 1 else { return }
//        self.targetTicksConut = ticksCount - 1
//        dispatch_async(dispatch_get_main_queue()) { [weak self] _ in
//            self?.tickTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
//                                                                     target: self!,
//                                                                     selector: #selector(CameraModel.tick),
//                                                                     userInfo: nil,
//                                                                     repeats: true)
//        }
//    }
//    
//    func tick() {
//        self.currentTicksCount += 1
//        if self.currentTicksCount == self.targetTicksConut {
//            self.tickTimer?.invalidate()
//            self.tickTimer = nil
//            self.currentTicksCount = 0
//            self.targetTicksConut = 0
//        } else {
//            audioAssistant?.playTick()
//        }
//    }

}



extension CameraModel: EventRecognizerDelegate {

    func eventRecognizer(_ recognizer: EventRecognizer, recognizedEvent event: Event) {
        if event == .hit {
            enableTakePhotoTimer()
        } else {
            disableTakePhotoTimer(nil)
        }
    }

}

