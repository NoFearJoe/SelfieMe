//
//  KYTilePhotoLayout.m
//  KYTilePhotoLayout-Demo
//
//  Created by Kitten Yang on 6/5/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

#import "KYTilePhotoLayout.h"



#define LayoutHorizontal self.LayoutDirection == Horizontal
#define LayoutVertical   self.LayoutDirection == Vertical


@interface KYTilePhotoLayout()

@property (nonatomic,assign)NSUInteger columnsCount;
@property (nonatomic,strong)NSMutableArray *COLUMNSHEIGHTS;
@property (nonatomic,strong)NSMutableArray *itemsAttributes;

@end

@implementation KYTilePhotoLayout

#pragma mark --  UICollectionViewLayout


-(void)prepareLayout {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft | orientation ==  UIInterfaceOrientationLandscapeRight){
        self.columnsCount = self.ColOfLandscape;
    }else{
        self.columnsCount = self.ColOfPortrait;
    }
    
    NSUInteger itemCounts = [[self collectionView]numberOfItemsInSection:0];
    self.itemsAttributes = [NSMutableArray arrayWithCapacity:itemCounts];
    
    self.COLUMNSHEIGHTS = [NSMutableArray arrayWithCapacity:self.columnsCount];
    for (NSInteger i = 0; i<self.columnsCount; i++) {
        [self.COLUMNSHEIGHTS addObject:@(0)];
    }
    
    
    for (NSUInteger i = 0; i < itemCounts; i++) {
        NSUInteger shtIndex = [self findShortestColumn];
        
        NSUInteger origin_x = LayoutVertical ? shtIndex * [self columnWidth] : [self.COLUMNSHEIGHTS[shtIndex] integerValue];
        NSUInteger origin_y = LayoutVertical ? [self.COLUMNSHEIGHTS[shtIndex] integerValue] : shtIndex * [self columnWidth];
        
        NSUInteger size_width = 0.0;
        NSUInteger randomOfWhetherDouble = arc4random() % 100;
        
        if (shtIndex < self.columnsCount - 1 && [self.COLUMNSHEIGHTS[shtIndex] floatValue] == [self.COLUMNSHEIGHTS[shtIndex+1] floatValue] && randomOfWhetherDouble < self.DoubleColumnThreshold) {
            size_width = 2 * [self columnWidth];
        } else {
            size_width = [self columnWidth];
        }
        
        NSUInteger size_height = 0.0;
        CGFloat retVal;
        if (size_width == 2 * [self columnWidth]) {
            float extraRandomHeight = arc4random() % 25;
            retVal = 0.75 + (extraRandomHeight / 100);
            
            size_height = size_width;// * retVal;
//            size_height = size_height - (size_height % 40);
        } else {
            float extraRandomHeight = arc4random() % 50;
            retVal = 0.75 + (extraRandomHeight / 100);
            size_height = size_width;// * retVal;
//            size_height = size_height - (size_height % 40);
        }
        
        if (LayoutHorizontal) {
            NSUInteger temp = size_width;
            size_width = size_height;
            size_height = temp;
            
            if (size_height == 2*[self columnWidth]) {
                self.COLUMNSHEIGHTS[shtIndex] = @(origin_x + size_width);
                self.COLUMNSHEIGHTS[shtIndex+1] = @(origin_x + size_width);
            } else {
                self.COLUMNSHEIGHTS[shtIndex] = @(origin_x + size_width);
            }
        } else {
            if (size_width == 2*[self columnWidth]) {
                self.COLUMNSHEIGHTS[shtIndex] = @(origin_y + size_height);
                self.COLUMNSHEIGHTS[shtIndex+1] = @(origin_y + size_height);
            } else {
                self.COLUMNSHEIGHTS[shtIndex] = @(origin_y + size_height);
            }
        }
        
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectMake(origin_x, origin_y, size_width, size_height);
        [self.itemsAttributes addObject:attributes];
        
    }
    
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    return self.itemsAttributes;
}


-(CGSize)collectionViewContentSize {
    CGSize size = self.collectionView.bounds.size;
    NSUInteger longstIndex = [self findLongestColumn];
    float columnMax = [self.COLUMNSHEIGHTS[longstIndex] floatValue];
    
    if (LayoutVertical) {
        size.height = columnMax;
    }else{
        size.width  = columnMax;
    }
    
    return size;
}



#pragma mark -- Public Method

- (float)columnWidth {
    return LayoutVertical ? roundf(self.collectionView.bounds.size.width / self.columnsCount) : roundf(self.collectionView.bounds.size.height / self.columnsCount);
}


-(NSUInteger)findShortestColumn {

    NSUInteger shortestIndex = 0;
    CGFloat shortestValue = MAXFLOAT;
    

    NSUInteger index = 0;
    for (NSNumber *columnHeight in self.COLUMNSHEIGHTS) {
        if ([columnHeight floatValue] < shortestValue) {
            shortestValue = [columnHeight floatValue];
            shortestIndex = index;
        }
        index++;
    }
    
    return shortestIndex;
    
}


-(NSUInteger)findLongestColumn {
    NSUInteger longestIndex = 0;
    CGFloat longestValue = 0;
    
    
    NSUInteger index = 0;
    for (NSNumber *columnHeight in self.COLUMNSHEIGHTS) {
        if ([columnHeight floatValue] > longestValue) {
            longestValue = [columnHeight floatValue];
            longestIndex = index;
        }
        index++;
    }
    
    return longestIndex;

}



@end
