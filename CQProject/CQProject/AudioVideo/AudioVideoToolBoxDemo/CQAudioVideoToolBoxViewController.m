//
//  CQAudioVideoToolBoxViewController.m
//  CQProject
//
//  Created by CharType on 2020/10/26.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQAudioVideoToolBoxViewController.h"

@interface CQAudioVideoToolBoxViewController ()
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIStackView *stackView;
@end

@implementation CQAudioVideoToolBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"完整编解码";
    [self.view addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.view).offset(84);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(30);
    }];
    
}

- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.startButton, self.stopButton,self.closeButton]];
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.alignment = UIStackViewAlignmentFill;
        _stackView.distribution = UIStackViewDistributionEqualSpacing;
    }
    return _stackView;
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [[UIButton alloc] init];
        [_startButton setTitle:@"开始编码" forState:UIControlStateNormal];
        _startButton.layer.cornerRadius = 15;
        _startButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _startButton.layer.masksToBounds = YES;
        [_startButton setBackgroundColor:[UIColor orangeColor]];
        [_startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 30));
        }];
    }
    return _startButton;;
}

- (UIButton *)stopButton {
    if (!_stopButton) {
        _stopButton = [[UIButton alloc] init];
        [_stopButton setTitle:@"停止编码" forState:UIControlStateNormal];
        _stopButton.layer.cornerRadius = 15;
        _stopButton.layer.masksToBounds = YES;
        _stopButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_stopButton setBackgroundColor:[UIColor orangeColor]];
        [_stopButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 30));
        }];
    }
    return _stopButton;;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setTitle:@"关闭文件" forState:UIControlStateNormal];
        _closeButton.layer.cornerRadius = 15;
        _closeButton.layer.masksToBounds = YES;
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_closeButton setBackgroundColor:[UIColor orangeColor]];
        [_closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 30));
        }];
    }
    return _closeButton;
}

@end
