//
//  CameraAssembly.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 26.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation



final class CameraAssembly {
    
    class func createCamera() -> Camera {
        let camera = Camera(position: CameraPosition.back)
        camera.setQuality(CameraQuality.ultra)

        if #available(iOS 9, *) {
            camera.addInput(CameraInput.device)
            camera.addOutput(CameraOutput.metadata)
            camera.setOutput(CameraOutput.metadata, enabled: false)
        } else {
            camera.addInput(CameraInput.device)
            camera.addOutput(CameraOutput.videoData)
            camera.setOutput(CameraOutput.videoData, enabled: false)
            camera.setOutput(CameraOutput.videoData, orientation: AVCaptureVideoOrientation.portrait)
        }
        
        camera.addOutput(CameraOutput.stillImage)

        camera.setFocusMode(AVCaptureFocusMode.continuousAutoFocus)
        camera.setExposureMode(AVCaptureExposureMode.continuousAutoExposure)
        camera.setWhiteBalanceMode(AVCaptureWhiteBalanceMode.continuousAutoWhiteBalance)
        camera.setLowLightBoostEnabled(true)
        
        camera.setCaptureResolution(CaptureResolutions._3x4)
        
        camera.setOutput(CameraOutput.stillImage, orientation: AVCaptureVideoOrientation.portrait)
        
        return camera
    }

}
