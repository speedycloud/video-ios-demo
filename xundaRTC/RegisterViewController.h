//
//  RegisterViewController.h
//  xundaRTC
//
//  Created by 大V on 2018/7/31.
//  Copyright © 2018年 season. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController
@property(strong ,nonatomic)IBOutlet UITextField *nameTF;
@property(strong ,nonatomic)IBOutlet UITextField *emailTF;
@property(strong ,nonatomic)IBOutlet UITextField *phoneTF;
@property(strong ,nonatomic)IBOutlet UITextField *passwordTF;
@property(strong ,nonatomic)IBOutlet UITextField *repasswordTF;
@property(strong ,nonatomic)IBOutlet UITextField *codeTF;

@property(strong ,nonatomic)IBOutlet UIButton *codeBtn;
@property(strong ,nonatomic)IBOutlet UIButton *registerBtn;

-(IBAction)codeAction:(id)sender;
-(IBAction)registerAction:(id)sender;
-(IBAction)backAction:(id)sender;

@end
