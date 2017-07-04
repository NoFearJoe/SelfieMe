
//  AppDelegate.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 17.01.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var applicationRoutingManager: ApplicationRoutingManager!

    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        _ = Analytics.instance
        
        if let rootViewController = window?.rootViewController as? ApplicationRootViewController {
            applicationRoutingManager = ApplicationRoutingManager(applicationRootViewController: rootViewController)
        }
        
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        DeviceOrientationRecognizer.sharedInstance.startRecognition()
        
        initTrackers()
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let controller = window?.rootViewController {
            if let previewController = controller.presentedViewController as? PreviewNavigationController {
                if previewController.visible {
                    return .all
                }
            }
        }
        return .portrait
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }
    

    func applicationWillTerminate(_ application: UIApplication) {

    }
    
    
    fileprivate func initTrackers() {
        let _ = IKTracker(key: Trackers.adTracker, condition: IKTrackerCondition.every(2))
    }

}

