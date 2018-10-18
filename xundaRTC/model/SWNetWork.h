//
//  SWNetWork.h
//  MIYA
//
//  Created by 宋薇 on 2017/3/20.
//  Copyright © 2017年 宋薇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
//请求成功回调block
typedef void (^requestSuccessBlock)(NSDictionary *dic);
typedef void (^datarequestSuccessBlock)(NSData *dicdata);

typedef void (^xmlrequestSuccessBlock)(NSXMLParser *parser);

//请求失败回调block
typedef void (^requestFailureBlock)(NSError *error);

//请求方法define
typedef enum {
    GET,
    POST,
    PUT,
    DELETE,
    HEAD,
    BODY,
    LOGIN
} HTTPMethod;


@interface SWNetWork : AFHTTPSessionManager
+ (instancetype)sharedManager;
- (void)requestWithMethod:(HTTPMethod)method
                 WithPath:(NSString *)path
               WithParams:(id)params
         WithSuccessBlock:(requestSuccessBlock)success
          WithFailurBlock:(requestFailureBlock)failure;

- (void)requestdataWithMethod:(HTTPMethod)method
                 WithPath:(NSString *)path
               WithParams:(id)params
         WithSuccessBlock:(datarequestSuccessBlock)success
          WithFailurBlock:(requestFailureBlock)failure;


- (void)networkWithURL:(NSString *)url pic:(UIImage *)image parameter:(NSDictionary *)paraDic success:(void (^)(id obj))success fail:(void (^)(NSError *error))fail;
@end
