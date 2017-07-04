//
//  GalleryViewController.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 18.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import Photos


enum GalleryGridSize {
    case small
    case large
}


final class GalleryViewController: UIViewController {
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var closeButton: BarButton!
    var gridButton: BarButton!
    var editButton: UIBarButtonItem!
    var selectButton: UIBarButtonItem?
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    
    var closeDelegate: CloseDelegate?
    var previewInterface: PreviewInterface?
    
    
    fileprivate var smallGrid = false
    
    fileprivate var dataProvider: GalleryProvider!
    
    fileprivate let animationProvider = NavigationControllerAnimatorProvider()
    
    
    fileprivate var editMode: Bool = false {
        didSet {
            configureViewWithEditMode(editMode)
        }
    }
    
    
    fileprivate var model: GalleryModel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        model = GalleryModel()
        model.itemsSelectedBlock = itemsSelected
        
        dataProvider = GalleryProvider(model: model)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = animationProvider
        
        editMode = false
        
        let nib = UINib(nibName: GalleryViewCell.identifier, bundle: Bundle.main)
        photoCollectionView.register(nib, forCellWithReuseIdentifier: GalleryViewCell.identifier)
        
        photoCollectionView.dataSource = dataProvider
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Analytics.instance.send(AnalyticsCategory.Gallery, action: AnalyticsAction.Open, label: AnalyticsLabel.None, value: 0)
        
        configureNavigationBar()
        
        view.backgroundColor = Theme.backgroundColor
        photoCollectionView.backgroundColor = Theme.backgroundColor
        
        photoCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.setTransparentColor(Theme.backgroundColor75)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        model.operationQueue.cancelAllOperations()
        model.loadPhotosForShareQueue.cancelAllOperations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        model.operationQueue.cancelAllOperations()
        model.loadPhotosForShareQueue.cancelAllOperations()
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return navigationController?.preferredStatusBarStyle ?? .lightContent
    }
    
    override var shouldAutorotate : Bool {
        return navigationController?.shouldAutorotate ?? true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return navigationController?.supportedInterfaceOrientations ?? UIInterfaceOrientationMask.all
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return navigationController?.preferredInterfaceOrientationForPresentation ?? UIInterfaceOrientation.portrait
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            self?.photoCollectionView.reloadData()
        }, completion: nil)
    }
    
    
    @IBAction func onClose(_ sender: AnyObject) {
        DispatchQueue.main.async { [weak self] _ in
            let delegate = self?.closeDelegate
            if let navController = self?.navigationController {
                navController.dismiss(animated: true, completion: {
                    if let strongSelf = self {
                        delegate?.onClose(strongSelf)
                    }
                })
            } else {
                self?.dismiss(animated: true, completion: {
                    if let strongSelf = self {
                        delegate?.onClose(strongSelf)
                    }
                })
            }
        }
    }
    
    @IBAction func onGrid(_ sender: AnyObject) {
        smallGrid = !smallGrid
        gridButton.image = UIImage(named: !smallGrid ? "galleryButtonImageSmall" : "galleryButtonImage")
        
        self.photoCollectionView.reloadData()
    }
    
    
    @IBAction func onEdit(_ sender: AnyObject) {
        editMode = !editMode
        
        if !editMode {
            model.deselectAllItems()
            photoCollectionView.reloadItems(at: photoCollectionView.indexPathsForVisibleItems)
        }
    }
    
    @IBAction func onShare(_ sender: UIBarButtonItem) {
        var images = [AnyObject]()
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        let count = model.selectedItems.count > 4 ? 4 : model.selectedItems.count
        var counter = count
        
        if count > 0 {
            Analytics.instance.send(AnalyticsCategory.Gallery, action: AnalyticsAction.Share, label: AnalyticsLabel.Photos, value: count as NSNumber)
            setEditButtonsEnabled(false)
            setInterfaceLocked(true)
        }
        
        for asset in model.selectedAssets() {
            let size = CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))
            
            let operation = PhotoLoadOperation(asset: asset, size: size)
            operation.loadCompletionBlock = { [weak self] (image) -> Void in
                if image != nil {
                    images.append(image!)
                }
                counter -= 1
                
                if counter == 0 {
                    self?.setEditButtonsEnabled(true)
                    self?.setInterfaceLocked(false)
                    
                    let message = localized("SHARE_MESSAGE") + "\niOS: http://goo.gl/eQFjwh" + "\nAndroid: https://goo.gl/9uUVZE"
                    images.insert(message as AnyObject, at: 0)
                    
                    if let button = self?.shareButton {
                        let activityViewController = ShareControllerBuilder.buildPhotoShareController(images, barButtonItem: button)
                        self?.present(activityViewController, animated: true, completion: nil)
                    }
                }
            }
            model.loadPhotosForShareQueue.addOperation(operation)
            if counter == 0 {
                break
            }
        }
    }
    
    @IBAction func onDelete(_ sender: AnyObject) {
        let assets = model.selectedAssets()
        if assets.count > 0 {
            Analytics.instance.send(AnalyticsCategory.Gallery, action: AnalyticsAction.Delete, label: AnalyticsLabel.Photos, value: assets.count as NSNumber)
            setEditButtonsEnabled(false)
            setInterfaceLocked(true)
            PhotoLibraryManager.sharedManager.removeAssets(assets, completionBlock: { [weak self] (success) in
                if success {
                    let indexes = self?.model.selectedItems.map() { IndexPath(item: $0, section: 0) }
                    self?.model.fetch(true, options: self!.model.sortOptionsByLastDate)
                    self?.model.deselectAllItems()
                    if let indexes = indexes {
                        self?.photoCollectionView.deleteItems(at: indexes)
                    }
                    self?.editMode = false
                }
                self?.setEditButtonsEnabled(!success)
                self?.setInterfaceLocked(false)
            })
        }
    }
    
    @IBAction func onSelectAll(_ sender: AnyObject) {
        var indexes = [IndexPath]()
        
        if model.selectedItems.count > 0 {
            indexes = model.selectedItems.map() { IndexPath(item: $0, section: 0) }
            model.deselectAllItems()
        } else {
            model.selectAllItems()
            indexes = model.selectedItems.map() { IndexPath(item: $0, section: 0) }
        }
        
        photoCollectionView.reloadItems(at: indexes)
    }
    
    
    fileprivate func itemsSelected(_ count: Int) -> Void {
        if count == 0 {
            setEditButtonsEnabled(false)
            
            selectButton?.title = NSLocalizedString("GALLERY_SELECT_ALL", comment: "")
        } else if model.dataSource != nil && count == model.dataSource!.count {
            setEditButtonsEnabled(true)
            
            selectButton?.title = NSLocalizedString("GALLERY_DESELECT_ALL", comment: "")
        } else  if model.dataSource != nil {
            setEditButtonsEnabled(true)
            
            selectButton?.title = NSLocalizedString("GALLERY_DESELECT_ALL", comment: "")
        }
    }
    
    
    
    fileprivate func configureViewWithEditMode(_ editMode: Bool) {
        if editMode {
            navigationController?.setToolbarHidden(false, animated: true)
            
            setEditButtonsEnabled(false)
            
            editButton = buildDoneButton(self, selector: #selector(GalleryViewController.onEdit(_:)))
            selectButton = buildSelectButton(self, selector: #selector(GalleryViewController.onSelectAll(_:)))
            
            navigationItem.setRightBarButtonItems([editButton, selectButton!], animated: true)
        } else {
            navigationController?.setToolbarHidden(true, animated: true)
            
            setEditButtonsEnabled(false)
            
            editButton = buildEditButton(self, selector: #selector(GalleryViewController.onEdit(_:)))
            navigationItem.setRightBarButtonItems([editButton], animated: true)
        }
    }
    
    fileprivate func setEditButtonsEnabled(_ enabled: Bool) {
        deleteButton.isEnabled = enabled
        shareButton.isEnabled = enabled
    }
        
    fileprivate func configureNavigationBar() {
        let spacer = buildSpacer()
        closeButton = buildCloseButton(self, selector: #selector(GalleryViewController.onClose(_:))) as! BarButton
        
        gridButton = buildGridButton(true, target: self, selector: #selector(GalleryViewController.onGrid(_:))) as! BarButton
        editButton = buildEditButton(self, selector: #selector(GalleryViewController.onEdit(_:)))
        
        navigationItem.hidesBackButton = true
        navigationItem.setLeftBarButtonItems([spacer, closeButton, gridButton], animated: true)
        navigationItem.setRightBarButtonItems([editButton], animated: true)
    }
    
}



extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _ = model.dataSource {
            if editMode {
                model.toggleSelection(indexPath)
                
                collectionView.reloadItems(at: [indexPath])
            } else {
                collectionView.deselectItem(at: indexPath, animated: false)
                
                let index = abs((model.dataSource?.count ?? 0) - ((indexPath as NSIndexPath).row + 1))
                _ = navigationController?.popViewController(animated: true)
                previewInterface?.setAssetIndex(index, animated: false)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.isSelected = model.isSelected(indexPath)
    }
    
}



extension GalleryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let _ = model.dataSource {
            let numberOfItems = CGFloat(round(Double(numberOfItemsInRow()) * (smallGrid ? 2.0 : 1.0)))
            let width = photoCollectionView.frame.size.width / numberOfItems//(isPortrait ? numberOfItems : (numberOfItems / 2.0))

            let height = width
            
            return CGSize(width: width, height: height)
        }
        
        return CGSize.zero
    }
    
    fileprivate func numberOfItemsInRow() -> Int {
        let orientationIsPortrait = UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)
        switch (orientationIsPortrait, Device.iPad == true) {
        case (true, true): return 4
        case (true, false): return 2
        case (false, true): return 8
        case (false, false): return 4
        }
    }
    
}

