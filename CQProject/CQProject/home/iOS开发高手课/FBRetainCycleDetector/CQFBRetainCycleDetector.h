//
//  CQFBRetainCycleDetector.h
//  CQProject
//
//  Created by CharType on 2020/9/1.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CQFBRetainCycleDetector : NSObject
@property (nonatomic, strong) UIViewController *viewController;
@end

NS_ASSUME_NONNULL_END
