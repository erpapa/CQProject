//
//  CQBDDTestViewControllerSpec.m
//  CQProject
//
//  Created by CharType on 2020/8/8.
//  Copyright 2020 CharType. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CQBDDTestViewController.h"


SPEC_BEGIN(CQBDDTestViewControllerSpec)

describe(@"CQBDDTestViewController", ^{
    __block CQBDDTestViewController *vc = nil;
    beforeEach(^{
        vc = [[CQBDDTestViewController alloc] init];
    });
    
    afterEach(^{
        vc = nil;
    });
    
    it(@"测试- (int)addnum1:(int)num1 num2:(int)num2", ^{
        int num = [vc addnum1:100 num2:10000];
        [[theValue(num) should] equal:theValue(10100)];
    });

});

SPEC_END
