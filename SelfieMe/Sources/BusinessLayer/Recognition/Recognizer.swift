//
//  Recognizer.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 25.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


final class Recognizer: NSObject {

    
    fileprivate var detector: CIDetector?
//    private let bufferContext = CIContext(options: [kCIContextPriorityRequestLow: true, kCIContextUseSoftwareRenderer: true])
    
    
    fileprivate var recognitionDirector: RecognitionDirector
    fileprivate var eventRecognizer: EventRecognizer
    
    
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer
    
    var captureResolution: CaptureResolution = CaptureResolutions._undefined
    var anchor = CGPoint.zero
    
    
    init(previewLayer: AVCaptureVideoPreviewLayer) {
        eventRecognizer = EventRecognizer()

        recognitionDirector = RecognitionDirector()
        recognitionDirector.delegate = eventRecognizer
        
        self.previewLayer = previewLayer
        
        super.init()
        
        // TODO: init detector
    }
    
    
    func addListener(_ listener: EventRecognizerDelegate?) {
        if let listener = listener {
            eventRecognizer.addListener(listener)
        }
    }
    
    
    func reset() {
        eventRecognizer.reset()
    }

}


@available(iOS 8, *)
extension Recognizer {
    
    func initDetector() {
        let options = [
            kCIContextPriorityRequestLow: true,
            kCIContextUseSoftwareRenderer: true
        ]
        
        let context = CIContext(options: options)
        
        let detectorOptions: [String: AnyObject] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh as AnyObject,
            CIDetectorSmile: true as AnyObject,
            CIDetectorEyeBlink: true as AnyObject]
        
        detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: detectorOptions)
    }
    
    func destroyDetector() {
        detector = nil
    }
    
}


extension Recognizer {

    struct Queues {
        static let metadataQueue  = DispatchQueue(label: "camera.stream.manager.metadata.queue", attributes: [])
        static let videoDataQueue = DispatchQueue(label: "camera.stream.manager.video.queue",    attributes: [])
    }

}


extension Recognizer {
    
    @available(iOS 8, *)
    func didFoundFaces(_ faces: [Face], inClap clap: CGRect) {
        let angle = CGFloat(Utils.angleForCurrentDeviceOrientation())
        let layer = previewLayer
        let rotationsCount = angle == 90 || angle == -90 || angle == 270 || angle == -270 ? 1 : 0
        let exchangeY = angle == 90 || angle == 180
        var point = rotationsCount == 0 ? anchor : anchor.exchanged()
        if exchangeY {
            point.y = 1 - point.y
        }
        let viewPoint = FigureConverter.pointToViewPoint(point, frame: layer.frame)
        CameraSettings.settings.anchorPoint = FigureConverter.viewPointToDevicePoint(viewPoint, gravity: layer.videoGravity, withFrameSize: layer.frame.size, andApertureSize: clap.size)
        
        let facesCount = CameraSettings.settings.facesState.rawValue
        
        var facesForProcess = faces
        
        if facesCount != 0 && faces.count > facesCount {
            facesForProcess.removeSubrange((facesCount - 1)..<faces.count)
        }
        
        let deviceOrientation = DeviceOrientationRecognizer.sharedInstance.deviceOrientation
        let orientation = Utils.deviceOrientationToCaptureVideoOrientation(deviceOrientation)
        
        recognitionDirector.handleFaces(facesForProcess,
                                        requiredFacesCount: facesCount,
                                        frameBounds: clap,
                                        anchorPoint: CameraSettings.settings.anchorPoint ?? CGPoint.zero,
                                        layerOrientation: orientation)
    }
    
    @available(iOS 8, *)
    func didNotFoundFacesInClap(_ clap: CGRect) {
        recognitionDirector.handleNoFaces()
    }
    
    @available (iOS 9, *)
    func didCaptureMetadataObjects(_ metadataObjects: [AVMetadataObject]) {
        let faces = metadataObjects.filter() { $0.type == AVMetadataObjectTypeFace }.flatMap() { (object) -> Face in
            let transformedMetadataObject = previewLayer.transformedMetadataObject(for: object)
            return Face(rect: transformedMetadataObject!.bounds)
        }
        
        if faces.count > 0 {
            let ratio = captureResolution.getRatioRelativeToRect(previewLayer.frame)
            let clapForCaptureResolution = FrameAdapter.adaptedFrame(previewLayer.frame, inContainer: previewLayer.frame, withTargetRatio: CGFloat(ratio), center: true)
            
            let viewPoint = FigureConverter.pointToViewPoint(anchor, frame: previewLayer.frame)
            CameraSettings.settings.anchorPoint = FigureConverter.viewPointToDevicePoint(viewPoint, gravity: previewLayer.videoGravity, withFrameSize: previewLayer.frame.size, andApertureSize: clapForCaptureResolution.size)
            
            let facesCount = CameraSettings.settings.facesState.rawValue
            
            var facesForProcess = faces
            
            if facesCount != 0 && faces.count > facesCount {
                facesForProcess.removeSubrange((facesCount - 1)..<faces.count)
            }
            
            let deviceOrientation = DeviceOrientationRecognizer.sharedInstance.deviceOrientation
            let orientation = Utils.deviceOrientationToCaptureVideoOrientation(deviceOrientation)
            
            recognitionDirector.handleFaces(facesForProcess,
                                            requiredFacesCount: facesCount,
                                            frameBounds: clapForCaptureResolution,
                                            anchorPoint: CameraSettings.settings.anchorPoint ?? CGPoint.zero,
                                            layerOrientation: orientation)
        } else {
            recognitionDirector.handleNoFaces()
        }
    }
    
}




@available(iOS 8, *)
extension Recognizer: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if let description = CMSampleBufferGetFormatDescription(sampleBuffer) {
            // Get clean aperture of frame
            let clap = CMVideoFormatDescriptionGetCleanAperture(description, false);
            // Calculate clap ratio
            let ratio = captureResolution.getRatioRelativeToRect(clap)
            // Build clap for current camera mode
            var clapForCaptureResolution = FrameAdapter.adaptedFrame(clap, inContainer: clap, withTargetRatio: CGFloat(ratio), center: true)
            // Rotate clap
            let angle = CGFloat(Utils.angleForCurrentDeviceOrientation())
            if angle == 90 || angle == -90 || angle == 270 || angle == -270 {
                let tempWidth = clapForCaptureResolution.size.width
                clapForCaptureResolution.size.width = clapForCaptureResolution.size.height
                clapForCaptureResolution.size.height = tempWidth
                let tempX = clapForCaptureResolution.origin.x
                clapForCaptureResolution.origin.x = clapForCaptureResolution.origin.y
                clapForCaptureResolution.origin.y = tempX
            }
            //Rotate image
            let uiImage = imageFromSampleBuffer(sampleBuffer)!.fixedOrientationImage().rotatedByAngle(-angle)
            // Crop image
            let croppedImage = uiImage.croppedByFrame(clapForCaptureResolution)
            let ciImage = CIImage(cgImage: croppedImage.cgImage!)

//            let orientation = UIImage.imageEXIFOrientation()
            let options = [
                CIDetectorImageOrientation: 1 // Always portrait
            ]
            if let features = detector?.features(in: ciImage, options: options) {
                let faceHandler = FaceHandler(features: features)
                // Change Y-axis value to opposite (Because of CIDetector specialities)
                faceHandler.normalizeFacesWithClap(clapForCaptureResolution)

                if faceHandler.faces.count != 0 {
                    self.didFoundFaces(faceHandler.faces, inClap: clapForCaptureResolution)
                } else {
                    self.didNotFoundFacesInClap(clapForCaptureResolution)
                }
            }
        }
    }


    func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))

            let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)

            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
            let width = CVPixelBufferGetWidth(imageBuffer)
            let height = CVPixelBufferGetHeight(imageBuffer)

            let colorSpace = CGColorSpaceCreateDeviceRGB()

            let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
            if let quartzImage = context?.makeImage() {
                CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))

                let image = UIImage(cgImage: quartzImage)

                return image
            } else {
                CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
            }
        }
        return nil
    }

}



extension Recognizer: AVCaptureMetadataOutputObjectsDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if #available(iOS 9, *) {
            self.didCaptureMetadataObjects(metadataObjects as! [AVMetadataObject])
        }
    }
    
}
