//
//  CQComponentViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/21.
//  Copyright © 2020 CharType. All rights reserved.
// 组件化中间层如何通信测试

#import "CQComponentViewController.h"
#import "Person.h"

@interface CQComponentViewController ()
@property (nonatomic, strong) UIButton *button;
@end

@implementation CQComponentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"组件化中间层调用";
    [self.view addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(100);
        make.top.equalTo(self.view).offset(100);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
}

- (void)buttonClick {
    Person *p = [[Person alloc] init];
    p.age = 20;
    id obj = [[CTMediator sharedInstance] performTarget:@"kvoTwo" action:@"CTMediatorViewControllerWith" params:@{@"p":p} shouldCacheTarget:YES];
    [self.navigationController pushViewController:obj animated:YES];
    
    
//    id object = [[JSObjection defaultInjector] getObject:NSClassFromString(@"CQTwoKVOViewController")];
//    [self.navigationController pushViewController:object animated:YES];
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] init];
        _button.backgroundColor = [UIColor redColor];
        [_button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

@end
