//
//  FiltersProvider.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 30.07.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit
import GPUImage


final class FiltersProvider: NSObject {
    
    static let image = UIImage(named: "filterTemplateImage")
    
    var currentIndex: Int = 0
    
    let operationQueue = OperationQueue()
    
    override init() {
        super.init()
        
        operationQueue.maxConcurrentOperationCount = 5
    }

}


extension FiltersProvider: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterOperations.count + 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filtersCollectionViewCellIdentifier", for: indexPath) as! FiltersCollectionViewCell
        
        if (indexPath as NSIndexPath).item == 0 {
            cell.image = FiltersProvider.image
            cell.filterNameLabel.text = ""
        } else {
            if let image = FiltersProvider.image {
                let filterInterface = filterOperations[(indexPath as NSIndexPath).item - 1]

                if let filter = filterInterface.filter , cell.filter?.listName != filterInterface.listName {
                    let filterOperation = FilterApplyOperation(filter: filter, image: image, onComplete: { [weak cell] filteredImage in
                        DispatchQueue.main.async(execute: { [weak cell] _ in
                            if let img = filteredImage {
                                cell?.image = img
                                cell?.filter = filterInterface
                            }
                        })
                    })
                    cell.filterOperation = filterOperation
                    operationQueue.addOperation(filterOperation)
                } else {
                    if cell.image == nil {
                        cell.image = image
                    }
                }
                
                cell.filterNameLabel.text = filterInterface.titleName
            } else {
                cell.image = FiltersProvider.image
                cell.filterNameLabel.text = nil
            }
        }
        
        if currentIndex == (indexPath as NSIndexPath).row {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
        
        return cell
    }

}
