//
//  SocketSignalingChannel.m
//  xundaRTC
//
//  Created by 大V on 2018/8/14.
//  Copyright © 2018年 season. All rights reserved.
//

#import "SocketSignalingChannel.h"

@implementation SocketSignalingChannel
-(id)init{
    self=[super init];
    
    return self;
}

- (void)addObserver:(id<RTCP2PSignalingChannelObserver>)observer {
    
}

- (void)connect:(NSString *)token onSuccess:(void (^)(NSString *))onSuccess onFailure:(void (^)(NSError *))onFailure {
    
}

- (void)disconnectWithOnSuccess:(void (^)())onSuccess onFailure:(void (^)(NSError *))onFailure {
    
}

- (void)removeObserver:(id<RTCP2PSignalingChannelObserver>)observer {
    
}

- (void)sendMessage:(NSString *)message to:(NSString *)targetId onSuccess:(void (^)())onSuccess onFailure:(void (^)(NSError *))onFailure {
    
}

@end
