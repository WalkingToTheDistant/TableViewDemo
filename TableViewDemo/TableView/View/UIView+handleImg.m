//
//  UIView+handleImg.m
//  TableViewDemo
//
//  Created by LHJ on 2017/10/27.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "UIView+handleImg.h"
#import "HandleData.h"

@implementation UIView (handleImg)

- (void) lhj_setImgWithURL:(NSURL*)url
{
    [self lhj_setImgWithURL:url withConerRadius:0];
}

- (void) lhj_setImgWithURL:(NSURL*)url withConerRadius:(float)radius;
{
    if(url == nil){
        self.layer.contents = nil;
        return;
    }
    
    UIImage* obj = [HandleData cache_getImgWithKey:url];
    if(obj != nil){
        self.layer.contents = (__bridge id _Nullable)(obj.CGImage);
        return;
    }
    const float widthBound = self.bounds.size.width; // 在主线程使用
    __weak typeof(self) wkSelf = self;
    [HandleData handleImgWithURL:url withCompleteBlock:^(UIImage *img) {
        
        if(radius > 0){
            CGSize size = img.size;
            float valueWidth = radius/widthBound;
            float newRadius = valueWidth * size.width;
            
            UIGraphicsBeginImageContextWithOptions(size, NO, 0);
            CGRect rect = CGRectMake(0, 0, size.width, size.height);
            
            if(valueWidth == 0.5){
                if(size.width > size.height){
                    newRadius = size.height/2;
                } else {
                    newRadius = size.width/2;
                }
                UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(size.width/2, size.height/2) radius:newRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
                [path addClip]; // 裁剪
//                strContentsGra = kCAGravityResizeAspectFill;
            } else {
                CGRect rectPath = rect;
                rectPath.size.height -= 2; // 需要往上移动2个坐标点，不然会出现断边
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rectPath cornerRadius:newRadius];
                [path addClip]; // 裁剪
            }
            
            [img drawInRect:rect];
            img = nil;
            
            img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        [GCD GCDAsync_MainQueue:^{
            
            __block NSString *strContentsGra = kCAGravityResizeAspect;
            if(self.contentMode == UIViewContentModeScaleAspectFill){
                strContentsGra = kCAGravityResizeAspectFill;
            } else if(self.contentMode == UIViewContentModeScaleToFill){
                strContentsGra = kCAGravityResize;
            }
            
            wkSelf.layer.contentsGravity = strContentsGra;
            wkSelf.layer.contentsScale = [UIScreen mainScreen].scale;
            if(img != nil){
                wkSelf.layer.contents = (__bridge id _Nullable)(img.CGImage);
            } else {
                wkSelf.layer.contents = nil;
            }
            strContentsGra = nil;
        }];
        [HandleData cache_setImg:img WithKey:url];
    }];
}
- (UIImage*) lhj_getCurrentImg
{
    return [UIImage imageWithCGImage:(__bridge CGImageRef _Nonnull)(self.layer.contents)];
}


@end
