//
//  ImgShowView.h
//  TableViewDemo
//
//  Created by LHJ on 2017/11/8.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImgShowView : UIView

@property(nonatomic, retain) NSArray<UIImage*> *aryImgs;

@property(nonatomic, retain) NSArray<NSURL*> *aryImgHDURLs;

@property(nonatomic, retain) NSArray<NSValue*> *aryImgFrames;

@property(nonatomic, assign) int curIndex;

/** 开始显示图片 */
- (void) beginShowImg;

@end
