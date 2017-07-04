//
//  PhotoLoadOperation.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 27.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import Photos
import UIKit


class PhotoLoadOperation: Operation {

    var asset: PHAsset
    var size: CGSize
    
    var loadCompletionBlock: ((UIImage?) -> Void)?
    
    override var isAsynchronous: Bool {
        return true
    }
    
    init(asset: PHAsset, size: CGSize, onComplete: ((UIImage?) -> Void)? = nil) {
        self.asset = asset
        self.size = size
        self.loadCompletionBlock = onComplete
        
        super.init()
    }
    
    
    override func main() {
        if self.isCancelled {
            return
        }
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = .current
        requestOptions.isSynchronous = true
        
        let completionBlock = loadCompletionBlock
        
        PhotoLibraryManager.sharedManager.loadPhotoAsset(asset, size: size, mode: .aspectFit, options: requestOptions) { (image) -> Void in
            completionBlock?(image)
        }
    }

}
