//
//  AdService.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 26.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import GoogleMobileAds
import MessageUI


final class AdService: NSObject {

    fileprivate var interstitial: GADInterstitial?
    
    
    init(delegate: GADInterstitialDelegate) {
        super.init()
        createInterstitial(delegate)
    }
    
    
    func createInterstitial(_ delegate: GADInterstitialDelegate) {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-8949731993528836/1663010705")
        interstitial?.delegate = delegate
        self.loadInterstitialRequest()
    }
    
    func destroyInterstitial() {
        interstitial = nil
    }
    
    fileprivate func loadInterstitialRequest() {
        let request = GADRequest()
    #if DEBUG
        request.testDevices = [kGADSimulatorID, "7c9eb69260697609507db263ab41ab1a", "8870fbeb24946d4d23ef55ba6d8e6be0"]
    #endif
        interstitial?.load(request)
    }
    
    func showAd(_ viewController: UIViewController) {
        DispatchQueue.main.async { [weak self] () -> Void in
            if self?.interstitial?.isReady == true {
                ApplicationSettings.setCurrentAdNumber(ApplicationSettings.currentAdNumber() + 1)
                self?.interstitial?.present(fromRootViewController: viewController)
            }
        }
    }
    
    
    func showDisableAdsDialog(_ viewController: CameraViewController) {
        let alert = AlertViewBuilder.buildDisableAdAlertController { [weak self] (answer) in
            ApplicationSettings.setAdAnswerRecieved(true)
            switch answer {
//            case .TellFriends:
//                if let view = viewController.view {
//                    if Device.iPad {
//                        IKTrackerPool.sharedInstance[Trackers.adTracker]?.disable()
//                        self?.destroyInterstitial()
//                        let controller = AlertViewBuilder.buildShareViewController(view)
//                        viewController.presentViewController(controller, animated: true)
//                    } else {
//                        let controller = AlertViewBuilder.buildSMSViewController(self)
//                        viewController.presentViewController(controller, animated: true)
//                    }
//                }
//                Analytics.instance.send(AnalyticsCategory.Ads, action: AnalyticsAction.Answer, label: AnalyticsLabel.Message, value: 0)
//                break
//            case .Rate:
//                if let url = NSURL(string: "itms-apps://itunes.apple.com/app/id" + "1126247967") {
//                    IKTrackerPool.sharedInstance[Trackers.adTracker]?.disable()
//                    ApplicationSettings.setRated(true)
//                    self?.destroyInterstitial()
//                    URLHelper.openURL(url)
//                }
//                Analytics.instance.send(AnalyticsCategory.Ads, action: AnalyticsAction.Answer, label: AnalyticsLabel.Rate, value: 0)
//                break
            case .buyPlusVersion:
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id" + Strings.otherAppID) {
//                    IKTrackerPool.sharedInstance[Trackers.adTracker]?.disable()
//                    ApplicationSettings.setRated(true)
//                    self?.destroyInterstitial()
                    self?.createInterstitial(viewController)
                    URLHelper.openURL(url)
                }
                Analytics.instance.send(AnalyticsCategory.Ads, action: AnalyticsAction.Answer, label: AnalyticsLabel.Rate, value: 0)
                break
            case .notNow:
                self?.createInterstitial(viewController)
                Analytics.instance.send(AnalyticsCategory.Ads, action: AnalyticsAction.Answer, label: AnalyticsLabel.NotNow, value: 0)
                break
            }
        }
        ApplicationSettings.setAdAnswerRecieved(false)
        viewController.present(alert, animated: true)
    }

}


extension AdService: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if result == MessageComposeResult.sent {
            IKTrackerPool.sharedInstance[Trackers.adTracker]?.disable()
            destroyInterstitial()
            controller.dismiss(animated: true, completion: nil)
        }
        if result == MessageComposeResult.cancelled {
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
}
