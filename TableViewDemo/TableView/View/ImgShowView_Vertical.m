//
//  ImgShowView_Layer.m
//  TableViewDemo
//
//  Created by LHJ on 2017/11/29.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "ImgShowView_Vertical.h"
#import "CPublic.h"

static NSString *const AnimationKey_Transform = @"Transform";
static NSString *const AnimationKey_Opacity = @"Opacity";
static NSString *const AnimationKey_Layer = @"Layer";
static NSString *const Key_AnimationGroup = @"Key_AnimationGroup";

@interface ImgShowView_Vertical()<CAAnimationDelegate>

@property(nonatomic, retain) UIView *viewWhiteColor;

@property(nonatomic, retain) UIView *backgroundView;

@property(nonatomic, assign) BOOL beginShow;

@property(nonatomic, retain) NSMutableArray<UIView*> *muAryViewSave;

@property(nonatomic, retain) NSMutableArray<UIView*> *muAryViewShow;

@property(nonatomic, retain) NSMutableArray<NSValue*> *muAryTransfrom;

@property(nonatomic, retain) NSMutableArray<NSNumber*> *muAryAlpha;

@property(nonatomic, retain) UIView *viewContainter;

@property(nonatomic, assign) int numOfShowView;

@property(nonatomic, retain) UIPanGestureRecognizer *panGes;

@property(nonatomic, assign) CGPoint pointBeginTouch;

@property(nonatomic, assign) BOOL isMoveAlready;

@property(nonatomic, retain) NSMutableDictionary<NSString*, NSMutableArray*> *muDicAnimation;

@end

@implementation ImgShowView_Vertical

static CGRect st_frameOri;

// =============================================================================
#pragma mark - 元类方法
/** 获取该图片展示效果的出现动画的Transform3D */
+ (CATransform3D) getBeginTransform:(CGRect)frameBegin
                            withImg:(UIImage*)imgCur
{
    int widthImg = [UIScreen mainScreen].bounds.size.width*6/10;
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
- (void) removeFromSuperview
{
    [super removeFromSuperview];
    
    [_muAryViewSave removeAllObjects];
    [_muAryViewShow removeAllObjects];
    [_muDicAnimation removeAllObjects];
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
        [_backgroundView setUserInteractionEnabled:NO];
        [_backgroundView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_backgroundView];
        
        _viewContainter = [UIView new];
        [_viewContainter setFrame:self.bounds];
        [_viewContainter setUserInteractionEnabled:YES];
        [_viewContainter setBackgroundColor:Color_Transparent];
        [self addSubview:_viewContainter];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGes:)];
        [_viewContainter addGestureRecognizer:tapGes];

        _panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGes:)];
    }
    return self;
}
- (void) createTransfroms
{
    _numOfShowView = 5;
    _numOfShowView = (_numOfShowView <= self.aryImgs.count) ? _numOfShowView : (int)self.aryImgs.count;
    _muDicAnimation = [NSMutableDictionary new];
    
    if(_muAryTransfrom == nil){
        _muAryTransfrom = [NSMutableArray new];
    }
    if(_muAryAlpha == nil){
        _muAryAlpha = [NSMutableArray new];
    }
    
    const float scaleValue = 0.08f;
    for(int i=0; i<_numOfShowView; i+=1){
        CATransform3D transform = CATransform3DIdentity;
        
        if((i+1) == _numOfShowView){
            float scale = 1.0f - (scaleValue*(i-1));
            scale = (scale >= 0.f)? scale : 0.f;
            
            float ty = - (_viewContainter.bounds.size.height/2 + CGRectGetHeight(st_frameOri)/2);
            transform = CATransform3DTranslate(transform, 0, ty, 0);
            transform = CATransform3DScale(transform, scale, scale, 1);
            
        } else {
            float scale = 1 - (scaleValue*i);
            scale = (scale >= 0.f)? scale : 0.f;
            float ty = -(CGRectGetHeight(st_frameOri)/10)*i;
            transform = CATransform3DTranslate(transform, 0, ty, 0);
            transform = CATransform3DScale(transform, scale, scale, 1);
        }
        float alpha = 1.0f - (0.2f*i);
        alpha = (alpha >= 0.f)? alpha : 0.f;
        
        [_muAryTransfrom addObject:[NSValue valueWithCATransform3D:transform]];
        [_muAryAlpha addObject:[NSNumber numberWithFloat:alpha]];
    }
}
- (UIView*) getViewSave
{
    UIView *viewResult = nil;
    
    if(_muAryViewSave == nil){
        _muAryViewSave = [NSMutableArray new];
    }
    
    for(UIView *viewFor in _muAryViewSave){ // 复用
        if([viewFor superview] == nil){
            viewResult = viewFor;
        }
    }
    if(viewResult == nil) { // 没有就新建
        UIView *view = [UIView new];
        [view setBackgroundColor:Color_Transparent];
        [view setContentMode:UIViewContentModeScaleToFill];
        [view setUserInteractionEnabled:NO];
        [view.layer setContentsGravity:kCAGravityResize];
        [_muAryViewSave addObject:view];
        viewResult = view;
    }
    viewResult.layer.transform = CATransform3DIdentity;
    viewResult.layer.opacity = 1.0f;
    return viewResult;
}
/** 设置黑色背景的透明度 */
- (void) setBackViewAlpha:(float)alpha
{
    [_backgroundView setAlpha:alpha];
}
- (void) layoutSubviews{
    [super layoutSubviews];
    
    if(CGRectEqualToRect(self.frame, CGRectZero) == YES) { return; }
    
    if(_beginShow == YES){
        [self handleWhiteView];
    }
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
    [self createTransfroms];
    [self beginAniForImgShow];
}
- (void) beginAniForImgShow{ // 启动图片出现的动画
    
    CGRect frame = st_frameOri;
    NSInteger countFor = _numOfShowView;
    if(countFor > self.aryImgs.count){
        countFor = self.aryImgs.count;
    }
    
    if(_muAryViewShow == nil){
        _muAryViewShow = [NSMutableArray new];
    }
    
    for(int index=self.curIndex, num=0; num<countFor; num+=1){
        UIView *view = [self getViewSave];
        [view setUserInteractionEnabled:NO];
        [view setFrame:frame];
        [view setTag:num];
        UIImage *imgFor = self.aryImgs[index];
        view.layer.contents = (__bridge id)imgFor.CGImage;
        [_viewContainter addSubview:view];
        [_viewContainter sendSubviewToBack:view];
        
        [_muAryViewShow addObject:view];
        
        NSNumber *numAlpha = _muAryAlpha[num];
        CATransform3D transform = [_muAryTransfrom[num] CATransform3DValue];
        CATransform3D transformBegin = transform;
        if(index != self.curIndex){
            transformBegin = CATransform3DTranslate(transformBegin, 0, -40, 0);
        }
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.fromValue = [NSValue valueWithCATransform3D:transformBegin];
        animation.toValue = [NSValue valueWithCATransform3D:transform];
        
        CABasicAnimation *animationOpactity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        if(index == self.curIndex){
            animationOpactity.fromValue = @(1.0f);
        } else {
            animationOpactity.fromValue = @(0.0f);
        }
        animationOpactity.toValue = numAlpha;
        
        const float duration = 0.6f;
        CAAnimationGroup *animationGroup = [self createAnimationGroup:@[animation, animationOpactity]
                                                         withNumAlpha:numAlpha
                                                            withLayer:view.layer
                                                   withTransformValue:[NSValue valueWithCATransform3D:transform]
                                                              withBeginTime:(duration/2*num)
                                                         withDuration:duration];
        
        [self addAnimation:animationGroup withLayer:view.layer];
        
        index += 1;
        if(index >= self.aryImgs.count){
            index = 0;
        }
    }
    
    UIView *viewCur = [_muAryViewShow firstObject];
    if(viewCur != nil){
        [viewCur setUserInteractionEnabled:YES];
        [viewCur addGestureRecognizer:_panGes];
    }
}
- (CAAnimationGroup*) createAnimationGroup:(NSArray*)aryAnimation
                              withNumAlpha:(NSNumber*)numAlpha
                                 withLayer:(CALayer*)layer
                        withTransformValue:(NSValue*)valueTransform
                             withBeginTime:(CFTimeInterval)time
                              withDuration:(float)duration
{
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = aryAnimation;
    animationGroup.duration = duration;
    animationGroup.beginTime = time;
    animationGroup.fillMode = kCAFillModeBoth;
    animationGroup.removedOnCompletion = NO;
    animationGroup.delegate = (id)self;
    
    [animationGroup setValue:numAlpha forKey:AnimationKey_Opacity];
    [animationGroup setValue:layer forKey:AnimationKey_Layer];
    [animationGroup setValue:valueTransform forKey:AnimationKey_Transform];
    
    return animationGroup;
}
- (void) addAnimation:(CAAnimationGroup*)animation withLayer:(CALayer*)layer
{
    if([layer animationForKey:Key_AnimationGroup] != nil){ // 有动画正在执行
        NSString *strKey = [NSString stringWithFormat:@"%p", layer];
        NSMutableArray *muAry = _muDicAnimation[strKey];
        if(muAry == nil){
            muAry = [NSMutableArray new];
            [_muDicAnimation setObject:muAry forKey:strKey];
        }
        [muAry addObject:animation];
    } else {
        animation.beginTime = CACurrentMediaTime() + animation.beginTime;
        [layer addAnimation:animation forKey:Key_AnimationGroup];
    }
}
- (void) checkoutAnimationWithLayer:(CALayer*)layer
{
    NSString *strKey = [NSString stringWithFormat:@"%p", layer];
    NSMutableArray *muAry = _muDicAnimation[strKey];
    if(muAry != nil
        && muAry.count > 0){
        CAAnimationGroup *animation = [muAry firstObject];
        [muAry removeObject:animation];
        animation.beginTime = CACurrentMediaTime() + animation.beginTime*2;
        [layer addAnimation:animation forKey:Key_AnimationGroup];
    }
}

- (void) closeImgShowView:(UIView*)view
{
    CGRect frameView = view.frame;

    UIImageView *imgViewAni = [UIImageView new];
    UIImage *img = [view lhj_getCurrentImg];
    imgViewAni.image = img;
    [imgViewAni setContentMode:UIViewContentModeScaleToFill];
    [imgViewAni setBackgroundColor:Color_Transparent];
    
    [imgViewAni setFrame:frameView];
    [self addSubview:imgViewAni];
    [_viewContainter setHidden:YES];
    
    CGRect frameTo;
    if(self.curIndex < self.aryImgFrames.count){ // 开启动画
        frameTo = [self.aryImgFrames[self.curIndex] CGRectValue];

    } else {
        frameTo = frameView;
        if(CGRectGetMaxX(frameTo)/2 >= _viewContainter.bounds.size.width/2){
            frameTo.origin.x = _viewContainter.bounds.size.width;
        } else {
            frameTo.origin.x = _viewContainter.bounds.origin.x - frameTo.size.width;
        }
    }

    float tx = - ((CGRectGetMinX(frameView) - CGRectGetMinX(frameTo)  + CGRectGetWidth(frameView)/2 -  CGRectGetWidth(frameTo)/2));
    float ty = - ((CGRectGetMinY(frameView) - CGRectGetMinY(frameTo)  + CGRectGetHeight(frameView)/2 -  CGRectGetHeight(frameTo)/2));
    float scaleX = CGRectGetWidth(frameTo) / CGRectGetWidth(frameView);
    float scaleY = CGRectGetHeight(frameTo) / CGRectGetHeight(frameView);

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

// =============================================================================
#pragma mark - 处理动作的事件
/** 处理单击手势 */
- (void) handleTapGes:(UITapGestureRecognizer*)tapGes
{
    UIView *view = [_muAryViewShow firstObject];
    [self closeImgShowView:view];
}
- (void) handlePanGes:(UIPanGestureRecognizer*)panGes
{
    switch(panGes.state){
        case UIGestureRecognizerStateBegan:{
            [panGes setTranslation:CGPointZero inView:panGes.view];
            _pointBeginTouch = panGes.view.center;
            _isMoveAlready = NO;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint pointMove = [panGes translationInView:panGes.view];
            [panGes setTranslation:CGPointZero inView:panGes.view];
            CATransform3D transform = panGes.view.layer.transform;
            
            pointMove = [self handlePointMove:pointMove withViewMove:panGes.view];
            
            transform = CATransform3DTranslate(transform, pointMove.x, pointMove.y, 0);
            panGes.view.layer.transform = transform;
            [self handleViewMove:panGes.view];
            
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [self handleEndMove:panGes.view];
            break;
        }
        default:{
            break;
        }
    }
}
- (CGPoint) handlePointMove:(CGPoint)point withViewMove:(UIView*)viewMove
{
    float abs_x = fabs(point.x);
    
    CGPoint pointResult = point;
    const float angle = M_PI_2/3; // 30度角
    
    const float centerX = CGRectGetMinX(viewMove.frame) + CGRectGetWidth(viewMove.frame)/2;
    const float centerY = CGRectGetMinY(viewMove.frame) + CGRectGetHeight(viewMove.frame)/2;
    const float limitX = viewMove.center.x;
    const float limitY = viewMove.center.y;
    
    float resultY = tan(angle) * abs_x;
    if(centerX <= limitX){ // 在左边
        if(point.x <= 0){ // 正在向左滑动
            pointResult.y = resultY;
            
        } else { // 正在向右滑动
            pointResult.y = -resultY;
        }
        
    } else { // 在右边
        if(point.x >= 0){ // 正在向右滑动
            pointResult.y = resultY;
            
        } else { // 正在向左滑动
            pointResult.y = -resultY;
        }
    }
    if(centerY + pointResult.y < limitY){
        pointResult.y = (limitY - centerY);
    }
    
    return pointResult;
}
- (void) handleViewMove:(UIView*) viewMove
{
    const float valueLeft = CGRectGetWidth(_viewContainter.bounds)/4;
    const float valueRight = CGRectGetWidth(_viewContainter.bounds)*3/4;
    const float centerX = CGRectGetMinX(viewMove.frame) + CGRectGetWidth(viewMove.frame)/2;
    
    if(_isMoveAlready != YES
        && (centerX < valueLeft || centerX > valueRight)){
        _isMoveAlready = YES;
        [self moveImgItem:YES];
        
    } else if(_isMoveAlready == YES
                && (centerX >= valueLeft && centerX <= valueRight)){
        [self moveImgItem:NO];
        _isMoveAlready = NO;
    }
}
/** 是否移到下一个 */
- (void) moveImgItem:(BOOL)isNext
{
    int num = 0;
    for(int i=1; i<_muAryViewShow.count; i+=1){
        UIView *viewFor = _muAryViewShow[i];
        
        if(isNext == YES){
            num = i - 1;
        } else {
            num = i;
        }
        CATransform3D transform;
        if(num < _muAryTransfrom.count){
            transform = [_muAryTransfrom[num] CATransform3DValue];
        } else {
            transform = [[_muAryTransfrom lastObject] CATransform3DValue];
        }
        NSNumber *numAlpha;
        if(num < _muAryAlpha.count){
            numAlpha = _muAryAlpha[num];
        } else {
            numAlpha = [_muAryAlpha lastObject];
        }
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.toValue = [NSValue valueWithCATransform3D:transform];
        
        CABasicAnimation *animationOpactity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animationOpactity.toValue = numAlpha;
        
        const float duration = 0.2f;
        CFTimeInterval beginTime;
        if(isNext == YES){
            beginTime = duration/2 * num;
        } else {
            beginTime = duration/2 * (_muAryViewShow.count - num);
        }
        CAAnimationGroup *animationGroup = [self createAnimationGroup:@[animation, animationOpactity]
                                                         withNumAlpha:numAlpha
                                                            withLayer:viewFor.layer
                                                   withTransformValue:[NSValue valueWithCATransform3D:transform]
                                                        withBeginTime:beginTime
                                                         withDuration:duration];
        [self addAnimation:animationGroup withLayer:viewFor.layer];
        
    }
    if(isNext == YES){
        num += 1;
        int index = (self.curIndex + (int)_muAryViewShow.count) % self.aryImgs.count;
        
        UIView *viewLast = [self getViewSave];
        [viewLast setUserInteractionEnabled:NO];
        [viewLast setFrame:st_frameOri];
        [viewLast setTag:num];
        UIImage *img = self.aryImgs[index];
        viewLast.layer.contents = (__bridge id)img.CGImage;
        [_viewContainter addSubview:viewLast];
        [_viewContainter sendSubviewToBack:viewLast];
        [_muAryViewShow addObject:viewLast];
        
        CATransform3D transform = [_muAryTransfrom[num] CATransform3DValue];
        NSNumber *numAlpha = _muAryAlpha[num];
        viewLast.layer.transform = transform;
        viewLast.layer.opacity = [numAlpha floatValue];
    } else {
        UIView *viewLast = [_muAryViewShow lastObject];
        viewLast.layer.contents = nil;
        [viewLast removeFromSuperview];
        [_muAryViewShow removeLastObject];
    }
}
- (void) handleEndMove:(UIView*)viewMove
{
    const float centerX = CGRectGetMinX(viewMove.frame) + CGRectGetWidth(viewMove.frame)/2;
    const float valueDirection = CGRectGetWidth(_viewContainter.bounds)/2;
    if(_isMoveAlready == YES){ // 已经切换到下一个图片了，需要处理索引问题，把当前手势移动的图片View移除
        [viewMove removeGestureRecognizer:_panGes];
        CGRect frameTo = viewMove.frame;
        if(centerX < valueDirection){
            frameTo.origin.x = -CGRectGetWidth(viewMove.frame);
            
        } else {
            frameTo.origin.x = CGRectGetWidth(_viewContainter.bounds);
        }
        [UIView animateWithDuration:0.2f animations:^{
            viewMove.frame = frameTo;
            
        } completion:^(BOOL finished) {
            
            [viewMove removeFromSuperview];
            [_muAryViewShow removeObject:viewMove];
            self.curIndex += 1;
            if(self.curIndex >= self.aryImgs.count){
                self.curIndex = 0;
            }
            
            UIView *viewFirst = [_muAryViewShow firstObject];
            [viewFirst setUserInteractionEnabled:YES];
            [viewFirst addGestureRecognizer:_panGes];
        }];
        
    } else { // 没有切换，那么需要把正在手势移动的图片回复到原始位置
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        animation.fillMode = kCAFillModeBoth;
        animation.removedOnCompletion = NO;
        animation.delegate = (id)self;
        [animation setValue:@(viewMove.layer.opacity) forKey:AnimationKey_Opacity];
        [animation setValue:viewMove.layer forKey:AnimationKey_Layer];
        [animation setValue:[NSValue valueWithCATransform3D:CATransform3DIdentity] forKey:AnimationKey_Transform];
        
        [viewMove.layer addAnimation:animation forKey:@"animation"];
    }
}

// =============================================================================
#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CATransform3D transform = [(NSValue*)[anim valueForKey:AnimationKey_Transform] CATransform3DValue];
    float opacity = [(NSNumber*)[anim valueForKey:AnimationKey_Opacity] floatValue];
    CALayer *layer = [anim valueForKey:AnimationKey_Layer];
    
    layer.transform = transform;
    layer.opacity = opacity;
    [layer removeAllAnimations];
    [self checkoutAnimationWithLayer:layer];
}

@end
