//
//  SingleManager.m
//  miya_iphone
//
//  Created by 宋薇 on 2017/8/9.
//  Copyright © 2017年 宋薇. All rights reserved.
//

#import "SingleManager.h"

@implementation SingleManager
static SingleManager *s_singleManager = nil;
+(SingleManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_singleManager == nil) {
            s_singleManager = [[SingleManager alloc]init];
        }
    });
    return s_singleManager;
}

@end
