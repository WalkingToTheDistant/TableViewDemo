//
//  GCD.m
//  TableViewDemo
//
//  Created by LHJ on 2017/10/27.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "GCD.h"

@implementation GCD

+ (void) GCDAsync_GlobalQueue:(void(^)(void)) block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}
+ (void) GCDAsync_MainQueue:(void(^)(void)) block
{
    dispatch_async(dispatch_get_main_queue(), block);
}
@end
