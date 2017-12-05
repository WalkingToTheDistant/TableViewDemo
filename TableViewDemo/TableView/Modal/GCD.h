//
//  GCD.h
//  TableViewDemo
//
//  Created by LHJ on 2017/10/27.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCD : NSObject

+ (void) GCDAsync_GlobalQueue:(void(^)(void)) block;

+ (void) GCDAsync_MainQueue:(void(^)(void)) block;

@end
