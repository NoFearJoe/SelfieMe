//
//  PhotoPreviewViewController.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 01.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import Photos
import GPUImage


final class PhotoPreviewViewController: UIViewController {
    @IBOutlet weak var filtersButton: UIBarButtonItem!
    
    @IBOutlet weak var photoContainerView: PreviewCollectionView!
    
    @IBOutlet weak var titleView: UINavigationItem!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var filtersCollectionView: FiltersCollectionView!
    @IBOutlet weak var filterSlider: UISlider!
    
    fileprivate var filterOperation: FilterOperationInterface?
    
    // MARK: Bar buttons
    var closeButton: BarButton!
    var galleryButton: BarButton!
    
    var cancelButton: UIBarButtonItem!
    var saveButton: UIBarButtonItem!
    
    
    var model = PreviewModel()
    
    
    var closeDelegate: CloseDelegate?
    
    fileprivate var photoDataProvider: PhotoPreviewDataProvider?
    fileprivate let filtersProvider = FiltersProvider()
    
    let flipDismissInteractor = FlipDismissInteractor()
    
    
    fileprivate var activityViewController: UIActivityViewController!
    
    
    fileprivate var shouldReloadAfterDismiss = true
    
    fileprivate let animationProvider = NavigationControllerAnimatorProvider()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.transitioningDelegate = flipDismissInteractor
        
        photoDataProvider = PhotoPreviewDataProvider(model: model)
        
        self.photoContainerView.alpha = 0.0
        
        navigationController?.delegate = animationProvider
        photoContainerView.dataSource = photoDataProvider
        photoContainerView.delegate = self
        
        filtersCollectionView.dataSource = filtersProvider
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = Theme.secondaryBackgroundColor
        photoContainerView.backgroundColor = UIColor.clear
        filtersCollectionView.backgroundColor = Theme.backgroundColor.withAlphaComponent(0.45)
        
        filterSlider.tintColor = Theme.mainColor
        filterSlider.thumbTintColor = Theme.lightTintColor.withAlphaComponent(0.75)
        
        navigationController?.setToolbarHidden(model.isInterfaceHidden, animated: true)
        navigationController?.setNavigationBarHidden(model.isInterfaceHidden, animated: true)
        setNeedsStatusBarAppearanceUpdate()
        UIView.animate(withDuration: Animation.shortDuration, animations: { [weak self] _ in
            self?.view.backgroundColor = (self?.model.isInterfaceHidden ?? false) ? Theme.backgroundColor : Theme.secondaryBackgroundColor
        }) 
        
        if shouldReloadAfterDismiss {
            Analytics.instance.send(AnalyticsCategory.Preview, action: AnalyticsAction.Open, label: AnalyticsLabel.None, value: 0)
            configureNavigationBar()
            configureFiltersButton()
            reload()
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true //model.isInterfaceHidden //navigationController?.prefersStatusBarHidden() ?? true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return navigationController?.preferredStatusBarStyle ?? .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .slide
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
        
        let itemNumber = photoContainerView.currentItemNumber
        
        photoContainerView.isHidden = true
        
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            _ = self?.photoContainerView.collectionViewLayout.collectionViewContentSize
            self?.photoContainerView.scrollToItemWithIndex(itemNumber, animated: false)
            self?.photoContainerView.reloadData()
        }) { [weak self] (context) in
            self?.photoContainerView.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        model.operationQueue.cancelAllOperations()
        filtersProvider.operationQueue.cancelAllOperations()
        photoDataProvider?.operationQueue.cancelAllOperations()
    }
    
    
    fileprivate func configureFiltersButton() {
        filtersButton.image = filtersButton.image?.withRenderingMode(.alwaysOriginal)
    #if SELFIE_ME
        filtersButton.badgeValue = "+"
        filtersButton.badgeBGColor = Theme.buyButtonTextColor
        filtersButton.badgeTextColor = Theme.buyButtonBackgroundColor
        filtersButton.badgeOriginX = 22
    #endif
    }
    
    
    fileprivate func initActivityViewController(_ items: [AnyObject]?, barButtonItem: UIBarButtonItem?) {
        activityViewController = ShareControllerBuilder.buildPhotoShareController(items, barButtonItem: barButtonItem)
    }
    
    // TODO: Сделать пересохранение, а не сохранение новой
    fileprivate func saveImage(_ image: UIImage) {
        if let data = UIImageJPEGRepresentation(image, 1.0) {
            PhotoLibraryManager.sharedManager.savePhotoToApplicationAlbum(data) { [weak self] (success) -> Void in
                self?.onCancel(self!)
                self?.setActivityIndicatorVisible(false)
            }
        } else {
            self.setActivityIndicatorVisible(false)
        }
    }
    
    
    
    @IBAction func onClose(_ sender: AnyObject) {
        DispatchQueue.main.async { [weak self] _ in
            let delegate = self?.closeDelegate
            if let navController = self?.navigationController {
                if let strongSelf = self {
                    delegate?.onClose(strongSelf)
                }
                navController.dismiss(animated: true, completion: nil)
            } else {
                if let strongSelf = self {
                    delegate?.onClose(strongSelf)
                }
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onGallery(_ sender: AnyObject) {
        let controller = StoryboardManager.manager.galleryViewController()
        controller.previewInterface = self
        DispatchQueue.main.async { [weak self] _ in
            self?.setFiltersViewVisible(false)
            self?.navigationController?.setToolbarHidden(true, animated: true)
            self?.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    @IBAction func onCancel(_ sender: AnyObject) {
        self.filtersProvider.currentIndex = 0
        self.applyFilter(nil)
        self.configureFilterSlider(nil)
        DispatchQueue.main.async(execute: { [weak self] _ in
            self?.filtersCollectionView.reloadData()
            self?.navigationItem.rightBarButtonItems?.forEach() { $0.isEnabled = false }
        })
    }
    
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        let index = photoContainerView.currentItemNumber
        if let asset = model.assetWithIndex(index) {
            Analytics.instance.send(AnalyticsCategory.Preview, action: AnalyticsAction.Share, label: AnalyticsLabel.Photo, value: 0)
            setActivityIndicatorVisible(true)
            let size = CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))
            let operation = PhotoLoadOperation(asset: asset, size: size)
            operation.loadCompletionBlock = { [weak self] (image) -> Void in
                if let img = image {
                    if let index = self?.filtersProvider.currentIndex {
                        if index == 0 {
                            self?.setActivityIndicatorVisible(false)
                        } else {
                            if let filter = filterOperations[index - 1].filter {
                                let filterOperation = FilterApplyOperation(filter: filter, image: img, onComplete: { (filteredImage) in
                                    if let img = filteredImage {
                                        self?.saveImage(img)
                                    } else {
                                        self?.setActivityIndicatorVisible(false)
                                    }
                                })
                                self?.model.operationQueue.addOperation(filterOperation)
                            } else {
                                self?.setActivityIndicatorVisible(false)
                            }
                        }
                    } else {
                        self?.setActivityIndicatorVisible(false)
                    }
                } else {
                    self?.setActivityIndicatorVisible(false)
                }
            }
            model.operationQueue.addOperation(operation)
        }
    }
    
    
    
    
    @IBAction func onDelete(_ sender: AnyObject) {
        let index = photoContainerView.currentItemNumber
        if let asset = model.assetWithIndex(index) {
            Analytics.instance.send(AnalyticsCategory.Preview, action: AnalyticsAction.Delete, label: AnalyticsLabel.Photo, value: 0)
            setActivityIndicatorVisible(true)
            PhotoLibraryManager.sharedManager.removeAssets([asset], completionBlock: { [weak self] (success) -> Void in
                if success {
                    let path = IndexPath(item: index, section: 0)
                    self?.photoContainerView.deleteItems(at: [path])
                    self?.photoContainerView.reloadData()
                    self?.setAssetIndex(index, animated: true)
                }
                self?.setActivityIndicatorVisible(false)
            })
        }
    }
    
    @IBAction func onFilter(_ sender: AnyObject) {
    #if SELFIE_ME
            let controller = AlertViewBuilder.buildDisableAdAlertController { (answer) in
                switch answer {
                case .buyPlusVersion:
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id" + Strings.otherAppID) {
                        URLHelper.openURL(url)
                    }
                    Analytics.instance.send(AnalyticsCategory.Ads, action: AnalyticsAction.Answer, label: AnalyticsLabel.Rate, value: 0)
                    break
                case .notNow:
                    break
                }
            }
            DispatchQueue.main.async { [weak self] _ in
                self?.present(controller, animated: true, completion: nil)
            }
    #else
        setFiltersViewVisible(filtersCollectionView.isHidden)
    #endif
    }
    
    @IBAction func onShare(_ sender: AnyObject) {
        let index = photoContainerView.currentItemNumber
        if let asset = model.assetWithIndex(index) {
            Analytics.instance.send(AnalyticsCategory.Preview, action: AnalyticsAction.Share, label: AnalyticsLabel.Photo, value: 0)
            setActivityIndicatorVisible(true)
            let size = CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))
            let operation = PhotoLoadOperation(asset: asset, size: size)
            operation.loadCompletionBlock = { [weak self] (image) -> Void in
                if let img = image {
                    let message = localized("SHARE_MESSAGE") + "\niOS: http://goo.gl/eQFjwh" + "\nAndroid: https://goo.gl/9uUVZE"
                    self?.initActivityViewController([message as AnyObject, img], barButtonItem: (sender as! UIBarButtonItem))
                    self?.present(self!.activityViewController, animated: true, completion: nil)
                }
                self?.setActivityIndicatorVisible(false)
            }
            model.operationQueue.addOperation(operation)
        }
    }
    
    
    @IBAction func onSingleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        model.isInterfaceHidden = !model.isInterfaceHidden
        navigationController?.setToolbarHidden(model.isInterfaceHidden, animated: true)
        navigationController?.setNavigationBarHidden(model.isInterfaceHidden, animated: true)
        setNeedsStatusBarAppearanceUpdate()
        UIView.animate(withDuration: Animation.shortDuration, animations: { [weak self] _ in
            self?.view.backgroundColor = (self?.model.isInterfaceHidden ?? false) ? Theme.backgroundColor : Theme.secondaryBackgroundColor
        }) 
    }
    
    
    @IBAction func onPanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard UIApplication.shared.statusBarOrientation.isPortrait else { return }

        flipDismissInteractor.interactWith(panGestureRecognizer: panGestureRecognizer, onClose: { [weak self] in
            self?.shouldReloadAfterDismiss = false
            self?.onClose(self!)
        }) { [weak self] _ in
            self?.shouldReloadAfterDismiss = false
        }
    }
    
    
    fileprivate func setFiltersViewVisible(_ visible: Bool) {
        self.filtersCollectionView.alpha = visible ? 0 : 1
        self.filterSlider.alpha = visible ? 0 : 1
        if visible {
            self.filtersCollectionView.isHidden = !visible
        }
        UIView.animate(withDuration: Animation.shortDuration, animations: { [weak self] () -> Void in
            self?.filtersCollectionView.alpha = visible ? 1 : 0
            self?.filterSlider.alpha = visible ? 1 : 0
        }, completion: { [weak self] (complete) -> Void in
            self?.filtersCollectionView.isHidden = !visible
            self?.configureFilterSlider(self!.filterOperation)
        }) 
    }
    
    
    fileprivate func applyFilter(_ filter: FilterOperationInterface?) {
        DispatchQueue.main.async { [weak self] _ in
            self?.photoDataProvider?.filterInterface = filter
            self?.photoContainerView.reloadData()
        }
    }
    
    fileprivate func setActivityIndicatorVisible(_ visible: Bool) {
        DispatchQueue.main.async { [weak self] _ in
            self?.view.bringSubview(toFront: self!.activityIndicatorView)
            self?.activityIndicatorView.isHidden = !visible
            if visible {
                UIApplication.shared.beginIgnoringInteractionEvents()
                self?.activityIndicatorView.startAnimating()
            } else {
                self?.activityIndicatorView.stopAnimating()
                if UIApplication.shared.isIgnoringInteractionEvents {
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
        }
    }
    
    
    fileprivate func configureNavigationBar() {
        let spacer1 = buildSpacer()
        closeButton = buildCloseButton(self, selector: #selector(PhotoPreviewViewController.onClose(_:))) as! BarButton
        galleryButton = buildGalleryButton(self, selector: #selector(PhotoPreviewViewController.onGallery(_:)))
        
        cancelButton = buildCancelButton(self, selector: #selector(PhotoPreviewViewController.onCancel(_:)))
        saveButton = buildSaveButton(self, selector: #selector(PhotoPreviewViewController.onSave(_:)))
        
        navigationItem.setLeftBarButtonItems([spacer1, closeButton, galleryButton], animated: true)
        navigationItem.setRightBarButtonItems([saveButton, cancelButton], animated: true)
        
        navigationItem.rightBarButtonItems?.forEach() { $0.isEnabled = false }
    }
    
    
    fileprivate func configureFilterSlider(_ filter: FilterOperationInterface?) {
        filterOperation = filter
        if let slider = self.filterSlider {
            if let filter = filter {
                switch filter.sliderConfiguration {
                case .disabled:
                    slider.isHidden = true
                case let .enabled(minimumValue, maximumValue, initialValue):
                    slider.minimumValue = minimumValue
                    slider.maximumValue = maximumValue
                    slider.value = initialValue
                    slider.isHidden = false
                    self.updateSliderValue()
                }
            } else {
                slider.isHidden = true
            }
        }
    }
    
    @IBAction func updateSliderValue() {
        if let currentFilterConfiguration = filterOperation {
            switch (currentFilterConfiguration.sliderConfiguration) {
            case .enabled(_, _, _):
                currentFilterConfiguration.updateBasedOnSliderValue(CGFloat(self.filterSlider!.value))
                self.applyFilter(currentFilterConfiguration)
            case .disabled:
                break
            }
        }
    }
    
}


extension PhotoPreviewViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _ = collectionView as? FiltersCollectionView {
            guard filtersProvider.currentIndex != (indexPath as NSIndexPath).row else { return }
            
            filtersProvider.currentIndex = (indexPath as NSIndexPath).row
            filtersCollectionView.reloadData()

            if (indexPath as NSIndexPath).item == 0 {
                applyFilter(nil)
                configureFilterSlider(nil)
                navigationItem.rightBarButtonItems?.forEach() { $0.isEnabled = false }
            } else {
                let filter = filterOperations[(indexPath as NSIndexPath).item - 1]
                
                configureFilterSlider(filter)
            
                applyFilter(filter)
                
                navigationItem.rightBarButtonItems?.forEach() { $0.isEnabled = true }
            }
        }
    }
    
}

extension PhotoPreviewViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView is FiltersCollectionView {
            return 16.0
        }
//        if collectionView is CategoriesCollectionView  {
//            return 16.0
//        }
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let _ = collectionView as? FiltersCollectionView {
            return 16.0
        }
//        if let _ = collectionView as? CategoriesCollectionView  {
//            return 16.0
//        }
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let view = collectionView as? FiltersCollectionView {
            let ratio: CGFloat = 4.0 / 3.0
            let height = view.frame.size.height * 0.9
            let width = height * ratio
            return CGSize(width: width, height: height)
        }
//        if let view = collectionView as? CategoriesCollectionView  {
//            return CGSizeMake(view.frame.size.height * 0.9, view.frame.size.height * 0.9)
//        }
        if collectionView is PreviewCollectionView {
            let l = collectionViewLayout as! UICollectionViewFlowLayout
            var size = collectionView.bounds.size
            size.height = size.height - collectionView.contentInset.top - collectionView.contentInset.bottom - l.sectionInset.top - l.sectionInset.bottom// - 16
            return size
        }
//
        return CGSize.zero
    }
    
}


extension PhotoPreviewViewController: PreviewInterface {

    func setAssetIndex(_ index: Int, animated: Bool = false) {
        model.currentAssetIndex = index
        photoContainerView.scrollToItemWithIndex(model.currentAssetIndex ?? (model.assetsCount - 1), animated: animated)
    }
    
    func reload() {
        self.photoContainerView.alpha = 0.0
        _ = self.photoContainerView.collectionViewLayout.collectionViewContentSize
        self.photoContainerView.scrollToItemWithIndex(model.currentAssetIndex ?? (model.assetsCount - 1), animated: false)
//        photoContainerView.reloadData()
        UIView.animate(withDuration: 0.5, animations: { [weak self] _ in
            self?.photoContainerView.alpha = 1.0
        }) 
    }

}



extension PhotoPreviewViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view {
            return !view.isDescendant(of: filtersCollectionView)
        }
        return true
    }

}

