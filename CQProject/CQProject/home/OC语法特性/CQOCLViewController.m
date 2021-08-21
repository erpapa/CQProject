//
//  CQOCLViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/25.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQOCLViewController.h"
#import "CQPerson.h"
#import "CQStudent.h"
#import "CQOCSubLViewController.h"

@interface CQOCLViewController ()
@property (nonatomic, strong) CQStudent *student;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) void (^myBlock)(void);
@end

@implementation CQOCLViewController

- (void)dealloc {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"延时打印 self %@", self);
//    });
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self myBlockSuperTest];
    __block NSObject *object = [[NSObject alloc] init];
    [self setAssociateValue:@(1) withKey:&object];
    NSNumber *m1 = [self getAssociatedValueForKey:&object];
    NSLog(@"m1 == %@",m1);
    @weakify(self);
    self.myBlock = ^{
        @strongify(self);
        [self setAssociateValue:@(2) withKey:&object];
    };
    NSNumber *m2 = [self getAssociatedValueForKey:&object];
    NSLog(@"m2 == %@",m2);
    self.myBlock();
    NSNumber *m3 = [self getAssociatedValueForKey:&object];
    NSLog(@"m3 == %@",m3);
}

- (void)myBlockSuperTest {
    self.button = [[UIButton alloc] init];
    [self.view addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(100);
        make.top.equalTo(self.view).offset(100);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    self.button.backgroundColor = [UIColor redColor];
    [self.button addTarget:self action:@selector(pushClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)pushClick {
    CQOCSubLViewController *vc = [[CQOCSubLViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)subBlockTest {
    NSLog(@"%s",__func__);
}

- (void)weeakObjectTest {
    self.student = [[CQStudent alloc] init];
    self.student.weakObject = [[CQWeakObject alloc] init];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [controllerWeakObject test];
    });
}

- (void)modelWithJsonTest {
    CQPerson *p = [CQPerson modelWithJSON:@{@"name":@"aaa"}];
    CQPerson *p2 = [CQPerson modelWithJSON:@{@"name1":@"aaa"}];
    CQPerson *p3 = [CQPerson modelWithJSON:@{@"name2":@"aaa"}];
    CQPerson *p4 = [CQPerson modelWithJSON:@{@"name3":@"aaa"}];
    NSLog(@"哈哈哈哈哈");
}


@end
