//
//  ImgShowView_Line.m
//  TableViewDemo
//
//  Created by LHJ on 2017/11/7.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "ImgShowView_Line.h"
#import "CPublic.h"
#import "CollectionCell_Line.h"

@interface ImgShowView_Line()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching>

@property(nonatomic, retain) UIView *viewWhiteColor;

@property(nonatomic, retain) UIView *backgroundView;

@property(nonatomic, retain) UICollectionView *collectionView;

@property(nonatomic, assign) BOOL beginShow;

@end

@implementation ImgShowView_Line

// =============================================================================
#pragma mark - 元类方法
+ (CATransform3D) getBeginTransform:(CGRect)frameBegin
                            withImg:(UIImage*)imgCur
{
    CATransform3D transformResult = CATransform3DIdentity;
    CGRect frameTo;
    float valueWidth = [UIScreen mainScreen].bounds.size.width / imgCur.size.width;
    float valueHeight = [UIScreen mainScreen].bounds.size.height / imgCur.size.height;
    if(valueWidth <= valueHeight){
        frameTo.size.width = [UIScreen mainScreen].bounds.size.width;
        frameTo.size.height = valueWidth * imgCur.size.height;
        frameTo.origin.x = 0;
        frameTo.origin.y = ([UIScreen mainScreen].bounds.size.height - frameTo.size.height)/2;
    } else {
        frameTo.size.height = [UIScreen mainScreen].bounds.size.height;
        frameTo.size.width = valueHeight * imgCur.size.width;
        frameTo.origin.y = 0;
        frameTo.origin.x = ([UIScreen mainScreen].bounds.size.width - frameTo.size.width)/2;
    }
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
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = self.bounds.size;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.pagingEnabled = YES;
        [_collectionView setDataSource:(id)self];
        [_collectionView setDelegate:(id)self];
        [_collectionView setBackgroundColor:Color_Transparent];
        [_collectionView registerClass:[CollectionCell_Line class] forCellWithReuseIdentifier:@"CollectionCell_Line"];
        [self addSubview:_collectionView];
        
#ifdef __IPHONE_10_0
        if([[UIDevice currentDevice].systemVersion floatValue] >= 10.0f){
            [_collectionView setPrefetchDataSource:(id)self];
        }
#endif
    }
    return self;
}
/** 设置黑色背景的透明度 */
- (void) setBackViewAlpha:(float) alpha
{
    [_backgroundView setAlpha:alpha];
}
- (void) layoutSubviews{
    [super layoutSubviews];
    
    if(CGRectEqualToRect(self.frame, CGRectZero) == YES) { return; }
    
    [self handleWhiteView];
    if(_beginShow == YES){
        int x = self.bounds.size.width * self.curIndex;
        [_collectionView setContentOffset:CGPointMake(x, 0)];
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
    [_collectionView reloadData];
    [self setNeedsLayout];
    [self layoutIfNeeded];
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
    float valueWidth =  frameView.size.width / imgWidth;
    float valueHeight =  frameView.size.height / imgHeight;
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
    [_collectionView setHidden:YES];
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
- (void) resetImgShowView:(UIView*)view
{
    [UIView animateWithDuration:0.5f animations:^{
        view.layer.transform = CATransform3DIdentity;
        [_backgroundView setAlpha:1.0f];
    }];
}

// =============================================================================
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (_beginShow == YES)? self.aryImgHDURLs.count : 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCell_Line *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell_Line" forIndexPath:indexPath];
    [cell setTag:indexPath.row];
    UIImage *img = (indexPath.row < self.aryImgs.count)? self.aryImgs[indexPath.row] : nil;
    NSURL *urlHD = (indexPath.row < self.aryImgHDURLs.count)? self.aryImgHDURLs[indexPath.row] : nil;
    
    if(img != nil){
        [cell setImg:img withHDImgURL:urlHD];
    } else {
        [cell setHDImgURL:urlHD];
    }
    
    __weak typeof(self) wkSelf = self;
    [cell setPanGestureBlock:^(id cell, UIPanGestureRecognizer *panGes) {
        [wkSelf handlePanGes:panGes withRow:(int)((UICollectionViewCell*)cell).tag];
    }];
    [cell setTapGestureBlock:^(id cell, UITapGestureRecognizer *tapGes) {
        [wkSelf handleTapGes:tapGes withRow:(int)((UICollectionViewCell*)cell).tag];
    }];
    
    return cell;
}
// =============================================================================
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}
// =============================================================================
#ifdef __IPHONE_10_0
#pragma mark - UICollectionViewDataSourcePrefetching
// indexPaths are ordered ascending by geometric distance from the collection view
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths NS_AVAILABLE_IOS(10_0)
{
    // 预先加载数据
    for(NSIndexPath *index in indexPaths){
        NSURL *urlHD = (index.row < self.aryImgHDURLs.count)? self.aryImgHDURLs[index.row] : nil;
        [HandleData prepareImgWithURL:urlHD];
    }
}
#endif

// =============================================================================
#pragma mark - UIScrollViewDelegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.curIndex = floor(scrollView.contentOffset.x /scrollView.bounds.size.width);
    [self handleWhiteView];
}

// =============================================================================
#pragma mark - 处理动作的事件
/** 处理单击手势 */
- (void) handleTapGes:(UITapGestureRecognizer*)tapGes withRow:(int)row
{
    [self closeImgShowView:tapGes.view];
}
/** 处理拖动手势 */
- (void) handlePanGes:(UIPanGestureRecognizer*) panGes withRow:(int)row
{
    if(_collectionView.dragging == YES
        || _collectionView.decelerating == YES){ // 正在滑动UIScrollView
        return;
    }
    static float alpha = 1.0f;
    switch(panGes.state){
        case  UIGestureRecognizerStateBegan:{
            [panGes setTranslation:CGPointZero inView:panGes.view];
            alpha = 1.0f;
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [_collectionView setScrollEnabled:NO];
            CGPoint pointMove = [panGes translationInView:panGes.view];
            [panGes setTranslation:CGPointZero inView:panGes.view];
            CATransform3D transform = panGes.view.layer.transform;
            
            float value = ((pointMove.y / (self.bounds.size.height/2)));
            float scale = 1.0f - value/2;
            
            alpha -= value;
            if(alpha < 0){
                alpha = 0.0f;
            } else if(alpha > 1.0f){
                alpha = 1.0f;
            }
            
            transform = CATransform3DTranslate(transform, pointMove.x, pointMove.y, 0);
            transform = CATransform3DScale(transform, scale, scale, 1.0f);
            panGes.view.layer.transform = transform;
            
            [_backgroundView setAlpha:alpha];
            
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [_collectionView setScrollEnabled:YES];
            if(alpha <= 0.5f){// 关闭图片浏览View
                [self closeImgShowView:panGes.view];
            } else{
                [self resetImgShowView:panGes.view];
            }
            
            break;
        }
        default:{
            break;
        }
    }
}
@end
