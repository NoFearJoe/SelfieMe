//
//  PreviewPhotoLoadOperation.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 16.06.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import Photos
import UIKit


class PreviewPhotoLoadOperation: Operation {
    
    var asset: PHAsset
    var size: CGSize
    var imageView: UIImageView
    
    override var isAsynchronous: Bool {
        return true
    }
    
    init(asset: PHAsset, size: CGSize, view: UIImageView) {
        self.asset = asset
        self.size = size
        self.imageView = view
        
        super.init()
    }
    
    
    override func main() {
        if self.isCancelled {
            return
        }
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = .current
        requestOptions.isSynchronous = true
        
        let imageView = self.imageView
        
        PhotoLibraryManager.sharedManager.loadPhotoAsset(asset, size: size, mode: .aspectFit, options: requestOptions) { (image) -> Void in
            imageView.image = image
        }
    }
    
}
