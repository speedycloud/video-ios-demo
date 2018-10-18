//
//  RoomDetailViewController.h
//  xundaRTC
//
//  Created by 大V on 2018/6/11.
//  Copyright © 2018年 season. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomDetailViewController : UIViewController
@property (nonatomic,assign) BOOL  isOnlyAudio;
@property (nonatomic,strong)NSDictionary *detailDic;
@property (nonatomic,strong)NSDictionary *joindetailDic;

@property (nonatomic,strong)NSString *roomtoken;

@end
