//
//  TableViewCell_ItemStyle_Imgs_2.h
//  TableViewDemo
//
//  Created by LHJ on 2017/10/30.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

@interface TableViewCell_ItemStyle_Imgs_2 : BaseTableViewCell

- (instancetype _Nullable)initWithStyle:(UITableViewCellStyle)style
                        reuseIdentifier:(nullable NSString *)reuseIdentifier
                        withLayoutFrame:(nonnull ItemSize*)itemSize;

- (void) setLayoutFrame:(nonnull ItemSize*)itemSize;

- (void) setTitle:(nonnull NSString*)title withImgs:(nullable NSArray<NSURL*>*) aryUrl;

- (void) setTitle:(nonnull NSString*)title withImgs:(nullable NSArray<NSURL*>*) aryUrl withImgCornerRadius:(float)cornetRadius;

@end
