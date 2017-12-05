//
//  ProcessDialog.m
//  TableViewDemo
//
//  Created by LHJ on 2017/11/17.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "ProcessDialog.h"
#import "CPublic.h"

static NSString *const KeyAnimation = @"KeyAnimation";
static NSString *const KeyAnimationKeyframe = @"KeyAnimationKeyframe";
static NSString *const KeyPath_AniKeyframe = @"KeyPath_AniKeyframe";

static ProcessDialog *staticProcessDialog = nil;

@interface ProcessDialog()<CAAnimationDelegate>

@property(nonatomic, retain) UIVisualEffectView *visualEffectView;

@property(nonatomic, retain) CAShapeLayer *shapeLayerProcess;

@property(nonatomic, retain) dispatch_source_t dispatchSource;

@property(nonatomic, retain) CADisplayLink *displayLink;

@property(nonatomic, retain) CATextLayer *textLayer;

@property(nonatomic, assign) float valueEnd;

@property(nonatomic, assign) float valueStart;

- (void) setProcessValueEnd:(float)value;

- (float) getProcessValueEnd;

- (float) getProcessValueStart;

- (void) setProcessValueStart:(float)value;

- (void) startTime;

@end

@implementation ProcessDialog

+ (instancetype) sharedProcessDialog
{
    if(staticProcessDialog == nil){
        staticProcessDialog = [ProcessDialog new];
    }
    return staticProcessDialog;
}
/** 0.0~1.0 */
+ (void) setProcess:(float)process
{
    ProcessDialog *dialog = [[self class] sharedProcessDialog];
    [dialog setProcessValueEnd:process];
}
- (void) setProcessValueEnd:(float)value
{
     _shapeLayerProcess.strokeEnd = value;
}

- (float) getProcessValueEnd
{
    return _shapeLayerProcess.strokeEnd;
}

- (float) getProcessValueStart
{
    return _shapeLayerProcess.strokeStart;
}

- (void) setProcessValueStart:(float)value
{
    _shapeLayerProcess.strokeStart = value;
}


+ (void) showDialog
{
    UIView *superView = [UIApplication sharedApplication].delegate.window.rootViewController.view;
    
    ProcessDialog *dialog = [[self class] sharedProcessDialog];
    [dialog setBackgroundColor:Color_Transparent];
    [dialog setFrame:superView.bounds];
    [superView addSubview:dialog];
    [superView bringSubviewToFront:dialog];
    [dialog startTime];
//    [dialog startEmitterCell];
}
+ (void) hideDialog
{
    ProcessDialog *dialog = [[self class] sharedProcessDialog];
    [dialog removeFromSuperview];
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if(CGRectIsEmpty(self.frame) == YES) { return; }

    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    [_visualEffectView.layer setCornerRadius:6.0f];
    [_visualEffectView.layer setMasksToBounds:YES];
    [self addSubview:_visualEffectView];

    const int height = 100;
    const int width = height;
    const int x = (CGRectGetWidth(self.bounds) - width)/2;
    const int y = (CGRectGetHeight(self.bounds) - height)/2;
    [_visualEffectView setFrame:CGRectMake(x, y, width, height)];

    [self initProcessLayer];
}
- (void) initProcessLayer
{
    CALayer *superLayer = _visualEffectView.layer;
    
    // ======= 灰色图层 =======
    CGPoint pointCenter = CGPointMake(superLayer.bounds.size.width/2, superLayer.bounds.size.height/2);
    const int cornerRedius = superLayer.bounds.size.width/5;
    const int lineWidth = cornerRedius;
    NSArray *aryLineDashPattern = @[@2, @4];
    
    CAShapeLayer *shapeLayerGray = [CAShapeLayer layer];
    [shapeLayerGray setFrame:superLayer.bounds];
    UIBezierPath *pathGray = [UIBezierPath bezierPath];
    [pathGray addArcWithCenter:pointCenter radius:cornerRedius startAngle:-M_PI/2 endAngle:M_PI*2 - M_PI/2 clockwise:YES];
    shapeLayerGray.path = pathGray.CGPath;
    shapeLayerGray.fillColor = [UIColor clearColor].CGColor;
    shapeLayerGray.strokeColor = [UIColor colorWithRed:0.64 green:0.71 blue:0.87 alpha:0.2].CGColor;
    shapeLayerGray.lineWidth = lineWidth;
    shapeLayerGray.lineDashPattern = aryLineDashPattern;
    [superLayer addSublayer:shapeLayerGray];
    
    // ======= 彩色图层 =======
    // 先创建渐变图层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    [gradientLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [gradientLayer setFrame:superLayer.bounds];
    [gradientLayer setColors:@[ (__bridge id)[UIColor orangeColor].CGColor,
                                (__bridge id)[UIColor greenColor].CGColor,
                                (__bridge id)RGB(190, 255, 230).CGColor]];
    [gradientLayer setLocations:@[@(0.35), @(0.5), @(0.60)]];
    [gradientLayer setStartPoint:CGPointMake(0, 0)];
    [gradientLayer setEndPoint:CGPointMake(1, 1)];
    [superLayer addSublayer:gradientLayer];
    
    // 虚线画圆
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setFrame:gradientLayer.bounds];

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:pointCenter radius:cornerRedius startAngle:-M_PI/2 endAngle:M_PI*2 - M_PI/2 clockwise:YES];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.lineDashPattern = aryLineDashPattern;
    shapeLayer.strokeEnd = 0.0f;
//    shapeLayer.strokeStart = 0.2f;
    gradientLayer.mask = shapeLayer;
    
    _shapeLayerProcess = shapeLayer;
    
    // 进度文本显示
    const static float fontSize = 12.0f;
    static NSString *const strTemp = @"100";
    float height = [strTemp boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                      attributes:@{NSFontAttributeName: Font(fontSize)}
                                         context:nil].size.height;
    CGRect frameText = superLayer.bounds;
    frameText.size.height = height;
    frameText.origin.y = (CGRectGetHeight(superLayer.bounds) - height)/2;
    
//    CATextLayer *textLayer = [CATextLayer layer];
//    [textLayer setFrame:frameText];
//    [textLayer setBackgroundColor:Color_Transparent.CGColor];
//    [textLayer setForegroundColor:RGB(255, 255, 255).CGColor];
//    [textLayer setAlignmentMode:kCAAlignmentCenter];
//    [textLayer setContentsScale:[UIScreen mainScreen].scale];
//    [textLayer setFontSize:fontSize];
//    [textLayer setString:@"90"];
//    [superLayer addSublayer:textLayer];
//
//    _textLayer = textLayer;
    
}
- (void) removeFromSuperview{
    [super removeFromSuperview];
    
    [self endTime];
    [self endAni];
}
- (void) endAni
{
    [self.shapeLayerProcess removeAllAnimations];
    
}

- (void) endTime
{
    if(_dispatchSource != nil){
        dispatch_source_cancel(_dispatchSource);
        _dispatchSource = nil;
    }
    
    if(_displayLink != nil){
        __weak typeof(self) wkSelf = self;
        [GCD GCDAsync_MainQueue:^{ // 确保在主线程
            [wkSelf.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            wkSelf.displayLink = nil;
        }];
    }
}
- (void) handleDisplayLink
{
    ProcessDialog *dialog = [[self class] sharedProcessDialog];
    [dialog setProcessValueEnd:dialog.valueEnd];
    [dialog setProcessValueStart:dialog.valueStart];
    
//    _textLayer.string = [NSString stringWithFormat:@"%i", (int)(dialog.valueEnd*100)];
}
- (void) startTime
{
    __weak typeof(self) wkSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        ProcessDialog *dialog = [[wkSelf class] sharedProcessDialog];

        const static float add = 0.05f;
        
        float valueEnd = [dialog valueEnd];
        if(valueEnd < 1.0f){
            dialog.valueEnd = valueEnd + add;
            dialog.valueEnd = (dialog.valueEnd > 1.0f)? 1.0f : dialog.valueEnd;
        } else { // 开始旋转
            [wkSelf endTime];
            [GCD GCDAsync_MainQueue:^{
                [wkSelf startAnimationForRotation];
            }];
        }
    });
    dispatch_resume(timer);
    _dispatchSource = timer;
    
    __block CADisplayLink *display = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink)];
    _displayLink = display;
    [GCD GCDAsync_MainQueue:^{ // 确保在主线程
        [display addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        display = nil;
    }];
}
/** 开启粒子效果 */
- (void) startEmitterCell
{
    ProcessDialog *dialog = [[self class] sharedProcessDialog];
    // 粒子效果
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.birthRate = 30;
    cell.lifetime = 10.0f;
    cell.velocity = 20.0f;
    cell.emissionLongitude = 0;
    cell.emissionRange = M_PI *2;    // 360 deg//周围发射角度
    cell.contents = (id)[UIImage imageNamed:@"FFTspark"].CGImage;
    cell.redRange = 0.6f;
    cell.greenRange = 0.6f;
    cell.blueRange = 0.6f;
    cell.alphaSpeed =-0.05f; //粒子透明度在生命周期内的改变速度
    cell.spin = 2* M_PI;  //子旋转角度
    cell.scale = 0.2f;
    cell.spinRange = 2* M_PI;  //子旋转角度范围
    
    CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
    emitterLayer.frame = dialog.visualEffectView.layer.bounds;
    emitterLayer.emitterSize = CGSizeMake(dialog.shapeLayerProcess.bounds.size.width/2, dialog.shapeLayerProcess.bounds.size.height/2);
    emitterLayer.emitterMode = kCAEmitterLayerOutline;//发射源模式
    emitterLayer.emitterShape = kCAEmitterLayerLine;//发射源的形状
    emitterLayer.renderMode = kCAEmitterLayerAdditive;//渲染模式
    emitterLayer.preservesDepth = YES;
    
    emitterLayer.seed = (arc4random()%100)+1;//用于初始化随机数产生的种子
    emitterLayer.emitterPosition = CGPointMake(CGRectGetWidth(emitterLayer.frame)/2, CGRectGetHeight(emitterLayer.frame)/2);
    emitterLayer.emitterCells = @[cell];
    //        [dialog.visualEffectView.layer addSublayer:emitterLayer];
    [dialog.visualEffectView.layer insertSublayer:emitterLayer below:dialog.shapeLayerProcess];
}
- (void) startAnimationForRotation{
    
    ProcessDialog *dialog = [[self class] sharedProcessDialog];
    // 开始加速的动画
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 2.0f;
    animation.cumulative = YES;
    animation.repeatCount = 1;
    animation.values = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat:0.0 * M_PI],
                        [NSNumber numberWithFloat:0.5 * M_PI],
                        [NSNumber numberWithFloat:1.0f * M_PI],
                        [NSNumber numberWithFloat:2.0 * M_PI], nil];
    animation.keyTimes = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0],
                          [NSNumber numberWithFloat:0.4],
                          [NSNumber numberWithFloat:0.6],
                          [NSNumber numberWithFloat:1.0], nil];
    animation.timingFunctions = [NSArray arrayWithObjects:
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], nil];
    animation.removedOnCompletion = YES;
    animation.delegate = (id)self;
    animation.fillMode = kCAFillModeBackwards;
    [animation setValue:KeyAnimationKeyframe forKey:KeyAnimation];
    
    [dialog.shapeLayerProcess addAnimation:animation forKey:KeyPath_AniKeyframe];

}
// ===============================================================
#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if([[anim valueForKey:KeyAnimation] isEqualToString:KeyAnimationKeyframe] == YES){ // 加速动画结束，开始循环动画
        ProcessDialog *dialog = [[self class] sharedProcessDialog];
        if([anim isRemovedOnCompletion] != YES){ // 先移除原动画
            [dialog.shapeLayerProcess removeAnimationForKey:KeyPath_AniKeyframe];
        }
        // 循环旋转的动画
        CABasicAnimation *animationRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animationRotation.fromValue = [NSNumber numberWithFloat:0];
        animationRotation.toValue = [NSNumber numberWithFloat:M_PI];
        animationRotation.duration = 0.8f;
        animationRotation.repeatCount = HUGE_VAL;
        [animationRotation setValue:KeyAnimationKeyframe forKey:KeyAnimation];
        [dialog.shapeLayerProcess addAnimation:animationRotation forKey:nil];
        
        
    }
}


@end
