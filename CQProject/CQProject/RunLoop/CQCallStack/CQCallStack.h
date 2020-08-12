//
//  CQCallStack.h
//  CQProject
//
//  Created by CharType on 2020/8/10.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CQCallStackType) {
    CQCallStackTypeAll, // 全部线程
    CQCallStackTypeMain, // 主线程
    CQCallStackTypeCurrent // 当前线程
};

@interface CQCallStack : NSObject
+ (NSString *)callStackWithType:(CQCallStackType)type;
@end


