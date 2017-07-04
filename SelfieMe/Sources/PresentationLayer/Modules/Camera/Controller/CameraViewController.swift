//
//  ViewController.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 17.01.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds
import MessageUI


final class CameraViewController: UIViewController {

    @IBOutlet weak var cameraStreamViewContainer: UIView!
    @IBOutlet weak var cameraStreamView: CameraStreamView!
    @IBOutlet weak var metadataView: MetadataView!
    
    @IBOutlet weak var controlsContainerView: UIView!
    @IBOutlet weak var takePhotoButton: PhotoButton!
    @IBOutlet weak var buttonsContainer: FlexibleView!
    @IBOutlet weak var cameraModeSwitcher: CarouselSwitcher!
    @IBOutlet weak var galleryButton: RotatableButton!
    @IBOutlet weak var settingsButton: RotatableButton!
    
//    private var HDRButton: MultiStateView?
    fileprivate var flashButton: MultiStateView?
    fileprivate var burstButton: MultiStateView?
    fileprivate var facesButton: MultiStateView?
    fileprivate var timerButton: MultiStateView?
    
    var needsConfigureWhenAvailable = false
    var viewAppeared: Bool = false
    var viewConfigured: Bool = false
    
    var takePhotoTimer: Timer?
    
    
    var model = CameraModel()
    
    #if SELFIE_ME
    var adService: AdService!
    #endif
    
    var educationModel: EducationModel?
    var popView: AMPopTip?
    
    var allControls = [UIView?]()
    
    
    fileprivate func requestAutorizations() {
        requestAuthorizationForType(.video) { [weak self] (status) -> Void in
            switch status {
            case .authorized:
                if self?.model.configured == false {
                    self?.model.configure(self!.cameraStreamView.previewLayer)
                    self?.addSessionObservers()
                }
                self?.setPlaceholderVisible(false)
                break
            case .denied: fallthrough
            case .restricted:
                self?.setPlaceholderVisible(true)
                self?.alertToEncourageCameraAccess()
                break
            case .notDetermined:
                self?.setPlaceholderVisible(true)
                break
            }
        }
        
        requestAuthorizationForType(.gallery) { [weak self] (status) -> Void in
            switch status {
            case .authorized:
                self?.galleryButton.isHidden = false
                PhotoLibraryManager.sharedManager.createApplicationAlbum()
                self?.updateGalleryButton()
                break
            case .denied: fallthrough
            case .restricted:
                self?.galleryButton.isHidden = true
                self?.alertToEncourageGalleryAccess()
                break
            case .notDetermined:
                self?.galleryButton.isHidden = true
                break
            }
        }
    }
    
    fileprivate func requestAuthorizationForType(_ type: AuthorizationType, completion: ((AuthorizationStatus) -> Void)?) {
        var authorized = AuthorizationManager.isAuhorizedForType(type)
        if authorized == false {
            AuthorizationManager.requestAuthorizationForType(type, lockableQueue: AppQueues.sessionQueue, completionBlock: { (status) -> Void in
                    authorized = status == AuthorizationStatus.authorized
                    completion?(status)
                })
        } else {
            completion?(.authorized)
        }
    }
    
    fileprivate func alertToEncourageCameraAccess() {
        let alert = AlertViewBuilder.buildEncourageCameraAccessAlertView()
        present(alert, animated: true)
    }
    
    fileprivate func alertToEncourageGalleryAccess() {
        let alert = AlertViewBuilder.buildEncourageGalleryAccessAlertView()
        present(alert, animated: true)
    }
    
    
    fileprivate func configure() {
        DispatchQueue.main.async { [weak self] () -> Void in
            if self != nil && !self!.viewConfigured {
                self!.takePhotoButton.setButtonState(.none)
                self!.configureCaptureResolutionSwitcher()
                self!.configureControls()
                self!.configureStreamView()
                self!.configureMetadataView()
                
                self!.allControls = [/*self!.HDRButton, */self!.flashButton, self!.burstButton, self!.facesButton, self!.timerButton, self!.takePhotoButton, self!.galleryButton, self!.settingsButton, self!.metadataView.anchorView]
                
                self!.educationModel?.start()
                
                self!.viewConfigured = true
                
                #if SELFIE_ME
                self!.adService?.createInterstitial(self!)
                #endif
            }
        }
    }
    
    fileprivate func configureStreamView() {
        self.model.camera.addSessionToPreviewLayer(cameraStreamView.previewLayer)
        model.setVideoOrientation()
        self.setCaptureResolution(CaptureResolutions._3x4, animated: false)
    }
    
    fileprivate func configureCaptureResolutionSwitcher() {
    #if SELFIE_ME
        cameraModeSwitcher.isUserInteractionEnabled = false
    #else
        cameraModeSwitcher.delegate = self
        cameraModeSwitcher.items = CaptureResolutions().names()
        cameraModeSwitcher.build()
    #endif
    }
    
    fileprivate func configureMetadataView() {
        self.metadataView.hideAnchorPoint(false, duration: 0, completion: nil)
        let layer = self.cameraStreamView.previewLayer
        let point = CGPoint(x: layer.frame.midX, y: layer.frame.midY)
        let cameraSreamViewParentView = self.cameraStreamView.superview!
        let relativePoint = FigureConverter.pointToRelativePoint(point, frame: cameraSreamViewParentView.frame)
        self.metadataView.anchorPointChanged = { [weak self] point in
            self?.model.recognizer?.anchor = point
        }
        self.metadataView.anchorPoint = relativePoint
        self.metadataView.showAnchorPoint(true, duration: Animation.defaultDuration, delay: 0.0)
    }
    
    fileprivate func configureControls() {
        buttonsContainer.removeAllSubviews()
        
        let controlsFactory = ControlsFactory.sharedInstance
        
//        if model.cameraStreamManager?.captureDeviceProxy.isPhotoHDRSupported == true {
//            HDRButton = controlsFactory.getControlButton(.HDR, delegate: self)
//            buttonsContainer.addSubview(HDRButton!)
//        }
        if model.camera.hasFlash == true {
            flashButton = controlsFactory.getControlButton(.flash, delegate: self)
            buttonsContainer.addSubview(flashButton!)
        }
        
        burstButton = controlsFactory.getControlButton(.burst, delegate: self)
        buttonsContainer.addSubview(burstButton!)

        facesButton = controlsFactory.getControlButton(.faces, delegate: self)
        buttonsContainer.addSubview(facesButton!)
        
        timerButton = controlsFactory.getControlButton(.timer, delegate: self)
        buttonsContainer.addSubview(timerButton!)
        
        buttonsContainer.layoutSubviews()
    }
    
    
    fileprivate func updateGalleryButton() {
        galleryButton.isEnabled = false
        PhotoLibraryManager.sharedManager.getLastPhotoFromApplicationAlbum(self.galleryButton.frame.size,
            mode: .aspectFill,
            completionBlock: { [weak self] (image) -> Void in
                if let img = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal) {
                    DispatchQueue.main.async(execute: { [weak self] () -> Void in
                        self?.galleryButton.setImage(img, for: UIControlState.normal)
                        self?.galleryButton.isEnabled = true
                    })
                } else {
                    DispatchQueue.main.async(execute: { [weak self] () -> Void in
                        self?.galleryButton.setImage(UIImage(), for: UIControlState.normal)
                        self?.galleryButton.isEnabled = false
                    })
                }
            }
        )
    }
    

    @IBAction func onRecognitionButtonTouched(_ sender: AnyObject) {
        setDetectionInEnabled(!model.detectionInProgress, silently: false, completion: nil)
    }
    
    fileprivate func setDetectionInEnabled(_ enabled: Bool, silently: Bool, completion: (() -> Void)?) {
        func setInterfaceEnabled(_ enabled: Bool) {
            self.galleryButton.isEnabled = enabled
            self.settingsButton.isEnabled = enabled
            self.metadataView.isUserInteractionEnabled = enabled
            
            self.takePhotoButton.setButtonState(enabled ? PhotoButtonState.none : PhotoButtonState.process)
            
            UIApplication.shared.isIdleTimerDisabled = !enabled
        }
        
        if model.detectionInProgress != enabled {
            model.detectionInProgress = enabled
            
            model.toggleDetection(enabled, silently: silently) { _ in
                DispatchQueue.main.async(execute: { _ in
                    if enabled {
                        setInterfaceEnabled(false)
                    } else {
                        setInterfaceEnabled(true)
                    }
                    completion?()
                })
            }
        }
    }
    
    
    func takePhoto() {
        setDetectionInEnabled(false, silently: true) { [weak self] in
            self?.model.disableTakePhotoTimer() { [weak self] in
                self?.model.takePhoto() { [weak self] _ in
                    self?.updateGalleryButton()
                    
                    if ApplicationSettings.openPhotoImmediately() {
                        self?.openPhotoPreviewViewController()
                    }
                }
            }
        }
    }
    
    
    @IBAction func onGalleryButtonTouch(_ sender: UIButton) {
        openPhotoPreviewViewController()
    }
    
    
    @IBAction func onSettingsButtonTouched(_ sender: UIButton) {
        educationModel?.commitAction(EducationAction(id: 3))
        openSettingsViewController()
    }
    
    
    fileprivate func setPlaceholderVisible(_ visible: Bool) {
        DispatchQueue.main.async { [weak self] () -> Void in
            let alreadyContains = self?.cameraStreamViewContainer.subviews.contains(where: { (view) -> Bool in
                return view is LockedCameraView
            }) ?? false
            if visible {
                if self != nil && !alreadyContains {
                    if let nib = Bundle.main.loadNibNamed("LockedCameraView", owner: self, options: nil)?.first {
                        let lockedCameraView = nib as! LockedCameraView
                        lockedCameraView.singleTapClosure = { [weak self] in
                            self!.requestAutorizations()
                        }
                        lockedCameraView.frame = self!.cameraStreamViewContainer.frame
                        self!.cameraStreamViewContainer.addSubview(lockedCameraView)
                        self!.cameraStreamViewContainer.bringSubview(toFront: lockedCameraView)
                    }
                }
            } else {
                if self != nil {
                    for subview in self!.cameraStreamViewContainer.subviews {
                        if subview is LockedCameraView {
                            subview.removeFromSuperview()
                        }
                    }
                }
            }
            
            self?.settingsButton.isHidden = visible
            self?.takePhotoButton.isHidden = visible
        }
    }
    
    
    fileprivate func showEducationPopover(_ text: String, sourceView: UIView, containerView: UIView, arrowDirection: AMPopTipDirection) {
        if popView == nil {
            popView = AMPopTip()
            popView?.actionAnimationIn = Animation.longDuration
            popView?.entranceAnimation = .scale
            popView?.actionAnimation = .float
            popView?.popoverColor = Theme.mainColor
            popView?.textColor = Theme.lightTintColor
            popView?.shouldDismissOnTap = false
            popView?.shouldDismissOnTapOutside = false
            popView?.shouldDismissOnSwipeOutside = false
            popView?.tapHandler = { [weak self] _ in
                self?.educationModel?.commitAction(EducationAction(id: self?.educationModel?.currentIndex ?? 0))
            }
        }
        
        let frame = containerView.convert(sourceView.frame, to: view)
        popView?.showText(text, direction: arrowDirection, maxWidth: 200, in: view, fromFrame: frame)
        
        setControlsEnabled(allControls, enabled: false)
        setControlsHighlighted(allControls, highlighted: false)
        setControlsEnabled([sourceView], enabled: true)
        setControlsHighlighted([sourceView], highlighted: true)
    }
    
    fileprivate func hideEducaionPopover() {
        popView?.hide()
        setControlsEnabled(allControls, enabled: true)
        setControlsHighlighted(allControls, highlighted: false)
    }
    
    
    deinit {
        removeObservers()
    }

}

// MARK: Observing methods

extension CameraViewController {
    
    fileprivate func addApplicationObservers() {
        DispatchQueue.main.async { [weak self] in
            if self != nil {
                self!.addDeviceOrientationObserver()
                
                NotificationCenter.default.addObserver(self!,
                    selector: #selector(CameraViewController.onApplicationWillEnterForeground(_:)),
                    name: NSNotification.Name.UIApplicationWillEnterForeground,
                    object: nil)
                NotificationCenter.default.addObserver(self!,
                    selector: #selector(CameraViewController.onApplicationWillResignActive(_:)),
                    name: NSNotification.Name.UIApplicationWillResignActive,
                    object: nil)
                NotificationCenter.default.addObserver(self!,
                    selector: #selector(CameraViewController.onApplicationDidEnterBackground(_:)),
                    name: NSNotification.Name.UIApplicationDidEnterBackground,
                    object: nil)
                NotificationCenter.default.addObserver(self!,
                    selector: #selector(CameraViewController.onApplicationDidBecomeActive(_:)),
                    name: NSNotification.Name.UIApplicationDidBecomeActive,
                    object: nil)
            }
        }
    }
    
    fileprivate func addSessionObservers() {
        DispatchQueue.main.async { [weak self] in
            if self != nil {
                NotificationCenter.default.addObserver(self!,
                                                                 selector: #selector(CameraViewController.onCaptureSessionRuntimeError(_:)),
                                                                 name: NSNotification.Name.AVCaptureSessionRuntimeError,
                                                                 object: nil)
                NotificationCenter.default.addObserver(self!,
                                                                 selector: #selector(CameraViewController.onCaptureSessionInterruptionEnded(_:)),
                                                                 name: NSNotification.Name.AVCaptureSessionInterruptionEnded,
                                                                 object: nil)
            }
        }
    }
    
    fileprivate func addDeviceOrientationObserver() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(CameraViewController.onDeviceOrientationChanged(_:)),
            name: NSNotification.Name(rawValue: DeviceOrientationDidChangeNotificationKey),
            object: nil)
    }
    
    fileprivate func removeDeviceOrientationObserver() {
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name(rawValue: DeviceOrientationDidChangeNotificationKey),
            object: nil)
    }
    
    fileprivate func removeSessionObservers() {
        NotificationCenter.default.removeObserver(self,
                                                            name: NSNotification.Name.AVCaptureSessionRuntimeError,
                                                            object: nil)
        NotificationCenter.default.removeObserver(self,
                                                            name: NSNotification.Name.AVCaptureSessionInterruptionEnded,
                                                            object: nil)
    }
    
    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func onDeviceOrientationChanged(_ notification: Notification) {
        model.setVideoOrientation()
    }
    
    func onApplicationWillEnterForeground(_ notification: Notification) {
        addDeviceOrientationObserver()
    }
    
    func onApplicationWillResignActive(_ notification: Notification) {
        removeDeviceOrientationObserver()
    }
    
    func onApplicationDidEnterBackground(_ notification: Notification) {
        removeDeviceOrientationObserver()
        setDetectionInEnabled(false, silently: false, completion: nil)
    }
    
    func onApplicationDidBecomeActive(_ notification: Notification) {
        addDeviceOrientationObserver()
        updateGalleryButton()
    }
    
    
    func onCaptureSessionRuntimeError(_ notification: Notification) {
        if let error = (notification as NSNotification).userInfo?[AVCaptureSessionErrorKey] as? NSError {
            if (error.code == AVError.Code.mediaServicesWereReset.rawValue) {
                removeSessionObservers()
                model.restartSession()
            }
        }
    }
    
    func onCaptureSessionInterruptionEnded(_ notification: Notification) {
        removeSessionObservers()
        model.restartSession()
        setPlaceholderVisible(false)
    }

}

// MARK: UIViewController methods

extension CameraViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if SELFIE_ME
        adService = AdService(delegate: self)
        #endif
            
        if !ApplicationSettings.isEducationPresented() {
            self.educationModel = EducationModel()
            self.educationModel?.dataSource = self
        }
        
        #if SELFIE_ME
        IKTrackerPool.sharedInstance[Trackers.adTracker]?.checkpoint = { [weak self] _ in
            self?.adService.showAd(self!)
        }
        #endif
            
        addApplicationObservers()
        
        self.setCaptureResolution(CaptureResolutions._3x4, animated: false)
        
        self.takePhotoButton.setButtonState(PhotoButtonState.disabled)
        
        model.camera.running?.asObservable().subscribe(onNext: { [weak self] (running) in
            if let appeared = self?.viewAppeared, let running = running , running && appeared {
                self?.configure()
            } else {
                self?.needsConfigureWhenAvailable = true
            }
        }).dispose()
        
        model.camera.capturing?.asObservable().subscribe(onNext: { [weak self] (capturing) in
            if let capturing = capturing {
                self?.setCapturing(capturing)
                if !capturing {
                    self?.educationModel?.commitAction(EducationAction(id: 2))
                }
            }
        }).dispose()
        
        self.model.performPhotoBlock = { [weak self] _ in
            self?.takePhoto()
        }
        
        galleryButton.imageView?.contentMode = .scaleAspectFill
        
        requestAutorizations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Analytics.instance.send(AnalyticsCategory.Camera, action: AnalyticsAction.Open, label: AnalyticsLabel.None, value: 0)
        
        DeviceOrientationRecognizer.sharedInstance.postCurrentDeviceOrientation()
        
        self.settingsButton.setImageViewTintColor(Theme.tintColor)
        self.updateGalleryButton()
        
        if self.needsConfigureWhenAvailable {
            configure()
            self.needsConfigureWhenAvailable = false
        }
        viewAppeared = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        #if SELFIE_ME
        if !ApplicationSettings.adAnswerRecieved() {
            self.adService?.showDisableAdsDialog(self)
        }
        #endif
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(
            alongsideTransition: { [weak self] (context) -> Void in
                self?.model.setVideoOrientation()
                self?.setCaptureResolution(CameraSettings.settings.cameraMode, animated: false)
            })
            { (context) -> Void in
                
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait //Device.iPad ? UIInterfaceOrientationMask.All : UIInterfaceOrientationMask.Portrait
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
}

// MARK: Camera managing methods

extension CameraViewController {
    
    fileprivate func setCaptureResolution(_ mode: CaptureResolution, animated: Bool) {
        if mode == CaptureResolutions._undefined {
            setPlaceholderVisible(true)
        } else {
            model.setCaptureResolution(mode)
            
            let viewRect = cameraStreamView.superview!.frame
            let ratio = mode.getRatioRelativeToRect(viewRect)
            let targetRect = FrameAdapter.adaptedFrame(CGRect.zero, inContainer: viewRect, withTargetRatio: CGFloat(ratio), center: true)
            
            self.metadataView.hideAnchorPoint(false, duration: Animation.shortDuration) { [weak self] _ in
                if animated {
                    UIView.animate(withDuration: animated ? Animation.defaultDuration : 0,
                        animations: { [weak self] () -> Void in
                            self?.cameraStreamView.frame = targetRect
                            self?.metadataView.frame = targetRect
                        },
                        completion: { [weak self] (success) -> Void in
                            if let anchor = self?.metadataView?.anchorPoint {
                                self?.metadataView.anchorPoint = anchor
                                self?.metadataView.showAnchorPoint(animated, duration: Animation.shortDuration, delay: 0)
                            }
                        }
                    )
                } else {
                    self?.cameraStreamView.frame = targetRect
                    self?.metadataView.frame = targetRect
                    if let anchor = self?.metadataView?.anchorPoint {
                        self?.metadataView.anchorPoint = anchor
                        self?.metadataView.showAnchorPoint(animated, duration: Animation.shortDuration, delay: 0)
                    }
                }
            }
        }
    }

}



// MARK: Gestures methods

extension CameraViewController {
    
    @IBAction func onLeftSwipe(_ sender: AnyObject) {
        cameraModeSwitcher.switchToNextItem()
    }
    
    @IBAction func onRightSwipe(_ sender: AnyObject) {
        cameraModeSwitcher.switchToPreviousItem()
    }
    
    @IBAction func onSingleTap(_ sender: UITapGestureRecognizer) {
        if let v = sender.view {
            let point = sender.location(in: v)
            let relativePoint = FigureConverter.pointToRelativePoint(point, frame: v.frame)
            metadataView.hideAnchorPoint(true, duration: Animation.shortDuration) { [weak self] _ in
                self?.metadataView.anchorPoint = relativePoint
            }
            self.metadataView.showAnchorPoint(true, duration: Animation.shortDuration, delay: Animation.shortDuration)
            
            educationModel?.commitAction(EducationAction(id: 0))
        }
    }
    
    @IBAction func onPan(_ sender: UIPanGestureRecognizer) {
        if let v = sender.view {
            let velocity = sender.velocity(in: v)
            if !velocity.x.isNaN && !velocity.y.isNaN {
                let viewPoint = FigureConverter.pointToViewPoint(metadataView.anchorPoint ?? CGPoint.zero, frame: v.frame)
                let point = CGPoint(x: velocity.x / 65.0 + viewPoint.x, y: velocity.y / 65.0 + viewPoint.y)
                let relativePoint = FigureConverter.pointToRelativePoint(point, frame: v.frame)
                metadataView.anchorPoint = relativePoint
                metadataView.showAnchorPoint()
                metadataView.gridView.drawGrid = true
                
                if sender.state == .ended {
                    educationModel?.commitAction(EducationAction(id: 0))
                }
            }
        }
    }
    
}

// MARK: Routing

extension CameraViewController {
    

    fileprivate func openPhotoPreviewViewController() {
        DispatchQueue.main.async { [weak self] () -> Void in
            let controller = PhotoPreviewAssembly.createModule(self)
            self?.navigationController?.present(controller, animated: true, completion: nil)
        }
    }
    
    fileprivate func openSettingsViewController() {
        DispatchQueue.main.async { [weak self] () -> Void in
            self?.performSegue(withIdentifier: SegueIdentifiers.navigationControllerSettingsControllerSegueIdentifier, sender: self!)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == SegueIdentifiers.navigationControllerSettingsControllerSegueIdentifier {
            let navController = segue.destination as! UINavigationController
            let controller = StoryboardManager.manager.settingsViewController()
            controller.closeDelegate = self
            navController.setViewControllers([controller], animated: true)
        }
    }
    
}


extension CameraViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer, let anchorView = metadataView.anchorView {
            let location = pan.location(in: metadataView)
            return anchorView.containsPoint(location)
        }
        
        return true
    }

}

extension CameraViewController {

    func setCapturing(_ capturing: Bool) {
        DispatchQueue.main.async { [weak self] () -> Void in
            if capturing {
                self?.takePhotoButton.setButtonState(PhotoButtonState.blocked)
            } else {
                self?.takePhotoButton.setButtonState(PhotoButtonState.none)
            }
        }
    }

}


extension CameraViewController: CarouselSwitcherDelegate {
    
    func carouselSwitcher(_ switcher: CarouselSwitcher, willChangeItemIndex index: UInt) {
//        takePhotoButton.setButtonState(PhotoButtonState.Blocked)
        setCaptureResolution(CaptureResolutions()[Int(index + 1)], animated: true)
    }
    
    func carouselSwitcher(_ switcher: CarouselSwitcher, didChangeItemIndex index: UInt) {
//        setDetectionInProgress(false, completion: nil)
    }
    
}


extension CameraViewController: MultiStateViewDelegate {

    func multiStateView(_ view: MultiStateView, stateChangedToIndex index: Int) {
        switch view.tag {
        case ControlButtonType.hdr.rawValue:
            let state = SettingState(rawValue: index) ?? SettingState.off
            model.setHDRState(state)
            
            let button = ControlsFactory.sharedInstance.getControlButton(.flash, delegate: self)

            if state == .on {
                button.setState(0)
            } else if state == .auto {
                if button.currentIndex == 1 {
                    button.setState(2)
                }
            }
            
            break
        case ControlButtonType.flash.rawValue:
            var state = SettingState.off
//            if CameraSettings.settings.hdrState == .Off {
                state = SettingState(rawValue: index) ?? SettingState.off
//            } else if CameraSettings.settings.hdrState == .Auto {
//                switch CameraSettings.settings.flashState! {
//                case .Auto:
//                    state = SettingState.Off
//                    break
//                case .Off:
//                    state = SettingState.Auto
//                    break
//                case .On:
//                    state = SettingState.Off
//                    break
//                }
//            }
            model.setFlashState(state)
            let button = ControlsFactory.sharedInstance.getControlButton(.flash, delegate: self)
            button.setState(state.rawValue)
            
            Analytics.instance.send(AnalyticsCategory.Camera, action: AnalyticsAction.Tap, label: AnalyticsLabel.Flash, value: state.rawValue as NSNumber)
            break
        case ControlButtonType.burst.rawValue:
            model.setBurstMode(SettingBurstMode(index: index))
        case ControlButtonType.torch.rawValue:
            let state = SettingState(rawValue: index) ?? SettingState.off
            model.setTorchState(state)
            Analytics.instance.send(AnalyticsCategory.Camera, action: AnalyticsAction.Tap, label: AnalyticsLabel.Burst, value: state.rawValue as NSNumber)
            break
        case ControlButtonType.faces.rawValue:
            let state = SettingFacesState(index: index)
            model.setFacesState(state)
            educationModel?.commitAction(EducationAction(id: 1))
            Analytics.instance.send(AnalyticsCategory.Camera, action: AnalyticsAction.Tap, label: AnalyticsLabel.Faces, value: state.rawValue as NSNumber)
            break
        case ControlButtonType.timer.rawValue:
            let state = SettingTimerState(index: index)
            model.setTimerState(state)
            Analytics.instance.send(AnalyticsCategory.Camera, action: AnalyticsAction.Tap, label: AnalyticsLabel.Timer, value: state.rawValue as NSNumber)
            break
        case ControlButtonType.livePhoto.rawValue: break
        default: break
        }
    }

}


extension CameraViewController: CloseDelegate {
    
    func onClose(_ sender: AnyObject) {
        updateGalleryButton()
        setNeedsStatusBarAppearanceUpdate()
        view.setNeedsLayout()
        view.layoutSubviews()
        setCaptureResolution(CameraSettings.settings.cameraMode, animated: false)
    }
    
}


extension CameraViewController: EducationModelDataSource {

    func educationModelNumberOfStages(_ model: EducationModel) -> Int {
        return 4
    }
    
    func educationModel(_ model: EducationModel, stageForIndex index: Int) -> EducationStage? {
        switch index {
        case 0: return EducationStage(message: localized("EDUCATION_STAGE_0"), sourceView: metadataView.anchorView, containerView: metadataView, arrowDirection: .up)
        case 1: return EducationStage(message: localized("EDUCATION_STAGE_1"), sourceView: facesButton!, containerView: buttonsContainer, arrowDirection: Device.iPad ? .up : .down)
        case 2: return EducationStage(message: localized("EDUCATION_STAGE_2"), sourceView: takePhotoButton, containerView: controlsContainerView, arrowDirection: .up)
        case 3: return EducationStage(message: localized("EDUCATION_STAGE_3"), sourceView: settingsButton, containerView: controlsContainerView, arrowDirection: .up)
        default: return nil
        }
    }
    
    func educationModel(_ model: EducationModel, actionForSegueForStageIndex index: Int) -> EducationAction? {
        switch index {
        case 0: return EducationAction(id: 0)
        case 1: return EducationAction(id: 1)
        case 2: return EducationAction(id: 2)
        case 3: return EducationAction(id: 3)
        default: return nil
        }
    }
    
    func educationModel(_ model: EducationModel, stageChanged stage: EducationStage) {
        self.showEducationPopover(stage.message,
                                  sourceView: stage.sourceView,
                                  containerView: stage.containerView,
                                  arrowDirection: stage.arrowDirection)
    }
    
    
    func educationModel(_ model: EducationModel, educationEnded ended: Bool) {
        if ended {
            educationModel?.dataSource = nil
            educationModel = nil
            hideEducaionPopover()
            ApplicationSettings.setEducationPresented(true)
        }
    }

}


extension CameraViewController: GADInterstitialDelegate {
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial!) {
        self.onClose(ad)
        #if SELFIE_ME
        self.adService.createInterstitial(self)
        #endif
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial!) {
        #if SELFIE_ME
//        if ApplicationSettings.currentAdNumber() > 1 {
            self.adService?.showDisableAdsDialog(self)
//        }
        #endif
    }

}
