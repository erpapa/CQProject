//
//  CQGestureRecognizerViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQGestureRecognizerViewController.h"
#import "UIButton+Expand.h"

@interface CQGestureRecognizerViewController ()
@property (nonatomic, strong) UIGestureRecognizer *guest;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UIView *view2;
@end

@implementation CQGestureRecognizerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"手势事件";
    [self.view addGestureRecognizer:self.guest];
    
    [self.view addSubview:self.view1];
    [self.view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(100);
        make.top.equalTo(self.view).offset(100);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    [self.view addSubview:self.view2];
    [self.view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(150);
        make.top.equalTo(self.view).offset(150);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    [self.view addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(200);
        make.top.equalTo(self.view).offset(200);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
}

- (void)buttonClick {
    NSLog(@"button事件响应了");
}

//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%s", __func__);
//}

- (UIView *)view1 {
    if (!_view1) {
        _view1 = [[UIButton alloc] init];
        _view1.backgroundColor = [UIColor redColor];
        @weakify(self);
        UILongPressGestureRecognizer *guest = [[UILongPressGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @strongify(self);
            NSLog(@"红色View长按手势对象被响应了");
        }];
        [_view1 addGestureRecognizer:guest];
    }
    return _view1;
}

- (UIView *)view2 {
    if (!_view2) {
        _view2 = [[UIButton alloc] init];
        _view2.backgroundColor = [UIColor yellowColor];
        @weakify(self);
        UITapGestureRecognizer *guest = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @strongify(self);
            NSLog(@"黄色View单击手势对象被响应了");
        }];
        [_view2 addGestureRecognizer:guest];
    }
    return _view2;
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] init];
        [_button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
        _button.backgroundColor = [UIColor redColor];
//        _button.expandEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        _button.expandTop = -10;
    }
    return _button;
}

- (UIGestureRecognizer *)guest {
    if (!_guest) {
        @weakify(self);
        _guest = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
//            @strongify(self);
            NSLog(@"父View的单击手势对象被响应了");
        }];
        _guest.delaysTouchesBegan = YES;
    }
    return _guest;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s",__func__);
}

@end
