//
//  TableViewCell_ItemStyle_ThreeImgs.m
//  TableViewDemo
//
//  Created by LHJ on 2017/10/30.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "TableViewCell_ItemStyle_ThreeImgs.h"

@interface TableViewCell_ItemStyle_ThreeImgs()

@property(nonatomic, retain) UILabel *labTitle;

@property(nonatomic, retain) NSMutableArray<UIView*> *muAryImgView;

@end

@implementation TableViewCell_ItemStyle_ThreeImgs

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
        _labTitle = [UILabel new];
        [_labTitle setOpaque:YES];
        [_labTitle setNumberOfLines:2];
        [_labTitle setLineBreakMode:NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail];
        [_labTitle setFont:Font_Title];
        [_labTitle setTextColor:Color_Title];
        [_labTitle setBackgroundColor:Color_Transparent];
        [_labTitle setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_labTitle];
        
        _muAryImgView = [NSMutableArray new];
        for(int i=0; i<3; i+=1){ // 预先创建，避免在滑动列表时新建控件，否则会造成性能问题
            
            UIView *imgView = [UIView new];
            [imgView setOpaque:YES]; // 不透明
            [imgView setContentMode:UIViewContentModeScaleToFill];
            [imgView setBackgroundColor:Color_Transparent];
            [imgView setUserInteractionEnabled:YES];
            [imgView setTag:i];
            [self addSubview:imgView];
            
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGes:)];
            [imgView addGestureRecognizer:tapGes];
            
            [_muAryImgView addObject:imgView];
        }
    }
    return self;
}
- (void) setLayoutFrame:(ItemSize*)itemSize
{
    if(CGRectEqualToRect(_labTitle.frame, itemSize.textRect) != YES){
        [_labTitle setFrame:itemSize.textRect];
    }
    for(int i=0; i<_muAryImgView.count; i+=1){
        UIView *view = _muAryImgView[i];
        if(i < itemSize.aryImgFrame.count){
            CGRect rect = [itemSize.aryImgFrame[i] CGRectValue];
            if(CGRectEqualToRect(view.frame, rect) != YES){ // 布局数据不一致，就进行更新，避免不必要的刷新Layout
                [view setFrame:rect];
            }
            [view setHidden:NO];
        } else {
            [view setHidden:YES];
        }
    }
}
- (void) setTitle:(nonnull NSString*)title withImgs:(nullable NSArray<NSURL*>*) aryUrl
{
    [self setTitle:title withImgs:aryUrl withImgCornerRadius:0];
}
- (void) setTitle:(nonnull NSString*)title withImgs:(nullable NSArray<NSURL*>*) aryUrl withImgCornerRadius:(float)cornetRadius
{
    [_labTitle setText:title];
    
    for(int i=0; i<_muAryImgView.count; i+=1){
        UIView *view = _muAryImgView[i];
        if(i<aryUrl.count){
            [view lhj_setImgWithURL:aryUrl[i] withConerRadius:cornetRadius];
            [view setHidden:NO];
        } else {
            [view lhj_setImgWithURL:nil]; // 清空图层
            [view setHidden:YES];
        }
    }
}

// ============================================================================
/** 动作触发方法 */
- (void) handleTapGes:(UITapGestureRecognizer*)tapGes
{
    UIView *imgView = tapGes.view;
    
    NSMutableArray<NSValue*> *muAryFrames = [NSMutableArray new];
    NSMutableArray<UIImage*> *muAryImgs = [NSMutableArray new];
    for(UIView *viewFor in _muAryImgView){
        if(viewFor.lhj_getCurrentImg == nil) { continue; }
        
        NSValue *valueFrame = @([HandleData getRelativePointForScreenWithView:viewFor]);
        [muAryFrames addObject:valueFrame];
        
        [muAryImgs addObject:[UIImage imageWithCGImage:(__bridge CGImageRef)viewFor.layer.contents]];
    }

    if(self.clickImgBlock != nil){
        self.clickImgBlock(self, muAryImgs, muAryFrames, (int)imgView.tag);
    }
}

@end
