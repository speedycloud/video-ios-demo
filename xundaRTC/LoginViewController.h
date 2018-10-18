//
//  LoginViewController.h
//  xundaRTC
//
//  Created by 大V on 2018/7/29.
//  Copyright © 2018年 season. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property(strong ,nonatomic)IBOutlet UITextField *nameTF;
@property(strong ,nonatomic)IBOutlet UITextField *passwordTF;
@property(strong ,nonatomic)IBOutlet UIButton *loginBtn;
@property(strong ,nonatomic)IBOutlet UIButton *registerBtn;

-(IBAction)loginAction:(id)sender;
-(IBAction)registerAction:(id)sender;

@end
