//
//  PhotoPreviewDataProvider.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 27.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import GPUImage


final class PhotoPreviewDataProvider: NSObject {

    var model: PreviewModel
    
    var filterInterface: FilterOperationInterface?
    
    let operationQueue = OperationQueue()
    
    init(model: PreviewModel) {
        self.model = model
        
        super.init()
        
        operationQueue.maxConcurrentOperationCount = 1
    }

}


extension PhotoPreviewDataProvider: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.assetsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCollectionViewCell", for: indexPath) as! PreviewCollectionViewCell
        
        if let asset = PhotoLibraryManager.sharedManager.fetchAsset(.application, offset: (indexPath as NSIndexPath).row, ascending: false) {
            let size = cell.bounds.size
            let operation = PhotoLoadOperation(asset: asset, size: size) { [weak self] image in
                DispatchQueue.main.async(execute: { [weak cell] _ in
                    cell?.originalImage = image
                    cell?.filteredImage = image
                })
                if let filter = self?.filterInterface?.filter, let image = image {
                    let filterOperation = FilterApplyOperation(filter: filter, image: image, onComplete: { (filteredImage) in
                        DispatchQueue.main.async(execute: { [weak cell] _ in
                            if let img = filteredImage {
                                cell?.filteredImage = img
                            } else {
                                cell?.filteredImage = cell?.originalImage
                            }
                        })
                    })
                    cell.filterOperation = filterOperation
                    self?.operationQueue.addOperation(filterOperation)
                } else {
                    DispatchQueue.main.async(execute: { [weak cell] _ in
                        cell?.filteredImage = cell?.originalImage
                    })
                }
            }
            self.model.operationQueue.addOperation(operation)
        } else {
            DispatchQueue.main.async(execute: { [weak cell] _ in
                cell?.originalImage = nil
                cell?.filteredImage = nil
            })
        }
        
        return cell
    }

}
