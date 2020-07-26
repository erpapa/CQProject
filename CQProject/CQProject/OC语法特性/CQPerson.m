//
//  CQPerson.m
//  CQProject
//
//  Created by CharType on 2020/7/25.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQPerson.h"

@implementation CQPerson
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"name" : @[@"name",@"name1",@"name2",@"name3"]
    };
}
@end
