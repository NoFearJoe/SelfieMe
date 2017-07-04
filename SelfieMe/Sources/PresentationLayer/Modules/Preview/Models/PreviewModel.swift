//
//  PreviewModel.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 16.06.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import Photos


final class PreviewModel {

    var isInterfaceHidden: Bool = false
    
    
    var currentAsset: PHAsset? {
        if let index = currentAssetIndex {
            return assetWithIndex(index)
        }
        return nil
    }
    
    var currentAssetIndex: Int?
    var assetsCount: Int {
        return PhotoLibraryManager.sharedManager.assetsCountInApplicationAlbum()
    }
    
    let operationQueue = OperationQueue()
    
    
    init() {
        operationQueue.maxConcurrentOperationCount = 3
    }
    
    
    func assetWithIndex(_ index: Int) -> PHAsset? {
        return PhotoLibraryManager.sharedManager.fetchAsset(.application, offset: index, ascending: false)
    }

}
