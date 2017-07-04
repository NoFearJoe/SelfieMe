//
//  EducationContentViewController.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 28.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


final class EducationContentViewController: UIViewController {
    
    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    
    
    var data: (index: Int, text: String, deviceImage: UIImage, isLast: Bool)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if data != nil && data!.isLast == false {
            deviceImageView.image = data?.deviceImage
        }
        textView.text = data?.text
        
        finishButton.isHidden = !(data?.isLast ?? false)
    }
    
    
    @IBAction func onFinish(_ sender: AnyObject) {
        (UIApplication.shared.delegate as! AppDelegate).applicationRoutingManager.showCameraViewController(true)
    }
    
}
