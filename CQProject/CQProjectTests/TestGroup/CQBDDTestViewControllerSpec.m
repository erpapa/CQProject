//
//  CQBDDTestViewControllerSpec.m
//  CQProject
//
//  Created by CharType on 2020/8/8.
//  Copyright 2020 CharType. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CQBDDTestViewController.h"
#import "Person.h"

SPEC_BEGIN(CQBDDTestViewControllerSpec)



describe(@"CQBDDTestViewController", ^{
    let(abc, ^id{
//        NSLog(@"在每个it之前执行一次");
//        NSLog(@"let");
        return [[NSObject alloc] init];
    });
    
    __block CQBDDTestViewController *vc = nil;
    
    beforeAll(^{
        NSLog(@"beforeAll");
        vc = [[CQBDDTestViewController alloc] init];
    });

    afterAll(^{
        NSLog(@"afterAll");
        vc = nil;
    });
    
//
//    beforeEach(^{
//        NSLog(@"beforeEach");
//
//    });
//
//    afterEach(^{
//        NSLog(@"afterEach");
//
//    });
    
    it(@"测试- (int)addnum1:(int)num1 num2:(int)num2", ^{
        NSLog(@"测试- (int)addnum1:(int)num1 num2:(int)num2");
        int num = [vc addnum1:100 num2:10000];
        [[theValue(num) should] equal:theValue(10100)];
    });
    
    it(@"测试最长无重复字串", ^{
        NSLog(@"测试最长无重复字串");
        int length1 = [vc lengthOfLongestSubstring:@"abcabc"];
        // 判断结果是否是指定的值 结果是基本数据类型需要使用theValue 进行装箱
        [[theValue(length1) should] equal:theValue(3)];
        // 判断是否是YES length1 可以转换为bool类型
        [[theValue(length1) should] beTrue];
        // 判断是否是NO length1 可以转换为bool类型
//        [[theValue(length1) should] beNo];
        
        int length2 = [vc lengthOfLongestSubstring:@"pwwkew"];
        [[theValue(length2) should] equal:theValue(3)];
    });
    
    it(@"ObjectIndex", ^{
        id obj = [vc objWithIndex:0];
        // 判断数据是nil
        [[obj should] beNil];
        id obj1 = [vc objWithIndex:1];
        // 判断数据不是nil
        [[obj1 should] beNonNil];
    });
    
    it(@"objWithIndex:objs:", ^{
        NSObject *o1 = [[NSObject alloc] init];
        NSObject *o2 = [[NSObject alloc] init];
        NSObject *o3 = [[Person alloc] init];
        NSObject *o4 = [[NSObject alloc] init];
        NSObject *o5 = [[NSObject alloc] init];
        NSObject *o6 = [[NSObject alloc] init];
        
        NSArray *array = @[o1,o2,o3,o4,o5,o6];
        id object1 = [vc objWithIndex:2 objs:array];
        // 判断是否是指定的object
        [[object1 should] equal:o3];
        // 判断class类型 通过beKindOfClass 来判断
        [[object1 should] beKindOfClass:[NSObject class]];
        
//        [[object1 should] beMemberOfClass:[NSObject class]];
        
        [[object1 should] beMemberOfClass:[Person class]];
        
        [[object1 should] beKindOfClass:[Person class]];
        
        // 测试不通过
//        [[object1 should] equal:o2];
        // 类型不匹配问题
//        [[object1 should] beYes];
//        [[object1 should] beTrue];
        
//        id object2 = [vc objWithIndex:10 objs:array];
//        [[object2 should] equal:o4];
    });
    
    it(@"getPersion", ^{
        Person *p = [vc getPersion];
        // 判断从开始测试，到测试结束是否调用了指定的方法，还可以添加参数  withCount 调用多少次
//        [[p should] receive:@selector(setAge:) withCount:2];
        // 最少调用几次
        //[[p should] receive:@selector(setAge:) withCountAtLeast:2];
        // 最多调几次
//        [[p should] receive:@selector(setAge:) withCountAtMost:3];
        // 测试后续调用这个方法的返回值都返回3 默认只会调用一次
        //[[p should] receive:@selector(getInteger) andReturn:theValue(3)];
        //// 测试后续调用这个方法的返回值都返回3  会调用指定的次数
        //[[p should] receive:@selector(getInteger) andReturn:theValue(3) withCount:2];
        // 测试后续调用这个方法的返回值都返回3  会调用指定的次数,最少调用多少次
        //[[p should] receive:@selector(getInteger) andReturn:theValue(3) withCountAtLeast:2];
        // 测试后续调用这个方法的返回值都返回3  会调用指定的次数，最多调用多少次
        //[[p should] receive:@selector(getInteger) andReturn:theValue(3) withCountAtMost:2];
        // 默认调用一次 第一个参数是否是指定的参数
        //[[p should] receive:@selector(setAge:) withArguments:theValue(200)];
        // 是否调了指定的次数，蚕食是否都是指定的值
        //[[p should] receive:@selector(setAge:) withCount:4 arguments:theValue(200)];
        // 是否最少调了指定次数，参数是否是指定的值 这个case会检测前几次的值是否是指定的值
        //[[p should] receive:@selector(setAge:) withCountAtLeast:2 arguments:theValue(200)];
        // 这个有疑问，测试未通过
        [[p should] receive:@selector(setAge:) withCountAtMost:3 arguments:theValue(200)];
        //方法返回指定的值，参数是否是正确的，只调用一次
        // [[p should] receive:@selector(setAge:) andReturn:(id)aValue withArguments:(id)firstArgument, ...]
        // 方法返回指定的值，参数是否是正确的，只调用指定的次数
//        [[p should] receive:@selector(setAge:) andReturn:(id)aValue withCount:(NSUInteger)aCount arguments:(id)firstArgument, ...]
        // 指定方法 返回值 最少调用次数和参数
//        [[p should] receive:@selector(setAge:) andReturn:(id)aValue withCountAtLeast:(NSUInteger)aCount arguments:(id)firstArgument, ...]
        //指定方法，指定返回值，最多调用次数和参数
//        [[p should] receive:@selector(setAge:) andReturn:(id)aValue withCountAtMost:(NSUInteger)aCount arguments:(id)firstArgument, ...]

//        p.age = 300;
//        p.age = 300;
//        p.age = 400;
//        p.age = 300;
        
        NSInteger sum = [p getInteger];
        NSInteger sum1 = [p getInteger];
        NSInteger sum2 = [p getInteger];
        
//        [[theValue(sum) should] equal:theValue(3)];
        
//        [[subject should] receive:(SEL)aSelector andReturn:(id)aValue withCount:(NSUInteger)aCount]
//        [[subject should] receive:(SEL)aSelector andReturn:(id)aValue withCountAtLeast:(NSUInteger)aCount]
//        [[subject should] receive:(SEL)aSelector andReturn:(id)aValue withCountAtMost:(NSUInteger)aCount]

    });
    
    it(@"模拟对象", ^{
        Person *p = [Person mock];
        [ [p should] receive:@selector(getInteger) andReturn:theValue(3)];
        [ [theValue([p getInteger]) should] equal:theValue(3)];
        Person *nullP = [Person nullMock];
        [ [theValue([nullP getInteger]) should] equal:theValue(0)];
//        [nullP applyBrakes];
        
    });
    specify(^{
        NSLog(@"简单测试");
        [[abc shouldNot] beNil];
    });
    
    pending_(@"等待实现的东西", ^{
        NSLog(@"等待实现的东西");
    });
    
});

SPEC_END
