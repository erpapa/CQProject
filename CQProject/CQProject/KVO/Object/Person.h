//
//  Person.h
//  CQProject
//
//  Created by CharType on 2020/7/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) Person *p1;
- (NSInteger)getInteger;
@end

NS_ASSUME_NONNULL_END
