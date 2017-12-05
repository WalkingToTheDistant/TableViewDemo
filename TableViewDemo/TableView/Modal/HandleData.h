//
//  HandleData.h
//  TableViewDemo
//
//  Created by LHJ on 2017/10/27.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GCD.h"
#import "ItemData.h"
#import "CPublic.h"

#define Color_Title     RGB(30, 30, 30)
#define Color_ImgCount  RGB(255, 255, 255)

#define Font_Title      Font(16.0f)
#define Font_ImgCount   Font(12.0f)

@interface HandleData : NSObject

+ (void) work:(void(^)(NSArray<ItemData*>*listData))completeBlock;

+ (void) prepareImgWithURL:(NSURL*)url;

/** 获取工程的文件路径URL */
+ (NSURL*) getFileURLWithResource:(NSString*)name withType:(NSString*) ext;

/** 将URL的图片加载成imgRef */
+ (void) handleImgWithURL:(NSURL*)url withCompleteBlock:(void(^)(UIImage *img)) completeBlock;

+ (UIImage*) cache_getImgWithKey:(id)key;

+ (void) cache_setImg:(UIImage*) img WithKey:(id)key;

/** 获取三行文字的高度 */
+ (int) getHeightForTextOfThreeRow;

/** 获取两行文字的高度 */
+ (int) getHeightForTextOfTwoRow;

/** 获取文字的尺寸 */
+ (CGSize) getSizeForTitleFontWithStr:(NSString*)str withMaxSize:(CGSize)maxSize;

/** 获取文字的尺寸 */
+ (CGSize) getSizeForOneTextWithStr:(NSString*)str withFont:(UIFont*)font withMaxSize:(CGSize)maxSize;

/** 获取View在全屏中的相对Frame */
+ (CGRect)getRelativePointForScreenWithView:(UIView *)v_view;

@end
