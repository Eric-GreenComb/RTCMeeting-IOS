//
//  OneViewController.m
//  RTCMeeting
//
//  Created by jianqiangzhang on 2017/3/9.
//  Copyright © 2017年 jianqiangzhang. All rights reserved.
//

#import "TwoViewController.h"
#import <RTMPCHybirdEngine/RTMeetKit.h>
#import <RTMPCHybirdEngine/RTConfig.h>
#import "Config.h"
#import "ASHUD.h"
#import <RTMPCHybirdEngine/RTCCommon.h>
#import "UINavigationController+FDFullscreenPopGesture.h"
#import <Masonry.h>

@interface TwoViewController ()<RTMeetKitDelegate>

@property (nonatomic, strong) RTMeetKit *meetKit;

@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, strong) UIImageView *closeCameraView;

@property (nonatomic, strong) NSMutableArray *remoteArray;

@property (nonatomic, assign) int remoteViewTag;

@property (strong, nonatomic) UIView *toolBarView;

@property (nonatomic, assign) CGSize localVideoSize;

@end

@implementation TwoViewController

- (void)dealloc
{
    if (self.meetKit) {
        [self.meetKit Leave];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.cameraView];
    
    [self.view addSubview:self.toolBarView];
    
    self.remoteViewTag = 300;
    
    self.remoteArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    [RTConfig SetVideoLayout:RTC_V_3X3_auto];
  
    self.meetKit = [[RTMeetKit alloc] initWithDelegate:self];
    
    [self.meetKit ConfigServerForPriCloud:@"teameeting.anyrtc.io" andPort:9060];
    
    [self.meetKit InitEngineWithAnyrtcInfo:developerID andAppID:appID andAppKey:key andAppToken:token];
    
    [self.meetKit SetVideoCapturer:self.cameraView andUseFront:YES];
#warning 确保每个会议房间唯一
    [self.meetKit Join:@"123"];
    
    
}
- (UIView*)cameraView
{
    if (!_cameraView) {
        _cameraView = [[UIView alloc] initWithFrame:CGRectZero];
        
        UITapGestureRecognizer *tag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCameraEvent)];
        [_cameraView addGestureRecognizer:tag];
        
        [_cameraView addSubview:self.closeCameraView];
        [self.closeCameraView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.edges.equalTo(_cameraView).with.insets(UIEdgeInsetsMake(-1, 0, 0, 0));
        }];
    }
    return _cameraView;
}

- (UIImageView*)closeCameraView {
    if (!_closeCameraView) {
        _closeCameraView = [UIImageView new];
        _closeCameraView.backgroundColor = [UIColor blackColor];
        _closeCameraView.hidden = YES;
    }
    return _closeCameraView;
}

// 布局
- (void)layout
{
    [self.toolBarView bringSubviewToFront:self.view];
    
    if (self.remoteArray.count ==0) {
        if (_localVideoSize.width && _localVideoSize.height > 0) {
            float scaleW = self.view.bounds.size.width/_localVideoSize.width;
            float scaleH = self.view.bounds.size.height/_localVideoSize.height;
            if (scaleW>scaleH) {
                _cameraView.frame = CGRectMake(0, 0, _localVideoSize.width*scaleW, _localVideoSize.height*scaleW);
               _cameraView.center =  CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));;
            }else{
               _cameraView.frame = CGRectMake(0, 0, _localVideoSize.width*scaleH, _localVideoSize.height*scaleH);
               _cameraView.center =  CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));;
            }
            
        } else {
           _cameraView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        }
    }else if (self.remoteArray.count ==1 ){
        float width = self.view.frame.size.width/2.0;
        float height = width;
        _cameraView.frame = CGRectMake(0, height/2, width, height);
        
        NSDictionary *dict = [self.remoteArray firstObject];
        UIView *videoView = [dict objectForKey:@"View"];
        videoView.frame = CGRectMake(width, height/2, width, height);
        
    }else if (self.remoteArray.count <= 3) {
        float width = self.view.frame.size.width/2.0;
        float height = width;
        _cameraView.frame = CGRectMake(0, 0, width, height);
      
        if (self.remoteArray.count ==2) {
            NSDictionary *dict = [self.remoteArray firstObject];
            UIView *videoView = [dict objectForKey:@"View"];
            videoView.frame = CGRectMake(width, 0, width, height);
            
            NSDictionary *dictlast = [self.remoteArray lastObject];
            UIView *videoViewLast = [dictlast objectForKey:@"View"];
            videoViewLast.frame = CGRectMake(CGRectGetMidX(self.view.frame)-width/2, height, width, height);
            
        }else{
            float allWidth = width;
            float allHeight = 0;
            
            for (int i= 0;i<self.remoteArray.count;i++) {
                NSDictionary *dict = [self.remoteArray objectAtIndex:i];
                UIView *videoView = [dict objectForKey:@"View"];
                if (allWidth+10>self.view.frame.size.width) {
                    allHeight +=width;
                    allWidth = 0;
                    videoView.frame = CGRectMake(0, allHeight, width, height);
                    allWidth = width;
                }else{
                    videoView.frame = CGRectMake(allWidth, allHeight, width, height);
                    allWidth+=width;
                }
            }

        }
        
        
    }else {
        
        float width = self.view.frame.size.width/3.0;
        float height = width;
        
        _cameraView.frame = CGRectMake(0, 0, width, height);
        float allWidth = width;
        float allHeight = 0;
        
        for (int i= 0;i<self.remoteArray.count;i++) {
            NSDictionary *dict = [self.remoteArray objectAtIndex:i];
            UIView *videoView = [dict objectForKey:@"View"];
            if (allWidth+10>self.view.frame.size.width) {
                allHeight +=width;
                allWidth = 0;
                videoView.frame = CGRectMake(0, allHeight, width, height);
                allWidth = width;
            }else{
                videoView.frame = CGRectMake(allWidth, allHeight, width, height);
                allWidth+=width;
            }
        }
    }
    
}

#pragma mark - RTMeetKitDelegate
- (void)OnRTCJoinMeetOK:(NSString*)strAnyrtcId
{
    [ASHUD showHUDWithCompleteStyleInView:self.view content:@"进入会议室成功" icon:nil];
    [self layout];
}

- (void)OnRTCJoinMeetFailed:(NSString*)strAnyrtcId withCode:(int)code withReaso:(NSString*)strReason
{
    [ASHUD showHUDWithCompleteStyleInView:self.view content:[self getErrorInfoForRtc:code] icon:nil];
    [self.meetKit Leave];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}
- (void)OnRTCLeaveMeet:(int) code
{
    if (code == AnyRTC_FORCE_EXIT)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请去AnyRTC官网申请账号,如有疑问请联系客服!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
    }else{
        
        [ASHUD showHUDWithCompleteStyleInView:self.view content:[self getErrorInfoForRtc:code] icon:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.navigationController popViewControllerAnimated:YES];
            
        });
    }
    
}
- (void)OnRTCOpenVideoRender:(NSString*)strLivePeerID
{
    UIView *videoView = [self getVideoViewWithStrID:strLivePeerID];
    
    [self.meetKit SetRTCVideoRender:strLivePeerID andRender:videoView];
    
    [self.view addSubview:videoView];
  
    [self layout];
    
    
}
- (void)OnRTCCloseVideoRender:(NSString*)strLivePeerID
{
    for (int i=0; i<self.remoteArray.count; i++) {
        NSDictionary *dict = [self.remoteArray objectAtIndex:i];
        if ([[dict objectForKey:@"PeerID"] isEqualToString:strLivePeerID]) {
            UIView *videoView = [dict objectForKey:@"View"];
            [videoView removeFromSuperview];
            [self.remoteArray removeObjectAtIndex:i];
            [self layout];
            break;
        }
    }
    
}
// 谁关闭了摄像头或则关闭了音频（一般是摄像头做处理，音频不做处理）
- (void)OnRTCAVStatus:(NSString*)strLivePeerID withAudio:(BOOL)audio withVideo:(BOOL)video
{
    
}
// 音频监测
- (void)OnRTCAudioActive:(NSString *)strLivePeerID withShowTime:(int)time
{
    
}

-(void) OnRtcViewChanged:(UIView*)videoView didChangeVideoSize:(CGSize)size
{
    if (videoView ==self.cameraView) {
        _localVideoSize = size;
         [self layout];
    }
}

- (UIView*)getVideoViewWithStrID:(NSString*)publishID {
    
    UIView *pullView;
    pullView = [[UIView alloc] init];
    pullView.frame = CGRectZero;
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:pullView,@"View",publishID,@"PeerID", [NSString stringWithFormat:@"%d",self.remoteViewTag],@"buttonTag",nil];
    [self.remoteArray addObject:dict];
    self.remoteViewTag++;
    
    return pullView;
}
- (UIView*)toolBarView
{
    if (!_toolBarView) {
        _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame)-180, CGRectGetWidth(self.view.frame), 180)];
        
        // 静音、开关视频、转换摄像头 挂断
        UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [audioButton addTarget:self action:@selector(audioButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [audioButton setTitle:@"静音" forState:UIControlStateNormal];
        [audioButton setTitle:@"开声音" forState:UIControlStateSelected];
        [_toolBarView addSubview:audioButton];
        // 摄像头关闭，实为不传送视频数据。
        UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [videoButton addTarget:self action:@selector(videoButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [videoButton setTitle:@"关摄像头" forState:UIControlStateNormal];
        [videoButton setTitle:@"开摄像头" forState:UIControlStateSelected];
        [_toolBarView addSubview:videoButton];
        
        UIButton *soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [soundButton addTarget:self action:@selector(soundButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [soundButton setTitle:@"免提开" forState:UIControlStateNormal];
        [soundButton setTitle:@"免提关" forState:UIControlStateSelected];
        soundButton.selected = YES;
        [_toolBarView addSubview:soundButton];
        
        UIButton *hangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [hangupButton addTarget:self action:@selector(hangupButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [hangupButton setTitle:@"挂断" forState:UIControlStateNormal];
        [_toolBarView addSubview:hangupButton];
        
        [soundButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@[@(80)]);
            make.height.equalTo(@[@(55)]);
            make.top.equalTo(_toolBarView.mas_top).offset(15);
            make.centerX.equalTo(_toolBarView.mas_centerX);
        }];
        
        [audioButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@[@(55)]);
            make.width.equalTo(@[@(80)]);
            make.top.equalTo(_toolBarView.mas_top).offset(15);
            make.centerX.equalTo(_toolBarView.mas_centerX).multipliedBy(.5);
        }];
        
        [videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@[@(55)]);
            make.width.equalTo(@[@(80)]);
            make.top.equalTo(_toolBarView.mas_top).offset(15);
            make.centerX.equalTo(_toolBarView.mas_centerX).multipliedBy(1.5);
        }];
        
        [hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@[@(60)]);
            make.bottom.equalTo(_toolBarView.mas_bottom).offset(-20);
            make.centerX.equalTo(_toolBarView.mas_centerX);
        }];
        
        
    }
    return _toolBarView;
}

// 获取错误信息
- (NSString*)getErrorInfoForRtc:(int)code {
    switch (code) {
        case AnyRTC_OK:
            return @"RTC:链接成功";
            break;
        case AnyRTC_UNKNOW:
            return @"RTC:未知错误";
            break;
        case AnyRTC_EXCEPTION:
            return @"RTC:SDK调用异常";
            break;
        case AnyRTC_NET_ERR:
            return @"RTC:网络错误";
            break;
        case AnyRTC_LIVE_ERR:
            return @"RTC:直播出错";
            break;
        case AnyRTC_BAD_REQ:
            return @"RTC:服务不支持的错误请求";
            break;
        case AnyRTC_AUTH_FAIL:
            return @"RTC:认证失败";
            break;
        case AnyRTC_NO_USER:
            return @"RTC:此开发者信息不存在";
            break;
        case AnyRTC_SQL_ERR:
            return @"RTC: 服务器内部数据库错误";
            break;
        case AnyRTC_ARREARS:
            return @"RTC:账号欠费";
            break;
        case AnyRTC_LOCKED:
            return @"RTC:账号被锁定";
            break;
        case AnyRTC_FORCE_EXIT:
            return @"RTC:强制离开";
            break;
        default:
            break;
    }
    return @"未知错误";
}


- (void)audioButtonEvent:(UIButton*)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.meetKit SetAudioEnable:NO];
    }else{
        [self.meetKit SetAudioEnable:YES];
    }
}
- (void)videoButtonEvent:(UIButton*)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.meetKit SetVideoEnable:NO];
        self.closeCameraView.hidden = NO;
    }else{
        [self.meetKit SetVideoEnable:YES];
        self.closeCameraView.hidden = YES;
    }
}
// 扬声器开关
- (void)soundButtonEvent:(UIButton*)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.meetKit SetSpeakerOn:YES];
    }else{
        [self.meetKit SetSpeakerOn:NO];
    }
}
- (void)hangupButtonEvent:(UIButton*)sender
{
    [self.meetKit Leave];
    self.meetKit = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}
// 转换摄像头
- (void)changeCameraEvent
{
    
    if (self.closeCameraView.hidden) {
         [self.meetKit SwitchCamera];
    }
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
