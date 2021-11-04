//
//  CQPerson.m
//  CQProject
//
//  Created by CharType on 2020/7/25.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQPerson.h"

@implementation CQPerson

+ (void)initialize {
    if(self  == [CQPerson class]) {
        NSLog(@"是CQPerson对象第一次创建");
    } else {
        NSLog(@"不是CQPerson对象第一次创建");
    }
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"name" : @[@"name",@"name1",@"name2",@"name3"]
    };
}
@end
