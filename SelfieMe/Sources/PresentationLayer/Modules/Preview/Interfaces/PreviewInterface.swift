//
//  PreviewInterface.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 20.06.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation


protocol PreviewInterface {
    func setAssetIndex(_ index: Int, animated: Bool)
    func reload()
}
