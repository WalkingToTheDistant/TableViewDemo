//
//  CollectionCell_Line.h
//  TableViewDemo
//
//  Created by LHJ on 2017/11/8.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TapGestureBlock)(id cell, UITapGestureRecognizer *tapGes);
typedef void(^PanGestureBlock)(id cell, UIPanGestureRecognizer *panGes);

@interface CollectionCell_Line : UICollectionViewCell

// 先显示省略图，然后下载高清图之后再替换
- (void) setImg:(UIImage*)img withHDImgURL:(NSURL*)url;

// 先显示省略图，然后下载高清图之后再替换
- (void) setHDImgURL:(NSURL*)url;

@property(nonatomic, copy) TapGestureBlock tapGestureBlock;

@property(nonatomic, copy) PanGestureBlock panGestureBlock;

@end
