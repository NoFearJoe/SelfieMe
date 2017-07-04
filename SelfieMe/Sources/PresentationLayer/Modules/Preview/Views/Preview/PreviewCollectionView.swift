//
//  PreviewCollectionView.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 20.06.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit



final class PreviewCollectionView: UICollectionView {

    var currentItemNumber: Int {
        let offset = self.contentOffset.x
        let width = bounds.size.width
        return Int(max(0, min(CGFloat(dataSource?.collectionView(self, numberOfItemsInSection: 0) ?? 0), offset / width)))
    }
    
    
    
    func scrollToItemWithIndex(_ index: Int, animated: Bool) {
        var i = index
        if index < 0 {
            i = 0
        }
        if let count = dataSource?.collectionView(self, numberOfItemsInSection: 0) , index >= count {
            i = count - 1
        }

        let targetOffsetX = CGFloat(i) * bounds.size.width
        
        setContentOffset(CGPoint(x: targetOffsetX, y: contentOffset.y), animated: animated)
    }

}
