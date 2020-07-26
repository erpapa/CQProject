//
//  CQUIViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/25.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQUIViewController.h"

@interface CQUIViewController ()
@property (nonatomic, strong) UIView *custemView;
@end

@implementation CQUIViewController

//- (void)loadView {
//    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.custemView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    self.custemView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.custemView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        NSLog(@"view被点击到了");
    }];
    [self.custemView addGestureRecognizer:tap];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CALayer *layer = self.custemView.layer;
//    layer.frame = CGRectMake(100, 100, 200, 200);
    layer.width = 200;
    layer.height = 200;
}

@end
