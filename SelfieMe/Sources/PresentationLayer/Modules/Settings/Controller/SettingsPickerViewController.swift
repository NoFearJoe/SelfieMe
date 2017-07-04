//
//  SettingsPickerViewController.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 14.04.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


class SettingsPickerViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var model: SettingsPickerModel?
    
    var didSelectItem: ((SettingsPickerItem) -> ())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        view.backgroundColor = Theme.backgroundColor
        tableView.backgroundColor = Theme.backgroundColor
        tableView.separatorColor = Theme.thirdlyTintColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setToolbarHidden(false, animated: true)
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
    
}



extension SettingsPickerViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model != nil ? 1 : 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsPickerViewCell", for: indexPath)
        
        if let item = model?[(indexPath as NSIndexPath).row] {
            cell.textLabel?.text = item.text
            cell.detailTextLabel?.text = item.detail
        }
        
        return cell
    }
    
}


extension SettingsPickerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = model?[(indexPath as NSIndexPath).row] {
            didSelectItem?(item)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Theme.thirdlyBackgroundColor
        cell.textLabel?.textColor = Theme.tintColor
        cell.detailTextLabel?.textColor = Theme.thirdlyTintColor
    }

}
