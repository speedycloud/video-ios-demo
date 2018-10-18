//
//  LoginViewController.m
//  xundaRTC
//
//  Created by 大V on 2018/7/29.
//  Copyright © 2018年 season. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize nameTF,passwordTF;
@synthesize loginBtn,registerBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor=[UIColor redColor];
    // Do any additional setup after loading the view.
}
-(IBAction)registerAction:(UIButton*)sender{
    
    RegisterViewController *registerview=[[RegisterViewController alloc]init];
    [self.navigationController pushViewController:registerview animated:YES];
    
    
}
-(IBAction)loginAction:(UIButton*)sender{
    
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
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else{
            }
            
        } else {
            
        }
        
    }] resume];

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
