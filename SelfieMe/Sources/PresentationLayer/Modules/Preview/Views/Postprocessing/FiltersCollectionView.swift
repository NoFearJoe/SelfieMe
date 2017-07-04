//
//  FiltersCollectionView.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 11.02.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import GPUImage


final class FiltersCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    
    fileprivate func initialize() {
        let nib = UINib(nibName: "FiltersCollectionViewCell", bundle: Bundle.main)
        register(nib, forCellWithReuseIdentifier: "filtersCollectionViewCellIdentifier")
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
    }
    
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
}
