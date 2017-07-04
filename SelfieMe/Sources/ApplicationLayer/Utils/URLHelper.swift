//
//  URLHelper.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 24.05.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation




class URLHelper {
    
    class func openURL(_ URL: Foundation.URL) {
        if UIApplication.shared.canOpenURL(URL) {
            UIApplication.shared.openURL(URL)
        }
    }
    
}
