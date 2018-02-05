//
//  ImgShowView_Layer.h
//  TableViewDemo
//
//  Created by LHJ on 2017/11/29.
//  Copyright © 2017年 LHJ. All rights reserved.
//
#import "ImgShowView.h"

@interface ImgShowView_Vertical_2 : ImgShowView

/** 设置黑色背景的透明度 */
- (void) setBackViewAlpha:(float) alpha;

/** 获取该图片展示效果的出现动画的Transform3D */
+ (CATransform3D) getBeginTransform:(CGRect)frameBegin
                            withImg:(UIImage*)imgCur;

@end
