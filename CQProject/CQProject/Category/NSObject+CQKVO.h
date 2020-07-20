//
//  NSObject+CQKVO.h
//  CQProject
//
//  Created by CharType on 2020/7/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CQKVO)
- (void)szy_addObserverBlockForKeyPath:(NSString *)keyPath
                                 block:(void (^)(id obj,id oldVal,id newVal))block;

- (void)szy_addObserverBlockForKeyPath:(NSString *)keyPath
                                target:(id)target
                                 block:(void (^)(id obj,id oldVal,id newVal))block;
// 取消所有KeyPath的监听
- (void)szy_removeObserverBlocksForKeyPath:(NSString *)keyPath;
// 取消监听，移除单个观察者
- (void)szy_removeObserverBlocksForKeyPath:(NSString *)keyPath target:(id)target;
// 取消当前对象的所有监听
- (void)szy_removeObserverBlocks;

@end

NS_ASSUME_NONNULL_END
