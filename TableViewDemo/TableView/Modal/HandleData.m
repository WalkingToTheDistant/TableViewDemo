//
//  HandleData.m
//  TableViewDemo
//
//  Created by LHJ on 2017/10/27.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "HandleData.h"

static NSCache *ImgCache = nil;

@implementation HandleData

+ (NSURL*) getFileURLWithResource:(NSString*)name withType:(NSString*) ext
{
    NSString *strPath = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    return [NSURL fileURLWithPath:strPath];
}

+ (void) work:(void(^)(NSArray<ItemData*>*listData))completeBlock
{
    NSMutableArray<ItemData*> *muAryResult = [NSMutableArray new];
    
    // --------------
    ItemData *data = [[ItemData alloc] initWithTitle:@"模特妹纸惊艳街头"];
    data.aryImgs = @[
                     [[self class] getFileURLWithResource:@"time-21" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-4" withType:@"jpg"]
                     ];
    data.itemStyle = ItemStyle_ThreeImgs;
    [muAryResult addObject:data];
    
    // --------------
    data = [[ItemData alloc] initWithTitle:@"2017会展中心大型车展正式开始，首日就接待10万游客，并完成5000订单"];
    data.aryImgs = @[
                     [[self class] getFileURLWithResource:@"time-0" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-1" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-2" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-3" withType:@"jpg"],
                     ];
    data.itemStyle = ItemStyle_Imgs_1;
    [muAryResult addObject:data];
    
    // --------------
    data = [[ItemData alloc] initWithTitle:@"世界那么大，浪一把！！！"];
    data.aryImgs = @[
                     [[self class] getFileURLWithResource:@"time-5" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-6" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-7" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-8" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"timg-24" withType:@"jpg"],
                     ];
    data.itemStyle = ItemStyle_Imgs_2;
    [muAryResult addObject:data];
    
    // --------------
    data = [[ItemData alloc] initWithTitle:@"漂亮妹纸图集"];
    data.aryImgs = @[
                     [[self class] getFileURLWithResource:@"time-10" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-11" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-12" withType:@"jpg"],
                     ];
    data.itemStyle = ItemStyle_ThreeImgs;
    [muAryResult addObject:data];
    
    // --------------
    data = [[ItemData alloc] initWithTitle:@"王者荣耀CosPlay"];
    data.aryImgs = @[
                     [[self class] getFileURLWithResource:@"time-18" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-19" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-14" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-15" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-16" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-17" withType:@"jpg"],
                     [[self class] getFileURLWithResource:@"time-20" withType:@"jpg"],
                     ];
    data.itemStyle = ItemStyle_Imgs_2;
    [muAryResult addObject:data];
    
    // --------------
    data = [[ItemData alloc] initWithTitle:@"日本富士山"];
    data.aryImgs = @[
                     [[self class] getFileURLWithResource:@"time-23" withType:@"jpg"]
                     ];
    data.itemStyle = ItemStyle_OneImg;
    [muAryResult addObject:data];
    
    if(completeBlock != nil){
        completeBlock(muAryResult);
    }
}
+ (void) handleImgWithURL:(NSURL*)url withCompleteBlock:(void(^)(UIImage *img)) completeBlock
{
    // 用 UIImage 或 CGImageSource 的那几个方法创建图片时，图片数据并不会立刻解码。图片设置到 UIImageView 或者 CALayer.contents 中去，并且 CALayer 被提交到 GPU 前，CGImage 中的数据才会得到解码。解决办法是：后台线程先把图片绘制到 CGBitmapContext 中，然后从 Bitmap 直接创建图片。
    [GCD GCDAsync_GlobalQueue:^{
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *imgResult  = [UIImage imageWithData:data];
        if(completeBlock != nil){
            completeBlock(imgResult);
        }
        
//        NSData *data = [NSData dataWithContentsOfURL:url];
//        UIImage *imgResult = nil;
//
//        if(data != nil){
//            UIImage *img = [UIImage imageWithData:data];
//            CGRect frame;
//            frame.origin = CGPointZero;
//            frame.size = img.size;
//
//            CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//            CGContextRef cxf = CGBitmapContextCreate( NULL,
//                                                     frame.size.width,
//                                                     frame.size.height,
//                                                     CGImageGetBitsPerComponent(img.CGImage),
//                                                     0,
//                                                     rgbColorSpace,
//                                                     kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
//            CGColorSpaceRelease(rgbColorSpace);
//            CGContextDrawImage(cxf, frame, img.CGImage);
//
//            img = nil;
//            data = nil;
//            CGImageRef imgRef = CGBitmapContextCreateImage(cxf);
//            imgResult = [UIImage imageWithCGImage:imgRef];
//            CGContextRelease(cxf);
//            CGImageRelease(imgRef);
//        }
//        if(completeBlock != nil){
//            completeBlock(imgResult);
//        }
       
    }];
}

+ (UIImage*) cache_getImgWithKey:(id)key
{
    if(ImgCache == nil) {
        return nil;
    }
    
    return [ImgCache objectForKey:key];
}

+ (void) cache_setImg:(UIImage*)img WithKey:(id)key
{
    if(ImgCache == nil){
        ImgCache = [NSCache new];
        ImgCache.totalCostLimit = 6 * 1024 * 1024; // 6MB
    }
    [ImgCache setObject:img forKey:key];
}
+ (int) getHeightForTextOfThreeRow
{
    static int height = 0;
    if(height == 0){
        NSString *str = @"一行\n二行\n三行";
        height = ceil([[self class] getFontSizeForStr:str].height);
    }
    return height;
}
+ (int) getHeightForTextOfTwoRow
{
    static int height = 0;
    if(height == 0){
        NSString *str = @"一行\n二行";
        height = ceil([[self class] getFontSizeForStr:str].height);
    }
    return height;
}
/** 获取文字的尺寸 */
+ (CGSize) getSizeForOneTextWithStr:(NSString*)str
                           withFont:(UIFont*)font
                        withMaxSize:(CGSize)maxSize
{
    return [[self class] getFontSizeForStr:str withFont:font withMaxSize:maxSize];
}
+ (CGSize) getFontSizeForStr:(NSString*)str
                 withFont:(UIFont*)font
              withMaxSize:(CGSize)maxSize
{
    CGSize sizeResult = [str boundingRectWithSize:maxSize
                                    options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                 attributes:@{NSFontAttributeName : font}
                                    context:nil].size;
    sizeResult.height = ceil(sizeResult.height);
    return sizeResult;
}
+ (CGSize) getFontSizeForStr:(NSString*)str
{
    return [[self class] getFontSizeForStr:str withFont:Font_Title withMaxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}
/** 获取文字的尺寸 */
+ (CGSize) getSizeForTitleFontWithStr:(NSString*)str withMaxSize:(CGSize)maxSize
{
    CGSize sizeResult = [[self class] getFontSizeForStr:str withFont:Font_Title withMaxSize:maxSize];
    return sizeResult;
}
+ (CGRect)getRelativePointForScreenWithView:(UIView *)v_view
{
    BOOL iOS7 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7;
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (iOS7 != YES) {
        screenHeight -= 20;
    }
    UIView *view = v_view;
    CGFloat x = .0;
    CGFloat y = .0;
    while (view.frame.size.width != screenWidth || view.frame.size.height != screenHeight) {
        x += view.frame.origin.x;
        y += view.frame.origin.y;
        view = view.superview;
        if ([view isKindOfClass:[UIScrollView class]]) {
            x -= ((UIScrollView *) view).contentOffset.x;
            y -= ((UIScrollView *) view).contentOffset.y;
        }
    }
    return CGRectMake(x, y, CGRectGetWidth(v_view.frame), CGRectGetHeight(v_view.frame));
}
+ (void) prepareImgWithURL:(NSURL*)url
{
    UIImage* obj = [HandleData cache_getImgWithKey:url];
    if(obj != nil){
        return;
    }
    [HandleData handleImgWithURL:url withCompleteBlock:^(UIImage *imgResult) {
        [HandleData cache_setImg:imgResult WithKey:url];
    }];
}

@end
