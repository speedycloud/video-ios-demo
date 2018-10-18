//
//  RoomDetailViewController.m
//  xundaRTC
//
//  Created by 大V on 2018/6/11.
//  Copyright © 2018年 season. All rights reserved.
//

#import "RoomDetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "ChatViewController.h"
#import <PureRTC/PureRTC.h>

@interface RoomDetailViewController ()<RTCRemoteMixedStreamObserver , RTCConferenceClientObserver,UITableViewDelegate,UITableViewDataSource>{

    PlayButton *cancelBtn;
    PlayButton *micBtn;

    PlayButton *audioBtn;
    PlayButton *chatBtn;
    PlayButton *moreBtn;
    PlayButton *speakerphoneBtn;
    UILabel  *statueLabel;
    
    
    
    
    PlayButton *hiddenBtn;
    PlayButton *silenceBtn;
    PlayButton *turnBtn;
    
    UIView *moreView;
    
    UIView *resolutionView;


    
    
    
}
@property (nonatomic,strong)RTCConferenceUser *myuser;
@property (nonatomic,strong) UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray *dataListArry;
@property (nonatomic, assign)BOOL ifSelected;//是否选中
@property (nonatomic, strong)NSIndexPath * lastSelected;//上一次选中的索引
@property (nonatomic, assign)int chooseNum;//上一次选中的索引

@property(nonatomic,nonatomic) RTCLocalStream* localStream;
@property(nonatomic,nonatomic) RTCRemoteStream* remoteStream;
@property(nonatomic,nonatomic) RTCConferenceClient* conferenceClient;
@property(nonatomic,nonatomic) RTCEAGLVideoView *localVideoView;
@property(nonatomic,nonatomic) RTCEAGLVideoView *remoteVideoView;
@property(nonatomic,nonatomic) RTCAVFoundationVideoSource *videoSource;
@property(nonatomic,nonatomic) RTCConferenceClientConfiguration *config;
@property(nonatomic,nonatomic) UIActivityIndicatorView *act;
@property(nonatomic,nonatomic) UIButton *quitBtn;
@property(nonatomic,nonatomic) NSString* stats;
@property(nonatomic,nonatomic) NSString *statueStr;
@property(nonatomic,nonatomic) RTCRemoteMixedStream* mixedStream;
@property(nonatomic,nonatomic) NSObject* obSrv;

@end

@implementation RoomDetailViewController{
    NSTimer* getStatsTimer;
    dispatch_queue_t _queue_events;
}

- (void)panGRAct: (UIPanGestureRecognizer *)rec{
    CGPoint point = [rec translationInView:self.view];
    NSLog(@"%f,%f",point.x,point.y);
    rec.view.center = CGPointMake(rec.view.center.x + point.x, rec.view.center.y + point.y);
    [rec setTranslation:CGPointMake(0, 0) inView:self.view];
}
-(void)doubleTap:(UIGestureRecognizer *) gr

{
    
    NSLog(@"doubleTap");
    
    [_conferenceClient subscribe:_remoteStream onSuccess:^(RTCRemoteStream * RemoteStream) {
        
        [SVProgressHUD showInfoWithStatus:@"订阅成功"];
        
    } onFailure:^(NSError * error) {
        [SVProgressHUD showInfoWithStatus:@"不能订阅当前流"];
        
    }];
    
}


-(void)okBtnAction{
    
    
    [resolutionView removeFromSuperview];
    
    RTCSetMinDebugLogLevel(RTCLoggingSeverityVerbose);
    
    self.view.backgroundColor=RGB(32, 36, 39, 1);
    _queue_events = dispatch_queue_create("SDK-Events", NULL); // TBD: Release on destroy
    
//    _remoteVideoView=[[RTCEAGLVideoView alloc]initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, kWidth, kHeight-100-STATUS_BAR_HEIGHT)];
    _remoteVideoView=[[RTCEAGLVideoView alloc]initWithFrame:CGRectMake(0, kHeight/2-kWidth/2, kWidth, kWidth)];

    _remoteVideoView.layer.borderColor = [UIColor whiteColor].CGColor;
    _remoteVideoView.layer.borderWidth = 2.0f;
    [self.view addSubview:_remoteVideoView];
    
    UITapGestureRecognizer * doubleTapRecognizer=
    
    [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    
    doubleTapRecognizer.numberOfTapsRequired=2;
    
    doubleTapRecognizer.delaysTouchesBegan=YES;
    
    [_remoteVideoView addGestureRecognizer:doubleTapRecognizer];

    
    _localVideoView=[[RTCEAGLVideoView alloc]initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, kWidth/3, kWidth/3)];
    _localVideoView.layer.borderColor = [UIColor whiteColor].CGColor;
    _localVideoView.layer.borderWidth = 2.0f;
    [self.view addSubview:_localVideoView];
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGRAct:)];
    [_localVideoView setUserInteractionEnabled:YES];
    [_localVideoView addGestureRecognizer:panGR];

    
    
    
    cancelBtn = [[PlayButton alloc]init];
    cancelBtn.frame = CGRectMake((kWidth-250)/6, kHeight-80, 50, 50);
    [cancelBtn setImage:YDIMG(@"挂断电话") forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    micBtn = [[PlayButton alloc]init];
    micBtn.frame = CGRectMake((kWidth-250)/6*2+50, kHeight-80, 50, 50);
    [micBtn setImage:YDIMG(@"免提-关闭") forState:UIControlStateNormal];
    [micBtn setImage:YDIMG(@"免提-开启") forState:UIControlStateSelected];
    [micBtn addTarget:self action:@selector(speakerphoneBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:micBtn];
    
    audioBtn = [[PlayButton alloc]init];
    audioBtn.frame = CGRectMake((kWidth-250)/6*3+100, kHeight-80, 50, 50);
    [audioBtn setImage:YDIMG(@"audiocam") forState:UIControlStateNormal];
    [audioBtn setImage:YDIMG(@"开启摄像头") forState:UIControlStateSelected];
    [audioBtn addTarget:self action:@selector(audioBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:audioBtn];
    
    chatBtn = [[PlayButton alloc]init];
    chatBtn.frame = CGRectMake((kWidth-250)/6*4+150, kHeight-80, 50, 50);
    [chatBtn setImage:YDIMG(@"chat") forState:UIControlStateNormal];
    [chatBtn addTarget:self action:@selector(chatBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:chatBtn];
    
    moreBtn = [[PlayButton alloc]init];
    moreBtn.frame = CGRectMake((kWidth-250)/6*5+200, kHeight-80, 50, 50);
    [moreBtn setImage:YDIMG(@"更多") forState:UIControlStateNormal];
    moreBtn.tag=1000;
    [moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreBtn];
    
    
    _config=[[RTCConferenceClientConfiguration alloc]init];
    _config.candidateNetworkPolicy = RTCCandidateNetworkPolicyAll;
    _config.mediaCodec.videoCodec = VideoCodecH264;
    _config.iceTransportPolicy = RTCIceTransportPolicyAll;
    _conferenceClient=[[RTCConferenceClient alloc]initWithConfiguration:_config];
    [_conferenceClient addObserver:self];
    
    NSDictionary *MediaConstraintsdic=DICT(@"640",@"minWidth",@"480",@"minHeight",@"1280",@"maxWidth",@"720",@"maxHeight",@"15",@"minFrameRate",@"24",@"maxFrameRate");
    RTCMediaConstraints *MediaConstraints=[[RTCMediaConstraints alloc] initWithMandatoryConstraints:MediaConstraintsdic optionalConstraints:nil];
    
    
    self.videoSource=[[RTCAVFoundationVideoSource alloc]initWithConstraints:MediaConstraints];
    [self.videoSource setUseBackCamera:NO];
    _localStream=[[RTCLocalCameraStream alloc]initWithAudioEnabled:YES VideoSource:self.videoSource error:nil] ;
    if (self.isOnlyAudio==YES) {
        [_localStream disableVideo];
        audioBtn.selected=YES;

    }else{
        

    }
    [_localStream attach:_localVideoView];

    
    moreView=[[UIView alloc]initWithFrame:CGRectMake((kWidth-250)/6*5+200, kHeight-290, 50, 210)];
    [moreView setBackgroundColor:[UIColor clearColor]];
    moreView.hidden=YES;
    [self.view addSubview:moreView];
    
    hiddenBtn= [[PlayButton alloc]init];
    hiddenBtn.frame = CGRectMake(0, 0, 50, 50);
    hiddenBtn.tag=2000;
    [hiddenBtn setImage:YDIMG(@"缩小") forState:UIControlStateNormal];
    [hiddenBtn addTarget:self action:@selector(hiddenAction:) forControlEvents:UIControlEventTouchUpInside];
    [moreView addSubview:hiddenBtn];
    
    
    turnBtn= [[PlayButton alloc]init];
    turnBtn.frame = CGRectMake(0, 70, 50, 50);
    [turnBtn setImage:YDIMG(@"切换摄像头") forState:UIControlStateNormal];
    [turnBtn addTarget:self action:@selector(turnBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [moreView addSubview:turnBtn];
    
    silenceBtn= [[PlayButton alloc]init];
    silenceBtn.frame = CGRectMake(0, 140, 50, 50);
    [silenceBtn setImage:YDIMG(@"静音") forState:UIControlStateNormal];
    [silenceBtn setImage:YDIMG(@"audiocam") forState:UIControlStateSelected];
    [silenceBtn addTarget:self action:@selector(silenceBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [moreView addSubview:silenceBtn];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    //默认情况下扬声器播放
    
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [audioSession setActive:YES error:nil];
    

    [self doJoin];
    
    

    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    DebugLog(@"detail dic is %@",self.detailDic);

    DebugLog(@"join dic is %@",self.joindetailDic);

    if ([[[self.detailDic objectForKey:@"room"] objectForKey:@"enableMixing"] intValue]==1) {
        
        _dataListArry=[[NSMutableArray alloc] initWithObjects:@"3840 x 2160",@"2880 x 1620",@"2560 x 1440",@"1920 x 1080",@"1280 x 720",@"960 x 540",@"800 x 600",@"640 x 480",@"352 x 288", nil];
        
        resolutionView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
        [resolutionView setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:resolutionView];
        
        
        
        UILabel *namelabel = [[UILabel alloc]initWithFrame:CGRectMake(20,NAVIGATION_BAR_HEIGHT,kWidth-40,40)];
        namelabel.textAlignment = NSTextAlignmentLeft;
        namelabel.font = [UIFont systemFontOfSize:14];
        namelabel.textColor=RGB(0, 0, 0, 1);
        namelabel.numberOfLines=0;
        namelabel.text=@"请选择混流后的分辨率";
        [resolutionView addSubview:namelabel];

        
        PlayButton *okBtn = [[PlayButton alloc]init];
        okBtn.frame = CGRectMake(kWidth-100, kHeight-80, 100, 50);
        [okBtn setTitle:@"OK" forState:UIControlStateNormal];
        [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [okBtn addTarget:self action:@selector(okBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [resolutionView addSubview:okBtn];
        
        _chooseNum=0;
        
        
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, kWidth, kHeight-NAVIGATION_BAR_HEIGHT-100) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.translatesAutoresizingMaskIntoConstraints=NO;
            [resolutionView addSubview:tableView];
            tableView;
        });


        
        
        
    }else{
        
        
        
    
    
    
        RTCSetMinDebugLogLevel(RTCLoggingSeverityVerbose);
        
        self.view.backgroundColor=RGB(32, 36, 39, 1);
        _queue_events = dispatch_queue_create("SDK-Events", NULL); // TBD: Release on destroy
        
        _remoteVideoView=[[RTCEAGLVideoView alloc]initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, kWidth, kHeight-100-STATUS_BAR_HEIGHT)];
        _remoteVideoView.layer.borderColor = [UIColor whiteColor].CGColor;
        _remoteVideoView.layer.borderWidth = 2.0f;
        [self.view addSubview:_remoteVideoView];
        
        UITapGestureRecognizer * doubleTapRecognizer=
        
        [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        
        doubleTapRecognizer.numberOfTapsRequired=2;
        
        doubleTapRecognizer.delaysTouchesBegan=YES;
        
        [_remoteVideoView addGestureRecognizer:doubleTapRecognizer];

        _localVideoView=[[RTCEAGLVideoView alloc]initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, kWidth/3, kWidth/3)];
        _localVideoView.layer.borderColor = [UIColor whiteColor].CGColor;
        _localVideoView.layer.borderWidth = 2.0f;
        [self.view addSubview:_localVideoView];
        
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGRAct:)];
        [_localVideoView setUserInteractionEnabled:YES];
        [_localVideoView addGestureRecognizer:panGR];

        cancelBtn = [[PlayButton alloc]init];
        cancelBtn.frame = CGRectMake((kWidth-250)/6, kHeight-80, 50, 50);
        [cancelBtn setImage:YDIMG(@"挂断电话") forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cancelBtn];
        
        micBtn = [[PlayButton alloc]init];
        micBtn.frame = CGRectMake((kWidth-250)/6*2+50, kHeight-80, 50, 50);
        [micBtn setImage:YDIMG(@"免提-关闭") forState:UIControlStateNormal];
        [micBtn setImage:YDIMG(@"免提-开启") forState:UIControlStateSelected];
        [micBtn addTarget:self action:@selector(speakerphoneBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:micBtn];
        
        audioBtn = [[PlayButton alloc]init];
        audioBtn.frame = CGRectMake((kWidth-250)/6*3+100, kHeight-80, 50, 50);
        [audioBtn setImage:YDIMG(@"audiocam") forState:UIControlStateNormal];
        [audioBtn setImage:YDIMG(@"开启摄像头") forState:UIControlStateSelected];
        [audioBtn addTarget:self action:@selector(audioBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:audioBtn];
        
        chatBtn = [[PlayButton alloc]init];
        chatBtn.frame = CGRectMake((kWidth-250)/6*4+150, kHeight-80, 50, 50);
        [chatBtn setImage:YDIMG(@"chat") forState:UIControlStateNormal];
        [chatBtn addTarget:self action:@selector(chatBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:chatBtn];
        
        moreBtn = [[PlayButton alloc]init];
        moreBtn.frame = CGRectMake((kWidth-250)/6*5+200, kHeight-80, 50, 50);
        [moreBtn setImage:YDIMG(@"更多") forState:UIControlStateNormal];
        moreBtn.tag=1000;
        [moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:moreBtn];
        
        
        _config=[[RTCConferenceClientConfiguration alloc]init];
        _config.candidateNetworkPolicy = RTCCandidateNetworkPolicyAll;
        _config.mediaCodec.videoCodec = VideoCodecH264;
        _config.iceTransportPolicy = RTCIceTransportPolicyAll;
        _conferenceClient=[[RTCConferenceClient alloc]initWithConfiguration:_config];
        [_conferenceClient addObserver:self];
        
        NSDictionary *MediaConstraintsdic=DICT(@"640",@"minWidth",@"480",@"minHeight",@"1280",@"maxWidth",@"720",@"maxHeight",@"15",@"minFrameRate",@"24",@"maxFrameRate");
        RTCMediaConstraints *MediaConstraints=[[RTCMediaConstraints alloc] initWithMandatoryConstraints:MediaConstraintsdic optionalConstraints:nil];
        
        
        self.videoSource=[[RTCAVFoundationVideoSource alloc]initWithConstraints:MediaConstraints];
        [self.videoSource setUseBackCamera:NO];
        _localStream=[[RTCLocalCameraStream alloc]initWithAudioEnabled:YES VideoSource:self.videoSource error:nil] ;
        [_localStream attach:_localVideoView];
        
        
        moreView=[[UIView alloc]initWithFrame:CGRectMake((kWidth-250)/6*5+200, kHeight-290, 50, 210)];
        [moreView setBackgroundColor:[UIColor clearColor]];
        moreView.hidden=YES;
        [self.view addSubview:moreView];
        
        hiddenBtn= [[PlayButton alloc]init];
        hiddenBtn.frame = CGRectMake(0, 0, 50, 50);
        hiddenBtn.tag=2000;
        [hiddenBtn setImage:YDIMG(@"缩小") forState:UIControlStateNormal];
        [hiddenBtn addTarget:self action:@selector(hiddenAction:) forControlEvents:UIControlEventTouchUpInside];
        [moreView addSubview:hiddenBtn];
        
        
        turnBtn= [[PlayButton alloc]init];
        turnBtn.frame = CGRectMake(0, 70, 50, 50);
        [turnBtn setImage:YDIMG(@"切换摄像头") forState:UIControlStateNormal];
        [turnBtn addTarget:self action:@selector(turnBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [moreView addSubview:turnBtn];
        
        silenceBtn= [[PlayButton alloc]init];
        silenceBtn.frame = CGRectMake(0, 140, 50, 50);
        [silenceBtn setImage:YDIMG(@"静音") forState:UIControlStateNormal];
        [silenceBtn setImage:YDIMG(@"audiocam") forState:UIControlStateSelected];
        [silenceBtn addTarget:self action:@selector(silenceBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [moreView addSubview:silenceBtn];
        
        //        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        //        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        //
        //        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
        //
        //                                sizeof(sessionCategory),
        //
        //                                &sessionCategory);
        //
        //
        //
        //        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        //
        //        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
        //
        //                                 sizeof (audioRouteOverride),
        //.
        //                                 &audioRouteOverride);
        //
        //
        //
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        //默认情况下扬声器播放
        
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        [audioSession setActive:YES error:nil];
        
        
        
        //        [[NSNotificationCenter defaultCenter] addObserver:self
        //
        //                                                 selector:@selector(sensorStateChange:)
        //
        //                                                     name:@"UIDeviceProximityStateDidChangeNotification"
        //
        //                                                   object:nil];
        
        
        
        [self doJoin];
        
        

        
    }

    
}

-(void)sensorStateChange:(NSNotificationCenter *)notification;

{
    
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    
    if ([[UIDevice currentDevice] proximityState] == YES)
        
    {
        
        NSLog(@"Device is close to user");
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        
        
    }
    
    else
        
    {
        
        NSLog(@"Device is not close to user");
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
    }
    
}


-(void)hiddenAction:(PlayButton*)sender{
    if (sender.tag==2000) {
        
        hiddenBtn.tag=1999;
        [hiddenBtn setImage:YDIMG(@"放大") forState:UIControlStateNormal];
        _localVideoView.hidden=YES;
        
    }else{
        hiddenBtn.tag=2000;
        [hiddenBtn setImage:YDIMG(@"缩小") forState:UIControlStateNormal];
        _localVideoView.hidden=NO;;

        
    }
    moreView.hidden=YES;
    moreBtn.tag=1000;

    
}
-(void)moreBtnAction:(PlayButton *)sender{
    
    if (sender.tag==1000) {
        
        moreBtn.tag=999;
        
        moreView.hidden=NO;

    }else{
        moreBtn.tag=1000;

        moreView.hidden=YES;

    }
    
    
}



-(void) doJoin {
    [_conferenceClient joinWithToken:self.roomtoken onSuccess:^(RTCConferenceUser * user) {
        
        self.myuser=user;
        DebugLog(@"self.myuser is %@",self.myuser);

        
        [self doPublish];
        
    } onFailure:^(NSError* err) {
        DebugLog(@"Join failed. %@", err);
        
    }];
}

-(void)doPublish{
    [_conferenceClient pauseVideo:_localStream onSuccess:^{
        
    } onFailure:^(NSError * error) {
        
    }];
    
    [_conferenceClient publish:_localStream onSuccess:^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"publish success!");
        });
    } onFailure:^(NSError* err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"publish failure!");
            [self showMsg:[err localizedFailureReason]];
        });
    }];

}


#pragma mark ------- button action method
-(void)cancelBtnAction{
    
    [_conferenceClient leaveWithOnSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self onServerDisconnected];
            [self removeObserver:self.obSrv];
            [self backbtnAction];
            self->_mixedStream=nil;
            self->_localStream=nil;
            
        });
    } onFailure:nil];

//    _conferenceClient=nil;
}

-(void)silenceBtnAction:(PlayButton*)sender{

    moreView.hidden=YES;
    moreBtn.tag=1000;
    
    if (sender.selected==YES) {
        
        silenceBtn.selected=NO;
        
        [_conferenceClient playAudio:_localStream onSuccess:^{
            [SVProgressHUD showInfoWithStatus:@"已取消静音"];

        } onFailure:^(NSError * error) {
            
        }];

    }else{
        
        
        silenceBtn.selected=YES;
        
        [_conferenceClient pauseAudio:_localStream onSuccess:^{
            [SVProgressHUD showInfoWithStatus:@"已静音"];

            
            
        } onFailure:^(NSError * error) {
            
        }];

    }


}


-(void)speakerphoneBtnAction:(PlayButton*)sender{
//    if ([[UIDevice currentDevice] proximityState] == YES)
//
//    {
//
//        NSLog(@"Device is close to user");
//
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//
//
//
//    }
//
//    else
//
//    {
//
//        NSLog(@"Device is not close to user");
//
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//
//    }

    if (sender.selected==YES) {
        
        DebugLog(@"sender.selected==YES");
        micBtn.selected=NO;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    }else{
        
        
        DebugLog(@"sender.selected==no");
        micBtn.selected=YES;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    }
    
    
}

-(void)turnBtnAction:(PlayButton*)sender{
    BOOL backcam=!self.videoSource.useBackCamera;
    [self.videoSource setUseBackCamera:backcam];
    moreView.hidden=YES;
    moreBtn.tag=1000;

}
-(void)audioBtnAction:(PlayButton*)sender{
    
    if (sender.selected==YES) {
        
        DebugLog(@"sender.selected==YES");
        audioBtn.selected=NO;
        [_localStream enableVideo];
        
        [_conferenceClient playVideo:_localStream onSuccess:^{
            
        } onFailure:^(NSError * error) {
            
        }];
        
        
    }else{
        
        [_localStream disableVideo];

        DebugLog(@"sender.selected==no");
        audioBtn.selected=YES;
        [_conferenceClient pauseVideo:_localStream onSuccess:^{

        } onFailure:^(NSError * error) {
            
        }];
        
    }

    
    
    
}
-(void)chatBtnAction{
    ChatViewController *nextview=[[ChatViewController alloc]init];
    nextview.detailDic=self.detailDic;
    nextview.joindetailDic=self.joindetailDic;
    nextview.myuserID=self.myuser.getUserId;

    nextview.myuser=self.myuser;
    [self presentViewController:nextview animated:YES completion:nil];
}
-(void)backbtnAction{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


-(void)_onStreamAdded:(RTCRemoteStream*)stream {
    if ([stream isKindOfClass:[RTCRemoteMixedStream class]]) {
        _mixedStream = (RTCRemoteMixedStream *)stream;

        [_mixedStream addObserver:self];
  
        RTCConferenceSubscribeOptions *subOption = [[RTCConferenceSubscribeOptions alloc]init];
//        int width = INT_MAX;
//        int height = INT_MAX;
//        NSArray *formats = [_mixedStream supportedVideoFormats];
        

//        for (RTCVideoFormat* format in formats) {
////            if (format.resolution.width == 1280 && format.resolution.height == 720) {
////                width = format.resolution.width;
////                height = format.resolution.height;
////                break;
////            }
//
//            DebugLog(@"formatsresolution.widthis %f",format.resolution.width);
//            DebugLog(@"formatsresolution.height %f",format.resolution.height);
//
//            if (format.resolution.width < width && format.resolution.height != 0) {
//                width = format.resolution.width;
//                height = format.resolution.height;
//            }
//        }
        
        NSString *chooseRem=[_dataListArry objectAtIndex:_chooseNum];
         NSArray  *array = [chooseRem componentsSeparatedByString:@" x "];
        int resolutionwidth=[[array objectAtIndex:0] intValue];
        int resolutionheight=[[array objectAtIndex:1] intValue];
        DebugLog(@"resolutionwidth =%d",resolutionwidth);
        DebugLog(@"resolutionheight =%d",resolutionheight);

        [subOption setResolution:CGSizeMake(resolutionwidth, resolutionheight)];

        
//        [subOption setResolution:CGSizeMake(width, height)];
        //[[AVAudioSession sharedInstance]overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        [_conferenceClient subscribe:_mixedStream withOptions:subOption onSuccess:^(RTCRemoteStream *remoteStream) {
            // Periodically get connection stats and show it on the upper right corner.
            getStatsTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(printStats) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self->getStatsTimer forMode:NSDefaultRunLoopMode];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.remoteStream = remoteStream;
                [remoteStream attach:self.remoteVideoView];
            });
        } onFailure:^(NSError* err){
            NSLog(@"Subscribe stream failed. %@", [err localizedDescription]);
        }];
        
    }
}

-(void)onStreamAdded:(RTCRemoteStream*)stream {
    NSLog(@"On remote stream added.");
    dispatch_async(_queue_events, ^{
        [self _onStreamAdded:stream];
    });
}

-(void)printStats{
    [_conferenceClient getConnectionStatsForStream:_mixedStream onSuccess:^(RTCConnectionStats *stats) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableString* statsString=[NSMutableString stringWithFormat:@"Mixed stream info:\nAvaiable: %lukbps\n",(unsigned long)stats.videoBandwidthStats.availableReceiveBandwidth/1024];
            for(id channel in stats.mediaChannelStats){
                if([channel isKindOfClass:[RTCVideoReceiverStats class]]){
                    RTCVideoReceiverStats* videoReceiverStats=channel;
                    NSMutableString *channelStats=[NSMutableString stringWithFormat:@"Packets lost: %lu\nResolution: %dx%d\nDelay: %lu\nVideo Codec: %@", (unsigned long)videoReceiverStats.packetsLost,(unsigned int)videoReceiverStats.frameResolution.width,(unsigned int)videoReceiverStats.frameResolution.height,  (unsigned long)videoReceiverStats.delay, videoReceiverStats.codecName];
                    [statsString appendString:channelStats];
                }
            }
        });
    } onFailure:^(NSError *e) {
        dispatch_async(dispatch_get_main_queue(), ^{

        });
    }];
}

- (void)showMsg: (NSString *)msg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)onVideoLayoutChanged{
    NSLog(@"OnVideoLayoutChanged.");
}

- (void)addObserver:(id<NSObject>)observer {
    self.obSrv = observer;
}

- (void) removeObserver:(id<NSObject>)observer {
    self.obSrv = nil;
}


-(void)onStreamRemoved:(RTCRemoteStream *)stream {
    NSLog(@"Appdelegate on stream removed");
}

-(void)onMessageReceivedFrom:(NSString *)senderId message:(NSString *)message{
    NSLog(@"AppDelegate received message: %@, from %@", message, senderId);
}

-(void)onUserJoined:(RTCConferenceUser *)user{
    NSLog(@"AppDelegate received user join event: %@",[user getUserId]);
}

-(void)onUserLeft:(RTCConferenceUser *)user{
    NSLog(@"AppDelegate received user leave event: %@",[user getUserId]);
}

- (void) onServerDisconnected{
    NSLog(@"Server disconnected");
    _mixedStream = nil;
}

- (void)onStreamError:(NSError *)error forStream:(RTCStream *)stream {
    
}
#pragma mark------- table view delagate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return (int)_dataListArry.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return (kHeight-NAVIGATION_BAR_HEIGHT-100)/9;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"TimelineCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.userInteractionEnabled = YES;
        cell.backgroundColor=[UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    UILabel *nametitlelabel = [[UILabel alloc]init];
    nametitlelabel.textAlignment = NSTextAlignmentLeft;
    [nametitlelabel setFrame:CGRectMake(20,5,kWidth-40,60)];
    nametitlelabel.font =  [UIFont systemFontOfSize:14];
    nametitlelabel.textColor=[UIColor whiteColor];
    nametitlelabel.text = [NSString stringWithFormat:@"%@",[_dataListArry objectAtIndex:indexPath.row] ];
    nametitlelabel.backgroundColor=[UIColor clearColor];
    nametitlelabel.numberOfLines=0;
    [cell addSubview:nametitlelabel];
    
    


    if (self.ifSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * temp = self.lastSelected;//暂存上一次选中的行
    if (temp && temp != indexPath)//如果上一次的选中的行存在,并且不是当前选中的这一行,则让上一行不选中
    {
        self.ifSelected = NO;//修改之前选中的cell的数据为不选中
        [tableView reloadRowsAtIndexPaths:@[temp] withRowAnimation:UITableViewRowAnimationAutomatic];//刷新该行
    }
    self.lastSelected = indexPath;//选中的修改为当前行
    self.ifSelected = YES;//修改这个被选中的一行
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];//重新刷新
    
    _chooseNum=(int)indexPath.row;
    
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
