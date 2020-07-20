//
//  CQTwoKVOViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQTwoKVOViewController.h"
#import "NSObject+CQKVO.h"

@interface CQTwoKVOViewController ()
@property (nonatomic, assign) int age;

@end

@implementation CQTwoKVOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 第一个参数是添加监听者
    // 第二个是回调者
//    [self addObserver:self forKeyPath:@"p.age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self szy_addObserverBlockForKeyPath:@"p.age" block:^(id  _Nonnull obj, id  _Nonnull oldVal, id  _Nonnull newVal) {
        NSLog(@"kvo监听回调");
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"触发了Kvo");
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
