//
//  ChatViewController.m
//  xundaRTC
//
//  Created by 大V on 2018/6/11.
//  Copyright © 2018年 season. All rights reserved.
//

#import "ChatViewController.h"
#import "UUInputFunctionView.h"
#import "UUMessageCell.h"
#import "ChatModel.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "MJRefresh.h"
#import "UUChatCategory.h"
#import "SocketSignalingChannel.h"
#import <Foundation/Foundation.h>
#import <PureRTC/RTCP2PSignalingChannelProtocol.h>
#import <PureRTC/RTCPeerClient.h>

@interface ChatViewController ()<RTCP2PSignalingChannelProtocol,UUInputFunctionViewDelegate, UUMessageCellDelegate, UITableViewDataSource, UITableViewDelegate,RTCPeerClientObserver>
{
    CGFloat _keyboardHeight;
}
@property (strong, nonatomic) ChatModel *chatModel;

@property (strong, nonatomic) UITableView *chatTableView;

@property (strong, nonatomic) UUInputFunctionView *inputFuncView;

@property (nonatomic,strong)RTCPeerClient *peerclient;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DebugLog(@"detailDic is %@",self.detailDic);
    DebugLog(@"myuser is %@",self.myuser);
    DebugLog(@"myuserID is %@",self.myuserID);

    self.view.backgroundColor=kBaseRGB;
    
    UIImageView* navigationbarimg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kWidth,NAVIGATION_BAR_HEIGHT)];
    navigationbarimg.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:navigationbarimg];
    
    UILabel *titlelabel = [[UILabel alloc] init];
    titlelabel.frame = CGRectMake(0, STATUS_BAR_HEIGHT, kWidth, NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT);
    titlelabel.backgroundColor=[UIColor clearColor];
    titlelabel.textColor=[UIColor blackColor];
    titlelabel.text=[[self.detailDic objectForKey:@"room"] objectForKey:@"name"];
    titlelabel.textAlignment=NSTextAlignmentCenter;
    titlelabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:titlelabel];
    
    UIImageView *backimage=[[UIImageView alloc]initWithFrame:CGRectMake(20, STATUS_BAR_HEIGHT+13, 12, 24)];
    [backimage setImage:YDIMG(@"Rectangle")];
    [self.view addSubview:backimage];
    
    UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(38, STATUS_BAR_HEIGHT,kWidth , 50)];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.textColor = [UIColor blackColor];
    titleText.textAlignment = NSTextAlignmentLeft;
    titleText.font = [UIFont boldSystemFontOfSize:14];
    titleText.text=@"返回";
    [self.view addSubview:titleText];
    
    UIButton *backButton = [[UIButton alloc]init];
    backButton.frame = CGRectMake(10, STATUS_BAR_HEIGHT, 60, 50);
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    [self initBasicViews];
    [self addRefreshViews];
    [self loadBaseViewsAndData];
    _chatTableView.frame = CGRectMake(0, 0, self.view.uu_width, self.view.uu_height-40);
    _inputFuncView.frame = CGRectMake(0, _chatTableView.uu_bottom, self.view.uu_width, 40);
    
    
    id<RTCP2PSignalingChannelProtocol> scc=[[SocketSignalingChannel alloc]init];
    RTCPeerClientConfiguration* config=[[RTCPeerClientConfiguration alloc]init];
    config.candidateNetworkPolicy = RTCCandidateNetworkPolicyAll;
    config.mediaCodec.videoCodec = VideoCodecH264;
    config.iceTransportPolicy = RTCIceTransportPolicyAll;
    

    _peerclient=[[RTCPeerClient alloc]initWithConfiguration:config signalingChannel:scc];
    [_peerclient addObserver:self];
    DebugLog(@"++++++++++++++++++=%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"usertoken"]);
    
    
    NSMutableDictionary *tokenDict=[[NSMutableDictionary alloc]init];
    [tokenDict setValue:BASE_URL forKey:@"host"];
    [tokenDict setValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"usertoken"] forKey:@"token"];
    NSError* error;
    NSData* tokenData=[NSJSONSerialization dataWithJSONObject:tokenDict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *tokenString=[[NSString alloc]initWithData:tokenData encoding:NSUTF8StringEncoding];
    if(error){
        NSLog(@"Failed to get token.");
        return;
    }
    
    [scc connect:tokenString onSuccess:^(NSString *success) {
        DebugLog(@"connect scuess%@",success);

    } onFailure:^(NSError *Error) {
        DebugLog(@"connect Error%@",Error);

    }];


    [_peerclient connect:tokenString onSuccess:^(NSString * success) {
        DebugLog(@"connect scuess%@",success);

    } onFailure:^(NSError * Error) {
        DebugLog(@"connect Error%@",Error);

    }];
    
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //add notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustCollectionViewLayout) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self tableViewScrollToBottom];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (_inputFuncView.textViewInput.isFirstResponder) {
        _chatTableView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.view.uu_width, self.view.uu_height-40-_keyboardHeight-NAVIGATION_BAR_HEIGHT);
        _inputFuncView.frame = CGRectMake(0, _chatTableView.uu_bottom, self.view.uu_width, 40);
    } else {
        _chatTableView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.view.uu_width, self.view.uu_height-40-NAVIGATION_BAR_HEIGHT);
        _inputFuncView.frame = CGRectMake(0, _chatTableView.uu_bottom, self.view.uu_width, 40);
    }
}

-(void)backButtonAction{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)initBasicViews
{
    _chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, kWidth, kHeight-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    _chatTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _chatTableView.delegate = self;
    _chatTableView.dataSource = self;
    [self.view addSubview:_chatTableView];
    
    [_chatTableView registerClass:[UUMessageCell class] forCellReuseIdentifier:NSStringFromClass([UUMessageCell class])];
    
    _inputFuncView = [[UUInputFunctionView alloc] initWithFrame:CGRectMake(0, _chatTableView.uu_bottom, kWidth, 40)];
    _inputFuncView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _inputFuncView.delegate = self;
    [self.view addSubview:_inputFuncView];

}

- (void)addRefreshViews
{
    __weak typeof(self) weakSelf = self;
    
    //load more
    int pageNum = 10;
    
    self.chatTableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        
//        [weakSelf.chatModel addRandomItemsToDataSource:pageNum];
        
        if (weakSelf.chatModel.dataSource.count > pageNum) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pageNum inSection:0];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.chatTableView reloadData];
                [weakSelf.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
        }
        [weakSelf.chatTableView.mj_header endRefreshing];
    }];
}

- (void)loadBaseViewsAndData
{
    self.chatModel = [[ChatModel alloc] init];
    self.chatModel.isGroupChat = YES;
    [self.chatModel populateRandomDataSource];
    [self.chatTableView reloadData];
}

//- (void)segmentChanged:(UISegmentedControl *)segment
//{
//    self.chatModel.isGroupChat = segment.selectedSegmentIndex;
//    [self.chatModel.dataSource removeAllObjects];
//    [self.chatModel populateRandomDataSource];
//    [self.chatTableView reloadData];
//}
//
#pragma mark - notification event

//tableView Scroll to bottom
- (void)tableViewScrollToBottom
{
    if (self.chatModel.dataSource.count==0) { return; }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    _keyboardHeight = keyboardEndFrame.size.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    self.chatTableView.uu_height = self.view.uu_height - _inputFuncView.uu_height;
    self.chatTableView.uu_height -= notification.name == UIKeyboardWillShowNotification ? _keyboardHeight:0;
    self.chatTableView.contentOffset = CGPointMake(0, self.chatTableView.contentSize.height-self.chatTableView.uu_height);
    
    self.inputFuncView.uu_top = self.chatTableView.uu_bottom;
    
    [UIView commitAnimations];
}

- (void)adjustCollectionViewLayout
{
    [self.chatModel recountFrame];
    [self.chatTableView reloadData];
}

#pragma mark - InputFunctionViewDelegate

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    NSDictionary *dic = @{@"strContent": message,
                          @"type": @(UUMessageTypeText)};
    
//    [];
    funcView.textViewInput.text = @"";
//    [funcView changeSendBtnWithPhoto:YES];
    [self dealTheFunctionData:dic];
    
    [_peerclient send:[self.detailDic objectForKey:@"_id"] message:message onSuccess:^{
        DebugLog(@"sendMessage is success");
    } onFailure:^(NSError * error) {
        DebugLog(@"sendMessage is error%@",error);
    }];
    
//    id<RTCP2PSignalingChannelProtocol> scc=[[SocketSignalingChannel alloc]init];
//
//    [_peerclient sendMessage:message to:[self.detailDic objectForKey:@"_id"] onSuccess:^{
//
//        DebugLog(@"sendMessage is success");
//
//    } onFailure:^(NSError *error) {
//
//        DebugLog(@"sendMessage is error");
//
//    }];
    
    
    
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image
{
    NSDictionary *dic = @{@"picture": image,
                          @"type": @(UUMessageTypePicture)};
    [self dealTheFunctionData:dic];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    NSDictionary *dic = @{@"voice": voice,
                          @"strVoiceTime": [NSString stringWithFormat:@"%d",(int)second],
                          @"type": @(UUMessageTypeVoice)};
    [self dealTheFunctionData:dic];
}

- (void)dealTheFunctionData:(NSDictionary *)dic
{
    [self.chatModel addSpecifiedItem:dic];
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}

#pragma mark - tableView delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UUMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UUMessageCell class])];
    cell.delegate = self;
    cell.messageFrame = self.chatModel.dataSource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.chatModel.dataSource[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - UUMessageCellDelegate

- (void)chatCell:(UUMessageCell *)cell headImageDidClick:(NSString *)userId
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:cell.messageFrame.message.strName message:@"headImage clicked" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
    [alert show];
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
