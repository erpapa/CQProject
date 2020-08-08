//
//  CQBDDTestSpec.m
//  CQProjectTests
//
//  Created by CharType on 2020/8/8.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CQBDDTestViewController.h"

SPEC_BEGIN(CQBDDTestSpec)
describe(@"CQBDDTestViewController", ^{
    context(@"创建对象", ^{
        __block CQBDDTestViewController *vc = nil;
        beforeEach(^{
            vc = [[CQBDDTestViewController alloc] init];
        });
        
        afterEach(^{
            vc = nil;
        });
        
        it(@"测试两数相加方法", ^{
            int num =  [vc addnum1:1 num2:2];
            [[theValue(num) should] equal:theValue(3)];
        });
        
    });
});
SPEC_END
