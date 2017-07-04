//
//  GalleryViewCell.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 18.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


final class GalleryViewCell: UICollectionViewCell {
    
    var operation: Operation?
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var selectedView: UIView!
    
    static let identifier = "GalleryViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedView.backgroundColor = Theme.mainColor.withAlphaComponent(0.25)
        selectedView.alpha = 0.0
    }
    
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: Animation.shortDuration, animations: { [weak self] in
                self!.selectedView.alpha = self!.isSelected ? 1.0 : 0.0
            }) 
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoView.image = nil
        
        operation?.cancel()
        operation = nil
    }
    
}
