//
//  ViewController.m
//  xundaRTC
//
//  Created by 大V on 2018/6/6.
//  Copyright © 2018年 season. All rights reserved.
//

#import "ViewController.h"
#import "CreatRoomViewController.h"
#import "ChatViewController.h"
#import "RoomDetailViewController.h"
#import <AVFoundation/AVCaptureDevice.h>
#import "LoginViewController.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray *dataListArry;
@property (nonatomic,strong) NSMutableArray *searchListArry;

@end

@implementation ViewController
-(void)viewDidAppear:(BOOL)animated{
    NSString *userIdstr=[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    
    if ([userIdstr isEqualToString:@""]) {

        LoginViewController *login=[[LoginViewController alloc] init];
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:login];
        nav.navigationBar.hidden=YES;
        [self presentViewController:nav animated:YES completion:nil];

    }else{
    
        [self getroomdata];
        
    }


    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self logindata];
    self.view.backgroundColor=kBaseRGB;

    UIImageView* navigationbarimg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kWidth,NAVIGATION_BAR_HEIGHT)];
    navigationbarimg.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:navigationbarimg];

    UIImageView *lineiimg=[[UIImageView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT-1, kWidth, 1)];
    [lineiimg setBackgroundColor:kBaseRGB];
    [self.view addSubview:lineiimg];
//
//
//
    UILabel *titlelabel = [[UILabel alloc] init];
    titlelabel.frame = CGRectMake(0, STATUS_BAR_HEIGHT, kWidth, NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT);
    titlelabel.backgroundColor=[UIColor clearColor];
    titlelabel.textColor=[UIColor blackColor];
    titlelabel.text=@"房间";
    titlelabel.textAlignment=NSTextAlignmentCenter;
    titlelabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:titlelabel];
//
//
    UIButton *addButton = [[UIButton alloc]initWithFrame:CGRectMake(kWidth-60, STATUS_BAR_HEIGHT+7, 25, 25)];
    [addButton setImage:YDIMG(@"加.png") forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];

    self.searchListArry = [NSMutableArray array];
    self.dataListArry = [NSMutableArray new];


    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, kWidth, kHeight-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.translatesAutoresizingMaskIntoConstraints=NO;
        [self.view addSubview:tableView];
        tableView;
    });
    AVAuthorizationStatus auth = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    NSString *title = @"请在-设置-隐私-相机 选项中，允许访问你的相机。";

    if (auth == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
                [alertView show];
            });
        }];
    }
    else {

    }
    

}

-(void)viewWillAppear:(BOOL)animated{
    
//    [self getroomdata];
    
}



#pragma mark-------  button action method

-(void)addAction{
    
    CreatRoomViewController *nextview=[[CreatRoomViewController alloc]init];
    [self presentViewController:nextview animated:YES completion:nil];
    
}


-(void)videoButtonAction:(PlayButton*)sender{
    NSString *tokenstr=[[NSUserDefaults standardUserDefaults]objectForKey:@"usertoken"];
    NSString *path=[NSString stringWithFormat:@"%@/rooms/%@/token?usertoken=%@",BASE_URL,[sender.detailDic objectForKey:@"_id"],tokenstr];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:path parameters:nil error:nil];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSString *responseObjectstr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSDictionary *dic=[self dictionaryWithJsonString:responseObjectstr];
            DebugLog(@"join room data dic is %@",dic);
            if ([dic isKindOfClass:[NSDictionary class]]) {
                RoomDetailViewController *nextview=[[RoomDetailViewController alloc]init];
                nextview.isOnlyAudio=NO;
                nextview.detailDic=sender.detailDic;
                nextview.joindetailDic=dic;
                nextview.roomtoken=[dic objectForKey:@"token"];
                [self presentViewController:nextview animated:YES completion:nil];
            }
        } else {
            NSLog(@"error %@",error.description);
        }
        
    }] resume];

    
}
-(void)audioButtonAction:(PlayButton*)sender{
    
    NSString *tokenstr=[[NSUserDefaults standardUserDefaults]objectForKey:@"usertoken"];
    NSString *path=[NSString stringWithFormat:@"%@/rooms/%@/token?usertoken=%@",BASE_URL,[sender.detailDic objectForKey:@"_id"],tokenstr];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:path parameters:nil error:nil];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSString *responseObjectstr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSDictionary *dic=[self dictionaryWithJsonString:responseObjectstr];
            if ([dic isKindOfClass:[NSDictionary class]]) {
                RoomDetailViewController *nextview=[[RoomDetailViewController alloc]init];
                nextview.isOnlyAudio=YES;
                nextview.detailDic=sender.detailDic;
                nextview.joindetailDic=dic;
                nextview.roomtoken=[dic objectForKey:@"token"];
                [self presentViewController:nextview animated:YES completion:nil];
            }
        } else {
        }
        
    }] resume];
}

#pragma mark------- get data method
//get room data list
-(void)getroomdata{
    
    NSString *tokenstr=[[NSUserDefaults standardUserDefaults]objectForKey:@"usertoken"];
    NSString *path=[NSString stringWithFormat:@"%@/rooms?usertoken=%@",BASE_URL,tokenstr];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:path parameters:nil error:nil];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSString *responseObjectstr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            self->_dataListArry = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error];
            [_myTableView reloadData];
        } else {
        }
        
    }] resume];
    
    
}

//login in
-(void)logindata{
    
    NSString *path=[NSString stringWithFormat:@"%@/login",BASE_URL];
    
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:path parameters:nil error:nil];

    [request addValue:@"Basic eHVuZGE6eHVuZGFpb3M=" forHTTPHeaderField:@"Authorization"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"Keep-alive" forHTTPHeaderField:@"Connection"];
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
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
                [self getroomdata];
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

#pragma mark------- table view delagate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return (int)_dataListArry.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"TimelineCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.userInteractionEnabled = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dic=[_dataListArry objectAtIndex:indexPath.row];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10,5,60,60)];
    [imageView setImage:[UIImage imageNamed:@"usericons"]];
    imageView.contentMode=UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds =YES;
    imageView.userInteractionEnabled = YES;
    [cell addSubview:imageView];
    
    UILabel *nametitlelabel = [[UILabel alloc]init];
    nametitlelabel.textAlignment = NSTextAlignmentLeft;
    [nametitlelabel setFrame:CGRectMake(80,5,kWidth-180,60)];
    nametitlelabel.font =  [UIFont systemFontOfSize:14];
    nametitlelabel.textColor=[UIColor blackColor];
    nametitlelabel.text = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"room"] objectForKey:@"name"] ];
    nametitlelabel.backgroundColor=[UIColor clearColor];
    nametitlelabel.numberOfLines=0;
    [cell addSubview:nametitlelabel];
    
    
    PlayButton *videoButton = [[PlayButton alloc]init];
    [videoButton setFrame:CGRectMake(kWidth-90, 15, 30, 30)];
    videoButton.detailDic=dic;
    [videoButton setImage:YDIMG(@"videocam.png") forState:UIControlStateNormal];
    [videoButton addTarget:self action:@selector(videoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:videoButton];
    
    PlayButton *audioButton = [[PlayButton alloc]init];
    [audioButton setFrame:CGRectMake(kWidth-45, 15, 30, 30)];
    audioButton.detailDic=dic;
    [audioButton setImage:YDIMG(@"audiocam") forState:UIControlStateNormal];
    [audioButton addTarget:self action:@selector(audioButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:audioButton];
    
    
    return cell;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
