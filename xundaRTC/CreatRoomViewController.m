//
//  CreatRoomViewController.m
//  xundaRTC
//
//  Created by 大V on 2018/6/11.
//  Copyright © 2018年 season. All rights reserved.
//

#import "CreatRoomViewController.h"

@interface CreatRoomViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDataSource, UITableViewDelegate>{
    
    UIPickerView        *choosePicker;
    int                 choosenum;
    UIView              *pickerview;
    UIView              *bkview;
    
}

@property (strong, nonatomic) UITableView       *myTableView;
@property (strong, nonatomic) UIImagePickerController *picker;
@property (nonatomic, strong) NSMutableArray *modeArray;
@property (nonatomic, strong) NSMutableArray *resolutionArray;
@property (nonatomic, strong) NSMutableArray *bkColorArray;
@property (nonatomic, strong) NSMutableArray *layoutArray;
@property (nonatomic, strong) UITextField   *nametextField;
@property (nonatomic,strong)NSString *roomnameStr;
@property (nonatomic,strong)NSString *publishLimitStr;
@property (nonatomic,strong)NSString *userLimitStr;
@property (nonatomic,strong)NSString *bitrateStr;
@property (nonatomic,strong)NSString *maxInputStr;
@property (nonatomic,strong)NSString *resolutionStr;
@property (nonatomic,strong)NSString *bkColorStr;
@property (nonatomic,strong)NSString *layoutStr;

@property (nonatomic,strong)NSString *enableMixingStr;
@property (nonatomic,strong)NSString *avCoordinatedStr;
@property (nonatomic,strong)NSString *multistreamingStr;
@property (nonatomic,strong)NSString *cropStr;

@end

@implementation CreatRoomViewController
-(void)viewWillAppear:(BOOL)animated{
    
    _roomnameStr=@"";


}
- (void)viewDidLoad {
    [super viewDidLoad];
    _publishLimitStr=@"-1";
    _roomnameStr=@"";
    _userLimitStr=@"-1";
    _bitrateStr=@"-1";
    _maxInputStr=@"-1";
    
    _enableMixingStr=@"0";
    _avCoordinatedStr=@"0";
    _multistreamingStr=@"0";
    _cropStr=@"0";
    
    _modeArray=[[NSMutableArray alloc]initWithObjects:@"hybrid", nil];
    _resolutionArray=[[NSMutableArray alloc]initWithObjects:@"uhd_4k",@"hd1080p",@"hd720p",@"r720 x 720",@"xvga",@"svga",@"vga",@"sif", nil];
    _bkColorArray=[[NSMutableArray alloc]initWithObjects:@"black", @"white",nil];
    _layoutArray=[[NSMutableArray alloc]initWithObjects:@"fluid", @"lecture",nil];
    
    _resolutionStr=[_resolutionArray objectAtIndex:0];
    _bkColorStr=[_bkColorArray objectAtIndex:0];
    _layoutStr=[_layoutArray objectAtIndex:0];

    self.view.backgroundColor=kBaseRGB;
    
    UIImageView* navigationbarimg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kWidth,NAVIGATION_BAR_HEIGHT)];
    navigationbarimg.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:navigationbarimg];
    
    UILabel *titlelabel = [[UILabel alloc] init];
    titlelabel.frame = CGRectMake(0, STATUS_BAR_HEIGHT, kWidth, NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT);
    titlelabel.backgroundColor=[UIColor clearColor];
    titlelabel.textColor=[UIColor blackColor];
    titlelabel.text=@"创建房间";
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
    
    UIButton* creatButton = [[UIButton alloc]init];
    creatButton.frame = CGRectMake(kWidth-100, STATUS_BAR_HEIGHT, 100, NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT);
    [creatButton setTitle:@"创建" forState:UIControlStateNormal];
    [creatButton setTitleColor:RGB(8,184,6,1) forState:UIControlStateNormal];
    [creatButton addTarget:self action:@selector(creatButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:creatButton];
    
    _myTableView = (
                    {
                        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, kWidth, kHeight-NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
                        tableView.backgroundColor = [UIColor clearColor];
                        tableView.dataSource = self;
                        tableView.delegate = self;
                        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                        [self.view addSubview:tableView];
                        tableView;
                    });

    pickerview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    [pickerview setBackgroundColor:RGB(67, 67, 67, 0.3)];
    pickerview.hidden=YES;
    [self.view addSubview:pickerview];
    
    UIButton *closeviewButton = [[UIButton alloc]init];
    closeviewButton.frame = CGRectMake(0, 0, kWidth, kHeight);
    [closeviewButton setBackgroundColor:[UIColor clearColor]];
    [closeviewButton addTarget:self action:@selector(closeviewButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [pickerview addSubview:closeviewButton];
    
    choosePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kHeight-216, kWidth, 216)];
    choosePicker.delegate=self;
    choosePicker.backgroundColor=[UIColor whiteColor];
    choosePicker.hidden=NO;
    choosePicker.showsSelectionIndicator=YES;
    [pickerview addSubview:choosePicker];

}

#pragma  mark ------button action method
-(void)closeviewButtonAction{
    
    pickerview.hidden=YES;
    
    
}

-(void)creatButtonAction{
    
    [self creatroomdata];
    
}

-(void)backButtonAction{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)closeButtonAction{
    
    if (bkview.superview) {
        [bkview removeFromSuperview];
    }
    
    
}

#pragma mark
#pragma mark ------------tableview delegate-----------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 13;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    return @"参数设置";
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"TimelineCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.userInteractionEnabled = YES;
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(25,0,kWidth/2,70)];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor=RGB(0, 0, 0, 1);
    label.numberOfLines=0;
    [cell addSubview:label];
    
    switch (indexPath.row) {
        case 0:
        {
            label.text=@"房间名";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            
            UILabel *namelabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/2,0,kWidth/2-30,70)];
            namelabel.textAlignment = NSTextAlignmentRight;
            namelabel.font = [UIFont systemFontOfSize:14];
            namelabel.textColor=RGB(0, 0, 0, 1);
            namelabel.numberOfLines=0;
            namelabel.text=_roomnameStr;
            [cell addSubview:namelabel];


        }
            break;
        case 1:
        {
            label.text=@"推流限制";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            
            UILabel *namelabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/2,0,kWidth/2-30,70)];
            namelabel.textAlignment = NSTextAlignmentRight;
            namelabel.font = [UIFont systemFontOfSize:14];
            namelabel.textColor=RGB(0, 0, 0, 1);
            namelabel.numberOfLines=0;
            namelabel.text=_publishLimitStr;
            [cell addSubview:namelabel];

        }
            break;
        case 2:
        {
            label.text=@"用户限制";
            
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            
            UILabel *namelabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/2,0,kWidth/2-30,70)];
            namelabel.textAlignment = NSTextAlignmentRight;
            namelabel.font = [UIFont systemFontOfSize:14];
            namelabel.textColor=RGB(0, 0, 0, 1);
            namelabel.numberOfLines=0;
            namelabel.text=_userLimitStr;
            [cell addSubview:namelabel];

        }
            break;
        case 3:
        {
            label.text=@"模式";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            
            UILabel *namelabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/2,0,kWidth/2-30,70)];
            namelabel.textAlignment = NSTextAlignmentRight;
            namelabel.font = [UIFont systemFontOfSize:14];
            namelabel.textColor=RGB(0, 0, 0, 1);
            namelabel.numberOfLines=0;
            namelabel.text=@"hybrid";
            [cell addSubview:namelabel];


        }
            break;
        case 4:
        {
            label.text=@"是否混流";
            UISwitch *mixSBtn= [[UISwitch alloc]initWithFrame:CGRectMake(kWidth-70, 20, 0, 0)];
            [mixSBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:mixSBtn];

        }
            break;
        case 5:
        {
            label.text=@"分辨率";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            UILabel *namelabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/2,0,kWidth/2-30,70)];
            namelabel.textAlignment = NSTextAlignmentRight;
            namelabel.font = [UIFont systemFontOfSize:14];
            namelabel.textColor=RGB(0, 0, 0, 1);
            namelabel.numberOfLines=0;
            namelabel.text=_resolutionStr;
            [cell addSubview:namelabel];

        }
            break;
        case 6:
        {
            label.text=@"比特率";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            
            UILabel *namelabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/2,0,kWidth/2-30,70)];
            namelabel.textAlignment = NSTextAlignmentRight;
            namelabel.font = [UIFont systemFontOfSize:14];
            namelabel.textColor=RGB(0, 0, 0, 1);
            namelabel.numberOfLines=0;
            namelabel.text=_bitrateStr;
            [cell addSubview:namelabel];

        }
            break;
        case 7:
        {
            label.text=@"背景";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            UILabel *namelabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/2,0,kWidth/2-30,70)];
            namelabel.textAlignment = NSTextAlignmentRight;
            namelabel.font = [UIFont systemFontOfSize:14];
            namelabel.textColor=RGB(0, 0, 0, 1);
            namelabel.numberOfLines=0;
            namelabel.text=_bkColorStr;
            [cell addSubview:namelabel];

        }
            break;
        case 8:
        {
            label.text=@"最大输入";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            UILabel *namelabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/2,0,kWidth/2-30,70)];
            namelabel.textAlignment = NSTextAlignmentRight;
            namelabel.font = [UIFont systemFontOfSize:14];
            namelabel.textColor=RGB(0, 0, 0, 1);
            namelabel.numberOfLines=0;
            namelabel.text=_maxInputStr;
            [cell addSubview:namelabel];

        }
            break;
        case 9:
        {
            label.text=@"布局";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            
            UILabel *namelabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/2,0,kWidth/2-30,70)];
            namelabel.textAlignment = NSTextAlignmentRight;
            namelabel.font = [UIFont systemFontOfSize:14];
            namelabel.textColor=RGB(0, 0, 0, 1);
            namelabel.numberOfLines=0;
            namelabel.text=_layoutStr;
            [cell addSubview:namelabel];

        }
            break;
        case 10:
        {
            label.text=@"视图坐标";
            UISwitch *viewSBtn= [[UISwitch alloc]initWithFrame:CGRectMake(kWidth-70, 20, 0, 0)];
            [viewSBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:viewSBtn];
        }
            break;
        case 11:
        {
            label.text=@"多个数据流";
            UISwitch *streamSBtn= [[UISwitch alloc]initWithFrame:CGRectMake(kWidth-70, 20, 0, 0)];
            [streamSBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:streamSBtn];
        }
            break;
        case 12:
        {
            label.text=@"剪切";
            UISwitch *cutSBtn= [[UISwitch alloc]initWithFrame:CGRectMake(kWidth-70, 20, 0, 0)];
            [cutSBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:cutSBtn];
        }
            break;

        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            {
                [self showputinView:0];
            }
            break;
        case 1:
        {
            [self showputinView:1];

        }
            break;
            
        case 2:
        {
            [self showputinView:2];

        }
            break;
            
            
            
        case 5:
        {
            choosenum=1;
            pickerview.hidden=NO;
            [choosePicker reloadAllComponents];
            [choosePicker selectRow:0 inComponent:0 animated:YES];

        }
            break;
            
        case 6:
        {
            [self showputinView:6];

        }
            break;
            
        case 7:
        {
            choosenum=2;
            pickerview.hidden=NO;
            [choosePicker reloadAllComponents];
            [choosePicker selectRow:0 inComponent:0 animated:YES];

        }
            break;
            
        case 8:
        {
            [self showputinView:8];

        }
            break;
            
        case 9:
        {
            choosenum=3;
            pickerview.hidden=NO;
            [choosePicker reloadAllComponents];
            [choosePicker selectRow:0 inComponent:0 animated:YES];

        }
            break;
            
            

        default:
            break;
    }
    
    
}

-(void)showputinView:(int)putintype{
    
    if (bkview.superview) {
        [bkview removeFromSuperview];
    }
    
    bkview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    [bkview setBackgroundColor:RGB(67, 67, 67, 0.5)];
    [self.view addSubview:bkview];
    
    UIButton *backButton = [[UIButton alloc]init];
    backButton.frame = CGRectMake(0, 0, kWidth, kHeight);
    [backButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [bkview addSubview:backButton];
    
    UIView *inputView=[[UIView alloc]initWithFrame:CGRectMake(kWidth/8, (kHeight-kWidth/2)/2, kWidth*3/4, 140)];
    [inputView setBackgroundColor:[UIColor whiteColor]];
    [bkview addSubview:inputView];
    
    
    _nametextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10,kWidth*3/4- 20, 50)];
    _nametextField.backgroundColor = [UIColor clearColor];
    _nametextField.font = [UIFont systemFontOfSize:16];
    _nametextField.textColor = [UIColor blackColor];
    [_nametextField.layer setBorderColor:RGB(221, 221, 221, 1).CGColor];
    [_nametextField.layer setBorderWidth:1.0];
    [_nametextField.layer setMasksToBounds:YES];
    [_nametextField.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
    _nametextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    if (putintype==0) {
        _nametextField.text=_roomnameStr;
        _nametextField.placeholder = @"请填写房间名";
        
    }
    else     if (putintype==1) {
        _nametextField.text=_publishLimitStr;
        _nametextField.placeholder = @"请填写推流限制";
        
    }
    else     if (putintype==2) {
        _nametextField.text=_userLimitStr;
        _nametextField.placeholder = @"请填写用户限制";
        
    }
    else     if (putintype==6) {
        _nametextField.text=_bitrateStr;
        _nametextField.placeholder = @"请填写比特率";
        
    }
    else     if (putintype==8) {
        _nametextField.text=_maxInputStr;
        _nametextField.placeholder = @"请填写最大输入";
        
    }
    
    [inputView addSubview:_nametextField];
    
    PlayButton *saveBtn=[PlayButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(30, 80, kWidth*3/4- 60,35);
    [saveBtn setBackgroundColor:RGB(227,67,78,1)];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:RGB(255, 255, 255, 1) forState:UIControlStateNormal];
    saveBtn.layer.masksToBounds =YES;
    saveBtn.userInteractionEnabled = YES;
    [saveBtn.layer setMasksToBounds:YES];
    [saveBtn.layer setCornerRadius:15.0]; //设置矩形四个圆角半径
    saveBtn.titleLabel.font =  [UIFont systemFontOfSize:16];
    [saveBtn.layer setBorderColor:RGB(221, 221, 221, 1).CGColor];
    [saveBtn.layer setBorderWidth:1.0];
    saveBtn.tag=1000+putintype;
    [saveBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:saveBtn];
    
    
    
}

-(void)save:(PlayButton *)sender{
    if (sender.tag-1000==0) {
        _roomnameStr=_nametextField.text;
    }
    else     if (sender.tag-1000==1) {
        _publishLimitStr=_nametextField.text;
    }
    else     if (sender.tag-1000==2) {
        _userLimitStr=_nametextField.text;
    }
    else     if (sender.tag-1000==6) {
        _bitrateStr=_nametextField.text;
    }
    else     if (sender.tag-1000==8) {
        _maxInputStr=_nametextField.text;
    }
    
    [self closeButtonAction];
    [_myTableView reloadData];
    
    
}
- (void)setTextValue:(NSString *)textValue andTextChangeBlock:(void(^)(NSString *textValue))block{
    [_nametextField becomeFirstResponder];
}


- (void)switchAction:(id)sender{
    
    //获取点击按钮对应的cell
    
    UISwitch *switchInCell = (UISwitch *)sender;
    
    //UISwitch的superview就是cell
    
    UITableViewCell * cell = (UITableViewCell*) switchInCell.superview;
    
    int  sbtntag = (int)[self.myTableView indexPathForCell:cell].row;
    
    DebugLog(@"sbtntag is %d",sbtntag);
    
    switch (sbtntag) {
        case 4:
        {
            if (switchInCell.on) {

                _enableMixingStr=@"1";
            } else {

                _enableMixingStr=@"0";

            }

            
        }
            break;
        case 10:
        {
            if (switchInCell.on) {
                
                _avCoordinatedStr=@"1";
            } else {
                
                _avCoordinatedStr=@"0";
                
            }

            
        }
            break;
        case 11:
        {
            
            if (switchInCell.on) {
                
                _multistreamingStr=@"1";
            } else {
                
                _multistreamingStr=@"0";
                
            }

        }
            break;
        case 12:
        {
            if (switchInCell.on) {
                _cropStr=@"1";
            } else {
                
                _cropStr=@"0";
                
            }
        }
            break;

        default:
            break;
    }

}

#pragma mark -------- post creat data method
-(void)creatroomdata{
    if ([_roomnameStr isEqualToString:@""]) {
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"请填写房间名称" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:alert animated:YES completion:nil];

    }else{
        
        
    
    
    NSDictionary *layoutDic=DICT(_layoutStr,@"base");
    NSDictionary *mediaMixingDic=DICT(layoutDic,@"layout",_multistreamingStr,@"multistreaming",_resolutionStr,@"resolution",_maxInputStr,@"maxInput",_bkColorStr,@"bkColor",_avCoordinatedStr,@"avCoordinated",_bitrateStr,@"bitrate",_cropStr,@"crop");
    NSDictionary *mediaMixingDics=DICT(mediaMixingDic,@"mediaMixing");
    
    NSDictionary *optionsDic=DICT(_publishLimitStr,@"publishLimit",_enableMixingStr,@"enableMixing",_userLimitStr,@"userLimit",@"2019-5-26T13:15:48Z",@"expirationDate",@"hybrid",@"mode",mediaMixingDics,@"mediaMixing");
    NSDictionary *paramsDic=DICT(_roomnameStr,@"name",optionsDic,@"options");
    
    DebugLog(@"paramsDic is %@",paramsDic);
    
    NSData *data= [NSJSONSerialization dataWithJSONObject:paramsDic options:NSJSONWritingPrettyPrinted error:nil];

    NSString *tokenstr=[[NSUserDefaults standardUserDefaults]objectForKey:@"usertoken"];
    
    
    NSString *path=[NSString stringWithFormat:@"%@/rooms?usertoken=%@",BASE_URL,tokenstr];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:path parameters:nil error:nil];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    
        NSData *body = data;
    
        [request setHTTPBody:body];
    
    //发起请求
    
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            
            NSLog(@"=============Reply JSON: %@", responseObject);
            
            NSString *responseObjectstr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            DebugLog(@"=========dicresponseObjectstris %@",responseObjectstr);

            NSDictionary *dic=[self dictionaryWithJsonString:responseObjectstr];
            DebugLog(@"dic===%@",dic);

            
            [self backButtonAction];
            
        } else {
            
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            
        }
        
    }] resume];
    
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
        NSLog(@"json解析失败：%@",error);
        return nil;
    }
    return dic;
}

#pragma mark --------UIPickerView delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    int pickercount=0;
    switch (choosenum) {
        case 1:
            pickercount=(int)_resolutionArray.count;
            break;
        case 2:
            pickercount=(int)_bkColorArray.count;
            break;
        case 3:
            pickercount=(int)_layoutArray.count;
            break;

        default:
            break;
    }
    return pickercount;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch (choosenum) {
        case 1:
            return [_resolutionArray objectAtIndex:row];
            break;
        case 2:
            return [_bkColorArray objectAtIndex:row];
            break;
        case 3:
            return [_layoutArray objectAtIndex:row];
            break;
            

        default:
            break;
    }
    return nil;
    
}
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (choosenum) {
        case 1:
        {
            _resolutionStr=[_resolutionArray objectAtIndex:row];

        }
            break;
        case 2:
        {
            _bkColorStr=[_bkColorArray objectAtIndex:row];
        }
            
            break;
        case 3:
        {
            _layoutStr=[_layoutArray objectAtIndex:row];
        }
            break;

        default:
            break;
    }
    [_myTableView reloadData];
    [self closeviewButtonAction];
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
