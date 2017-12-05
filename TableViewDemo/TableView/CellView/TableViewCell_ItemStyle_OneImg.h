//
//  TableViewCell_ItemStyle_oneImg.h
//  TableViewDemo
//
//  Created by LHJ on 2017/10/27.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

@interface TableViewCell_ItemStyle_OneImg : BaseTableViewCell


- (instancetype _Nullable)initWithStyle:(UITableViewCellStyle)style
                        reuseIdentifier:(nullable NSString *)reuseIdentifier
                        withLayoutFrame:(nonnull ItemSize*)itemSize;

- (void) setLayoutFrame:(nonnull ItemSize*)itemSize;

- (void) setTitle:(nonnull NSString*)title withImgURL:(nullable NSURL*)url;

- (void) setTitle:(nonnull NSString*)title withImgURL:(nullable NSURL*)url withImgCornerRadius:(float)cornetRadius;

@end
