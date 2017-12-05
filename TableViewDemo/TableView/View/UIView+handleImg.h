//
//  UIView+handleImg.h
//  TableViewDemo
//
//  Created by LHJ on 2017/10/27.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (handleImg)

- (void) lhj_setImgWithURL:(NSURL*)url withConerRadius:(float)radius;

- (void) lhj_setImgWithURL:(NSURL*)url;

- (UIImage*) lhj_getCurrentImg;

@end
