//
//  CQFPSViewController.m
//  CQProject
//
//  Created by CharType on 2020/8/12.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQFPSViewController.h"

@interface CQFPSViewController ()
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) int total;
@property (nonatomic, assign) CFTimeInterval timestamp;
@property (nonatomic, assign) CFTimeInterval lastTimeStamp;
@property (nonatomic, strong) UILabel *fpsLabel;
@end

@implementation CQFPSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.fpsLabel];
    [self.fpsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.center.mas_equalTo(self.view);
    }];
    [self start];
}

- (UILabel *)fpsLabel {
    if (!_fpsLabel) {
        _fpsLabel = [[UILabel alloc] init];
        _fpsLabel.textColor = [UIColor blackColor];
        _fpsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _fpsLabel;
}

- (void)setfps:(int)fps {
    if (fps <= 50) {
        self.fpsLabel.textColor = [UIColor redColor];
    } else {
        self.fpsLabel.textColor = [UIColor greenColor];
    }
    self.fpsLabel.text = [NSString stringWithFormat:@"%dFPS",fps];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.link invalidate];
}

- (void)start {
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(fpsCount:)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    sleep(5);
}

- (void)fpsCount:(CADisplayLink *)link {
    if (self.lastTimeStamp == 0) {
        self.lastTimeStamp = self.link.timestamp;
    } else {
        self.total++; // 开始渲染时间与上次渲染时间差值
        NSTimeInterval useTime = self.link.timestamp - self.lastTimeStamp;
        if (useTime < 1) return;
        self.lastTimeStamp = self.link.timestamp;
        // fps 计算
        int fps = self.total / useTime;
        [self setfps:fps];
        self.total = 0;
    }
}

@end
