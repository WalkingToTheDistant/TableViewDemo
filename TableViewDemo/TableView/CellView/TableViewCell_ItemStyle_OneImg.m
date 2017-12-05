//
//  TableViewCell_ItemStyle_oneImg.m
//  TableViewDemo
//
//  Created by LHJ on 2017/10/27.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "TableViewCell_ItemStyle_OneImg.h"
#import "UIView+handleImg.h"


@interface TableViewCell_ItemStyle_OneImg()

@property(nonatomic, retain) UILabel *labTitle;

@property(nonatomic, retain) UIView *imgView; // 因为只需要用Layer的content，所以用UIView就可以了

@end

@implementation TableViewCell_ItemStyle_OneImg

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(nullable NSString *)reuseIdentifier
              withLayoutFrame:(ItemSize*)itemSize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self != nil){
        [self setLayoutFrame:itemSize];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self != nil){
        _imgView = [UIView new];
        [_imgView setOpaque:YES]; // 不透明
        [_labTitle setNumberOfLines:2];
        [_labTitle setLineBreakMode:NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail];
        [_imgView setContentMode:UIViewContentModeScaleToFill];
        [_imgView setBackgroundColor:Color_Transparent];
        [_imgView setUserInteractionEnabled:YES];
        [self addSubview:_imgView];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGes:)];
        [_imgView addGestureRecognizer:tapGes];
        
        _labTitle = [UILabel new];
        [_labTitle setOpaque:YES];
        [_labTitle setFont:Font_Title];
        [_labTitle setTextColor:Color_Title];
        [_labTitle setBackgroundColor:Color_Transparent];
        [_labTitle setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_labTitle];
    }
    return self;
}
- (void) setLayoutFrame:(ItemSize*)itemSize
{
    if(CGRectEqualToRect(_labTitle.frame, itemSize.textRect) != YES){
        [_labTitle setFrame:itemSize.textRect];
    }
    
    if(CGRectIsEmpty(_imgView.frame) == YES){
        if(itemSize.aryImgFrame.count > 0){
            [_imgView setHidden:NO];
            CGRect rect = [itemSize.aryImgFrame[0] CGRectValue];
            [_imgView setFrame:rect];
        } else {
            [_imgView setHidden:YES];
        }
    }
}
- (void) setTitle:(NSString*)title withImgURL:(nullable NSURL*)url;
{
    [self setTitle:title withImgURL:url withImgCornerRadius:0];
}
- (void) setTitle:(nonnull NSString*)title withImgURL:(nullable NSURL*)url withImgCornerRadius:(float)cornetRadius
{
    [_labTitle setText:title];
    if(url != nil){
        [_imgView lhj_setImgWithURL:url withConerRadius:cornetRadius];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
// ============================================================================
/** 动作触发方法 */
- (void) handleTapGes:(UITapGestureRecognizer*)tapGes
{
    UIView *imgView = tapGes.view;
    
    NSMutableArray<NSValue*> *muAryFrames = [NSMutableArray new];
    NSValue *valueFrame = @([HandleData getRelativePointForScreenWithView:imgView]);
    [muAryFrames addObject:valueFrame];
    
    if(self.clickImgBlock != nil){
        self.clickImgBlock(self, @[[imgView lhj_getCurrentImg]], muAryFrames, 0);
    }
}

@end
