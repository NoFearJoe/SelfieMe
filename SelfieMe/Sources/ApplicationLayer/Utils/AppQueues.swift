//
//  GCDQueues.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 17.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation


struct AppQueues {

    static let sessionQueue         = DispatchQueue(label: "camera.stream.manager.session.queue",          attributes: [])
    static let videoOutputQueue     = DispatchQueue(label: "camera.stream.manager.video.output.queue",     attributes: [])
    static let metadataOutputQueue  = DispatchQueue(label: "camera.stream.manager.metadata.output.queue",  attributes: [])
    static let renderingQueue       = DispatchQueue(label: "camera.stream.manager.rendering.queue",        attributes: [])
    
    static let audioQueue           = DispatchQueue(label: "selfie.me.audio.queue",                        attributes: [])
    
}
