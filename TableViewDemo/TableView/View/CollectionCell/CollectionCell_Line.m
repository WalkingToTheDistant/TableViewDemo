//
//  CollectionCell_Line.m
//  TableViewDemo
//
//  Created by LHJ on 2017/11/8.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "CollectionCell_Line.h"
#import "CPublic.h"
#import "UIView+handleImg.h"

@interface CollectionCell_Line()<UIGestureRecognizerDelegate>

@property(nonatomic, retain) UIImageView *imgView;

@property(nonatomic, retain) UITapGestureRecognizer *tapGes;

@property(nonatomic, retain) UIPanGestureRecognizer *panGes;

@end

@implementation CollectionCell_Line

- (instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    [self initView];
    
    return self;
}

- (void) initView
{
    _imgView = [UIImageView new];
    [_imgView setFrame:self.bounds];
    [_imgView setBackgroundColor:Color_Transparent];
    [_imgView setUserInteractionEnabled:YES];
    [_imgView setContentMode:UIViewContentModeScaleAspectFit];
    [self.contentView addSubview:_imgView];
    
    _tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGes:)];
    [_imgView addGestureRecognizer:_tapGes];
    
    _panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGes:)];
    _panGes.delegate = (id)self;
    [_imgView addGestureRecognizer:_panGes];
}
- (void) setImg:(UIImage*)img withHDImgURL:(NSURL*)url
{
    [_imgView setImage:img];
    [_imgView lhj_setImgWithURL:url];
}
// 先显示省略图，然后下载高清图之后再替换
- (void) setHDImgURL:(NSURL*)url
{
    [_imgView lhj_setImgWithURL:url];
}

// =========================================================================================
#pragma mark - 动作触发方法
/** 处理单击手势 */
- (void) handleTapGes:(UITapGestureRecognizer*) tapGes
{
    if(_tapGestureBlock != nil){
        _tapGestureBlock(self, tapGes);
    }
}
/** 处理拖动手势 */
- (void) handlePanGes:(UIPanGestureRecognizer*) panGes
{
    if(_panGestureBlock != nil){
        _panGestureBlock(self, panGes);
    }
}
// =========================================================================================
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if([gestureRecognizer.view isKindOfClass:[UIScrollView class]] == YES){ // 如果手势是正在滑动UIScrollView，那么就阻止PanGes
        return NO;
    }
    return YES;
}


@end
