//
//  ImgShowView_Layer.m
//  TableViewDemo
//
//  Created by LHJ on 2017/11/29.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "ImgShowView_Vertical.h"
#import "CPublic.h"

@interface ImgShowView_Vertical()<CAAnimationDelegate>

@property(nonatomic, retain) UIView *viewWhiteColor;

@property(nonatomic, retain) UIView *backgroundView;

@property(nonatomic, assign) BOOL beginShow;

@property(nonatomic, retain) NSMutableArray<CALayer*> *muAryLayer;

@property(nonatomic, retain) UIView *viewLayerContainer;

@property(nonatomic, assign) float scaleChange;

@property(nonatomic, assign) float opacityChange;

@property(nonatomic, assign) CGPoint pointLastItem;

@property(nonatomic, assign) CGPoint pointFirstItem;

@property(nonatomic, assign) CGPoint pointMove;

@property(nonatomic, assign) float scrollY;

@property(nonatomic, assign) float scrollX;

@end

@implementation ImgShowView_Vertical

static CGRect st_frameOri;

// =============================================================================
#pragma mark - 元类方法
/** 获取该图片展示效果的出现动画的Transform3D */
+ (CATransform3D) getBeginTransform:(CGRect)frameBegin
                            withImg:(UIImage*)imgCur
{
    int widthImg = [UIScreen mainScreen].bounds.size.width*5/10;
    int heightImg = widthImg * 4/3;
    
    CATransform3D transformResult = CATransform3DIdentity;
    CGRect frameTo;
    frameTo.size.width = widthImg;
    frameTo.size.height = heightImg;
    frameTo.origin.x = ([UIScreen mainScreen].bounds.size.width - frameTo.size.width)/2;
    frameTo.origin.y = ([UIScreen mainScreen].bounds.size.height - frameTo.size.height)/2;
    
    st_frameOri = frameTo;
    
    int tx = (frameTo.origin.x - frameBegin.origin.x) + frameTo.size.width/2 - frameBegin.size.width/2;
    int ty = frameTo.origin.y - frameBegin.origin.y + frameTo.size.height/2 - frameBegin.size.height/2;
    float sx = frameTo.size.width/frameBegin.size.width;
    float sy = frameTo.size.height/frameBegin.size.height;
    
    transformResult = CATransform3DTranslate(transformResult, tx, ty, 0);
    transformResult = CATransform3DScale(transformResult, sx, sy, 1.0f);
    return transformResult;
}

// =============================================================================
#pragma mark - 类方法
- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil){
        [self setBackgroundColor:Color_Transparent];
        
        _viewWhiteColor = [UIView new];
        [_viewWhiteColor setBackgroundColor:[UIColor whiteColor]];
        [_viewWhiteColor setUserInteractionEnabled:NO];
        [self addSubview:_viewWhiteColor];
        
        _backgroundView = [UIView new];
        [_backgroundView setFrame:self.bounds];
        [_backgroundView setUserInteractionEnabled:YES];
        [_backgroundView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_backgroundView];
        
        _viewLayerContainer = [UIView new];
        [_viewLayerContainer setFrame:self.bounds];
        [_viewLayerContainer setUserInteractionEnabled:YES];
        [_viewLayerContainer setBackgroundColor:Color_Transparent];
        [self addSubview:_viewLayerContainer];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGes:)];
        [_viewLayerContainer addGestureRecognizer:tapGes];
        
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGes:)];
        [_viewLayerContainer addGestureRecognizer:panGes];
        
        _muAryLayer = [NSMutableArray new];
    }
    return self;
}
- (CALayer*) getLayer
{
    CALayer *layerResult = nil;
    
    for(CALayer *layerFor in _muAryLayer){ // 复用
        if([layerFor superlayer] == nil){
            layerResult = layerFor;
        }
    }
    if(layerResult == nil) { // 没有就新建
        if(_muAryLayer == nil){
            _muAryLayer = [NSMutableArray new];
        }
        CALayer *layer = [CALayer new];
        [layer setBackgroundColor:Color_Transparent.CGColor];
        [layer setContentsGravity:kCAGravityResize];
        
        [_muAryLayer addObject:layer];
        layerResult = layer;
    }
    return layerResult;
}
/** 设置黑色背景的透明度 */
- (void) setBackViewAlpha:(float)alpha
{
    [_backgroundView setAlpha:alpha];
}
- (void) layoutSubviews{
    [super layoutSubviews];
    
    if(CGRectEqualToRect(self.frame, CGRectZero) == YES) { return; }
    
    [self handleWhiteView];
}
- (void) handleWhiteView
{
    if(_viewWhiteColor != nil
       && self.curIndex < self.aryImgFrames.count){
        [_viewWhiteColor setHidden:NO];
        CGRect frame = [self.aryImgFrames[self.curIndex] CGRectValue];
        [_viewWhiteColor setFrame:frame];
        [self sendSubviewToBack:_viewWhiteColor]; // 保持在最底层
    } else {
        [_viewWhiteColor setHidden:YES];
    }
}
/** 开始显示图片 */
- (void) beginShowImg
{
    _beginShow = YES; // 开启显示图片
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self beginAniForImgShow];
}
- (void) beginAniForImgShow{ // 启动图片出现的动画
    
    _scaleChange = 0.15f;
    _opacityChange = 0.2f;
    
    NSMutableArray<CALayer*> *muAryTemp = [NSMutableArray new];
    
    CGRect frame = st_frameOri;
    
    int zPosition = 0;
    UIImage *img = self.aryImgs[self.curIndex];
    CALayer *layerFirst = [self getLayer];
    [layerFirst setFrame:frame];
    layerFirst.contents = (__bridge id)img.CGImage;
    [_viewLayerContainer.layer addSublayer:layerFirst];
    [muAryTemp addObject:layerFirst];
    layerFirst.zPosition = zPosition;
    
    int lastHeight = CGRectGetHeight(st_frameOri);
    int ty = 0;
    float sz = 0.8f;
    float opacity = 0.8f;
    int indexBegin = self.curIndex + 1;
    CATransform3D transformLast = CATransform3DIdentity;
    CALayer *layerLast = nil;
    
    for(int i=0, index=0; i<self.aryImgs.count && index<3; i+=1, index+=1){
        if(indexBegin >= self.aryImgs.count){
            indexBegin = 0;
        }
        int height = lastHeight*sz;
        ty += - height/2;
        lastHeight = height;
        zPosition -= 1;
        UIImage *imgFor = self.aryImgs[indexBegin];
        CALayer *layerFor  = [self getLayer];
        layerFor.contents = (__bridge id)imgFor.CGImage;;
        [layerFor setFrame:frame];
        layerFor.zPosition = zPosition;
        [_viewLayerContainer.layer addSublayer:layerFor];
        
        CATransform3D transformFor = layerFor.transform;
        transformFor = CATransform3DTranslate(transformFor, 0, ty, 0);
        transformFor = CATransform3DScale(transformFor, sz, sz, 1.0f);
        
        [muAryTemp addObject:layerFor];
        
        // ---- 开始动画
        const int aniY = ty-40;
        CATransform3D transformAni = CATransform3DIdentity;
        transformAni = CATransform3DTranslate(transformAni, 0, aniY, 0);
        transformAni = CATransform3DScale(transformAni, sz, sz, 1.0f);
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.fromValue = [NSValue valueWithCATransform3D:transformAni];
        animation.toValue = [NSValue valueWithCATransform3D:transformFor];

        CABasicAnimation *animationOpactity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animationOpactity.fromValue = @(0.0f) ;
        animationOpactity.toValue = @(opacity);

        const float duration = 0.8f;
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[animation, animationOpactity];
        animationGroup.duration = duration;
        animationGroup.beginTime = CACurrentMediaTime() + duration/2 * index;
        animationGroup.fillMode = kCAFillModeBoth;
        animationGroup.removedOnCompletion = NO;
        animationGroup.delegate = (id)self;
        [animationGroup setValue:[NSValue valueWithCATransform3D:transformFor] forKey:@"transform"];
        [animationGroup setValue:[NSNumber numberWithFloat:opacity] forKey:@"opacity"];
        [animationGroup setValue:layerFor forKey:@"layer"];
        
        [layerFor addAnimation:animationGroup forKey:@"animationGroup"];
        
        indexBegin += 1;
        opacity -= _opacityChange;
        sz -= _scaleChange;
        
        transformLast = transformFor;
        layerLast = layerFor;
    }
    if(layerLast != nil){
        CALayer *layerTemp = [CALayer layer];
        [layerTemp setFrame:layerLast.frame];
        layerTemp.transform = transformLast;
        
        _pointLastItem = CGPointMake(CGRectGetMinX(layerTemp.frame) + CGRectGetWidth(layerTemp.frame)/2,
                                     CGRectGetMinY(layerTemp.frame) + CGRectGetHeight(layerTemp.frame)/2);
        layerTemp = nil;
    }
    if(layerFirst != nil){
        CALayer *layerTemp = [CALayer layer];
        [layerTemp setFrame:layerFirst.frame];
        layerTemp.transform = layerFirst.transform;
        _pointFirstItem = CGPointMake(CGRectGetMinX(layerFirst.frame) + CGRectGetWidth(layerFirst.frame)/2,
                                      CGRectGetMinY(layerFirst.frame) + CGRectGetHeight(layerFirst.frame)/2);
        layerTemp = nil;
    }
    
    for(CALayer *layerFor in _muAryLayer){
        if([muAryTemp containsObject:layerFor] != YES){
            [layerFor removeFromSuperlayer];
        }
    }
    [muAryTemp removeAllObjects];
    muAryTemp = nil;
}
- (void) closeImgShowView:(UIView*)view
{
    CGRect frameView = view.frame;
    
    UIImageView *imgViewAni = [UIImageView new];
    UIImage *img = [view lhj_getCurrentImg];
    imgViewAni.image = img;
    [imgViewAni setContentMode:UIViewContentModeScaleToFill];
    [imgViewAni setBackgroundColor:Color_Transparent];
    
    const int imgWidth = img.size.width;
    const int imgHeight = img.size.height;
    float valueWidth = frameView.size.width / imgWidth;
    float valueHeight = frameView.size.height / imgHeight;
    CGRect frameCur;
    if(valueWidth <= valueHeight){
        frameCur.size.width = frameView.size.width;
        frameCur.size.height = frameView.size.width * imgHeight/ imgWidth;
        frameCur.origin.x = frameView.origin.x;
        frameCur.origin.y = CGRectGetMinY(frameView) + CGRectGetHeight(frameView)/2 - frameCur.size.height/2;
        
    } else {
        frameCur.size.height = view.bounds.size.height;
        frameCur.size.width = view.bounds.size.height * imgWidth/imgHeight;
        frameCur.origin.x = CGRectGetMinX(frameView) + CGRectGetWidth(frameView)/2 - frameCur.size.width/2;
        frameCur.origin.y = view.frame.origin.y;
    }
    [imgViewAni setFrame:frameCur];
    [self addSubview:imgViewAni];
    [_viewLayerContainer setHidden:YES];
    CGRect frameTo;
    
    if(self.curIndex < self.aryImgFrames.count){ // 开启动画
        frameTo = [self.aryImgFrames[self.curIndex] CGRectValue];
        
    } else {
        frameTo = frameCur;
        if(CGRectGetMaxX(frameTo)/2 >= self.bounds.size.width/2){
            frameTo.origin.x = self.bounds.size.width;
        } else {
            frameTo.origin.x = self.bounds.origin.x - frameTo.size.width;
        }
    }
    
    float tx = - ((CGRectGetMinX(frameCur) - CGRectGetMinX(frameTo)  + CGRectGetWidth(frameCur)/2 -  CGRectGetWidth(frameTo)/2));
    float ty = - ((CGRectGetMinY(frameCur) - CGRectGetMinY(frameTo)  + CGRectGetHeight(frameCur)/2 -  CGRectGetHeight(frameTo)/2));
    float scaleX = CGRectGetWidth(frameTo) / CGRectGetWidth(frameCur);
    float scaleY = CGRectGetHeight(frameTo) / CGRectGetHeight(frameCur);
    
    CATransform3D transformTo = imgViewAni.layer.transform;
    transformTo = CATransform3DTranslate(transformTo, tx, ty, 0.0f);
    transformTo = CATransform3DScale(transformTo, scaleX, scaleY, 1.0f);
    [UIView animateWithDuration:0.2f animations:^{
        imgViewAni.layer.transform = transformTo;
        [_backgroundView setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
/** 处理滚动手势的图片滚动 */
- (void) handleScrollValue:(float) scrollValue
{
    NSArray<CALayer*> *arySublayers = _viewLayerContainer.layer.sublayers;
    for(CALayer *layer in arySublayers){
        
        CATransform3D transform = layer.transform;
        
        float positionY = CGRectGetMinY(layer.frame) + CGRectGetHeight(layer.frame)/2;
        if(positionY >= _pointFirstItem.y){ // 开始向左右移动
            int changeX  = scrollValue;
//            int changeY = scrollValue/2;
            transform = CATransform3DTranslate(transform, changeX, 0, 0);
            
        } else if(positionY <= _pointLastItem.y){
            int changeY = scrollValue;
            transform = CATransform3DTranslate(transform, 0, changeY, 0);
            
        } else {
//            float height = CGRectGetHeight(layer.frame)/2;
//            float changeY = scrollValue * transform.m11;
//            float opactity = layer.opacity + changeY/height * _opacityChange;
////            scale = scale + changeY;
//            float scale = 1.0f + changeY/height * _scaleChange;
//            opactity = (opactity <= 1.0f)? opactity : 1.0f;
//
//            transform = CATransform3DTranslate(transform, 0, changeY, 0);
//            transform = CATransform3DScale(transform, scale, scale, 1.0f);
//            layer.opacity = opactity;
        }
        layer.transform = transform;
    }
}

// =============================================================================
#pragma mark - 处理动作的事件
/** 处理单击手势 */
- (void) handleTapGes:(UITapGestureRecognizer*)tapGes
{
    [self closeImgShowView:tapGes.view];
}
- (void) handlePanGes:(UIPanGestureRecognizer*)panGes
{
    switch(panGes.state){
        case UIGestureRecognizerStateBegan:{
//            [panGes setTranslation:CGPointZero inView:panGes.view];
            _pointMove = [panGes locationInView:panGes.view];
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            CGPoint point = [panGes locationInView:panGes.view];
            float x = -(_pointMove.x - point.x);
            float y = -(_pointMove.y - point.y);
            _pointMove = point;
            
            _scrollX += x;
            _scrollY += y;
            CATransform3D transform = CATransform3DIdentity;
            transform = CATransform3DTranslate(transform, _scrollX, _scrollY, 0);
            [_muAryLayer firstObject].transform = transform;

//            CGPoint pointMove = [panGes translationInView:panGes.view];
//            [panGes setTranslation:CGPointZero inView:panGes.view];
            
//            _scrollY = (fabs(pointMove.x) > fabs(pointMove.y))?  pointMove.x : pointMove.y;
            
//            int directionX = (pointMove.x < CGRectGetWidth(panGes.view.bounds)/2)? -1 : 1;
//            CATransform3D transform = panGes.view.layer.transform;
//
////            CATransform3D transform = panGes.view.layer.transform;
//            CALayer *layer1 = [_muAryLayer firstObject];
//            CALayer *layer2 = panGes.view.layer;
//            CATransform3D transform1 = layer1.transform;
//            CATransform3D transform2 = layer2.transform;
//
//            transform = CATransform3DTranslate(transform, pointMove.x, pointMove.y, 0);
//            panGes.view.layer.transform = transform;
//            panGes.view.layer.transform = transform;
            
//            [self handleScrollValue:_scrollY];
            
            break;
        }
        case UIGestureRecognizerStateEnded:{
            break;
        }
        default:{
            break;
        }
    }
}
// =============================================================================
#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CATransform3D transform = [(NSValue*)[anim valueForKey:@"transform"] CATransform3DValue];
    float opacity = [(NSNumber*)[anim valueForKey:@"opacity"] floatValue];
    CALayer *layer = [anim valueForKey:@"layer"];
    
    layer.transform = transform;
    layer.opacity = opacity;
    [layer removeAllAnimations];
}

@end
