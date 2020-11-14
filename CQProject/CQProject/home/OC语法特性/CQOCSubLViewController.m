//
//  CQOCSubLViewController.m
//  CQProject
//
//  Created by CharType on 2020/8/11.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQOCSubLViewController.h"
#import <objc/message.h>

struct objc_super;

@interface CQOCSubLViewController ()
@property (nonatomic, strong) void (^MyBlock)(void);
@end

@implementation CQOCSubLViewController
- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self subBlockTest];
}

- (void)subBlockTest {
    __weak typeof(self) weakSelf = self;
    self.MyBlock = ^{
        struct objc_super superInfo = {
                   .receiver = weakSelf,
                   .super_class = class_getSuperclass(NSClassFromString(@"CQOCSubLViewController")),
               };
               ((Class(*)(struct objc_super *, SEL))objc_msgSendSuper)(&superInfo,@selector(class));
    };
}

@end
