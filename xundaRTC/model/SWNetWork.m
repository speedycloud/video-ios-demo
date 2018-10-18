//
//  SWNetWork.m
//  ZBSR
//
//  Created by 宋薇 on 2017/1/6.
//  Copyright © 2017年 宋薇. All rights reserved.
//

#import "SWNetWork.h"

@implementation SWNetWork
+ (instancetype)sharedManager {
    static SWNetWork *manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"https://speedyrtc.xdylive.cn/api/1.0"]];
    });
    return manager;
}
-(instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        // 请求超时设定
        self.requestSerializer.timeoutInterval = 5;
        self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:url.absoluteString forHTTPHeaderField:@"Referer"];
        
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
        
        self.securityPolicy.allowInvalidCertificates = YES;
    }
    return self;
}

- (void)networkWithURL:(NSString *)url pic:(UIImage *)image parameter:(NSDictionary *)paraDic success:(void (^)(id obj))success fail:(void (^)(NSError *error))fail {
    //NSURLSession 配置信息
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    //创建请求
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:paraDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //在这里提交图片/视频/音频文件
        //把图片转为NSData
        //第一个参数是 data
        //第二个参数是服务器提供的字段名
        //第三个字段随意
        //第四个参数文件类型
        NSData *data = UIImageJPEGRepresentation(image, 0.5);
        [formData appendPartWithFileData:data name:@"file" fileName:[NSString stringWithFormat:@"%f.png", [[NSDate date] timeIntervalSince1970]] mimeType:@"image/png"];
    } error:nil];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            fail(error);
        } else {
            success(responseObject);
        }
    }];
    //开启任务
    [dataTask resume];
    
}

- (void)requestWithMethod:(HTTPMethod)method
                 WithPath:(NSString *)path
               WithParams:(id)params
         WithSuccessBlock:(requestSuccessBlock)success
          WithFailurBlock:(requestFailureBlock)failure
{
    switch (method) {
        case GET:{
            [self GET:path parameters:params progress:nil success:^(NSURLSessionTask *task, NSDictionary * responseObject) {
                success(responseObject);
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                failure(error);
            }];
            break;
        }
        case POST:{
            [self POST:path parameters:params progress:nil success:^(NSURLSessionTask *task, NSDictionary * responseObject) {
                success(responseObject);
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                failure(error);
            }];
            break;
        }
        case BODY:{
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            
            NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:path parameters:params error:nil];
            
            req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
            [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//            [req setValue:@"application/json" forHTTPHeaderField:]];
            [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];

//            [req sethe:params];
//            manager.requestSerializer = [AFJSONRequestSerializer new];
//            manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
//            manager.responseSerializer = [AFHTTPResponseSerializer serializer];//响应
//            [manager.requestSerializer setValue:@"value"forHTTPHeaderField:@"key"];
            [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                if (!error) {
                    
                    NSLog(@"Reply JSON: %@", responseObject);
                    
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        
                        //处理你的数据
                        
                    }
                    
                } else {
                    
                    NSLog(@"Error: %@, %@, %@", error, response, responseObject);
                    
                }
                
               
            }] resume];
            
        }
            break;
        case LOGIN:{
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            
            NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:path parameters:params error:nil];
            
            req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
            [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [req setValue:@"QmFzaWN4dW5kYToxMjM=" forHTTPHeaderField:@"Authorization"];
//"Basic" +  Base64::Encode(username + ":" + password)
            [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                DebugLog(@"responseObject==%@",responseObject);

                if (!error) {
                    
                    
                } else {
                    
                }
            }] resume];
            
        }
            break;

        default:
            break;
    }
}
@end
