//
//  ImgShowView.h
//  TableViewDemo
//
//  Created by LHJ on 2017/10/31.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : int{
    ImgShowType_Line = 0,
    ImgShowType_Vertical, /* 图片翻转-1 */
    ImgShowType_Vertical_2, /* 图片翻转-2 */
}ImgShowType;

@interface ImgShow : NSObject


+ (instancetype) sharedImgShow;

/** 打开图片浏览器
 * @param imgShowType  - 图片的浏览样式
 * @param aryImgs - 省略图
 * @param aryImgHDURLs - 高清图URL
 * @param aryFrames - 所有省略图在屏幕中的Frame
 * @param curIndex - 当前点击的图片Index
 */
+ (void) showImgViewWithType:(ImgShowType)imgShowType
                    withImgs:(NSArray<UIImage*>*)aryImgs
                 withImgURLs:(NSArray<NSURL*>*)aryImgHDURLs
               withImgFrames:(NSArray<NSValue*>*)aryFrames
                withCurIndex:(int)curIndex;

@end
