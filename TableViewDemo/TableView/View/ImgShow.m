//
//  ImgShowView.m
//  TableViewDemo
//
//  Created by LHJ on 2017/10/31.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "ImgShow.h"
#import "CPublic.h"
#import "UIView+handleImg.h"
#import "ImgShowView_Line.h"
#import "ImgShowView_Vertical.h"
#import "ImgShowView_Vertical_2.h"

@interface ImgShow()

@property(nonatomic, assign) ImgShowType imgShowType;

@property(nonatomic, retain) ImgShowView *imgShowView;

@end


@implementation ImgShow

static ImgShow *sharedInstance = nil;
static UIView *imgViewAni = nil;

// =========================================================================================
#pragma mark - 元类方法
+ (instancetype) sharedImgShow{
    if(sharedInstance == nil){
        sharedInstance = [ImgShow new];
    }
    return sharedInstance;
}

/** 根据Type加载不同的ImgShowView */
+ (ImgShowView*) getImgShowViewWithType:(ImgShowType)imgShowType
{
    CGRect frame = [UIScreen mainScreen].bounds;
    ImgShowView *viewResult = nil;
    switch (imgShowType) {
        case ImgShowType_Line:{
            viewResult = [[ImgShowView_Line alloc] initWithFrame:frame];
            break;
        }
        case ImgShowType_Vertical:{
            viewResult = [[ImgShowView_Vertical alloc] initWithFrame:frame];
            break;
        }
        case ImgShowType_Vertical_2:{
            viewResult = [[ImgShowView_Vertical_2 alloc] initWithFrame:frame];
            break;
        }
        default:
            break;
    }
    return viewResult;
}


+ (void) showImgViewWithType:(ImgShowType)imgShowType
                    withImgs:(NSArray<UIImage*>*)aryImgs
                 withImgURLs:(NSArray<NSURL*>*)aryImgHDURLs
               withImgFrames:(NSArray<NSValue*>*)aryFrames
                withCurIndex:(int)curIndex
{
    [GCD GCDAsync_MainQueue:^{
        ImgShow *obj = [ImgShow sharedImgShow];
        obj.imgShowType = imgShowType;
        obj.imgShowView = [self getImgShowViewWithType:obj.imgShowType];
        
        obj.imgShowView.aryImgs = aryImgs;
        obj.imgShowView.aryImgHDURLs = aryImgHDURLs;
        obj.imgShowView.curIndex = curIndex;
        obj.imgShowView.aryImgFrames = aryFrames;
        [[UIApplication sharedApplication].delegate.window addSubview:obj.imgShowView];
        
        [[self class] beginAni];
    }];
}
+ (CATransform3D) getBeginTransform:(CGRect)frameBegin
                            withImg:(UIImage*)imgCur
                    withImgShowType:(ImgShowType)imgShowType
{
    CATransform3D transformResult = CATransform3DIdentity;
    switch(imgShowType){
        case ImgShowType_Line:{
            transformResult = [ImgShowView_Line getBeginTransform:frameBegin withImg:imgCur];;
            break;
        }
        case ImgShowType_Vertical:{
            transformResult = [ImgShowView_Vertical getBeginTransform:frameBegin withImg:imgCur];;
            break;
        }
        case ImgShowType_Vertical_2:{
            transformResult = [ImgShowView_Vertical_2 getBeginTransform:frameBegin withImg:imgCur];;
            break;
        }
    }
    return transformResult;
}
+ (void) beginAni
{
    ImgShow *obj = [ImgShow sharedImgShow];
    CGRect frameCur = [obj.imgShowView.aryImgFrames[obj.imgShowView.curIndex] CGRectValue];
    UIImage *imgCur = obj.imgShowView.aryImgs[obj.imgShowView.curIndex];
    
    if(imgViewAni == nil){
        imgViewAni = [UIView new];
        imgViewAni.layer.opaque = YES;
    }
    imgViewAni.layer.contents = (__bridge id _Nullable)(imgCur.CGImage);
    imgViewAni.layer.contentsGravity = kCAGravityResize; // 拉伸
    [imgViewAni setFrame:frameCur];
    CATransform3D transformTo = [[self class] getBeginTransform:frameCur withImg:imgCur withImgShowType:obj.imgShowType];
    [[UIApplication sharedApplication].delegate.window addSubview:imgViewAni];
    [[UIApplication sharedApplication].delegate.window bringSubviewToFront:imgViewAni];
    
    const float duration = 0.24f;
    
    // 点击的图片的动画效果
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.repeatCount = 1; // 不重复
    anim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity] ;
    anim.toValue = [NSValue valueWithCATransform3D:transformTo];
    anim.duration = duration;
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    anim.delegate = (id)obj;
    [imgViewAni.layer addAnimation:anim forKey:nil];
    
    [[self class] handleAniForBackView:duration];
}
+ (void) handleAniForBackView:(float)duration
{
    ImgShow *obj = [ImgShow sharedImgShow];
    switch(obj.imgShowType){
        case ImgShowType_Line:{
            __block ImgShowView_Line *view = (ImgShowView_Line*)obj.imgShowView;
            [view setBackViewAlpha:0.0f];
            [UIView animateWithDuration:duration animations:^{
                [view setBackViewAlpha:1.0f];
                view = nil;
            }];
            break;
        }
        case ImgShowType_Vertical:{
            __block ImgShowView_Vertical *view = (ImgShowView_Vertical*)obj.imgShowView;
            [view setBackViewAlpha:0.0f];
            [UIView animateWithDuration:duration animations:^{
                [view setBackViewAlpha:1.0f];
                view = nil;
            }];
            break;
        }
        case ImgShowType_Vertical_2:{
            __block ImgShowView_Vertical_2 *view = (ImgShowView_Vertical_2*)obj.imgShowView;
            [view setBackViewAlpha:0.0f];
            [UIView animateWithDuration:duration animations:^{
                [view setBackViewAlpha:1.0f];
                view = nil;
            }];
            break;
        }
    }
}

// =========================================================================================
#pragma mark - 类方法
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    ImgShow *obj = [ImgShow sharedImgShow];
    [obj.imgShowView beginShowImg:^{
        [imgViewAni removeFromSuperview];
    }];
}




@end
