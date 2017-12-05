//
//  ItemData.h
//  TableViewDemo
//
//  Created by LHJ on 2017/10/27.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : int{
    ItemStyle_OneImg = 1, /* 只有一张图片 */
    ItemStyle_ThreeImgs, /* 有2~3张图片 */
    ItemStyle_Imgs_1, /* 4张图片以上 - 只显示第一张 */
    ItemStyle_Imgs_2, /* 4张图片以上 - 全部显示 */
} ItemStyle;

@interface ItemData : NSObject

- (instancetype) initWithTitle:(NSString*)title;

@property(nonatomic, copy) NSString *title;

@property(nonatomic, retain) NSArray<NSURL*> *aryImgs;

@property(nonatomic, assign) ItemStyle itemStyle;

@end
