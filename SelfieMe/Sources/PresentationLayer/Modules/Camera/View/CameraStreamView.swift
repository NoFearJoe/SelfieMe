//
//  CameraStreamView.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 25.01.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


/// View with AVCaptureVideoPreviewLayer for stream capture session
final class CameraStreamView: AutolayoutIgnorableView {
    
    override func updateConstraints() {
        removeConstraints(constraints)
        
        super.updateConstraints()
    }
    
    override class var layerClass : AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /**
     Returns current capture session
     
     - returns: AVCaptureSession object or nil
     */
    func session() -> AVCaptureSession? {
        return (layer as! AVCaptureVideoPreviewLayer).session
    }
    
    /**
     Set capture session for layer
     
     - parameter session: AVCaptureSession object
     */
    func setSession(_ session: AVCaptureSession) {
        (layer as! AVCaptureVideoPreviewLayer).session = session
        (layer as! AVCaptureVideoPreviewLayer).videoGravity = AVLayerVideoGravityResizeAspectFill
        (layer as! AVCaptureVideoPreviewLayer).masksToBounds = true
    }
    
    /**
     Set video orientation for layer
     
     - parameter orientation: AVCaptureVideoOrientation enum value
     */
    func setVideoOrientation(_ orientation: AVCaptureVideoOrientation) {
        (layer as! AVCaptureVideoPreviewLayer).connection?.videoOrientation = orientation
    }
    
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
}
