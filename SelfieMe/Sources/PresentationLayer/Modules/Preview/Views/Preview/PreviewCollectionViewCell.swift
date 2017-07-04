//
//  PreviewCollectionViewCell.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 20.06.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit



final class PreviewCollectionViewCell: UICollectionViewCell {

    var originalImage: UIImage? {
        didSet {
//            filteredImage = originalImage
        }
    }
    var filteredImage: UIImage? {
        didSet {
            previewImageView.image = filteredImage
        }
    }
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    var operation: Operation?
    var filterOperation: Operation?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        operation?.cancel()
        filterOperation?.cancel()
    }

}
