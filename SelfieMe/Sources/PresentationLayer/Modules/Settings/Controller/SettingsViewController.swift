//
//  SettingsViewController.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 12.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import MessageUI


class SettingsViewController: UIViewController {
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    
    var closeDelegate: CloseDelegate?
    
    
    var model: SettingsModel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let pathToBundle = Bundle.main.path(forResource: "Settings", ofType: "bundle"),
           let path = Bundle(path: pathToBundle)?.path(forResource: "Root", ofType: "plist") {
            model = SettingsModel(plistURL: URL(fileURLWithPath: path),
                                  onShare: { self.share() },
                                  onRate: { self.rate() },
                                  onBuy: { self.buy() },
                                  onTwitter: { self.twitter() },
                                  onMail: { self.mail() }
            )
        } else {
            model = SettingsModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = localized("SETTINGS_TITLE")
        
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Analytics.instance.send(AnalyticsCategory.Settings, action: AnalyticsAction.Open, label: AnalyticsLabel.None, value: 0)
        
        settingsTableView.reloadData()
        
        view.backgroundColor = Theme.backgroundColor
        settingsTableView.backgroundColor = Theme.backgroundColor
        settingsTableView.separatorColor = Theme.thirdlyTintColor
        
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true //navigationController?.prefersStatusBarHidden() ?? true
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
        
        coordinator.animate(alongsideTransition: { (context) in
            
        }) { (context) in
            
        }
    }
    
    
    
    fileprivate func configureNavigationBar() {
        let spacer1 = buildSpacer(-11)
        let closeButton = buildCloseButton()
        
        navigationItem.setLeftBarButtonItems([spacer1, closeButton], animated: true)
//        navigationItem.setRightBarButtonItems([saveButton], animated: true)
    }
    
    fileprivate func buildSpacer(_ width: CGFloat) -> UIBarButtonItem {
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = width
        return spacer
    }
    
    fileprivate func buildCloseButton() -> BarButton {
        let image = UIImage(named: "closeButtonImage")!
        let button = BarButton(image: image, target: self, action: #selector(SettingsViewController.onClose(_:)))
        button.width = 44.0
        return button
    }
    
    
    @IBAction func onClose(_ sender: AnyObject) {
        let delegate = closeDelegate
        
        if let navController = navigationController {
            navController.dismiss(animated: true, completion: {
                delegate?.onClose(self)
            })
        } else {
            self.dismiss(animated: true, completion: {
                delegate?.onClose(self)
            })
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.settingsPickerTableViewControllerSegueIdentifier {
            let item = (sender as! SettingsMultipleItem)
            let items = item.items
//            let titles = Array(items.keys).map() { localized("\($0)") }
            let controller = segue.destination as! SettingsPickerViewController
            controller.title = item.title
            let model = SettingsPickerModel(items: Array(items.values))
            controller.model = model
            controller.didSelectItem = { [weak self] (i) -> () in
                if let action = i.action {
                    action()
                } else {
                    ApplicationSettings.setValue(i.text as AnyObject, forKey: item.variable)
                }
                self?.settingsTableView.reloadData()
            }
        }
    }
    
    
    fileprivate func share() {
        let controller = AlertViewBuilder.buildShareViewController(self.view)
        DispatchQueue.main.async { [weak self] _ in
            self?.present(controller, animated: true, completion: nil)
        }
    }
    
    fileprivate func rate() {
        let controller = AlertViewBuilder.buildRateAlertController({ (success) in
            if success {
                ApplicationSettings.setRated(true)
            }
        })
        DispatchQueue.main.async { [weak self] _ in
            self?.present(controller, animated: true, completion: nil)
        }
    }
    
    fileprivate func buy() {
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
    }
    
    fileprivate func twitter() {
        if let URL = URL(string: Strings.twitter) {
            URLHelper.openURL(URL)
        }
    }
    
    fileprivate func mail() {
        if let controller = AlertViewBuilder.buildMessageViewController(self) {
            DispatchQueue.main.async { [weak self] _ in
                self?.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    
    
    fileprivate func showHelpMessage(_ message: String) {
        DispatchQueue.main.async { [weak self] _ in
            let alert = AlertViewBuilder.buildHelpMessageAlertController(message)
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
}



extension SettingsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.sections[section].items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.sections[section].title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.sections[section].subtitle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SettingsCell!
        
        let item = model.sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        
        if item is SettingsButtonItem {
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsButtonCell") as! SettingsButtonCell
        } else if item is SettingsToggleItem {
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsToggleCell") as! SettingsToggleCell
            (cell as! SettingsToggleCell).onToggleBlock = { (on) -> () in
                let key = (item as! SettingsToggleItem).variable
                ApplicationSettings.setValue(on as AnyObject, forKey: key)
                (item as! SettingsToggleItem).enabled = on
            }
        } else if item is SettingsMultipleItem {
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsMultipleCell") as! SettingsMultipleCell
        } else {
            cell = SettingsCell()
        }
        
        cell.selectionStyle = item.touchable ? .gray : .none
        
        cell.settingsItem = item
        
        return cell
    }

}


extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = model.sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        
        if item is SettingsButtonItem {
            (item as! SettingsButtonItem).action?()
        } else if item is SettingsToggleItem {
            
        } else if item is SettingsMultipleItem {
            performSegue(withIdentifier: SegueIdentifiers.settingsPickerTableViewControllerSegueIdentifier, sender: item)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let item = model.sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        
        if item.touchable {
            return indexPath
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Theme.thirdlyBackgroundColor
        cell.tintColor = Theme.tintColor
        
        #if SELFIE_ME
            if indexPath.section == 1 {
                (cell as? SettingsButtonCell)?.titleLabel.textColor = Theme.buyButtonTextColor
                let font = UIFont.boldSystemFont(ofSize: (cell as? SettingsButtonCell)?.titleLabel.font.pointSize ?? 12)
                (cell as? SettingsButtonCell)?.titleLabel.font = font
                cell.backgroundColor = Theme.buyButtonBackgroundColor
            } else {
                (cell as? SettingsButtonCell)?.titleLabel.textColor = Theme.mainColor
            }
        #else
            (cell as? SettingsButtonCell)?.titleLabel.textColor = Theme.mainColor
        #endif
    }
    
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let item = model.sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row] as? SettingsToggleItem {
            Analytics.instance.send(AnalyticsCategory.Settings, action: AnalyticsAction.Setup, label: item.title, value: 0)
            
            if let help = item.help {
                showHelpMessage(localized(help))
            }
        }
    }

}



extension SettingsViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}

