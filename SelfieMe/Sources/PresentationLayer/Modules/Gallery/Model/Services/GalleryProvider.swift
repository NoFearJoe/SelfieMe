//
//  GalleryProvider.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 27.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


final class GalleryProvider: NSObject {

    var model: GalleryModel
    
    
    init(model: GalleryModel) {
        self.model = model
        super.init()
    }
    

}


extension GalleryProvider: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryViewCell.identifier, for: indexPath) as! GalleryViewCell
        
        if let _ = model.dataSource {
            if let asset = model.assetAtIndexPath(indexPath) {
                let maxSide = max(cell.frame.size.width, cell.frame.size.height)
                let size = CGSize(width: maxSide, height: maxSide)
                let operation = PreviewPhotoLoadOperation(asset: asset, size: size, view: cell.photoView)
                cell.operation = operation
                model.operationQueue.addOperation(operation)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.dataSource?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}
