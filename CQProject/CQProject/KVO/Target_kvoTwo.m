//
//  Target_ViewController.m
//  CQProject
//
//  Created by CharType on 2020/7/26.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "Target_kvoTwo.h"
#import "CQTwoKVOViewController.h"
@interface Target_kvoTwo ()

@end

@implementation Target_kvoTwo
- (UIViewController *)Action_CTMediatorViewControllerWith:(NSDictionary *)dict {
    CQTwoKVOViewController *vc = [[CQTwoKVOViewController alloc] init];
    vc.p = dict[@"p"];
    return vc;
}

@end
