//
//  PhotoLibraryManager.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 01.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import Photos



enum PhotoLibraryAlbumType {
    case application
    case shared
}



final class PhotoLibraryManager {

    typealias PhotoLibraryManagerCompletionBlock = () -> Void
    typealias PhotoLibraryManagerCompletionBlockWithSuccess = (Bool) -> Void
    typealias PhotoLibraryPhotoBlock = (UIImage?) -> Void
        
    
    fileprivate var assetCollection: PHAssetCollection?
    fileprivate var assetCollectionPlaceholder: PHObjectPlaceholder?
    
    
    static let sharedManager = PhotoLibraryManager()
    
    
    fileprivate init() {        
        self.createApplicationAlbum()
    }
    
    func createApplicationAlbum() {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title = %@", PhotoLibrary.albumTitle)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        
        print(collection)
        
        if let object = collection.firstObject {
            self.assetCollection = object
        } else {
            PHPhotoLibrary.shared().performChanges(
                { [weak self] () -> Void in
                    let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoLibrary.albumTitle)
                    self?.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: { [weak self] (success, error) -> Void in
                    if success {
                        if let id = self?.assetCollectionPlaceholder?.localIdentifier {
                            let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil)
                            self?.assetCollection = fetchResult.firstObject
                        }
                    }
                })
        }
    }
    
    
    func savePhotoToApplicationAlbum(_ data: Data, completionBlock block: @escaping PhotoLibraryManagerCompletionBlockWithSuccess) {
        guard self.assetCollection != nil else { return }
        PHPhotoLibrary.shared().performChanges(
            { [weak self] () -> Void in
                if let image = UIImage(data: data) {
                    let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    assetRequest.creationDate = Date()
                    let assetPlaceholder = assetRequest.placeholderForCreatedAsset
                    if let assets = self?.fetchApplicationAlbumAssets(nil) {
                        if let collection = self?.assetCollection {
                            let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection, assets: assets as! PHFetchResult<PHAsset>)
                            if let placeholder = assetPlaceholder {
                                albumChangeRequest?.addAssets([placeholder] as NSFastEnumeration)
                            }
                        }
                    }
                }
            }, completionHandler: { (success, error) -> Void in
                block(success)
        })
    }
    
    func savePhotoToSharedAlbum(_ data: Data, completionBlock block: @escaping PhotoLibraryManagerCompletionBlockWithSuccess) {
        if #available(iOS 9.0, *) {
            PHPhotoLibrary.shared().performChanges({ () -> Void in
                PHAssetCreationRequest.forAsset().addResource(with: PHAssetResourceType.fullSizePhoto, data: data, options: nil)
                }, completionHandler: { (success, error) -> Void in
                    DispatchQueue.main.async(execute: { () -> Void in
                        block(success)
                    })
                })
        } else {
            let tempFileName = ProcessInfo.processInfo.globallyUniqueString
            let tempFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((tempFileName as NSString).appendingPathExtension("jpg")!)
            let tempURL = URL(fileURLWithPath: tempFilePath)
            
            PHPhotoLibrary.shared().performChanges({ () -> Void in
                try! data.write(to: tempURL, options: NSData.WritingOptions.atomic)
                
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: tempURL)
                }, completionHandler: { (success, error) -> Void in
                    try! FileManager.default.removeItem(at: tempURL)
                    DispatchQueue.main.async(execute: { () -> Void in
                        block(success)
                    })
                })
        }
    }
    
    
    func removeAssets(_ assets: [PHAsset], completionBlock block: PhotoLibraryManagerCompletionBlockWithSuccess?) {
        PHPhotoLibrary.shared().performChanges({ () -> Void in
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        }, completionHandler: { (success, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                block?(success)
            })
        })
    }
    
    
    
    func fetchApplicationAlbumAssets(_ options: PHFetchOptions?) -> PHFetchResult<AnyObject>? {
        guard let collection = self.assetCollection else { return nil }
        return PHAsset.fetchAssets(in: collection, options: options) as? PHFetchResult<AnyObject>
    }
    
    func fetchSharedAlbumAssets(_ options: PHFetchOptions?) -> PHFetchResult<AnyObject> {
        return PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options) as! PHFetchResult<AnyObject>
    }
    
    func fetchAssetWithIdentifier(_ localIdentifier: String, options: PHFetchOptions?) -> PHFetchResult<AnyObject>? {
        return PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: options) as? PHFetchResult<AnyObject>
    }
    
    
    
    func fetchAsset(_ album: PhotoLibraryAlbumType, offset: Int = 0, ascending: Bool = false) -> PHAsset? {
        guard offset >= 0 else { return nil }
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]
        
        var assets: PHFetchResult<AnyObject>?
        switch album {
        case .application:
            assets = self.fetchApplicationAlbumAssets(options)
        case .shared:
            assets = self.fetchSharedAlbumAssets(options)
        }
        
        let count = assets?.count ?? 0
        
        guard offset < count else { return nil }
        
        return assets?[count - offset - 1] as? PHAsset
    }
    
    
    func assetsCountInApplicationAlbum() -> Int {
        if let assets = self.fetchApplicationAlbumAssets(nil) {
            return assets.count
        }
        return 0
    }
    
    
    
    func getLastPhotoFromApplicationAlbum(_ size: CGSize, mode: PHImageContentMode, completionBlock block: @escaping PhotoLibraryPhotoBlock) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        if let assets = self.fetchApplicationAlbumAssets(options) {
            self.getLastPhotoWithAssets(assets, size: size, mode: mode, completionBlock: block)
        } else {
            block(nil)
        }
    }
    
    func getLastPhotoFromSharedAlbum(_ size: CGSize, mode: PHImageContentMode, completionBlock block: @escaping PhotoLibraryPhotoBlock) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let assets = self.fetchSharedAlbumAssets(options)
        self.getLastPhotoWithAssets(assets, size: size, mode: mode, completionBlock: block)
    }
    
    fileprivate func getLastPhotoWithAssets(_ assets: PHFetchResult<AnyObject>, size: CGSize, mode: PHImageContentMode, completionBlock block: @escaping PhotoLibraryPhotoBlock) {
        if let asset = assets.lastObject as? PHAsset {
            let requestOptions = PHImageRequestOptions()
            requestOptions.version = .current
            requestOptions.isSynchronous = true
            
            loadPhotoAsset(asset, size: size, mode: mode, options: requestOptions, completionBlock: block)
        } else {
            block(nil)
        }
    }
    
    
    func loadPhotoAsset(_ asset: PHAsset, size: CGSize, mode: PHImageContentMode, options: PHImageRequestOptions, completionBlock block: PhotoLibraryPhotoBlock?) {
        PHImageManager.default().requestImage(for: asset,
            targetSize: size,
            contentMode: mode,
            options: options) { (image, info) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    block?(image)
            })
        }
    }

}
