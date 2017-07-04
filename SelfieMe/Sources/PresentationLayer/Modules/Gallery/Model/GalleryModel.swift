//
//  GalleryModel.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 26.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import Photos


enum GallerySelection: Int {
    case none = 0
    case some = 1
    case all = 2
}


class GalleryModel {
    
    var dataSource: PHFetchResult<AnyObject>?
    var selectedItems = [Int]()
    
    var operationQueue: OperationQueue
    var loadPhotosForShareQueue: OperationQueue
    
    
    var itemsSelectedBlock: ((Int) -> Void)?
    
    init() {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 8
        
        loadPhotosForShareQueue = OperationQueue()
        loadPhotosForShareQueue.maxConcurrentOperationCount = 8
        
        fetch(true, options: sortOptionsByLastDate)
    }
    
    
    func fetch(_ albumPhotosOnly: Bool, options: PHFetchOptions) {
        selectedItems = [Int]()
        if albumPhotosOnly {
            dataSource = PhotoLibraryManager.sharedManager.fetchApplicationAlbumAssets(options)
        } else {
            dataSource = PhotoLibraryManager.sharedManager.fetchApplicationAlbumAssets(options)
        }
    }
    
    
    func assetAtIndexPath(_ indexPath: IndexPath) -> PHAsset? {
        if dataSource != nil {
            if dataSource!.count > (indexPath as NSIndexPath).row {
                return dataSource![(indexPath as NSIndexPath).row] as? PHAsset
            }
        }
        
        return nil
    }
    
    func selectedAssets() -> [PHAsset] {
        let assets = selectedItems.map() { assetAtIndexPath(IndexPath(row: $0, section: 0)) }
        let filteredAssets = assets.filter() { return $0 != nil }
        return filteredAssets.map() { $0! as PHAsset }
    }
    
    
    // MARK: Edit mode
    
    func toggleSelection(_ indexPath: IndexPath) {
        if isSelected(indexPath) {
            deselect(indexPath)
        } else {
            select(indexPath)
        }
    }
    
    fileprivate func select(_ indexPath: IndexPath) {
        if !isSelected(indexPath) {
            selectedItems.append((indexPath as NSIndexPath).row)
            itemsSelectedBlock?(selectedItems.count)
        }
    }
    
    fileprivate func deselect(_ indexPath: IndexPath) {
        if isSelected(indexPath) {
            if let index = selectedItems.index(of: (indexPath as NSIndexPath).row) {
                selectedItems.remove(at: index)
                itemsSelectedBlock?(selectedItems.count)
            }
        }
    }
    
    func selectAllItems() {
        if let _ = dataSource {
            for i in 0..<dataSource!.count {
                select(IndexPath(row: i, section: 0))
            }
        }
    }
    
    func deselectAllItems() {
        selectedItems = [Int]()
        itemsSelectedBlock?(selectedItems.count)
    }
    
    func isSelected(_ indexPath: IndexPath) -> Bool {
        return selectedItems.contains((indexPath as NSIndexPath).row)
    }
    
    
    
    var sortOptionsByLastDate: PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return options
    }
    
    var sortOptionsByFirstDate: PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return options
    }
    
}
