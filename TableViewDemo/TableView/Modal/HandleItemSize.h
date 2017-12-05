//
//  HandleItemSize.h
//  TableViewDemo
//
//  Created by LHJ on 2017/10/28.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HandleData.h"
#import <UIKit/UIKit.h>

// ===============================================================
/** 每个列表项的布局参数 */
@interface ItemSize : NSObject

@property(nonatomic, assign) CGRect textRect;

@property(nonatomic, retain) NSArray<NSValue*> *aryImgFrame;

@property(nonatomic, assign) CGRect imgCountFrame;

@property(nonatomic, assign) CGRect imgCountSubFrame_img;

@property(nonatomic, assign) CGRect imgCountSubFrame_count;

@property(nonatomic, assign) int itemCellHeight;

@end

// ===============================================================
/** 整个TableView的Item布局参数 */
@interface HandleItemSize : NSObject

@property(nonatomic, retain) NSArray<ItemSize*> *aryItemSizes;

+ (instancetype) sharedHandleItemSize;

+ (NSArray<ItemSize*> *) handleTableViewItemSize:(NSArray<ItemData*>*)aryItemDatas withMaxWidth:(int)maxWidth;

@end
