//
//  GalleryViewFlowLayout.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 25.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit



protocol GalleryViewLayoutDelegate {
    func galleryView(_ view: UICollectionView, numberOfColumnsInSection: Int) -> Int
    func galleryView(_ view: UICollectionView, heightForPhotoAtIndexPath: IndexPath) -> CGFloat
}


class GalleryViewLayout: UICollectionViewLayout {
    
//    var delegate: GalleryViewLayoutDelegate? {
//        return (collectionView?.delegate as? GalleryViewLayoutDelegate) ?? nil
//    }
//    
//    private var _numberOfItemFrameSections: Int = 0
//    private var _itemFrameSections = [[CGRect]]()
//    
//    private var headerFrames = [CGRect]()
//    private var footerFrames = [CGRect]()
//    private var contentSize = CGSizeZero
//    
//    
//    override func prepareLayout() {
//        super.prepareLayout()
//        
//        if let _ = collectionView {
//            // TODO: Заменить
//            var idealHeight: CGFloat = collectionView!.frame.size.width
//            if idealHeight == 0 {
//                idealHeight = CGRectGetHeight(collectionView!.bounds) / 3.0
//            }
//            
//            var headerFrames = [CGRect]()
//            var footerFrames = [CGRect]()
//            
//            var contentSize = CGSizeZero;
//            
//            // first release old item frame sections
////            [self clearItemFrames];
//            
//            // create new item frame sections
//            _numberOfItemFrameSections = self.collectionView!.numberOfSections()
//            _itemFrameSections = [[CGRect]]()
//            
//            for section in 0..<self.collectionView!.numberOfSections() {
//                // add new item frames array to sections array
//                let numberOfItemsInSections: Int = self.collectionView!.numberOfItemsInSection(section)
//                var itemFrames = [CGRect]()
//                _itemFrameSections[section] = itemFrames
//                
//                let sectionSize = CGSizeZero
//                
//                let totalItemSize: CGFloat = self.totalItemSizeForSection(section, preferredRowSize: idealHeight)
//                let numberOfRows: Int = max(Int(round(totalItemSize / self.viewPortAvailableSize())), 1)
//                
//                var sectionOffset = CGPointMake(0, contentSize.height);
//                
//                self.setFrames(itemFrames, forItemsInSection: section, numberOfRows: numberOfRows, sectionOffset: sectionOffset, sectionSize &sectionSize)
//            }
//            
//            self.headerFrames = headerFrames
//            self.footerFrames = footerFrames
//            
//            self.contentSize = contentSize;
//        }
//    }
//    
//    
//    override func collectionViewContentSize() -> CGSize {
//        return self.contentSize
//    }
//    
//    
//    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        var layoutAttributes = [UICollectionViewLayoutAttributes]()
//        
//        for section in 0..<self.collectionView!.numberOfSections() {
//            let sectionIndexPath = NSIndexPath(forItem: 0, inSection: section)
//            
//            let headerAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath:sectionIndexPath)
//            
//            if let hAttrs = headerAttributes {
//                if !CGSizeEqualToSize(hAttrs.frame.size, CGSizeZero) && CGRectIntersectsRect(hAttrs.frame, rect) {
//                    layoutAttributes.append(hAttrs)
//                }
//            }
//            
//            for i in 0..<self.collectionView!.numberOfItemsInSection(section) {
//                let itemFrame = _itemFrameSections[section][i]
//                if CGRectIntersectsRect(rect, itemFrame) {
//                    let indexPath = NSIndexPath(forItem: i, inSection: section)
//                    if let attrs = self.layoutAttributesForItemAtIndexPath(indexPath) {
//                        layoutAttributes.append(attrs)
//                    }
//                }
//            }
//            
//            let footerAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionFooter,
//                atIndexPath: sectionIndexPath)
//            
//            if let fAttrs = footerAttributes {
//                if !CGSizeEqualToSize(fAttrs.frame.size, CGSizeZero) && CGRectIntersectsRect(fAttrs.frame, rect) {
//                    layoutAttributes.append(fAttrs)
//                }
//            }
//        }
//        
//        return layoutAttributes
//    }
//    
//    
//    
//    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
//        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
//        attributes.frame = itemFrameForIndexPath(indexPath)
//        return attributes
//    }
//    
//    
//    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
//        let oldBounds = self.collectionView?.bounds ?? CGRectZero
//        
//        return newBounds.size.width != oldBounds.size.width || newBounds.size.height != oldBounds.size.height
//    }
//    
//    
//    private func headerFrameForSection(section: Int) -> CGRect {
//        return self.headerFrames[section]
//    }
//    
//    private func itemFrameForIndexPath(indexPath: NSIndexPath) -> CGRect {
//        return _itemFrameSections[indexPath.section][indexPath.item]
//    }
//
//    private func footerFrameForSection(section: Int) -> CGRect {
//        return footerFrames[section]
//    }
//    
//    
//    private func totalItemSizeForSection(section: Int, preferredRowSize: CGFloat) -> CGFloat {
//        var totalItemSize: CGFloat = 0.0
//        if let _ = collectionView {
//            for i in 0..<self.collectionView!.numberOfItemsInSection(section){
//                let preferredSize = self.delegate?.collectionView(self.collectionView, layout: self, preferredSizeForItemAtIndexPath: NSIndexPath( forItem: i, inSection: section)) ?? CGSizeZero
//                
//                totalItemSize += (preferredSize.width / preferredSize.height) * collectionView!.frame.size.width
//            }
//        }
//        
//        return totalItemSize
//    }
//    
//    
//    func weightsForItemsInSection(section: Int) -> [Int] {
//        var weights = [Int]()
//        for i in 0..<self.collectionView!.numberOfItemsInSection(section) {
//            let preferredSize = self.delegate?.collectionView(self.collectionView!, layout: self, preferredSizeForItemAtIndexPath: NSIndexPath( forItem: i, inSection: section))
//            let aspectRatio: Int = roundf((preferredSize.width / preferredSize.height) * 100)
//            weights.append(aspectRatio)
//        }
//        
//        return weights
//    }
//    
//    
//    private func setFrames(frames: [CGRect], forItemsInSection section: Int, numberOfRows: Int, sectionOffset: CGPoint, sectionSize: CGSize) {
//        var weights = self.weightsForItemsInSection(section)
//        var partition = NHLinearPartition.linearPartitionForSequence(weights, numberOfPartitions: numberOfRows)
//        
//        var i = 0
//        let offset = CGPointMake(sectionOffset.x, sectionOffset.y)
//        var previousItemSize = 0
//        var contentMaxValueInScrollDirection = 0
//        for row in partition {
//            var summedRatios = 0
//            for j in i..<(i + row.count) {
//                let preferredSize = self.delegate?.collectionView(self.collectionView!, layout: self, preferredSizeForItemAtIndexPath: NSIndexPath(forItem: j, inSection: section)) ?? CGSizeZero
//                
//                summedRatios += preferredSize.width / preferredSize.height
//            }
//            
//            let rowSize = self.viewPortAvailableSize - ((row.count - 1) * self.minimumInteritemSpacing)
//            for j in i..<(i + row.count) {
//                let preferredSize = self.delegate?.collectionView(self.collectionView!, layout: self, preferredSizeForItemAtIndexPath: NSIndexPath(forItem: j, inSection: section)) ?? CGSizeZero
//                
//                let actualSize = CGSizeMake(roundf(rowSize / summedRatios * (preferredSize.width / preferredSize.height)), roundf(rowSize / summedRatios))
//                
//                let frame = CGRectMake(offset.x, offset.y, actualSize.width, actualSize.height)
//                *frames++ = frame
//                
//                
//                offset.x += actualSize.width + self.minimumInteritemSpacing
//                previousItemSize = actualSize.height
//                contentMaxValueInScrollDirection = CGRectGetMaxY(frame)
//            }
//            
//            if (row.count > 0) {
//                offset = CGPointMake(self.sectionInset.left, offset.y + previousItemSize + self.minimumLineSpacing)
//            }
//            
//            i += row.count
//        }
//        
//        *sectionSize = CGSizeMake(self.viewPortWidth, (contentMaxValueInScrollDirection - sectionOffset.y) + self.sectionInset.bottom)
//    }
//    
//    
//    private func viewPortWidth() -> CGFloat {
//        if let _ = collectionView {
//            return CGRectGetWidth(self.collectionView!.frame) - self.collectionView!.contentInset.left - self.collectionView!.contentInset.right
//        }
//        return 0.0
//    }
//    
//    private func viewPortHeight() -> CGFloat {
//        if let _ = collectionView {
//            return (CGRectGetHeight(self.collectionView!.frame) - self.collectionView!.contentInset.top  - self.collectionView!.contentInset.bottom)
//        }
//        return 0.0
//    }
//    
//    private func viewPortAvailableSize() -> CGFloat {
//        return self.viewPortWidth()
//    }
    
}
