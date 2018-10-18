//
//  ChatViewController.h
//  xundaRTC
//
//  Created by 大V on 2018/6/11.
//  Copyright © 2018年 season. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PureRTC/PureRTC.h>

@interface ChatViewController : UIViewController
@property (nonatomic,strong)NSDictionary *detailDic;
@property (nonatomic,strong)NSDictionary *joindetailDic;

@property (nonatomic,strong)RTCConferenceUser *myuser;
@property (nonatomic,strong)NSString *myuserID;

@end
