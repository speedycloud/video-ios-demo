//
//  RegisterViewController.m
//  xundaRTC
//
//  Created by 大V on 2018/7/31.
//  Copyright © 2018年 season. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController (){
    
    
    NSTimer         *codeTimer;
    int             counttime;

    
}

@property (nonatomic,strong)NSString *codeStr;

@end

@implementation RegisterViewController
@synthesize nameTF,emailTF,phoneTF,passwordTF,repasswordTF,codeTF;
@synthesize codeBtn,registerBtn;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(IBAction)backAction:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)registerAction:(UIButton*)sender{
    
    NSDictionary *postDic=DICT(self.phoneTF.text,@"phone",self.emailTF.text,@"email",self.passwordTF.text,@"password",self.nameTF.text,@"name",self.codeTF.text,@"sms",nil);
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postDic options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }

    NSString *path=[NSString stringWithFormat:@"%@/signup",BASE_URL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:path parameters:nil error:nil];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSData *body = jsonData;
    
    [request setHTTPBody:body];

    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            
            NSString *responseObjectstr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSDictionary *dic=[self dictionaryWithJsonString:responseObjectstr];
            if ([dic isKindOfClass:[NSDictionary class]]) {
                
                DebugLog(@"+++++++++dic is %@",dic);
                
                if ([[dic objectForKey:@"status"] intValue]==200) {

                    
                    
                    [self getlogin];
                    
                    
                    
                    
                    
                    
                    
                    
                }
                
            }
            
        }
        else{
            
        }
        
    }] resume];

    
}

-(void)getlogin{
    
    
    NSString *basestring=[NSString stringWithFormat:@"%@:%@",nameTF.text,passwordTF.text];
    NSData *data = [basestring dataUsingEncoding:NSUTF8StringEncoding];
    NSString *stringBase64 = [data base64EncodedStringWithOptions:0]; // base64格式的字符串
    NSString *headerStr=[NSString stringWithFormat:@"Basic %@",stringBase64];
    
    NSString *path=[NSString stringWithFormat:@"%@/login",BASE_URL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:path parameters:nil error:nil];
    
    [request addValue:headerStr forHTTPHeaderField:@"Authorization"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"Keep-alive" forHTTPHeaderField:@"Connection"];
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            
            DebugLog(@"======login success");
            
            NSString *responseObjectstr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSDictionary *dic=[self dictionaryWithJsonString:responseObjectstr];
            if ([dic isKindOfClass:[NSDictionary class]]) {
                NSDictionary *userdic=dic;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *expiresInStr;
                if ([[userdic objectForKey:@"expiresIn"] isEqual:[NSNull null]]) {
                    expiresInStr=@"";
                }else{
                    expiresInStr=[NSString stringWithFormat:@"%@",[userdic objectForKey:@"expiresIn"]];
                }
                [defaults setObject:expiresInStr forKey:@"expiresIn"];
                NSString *usernameStr;
                if ([[userdic objectForKey:@"username"] isEqual:[NSNull null]]) {
                    usernameStr=@"";
                }else{
                    usernameStr=[NSString stringWithFormat:@"%@",[[userdic objectForKey:@"user"] objectForKey:@"username"]];
                }
                [defaults setObject:usernameStr forKey:@"username"];
                NSString *firstnameStr;
                if ([[userdic objectForKey:@"firstname"] isEqual:[NSNull null]]) {
                    firstnameStr=@"";
                }else{
                    firstnameStr=[NSString stringWithFormat:@"%@",[[userdic objectForKey:@"user"] objectForKey:@"firstname"]];
                }
                [defaults setObject:firstnameStr forKey:@"firstname"];
                NSString *lastnameStr;
                if ([[userdic objectForKey:@"lastname"] isEqual:[NSNull null]]) {
                    lastnameStr=@"";
                }else{
                    lastnameStr=[NSString stringWithFormat:@"%@",[[userdic objectForKey:@"user"] objectForKey:@"lastname"]];
                }
                [defaults setObject:lastnameStr forKey:@"lastname"];
                NSString *userIdStr;
                if ([[userdic objectForKey:@"userId"] isEqual:[NSNull null]]) {
                    userIdStr=@"";
                }else{
                    userIdStr=[NSString stringWithFormat:@"%@",[[userdic objectForKey:@"user"] objectForKey:@"userId"]];
                }
                [defaults setObject:userIdStr forKey:@"userId"];
                NSString *usertokenStr;
                if ([[userdic objectForKey:@"usertoken"] isEqual:[NSNull null]]) {
                    usertokenStr=@"";
                }else{
                    usertokenStr=[NSString stringWithFormat:@"%@",[[userdic objectForKey:@"user"] objectForKey:@"usertoken"]];
                }
                [defaults setObject:usertokenStr forKey:@"usertoken"];
                NSString *roleStr;
                if ([[userdic objectForKey:@"role"] isEqual:[NSNull null]]) {
                    roleStr=@"";
                }else{
                    roleStr=[NSString stringWithFormat:@"%@",[[userdic objectForKey:@"user"] objectForKey:@"role"]];
                }
                [defaults setObject:roleStr forKey:@"role"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                
            }
            else{
            }
            
        } else {
            
        }
        
    }] resume];

    
}
-(IBAction)codeAction:(UIButton*)sender{

    if ([phoneTF.text isEqualToString:@""]) {
        
    }else{
       // {"phone": "asdasd"}
        
        NSDictionary *postDic=DICT(self.phoneTF.text,@"phone",nil);
        
        DebugLog(@"postDic is%@",postDic);
        
        NSData *data= [NSJSONSerialization dataWithJSONObject:postDic options:NSJSONWritingPrettyPrinted error:nil];

//        NSString *jsstring=[NSString stringWithFormat:@"%@",jsonString];

        
        NSString *path=[NSString stringWithFormat:@"%@/sms",BASE_URL];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];

        NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:path parameters:nil error:nil];
        [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSData *body = data;
        
        [request setHTTPBody:body];

        [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (!error) {
                
                NSString *responseObjectstr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSDictionary *dic=[self dictionaryWithJsonString:responseObjectstr];
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    
                    DebugLog(@"dic is %@",dic);
                    
                    if ([[dic objectForKey:@"status"] intValue]==200) {
                        counttime=60;
                        codeTimer= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runTime) userInfo:nil repeats:YES];
                        NSString *codestr=[NSString stringWithFormat:@"重新获取%d",counttime];
                        [self.codeBtn setTitle:codestr forState:UIControlStateNormal];

                        
                        
                        
                    }
                    
                }
                
            }
             else{
            
        }
          
          }] resume];

        
    }
    
    
    
}

#pragma mark倒计时多少秒之后重新获取验证码
-(void)runTime{
    counttime--;
    NSString *codestr=[NSString stringWithFormat:@"重新获取%d",counttime];
    [self.codeBtn setTitle:codestr forState:UIControlStateNormal];

    if (counttime==0) {
        [self.codeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        [codeTimer invalidate];
    }
    
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if(error) {
        return nil;
    }
    return dic;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
