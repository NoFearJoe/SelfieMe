//
//  RecognizerAssembly.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 26.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation


final class RecognizerAssembly {

    class func createRecognizer(_ camera: Camera, previewLayer: AVCaptureVideoPreviewLayer) -> Recognizer {
        let recognizer = Recognizer(previewLayer: previewLayer)
    
        if #available(iOS 9, *) {
            camera.metadataOutput()?.setMetadataObjectsDelegate(recognizer, queue: Recognizer.Queues.metadataQueue)
        } else {
            camera.videoDataOutput()?.setSampleBufferDelegate(recognizer, queue: Recognizer.Queues.videoDataQueue)
        }
                
        return recognizer
    }

}
