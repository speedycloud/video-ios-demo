//
//  SingleManager.h
//  miya_iphone
//
//  Created by 宋薇 on 2017/8/9.
//  Copyright © 2017年 宋薇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleManager : NSObject
+(SingleManager *)defaultManager;

@property (strong, nonatomic) NSString *appId;

@property (strong, nonatomic) NSString *channelId;

@property (strong, nonatomic) NSString *userId;

@end
