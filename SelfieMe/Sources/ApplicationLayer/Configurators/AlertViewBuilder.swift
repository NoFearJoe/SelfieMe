//
//  AlertViewBuilder.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 16.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import MessageUI



enum DisableAdsAnswer {
//    case TellFriends
//    case Rate
    case buyPlusVersion
    case notNow
}



final class AlertViewBuilder {

    class func buildEncourageCameraAccessAlertView() -> UIAlertController {
        let alert = UIAlertController(
            title: localized("ALERT_WARNING"),
            message: localized("ALERT_MESSAGE_CAMERA_ACCESS_REQUIRED"),
            preferredStyle: Device.iPad ? UIAlertControllerStyle.alert : .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: localized("ALERT_ANSWER_ALLOW"), style: .default, handler: { (alert) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        alert.addAction(UIAlertAction(title: localized("ALERT_ANSWER_DENY"), style: .destructive, handler: nil))
        
        return alert
    }
    
    class func buildEncourageGalleryAccessAlertView() -> UIAlertController {
        let alert = UIAlertController(
            title: localized("ALERT_WARNING"),
            message: localized("ALERT_MESSAGE_GALLERY_ACCESS_REQUIRED"),
            preferredStyle: Device.iPad ? UIAlertControllerStyle.alert : .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: localized("ALERT_ANSWER_ALLOW"), style: .default, handler: { (alert) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        alert.addAction(UIAlertAction(title: localized("ALERT_ANSWER_DENY"), style: .destructive, handler: nil))
        
        return alert
    }
    
    
    
    class func buildShareViewController(_ sourceView: UIView) -> UIActivityViewController {
        let message = localized("SHARE_MESSAGE") + "\niOS: http://goo.gl/eQFjwh" + "\nAndroid: https://goo.gl/9uUVZE"
        let controller = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        controller.excludedActivityTypes = [UIActivityType.print, UIActivityType.assignToContact, UIActivityType.saveToCameraRoll, UIActivityType.addToReadingList]
        controller.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        controller.popoverPresentationController?.sourceView = sourceView
        controller.popoverPresentationController?.sourceRect = CGRect(x: sourceView.frame.midX, y: sourceView.frame.midY, width: 0, height: 0)
        return controller
    }
    
    
    class func buildSMSViewController(_ delegate: MFMessageComposeViewControllerDelegate?) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        if MFMessageComposeViewController.canSendText() {
            controller.body = localized("SHARE_MESSAGE") + "\niOS: http://goo.gl/eQFjwh" + "\nAndroid: https://goo.gl/9uUVZE"
            controller.disableUserAttachments()
            controller.messageComposeDelegate = delegate
        }
        return controller
    }
    
    
    class func buildRateAlertController(_ completion: boolClosure?) -> UIAlertController {
        let alert = UIAlertController(
            title: localized("ALERT_RATE"),
            message: localized("ALERT_MESSAGE_RATE"),
            preferredStyle: UIAlertControllerStyle.alert
        )
    
        alert.addAction(
            UIAlertAction(title: localized("ALERT_ANSWER_RATE"),
                style: .default,
                handler: { (alert) in
                    completion?(true)
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id" + Strings.appID) {
                        URLHelper.openURL(url)
                    }
            })
        )
        
        alert.addAction(
            UIAlertAction(title: localized("ALERT_ANSWER_NOT_NOW"),
                style: .destructive,
                handler: { (alert) in
                    completion?(false)
            })
        )
    
        return alert
    }
    
    
    class func buildAdAlertController(_ completion: boolClosure?) -> UIAlertController {
        let currentAdNumber = ApplicationSettings.currentAdNumber()
        
        let alert = UIAlertController(
            title: localized("PR_TITLE"),
            message: localized("PR_MESSAGE_\(currentAdNumber)"),
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        alert.addAction(
            UIAlertAction(title: localized("PR_ANSWER_NO"),
                style: .destructive,
                handler: { (alert) in
                    completion?(false)
            })
        )
        
        alert.addAction(
            UIAlertAction(title: localized("PR_ANSWER_OK"),
                style: .default,
                handler: { (alert) in
                    completion?(true)
            })
        )
        
        return alert
    }
    
    
    class func buildDisableAdAlertController(_ answer: ((DisableAdsAnswer) -> ())?) -> UIAlertController {
        let alert = UIAlertController(
            title: "SelfieMe+",//localized("PR_DISABLE_TITLE"),
            message: localized("PR_DISABLE_MESSAGE"),
            preferredStyle: UIAlertControllerStyle.alert
        )
        
//        alert.addAction(
//            UIAlertAction(title: localized("PR_DISABLE_ANSWER_SHARE"),
//                style: .Default,
//                handler: { (alert) in
//                    answer?(DisableAdsAnswer.TellFriends)
//            })
//        )
//        alert.addAction(
//            UIAlertAction(title: localized("PR_DISABLE_ANSWER_RATE"),
//                style: .Default,
//                handler: { (alert) in
//                    answer?(DisableAdsAnswer.Rate)
//            })
//        )
        alert.addAction(
            UIAlertAction(title: localized("PR_DISABLE_ANSWER_BUY_PLUS_VERSION"),
                style: .default,
                handler: { (alert) in
                    answer?(DisableAdsAnswer.buyPlusVersion)
            })
        )
        alert.addAction(
            UIAlertAction(title: localized("PR_DISABLE_ANSWER_NOT_NOW"),
                style: .destructive,
                handler: { (alert) in
                    answer?(DisableAdsAnswer.notNow)
            })
        )
        
        return alert
    }
    
    
    
    
    class func buildEducationPopoverViewController(_ text: String, sourceView: UIView, containerView: UIView) -> EducationPopoverViewController {
        let educationController = StoryboardManager.manager.educationPopoverController()
        educationController.text = text
        var size = AlertViewBuilder.labelHeight(text, font: UIFont.systemFont(ofSize: 12), width: 200)
        size.height += 8 * (size.height / 12)
        educationController.preferredContentSize = size
        educationController.containerView = containerView
        educationController.sourceView = sourceView
        var rect = CGRect(x: size.width / 2.0, y: 0, width: 0, height: 0)
        if sourceView.frame.origin.y <= size.height {
            rect.origin.y = size.height + 16
        } else {
            rect.origin.y = -16 - size.height
        }
        educationController.sourceRect = rect
        
        return educationController
    }
    
    
    
    class func buildMessageViewController(_ delegate: MFMailComposeViewControllerDelegate) -> MFMailComposeViewController? {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = delegate
            controller.setToRecipients([Strings.mail])
            controller.setSubject("")
            controller.setMessageBody("", isHTML: false)
            
            return controller
        } else {
            if let URL = URL(string: Strings.mail) {
                URLHelper.openURL(URL)
            }
        }
        return nil
    }
    
    
    class func buildHelpMessageAlertController(_ message: String) -> UIAlertController {
        let alert = UIAlertController(
            title: localized("HELP_TITLE"),
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        alert.addAction(
            UIAlertAction(title: "Ok",
                style: .cancel,
                handler: nil)
        )
        
        return alert
    }
    
    
    
    
    fileprivate class func labelHeight(_ text: String, font: UIFont, width: CGFloat) -> CGSize {
        let context = NSStringDrawingContext()
        let initialSize = CGSize(width: width, height: 60)
        let rect = (text as NSString).boundingRect(with: initialSize,
                                                           options: .usesLineFragmentOrigin,
                                                           attributes: [NSFontAttributeName: font],
                                                           context: context)
        return rect.size
    }
    
    

}
