//
//  TableViewCell_ItemStyle_Imgs_1.m
//  TableViewDemo
//
//  Created by LHJ on 2017/10/30.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "TableViewCell_ItemStyle_Imgs_1.h"

@interface TableViewCell_ItemStyle_Imgs_1()

@property(nonatomic, retain) UILabel *labTitle;

@property(nonatomic, retain) UIView *imgView;

@property(nonatomic, retain) UIView *viewImgCount;

@property(nonatomic, retain) UIView *ImgCountSub_imgView;

@property(nonatomic, retain) UILabel *ImgCountSub_text;

@end

@implementation TableViewCell_ItemStyle_Imgs_1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
        _labTitle = [UILabel new];
        [_labTitle setOpaque:YES];
        [_labTitle setFont:Font_Title];
        [_labTitle setTextColor:Color_Title];
        [_labTitle setNumberOfLines:2];
        [_labTitle setLineBreakMode:NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail];
        [_labTitle setBackgroundColor:Color_Transparent];
        [_labTitle setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_labTitle];
        
        _imgView = [UIView new];
        [_imgView setOpaque:YES]; // 不透明
        [_imgView setContentMode:UIViewContentModeScaleToFill];
        [_imgView setBackgroundColor:Color_Transparent];
        [_imgView setUserInteractionEnabled:YES];
        [self addSubview:_imgView];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGes:)];
        [_imgView addGestureRecognizer:tapGes];
        
        // ====== 图片数量的View
        _viewImgCount = [UIView new];
        [_viewImgCount setBackgroundColor:RGBA(50, 50, 50, 0.3f)];
        [_viewImgCount.layer setCornerRadius:6.0f];
        [_viewImgCount setOpaque:NO];
        [_viewImgCount setUserInteractionEnabled:NO];
        [_imgView addSubview:_viewImgCount];
        
        NSURL *imgURL = [HandleData getFileURLWithResource:@"imgCount" withType:@"png"];
        _ImgCountSub_imgView = [UIView new];
        [_ImgCountSub_imgView setOpaque:YES];
        [_ImgCountSub_imgView setBackgroundColor:Color_Transparent];
        [_ImgCountSub_imgView setContentMode:UIViewContentModeScaleToFill];
        [_ImgCountSub_imgView setUserInteractionEnabled:NO];
        [_ImgCountSub_imgView lhj_setImgWithURL:imgURL];
        [_viewImgCount addSubview:_ImgCountSub_imgView];
        
        _ImgCountSub_text = [UILabel new];
        [_ImgCountSub_text setOpaque:YES];
        [_ImgCountSub_text setFont:Font_ImgCount];
        [_ImgCountSub_text setTextColor:Color_ImgCount];
        [_ImgCountSub_text setBackgroundColor:Color_Transparent];
        [_ImgCountSub_text setTextAlignment:NSTextAlignmentLeft];
        [_viewImgCount addSubview:_ImgCountSub_text];
        
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
    if(CGRectEqualToRect(_viewImgCount.frame, itemSize.imgCountFrame) != YES){
        [_viewImgCount setFrame:itemSize.imgCountFrame];
    }
    if(CGRectEqualToRect(_ImgCountSub_text.frame, itemSize.imgCountSubFrame_count) != YES){
        [_ImgCountSub_text setFrame:itemSize.imgCountSubFrame_count];
    }
    if(CGRectEqualToRect(_ImgCountSub_imgView.frame, itemSize.imgCountSubFrame_img) != YES){
        [_ImgCountSub_imgView setFrame:itemSize.imgCountSubFrame_img];
    }
}
- (void) setTitle:(nonnull NSString*)title withImgs:(nullable NSArray<NSURL*>*) aryUrl
{
    [self setTitle:title withImgs:aryUrl withImgCornerRadius:0];
}
- (void) setTitle:(nonnull NSString*)title withImgs:(nullable NSArray<NSURL*>*) aryUrl withImgCornerRadius:(float)cornetRadius
{
    [_labTitle setText:title];
    
    if(aryUrl.count > 0){
        [_imgView setHidden:NO];
        [_imgView lhj_setImgWithURL:aryUrl[0] withConerRadius:cornetRadius];
        
    } else {
        [_imgView setHidden:YES];
    }
    NSString *strText = [NSString stringWithFormat:@"%li图", aryUrl.count];
    [_ImgCountSub_text setText:strText];
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
