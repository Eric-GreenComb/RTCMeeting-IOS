//
//  ViewController.m
//  RTCMeeting
//
//  Created by jianqiangzhang on 2017/3/9.
//  Copyright © 2017年 jianqiangzhang. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "OneViewController.h"
#import "TwoViewController.h"



@interface ViewController ()

@property (nonatomic, strong) UIButton *oneLayoutButton;
@property (nonatomic, strong) UIButton *twoLayoutButton;

@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"AnyRTC视频会议";
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    
    [self.view addSubview:self.oneLayoutButton];
    
    [self.view addSubview:self.twoLayoutButton];
    
    [self.view addSubview:self.tipLabel];
    
    
    [self.oneLayoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(self.view.mas_height).multipliedBy(.2);
    }];
    
    [self.twoLayoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.oneLayoutButton.mas_bottom);
        make.height.equalTo(self.view.mas_height).multipliedBy(.2);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.twoLayoutButton.mas_bottom);
        
    }];

    
}

- (void)oneLayoutEvent {
    OneViewController *oneController = [OneViewController new];
    [self presentViewController:oneController animated:YES completion:nil];
}

- (void)twoLayoutEvent {
    TwoViewController *twoController = [TwoViewController new];
   
    [self presentViewController:twoController animated:YES completion:nil];
}



- (UIButton *)oneLayoutButton {
    if (!_oneLayoutButton) {
        _oneLayoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_oneLayoutButton setTitle:@"1*3布局" forState:UIControlStateNormal];
        [_oneLayoutButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_oneLayoutButton addTarget:self action:@selector(oneLayoutEvent) forControlEvents:UIControlEventTouchUpInside];
        _oneLayoutButton.layer.cornerRadius = 10;
        _oneLayoutButton.layer.borderWidth = 1;
        _oneLayoutButton.layer.borderColor = [UIColor blackColor].CGColor;
    }
    return _oneLayoutButton;
}
- (UIButton *)twoLayoutButton {
    if (!_twoLayoutButton) {
        _twoLayoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_twoLayoutButton setTitle:@"微信布局" forState:UIControlStateNormal];
        [_twoLayoutButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_twoLayoutButton addTarget:self action:@selector(twoLayoutEvent) forControlEvents:UIControlEventTouchUpInside];
        _twoLayoutButton.layer.cornerRadius = 10;
        _twoLayoutButton.layer.borderWidth = 1;
        _twoLayoutButton.layer.borderColor = [UIColor blackColor].CGColor;
    }
    return _twoLayoutButton;
}
- (UILabel*)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel new];
        _tipLabel.numberOfLines = 0;
       NSString *htmlString = @"<html><title></title><body><b>1*3布局:</b> 该场景用于一对一，一对2或者3，视频分辨率比较高。该模式下最多为4人，在多，将会出现卡顿，视频丢失，该demo在该模式下布局最多4人。<br/><b>微信布局:</b>分辨率固定（比较小）。<br/><b>进入会议:</b>进入同一个会议室，确保会议ID一致。每个房间确保房间ID唯一即可。  </body><html>";
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        _tipLabel.attributedText = attrStr;
        
    }
    return _tipLabel;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
