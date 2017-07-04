//
//  FiltersCollectionViewCell.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 13.02.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


final class FiltersCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var filterPreviewImageView: UIImageView!
    @IBOutlet weak var filterNameLabel: UILabel!
    
    var filterOperation: Operation?
    
    var filter: FilterOperationInterface?
    
    var image: UIImage? {
        didSet {
            filterPreviewImageView.image = image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.drawsAsynchronously = true
        
        filterPreviewImageView.layer.drawsAsynchronously = true
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        filterOperation?.cancel()
    }
    
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderWidth = 2
                layer.borderColor = Theme.mainColor.withAlphaComponent(0.75).cgColor
                
                filterNameLabel.textColor = Theme.mainColor
            } else {
                layer.borderWidth = 1
                layer.borderColor = Theme.lightTintColor.withAlphaComponent(0.25).cgColor
                
                filterNameLabel.textColor = Theme.lightTintColor
            }
        }
    }
    
    // Это пока не поддерживается на iOS, но пусть останется
//    private func applyFilter(filter: Filter) {
//        filterPreviewImageView.layer.filters = [filter]
//        let filterName = filter.filter?.name
//        let filterAttributes = filter.attributes()
//        if let name = filterName, let attributes = filterAttributes {
//            for (key, value) in attributes {
//                filterPreviewImageView.layer.setValue(value, forKeyPath: "filters." + name + "." + key)
//            }
//        }
//    }
    
}
