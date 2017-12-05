//
//  CPublic.h
//  TableViewDemo
//
//  Created by LHJ on 2017/10/27.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#ifndef CPublic_h
#define CPublic_h

#import "HandleData.h"
#import "HandleItemSize.h"
#import "UIView+handleImg.h"
#import "GCD.h"

#define Font(s)         [UIFont fontWithName:@"AmericanTypewriter-Bold" size:s]

#define Color_Transparent [UIColor clearColor]
#define RGBA(r, g, b ,a)    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r, g, b)        RGBA(r, g, b, 1.0f)

typedef void(^ClickImgBlock)(id objSelf, NSArray<UIImage*> *aryImgs, NSArray<NSValue*> *aryImgScrFrames, int currentImgIndex);

#endif /* CPublic_h */
