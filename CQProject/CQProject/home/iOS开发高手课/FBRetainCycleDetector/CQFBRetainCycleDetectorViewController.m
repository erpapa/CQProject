//
//  CQFBRetainCycleDetectorViewController.m
//  CQProject
//
//  Created by CharType on 2020/9/1.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQFBRetainCycleDetectorViewController.h"
//#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import "CQFBRetainCycleDetector.h"

@interface CQFBRetainCycleDetectorViewController ()
@property (nonatomic, copy) void (^myBlock)(void);
@property (nonatomic, copy) NSString *name;
//@property (nonatomic, strong) FBRetainCycleDetector *detector;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CQFBRetainCycleDetector *object;
@end

@implementation CQFBRetainCycleDetectorViewController

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.object = [[CQFBRetainCycleDetector alloc] init];
    self.object.viewController = self;
//    self.detector = [FBRetainCycleDetector new];
//    [self.detector addCandidate:self];
//    self.name = @"chengqian";
//    self.myBlock = ^{
//        NSLog(@"%@",_name);
//    };
    [self blockRetainCycle];
    [self timerRetainCycle];
    [self testRetainCycle];
}

- (void)blockRetainCycle {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%@", self);
    });
}

- (void)timerRetainCycle {
//    _timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"timer %@",self);
//    }];
}

- (void)testRetainCycle {
//    FBRetainCycleDetector *detector = [[FBRetainCycleDetector alloc] init];
//    [detector addCandidate:self];
//    NSSet *retainCycles = [detector findRetainCycles];
//    NSLog(@"%@", retainCycles);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    NSSet *retainCycles = [self.detector findRetainCycles];
//    NSLog(@"%@", retainCycles);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.myBlock) {
        self.myBlock();
    }
}

@end
