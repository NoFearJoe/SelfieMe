//
//  CategoriesCollectionView.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 21.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit



class CategoriesCollectionView: UICollectionView {
    
    var data: [UIImage]? {
        didSet {
            reloadData()
        }
    }
    
    var currentIndex: Int = 0

    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    
    fileprivate func initialize() {
        let nib = UINib(nibName: CategoriesCollectionViewCell.identifier, bundle: Bundle.main)
        register(nib, forCellWithReuseIdentifier: CategoriesCollectionViewCell.identifier)
        
        dataSource = self
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
    }
    
}



extension CategoriesCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoriesCollectionViewCell.identifier, for: indexPath) as! CategoriesCollectionViewCell
        
        let img = data?[(indexPath as NSIndexPath).row] ?? UIImage()
        cell.imageView.image = img.withRenderingMode(.alwaysTemplate)
        
        if currentIndex == (indexPath as NSIndexPath).row {
            cell.imageView.tintColor = Theme.mainColor
        } else {
            cell.imageView.tintColor = Theme.tintColor
        }
        
        return cell
    }
    
}
