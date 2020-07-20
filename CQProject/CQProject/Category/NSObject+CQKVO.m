//
//  NSObject+CQKVO.m
//  CQProject
//
//  Created by CharType on 2020/7/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "NSObject+CQKVO.h"
#import "YYKit.h"
#import <objc/runtime.h>

@interface NSObject()
@property (nonatomic, strong) NSMutableArray<NSString *> *kvoCacheDictionary;
@end


@implementation NSObject (CQKVO)
- (void)addHookDeallocMethodKeyPath:(NSString * _Nonnull)keyPath {
    if (!self.kvoCacheDictionary) {
        self.kvoCacheDictionary = [NSMutableArray array];
    }
    @synchronized (self) {
        if (self.kvoCacheDictionary.count == 0) {
            SEL deallocSelect = NSSelectorFromString(@"dealloc");
            Method oldDeallocMethod = class_getInstanceMethod([self class], deallocSelect);
            void(*oldDeallocImp)(id,SEL) = (typeof(oldDeallocImp))method_getImplementation(oldDeallocMethod);
            void(^newDealloc)(id) = ^(__unsafe_unretained NSObject *dellocObject){
                [dellocObject.kvoCacheDictionary enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [dellocObject removeObserverBlocks];
                }];
                oldDeallocImp(dellocObject,deallocSelect);
            };
            IMP newDeallocImp = imp_implementationWithBlock(newDealloc);
            class_replaceMethod([self class], deallocSelect, newDeallocImp, method_getTypeEncoding(oldDeallocMethod));
        }
        [self.kvoCacheDictionary addObject:keyPath];
    }
}

- (void)szy_addObserverBlockForKeyPath:(NSString *)keyPath block:(void (^)(id _Nonnull, id _Nonnull, id _Nonnull))block {
    if (![keyPath isNotBlank] || !block) return;
    [self addObserverBlockForKeyPath:keyPath block:block];
    [self addHookDeallocMethodKeyPath:keyPath];
    return;
}

- (void)szy_addObserverBlockForKeyPath:(NSString *)keyPath target:(id)target block:(void (^)(id _Nonnull, id _Nonnull, id _Nonnull))block {
    if (![keyPath isNotBlank] || !block) return;
    [self addObserverBlockForKeyPath:keyPath block:block];
    [self addHookDeallocMethodKeyPath:keyPath];
}

- (void)szy_removeObserverBlocksForKeyPath:(NSString *)keyPath {
    [self removeObserverBlocksForKeyPath:keyPath];
}

- (void)szy_removeObserverBlocksForKeyPath:(NSString *)keyPath target:(id)target {
    [self removeObserverBlocksForKeyPath:keyPath];
}

- (void)szy_removeObserverBlocks {
    [self removeObserverBlocks];
}

- (NSMutableArray *)kvoCacheDictionary {
    return objc_getAssociatedObject(self, @selector(kvoCacheDictionary));
}

- (void)setKvoCacheDictionary:(NSMutableArray<NSString *> *)kvoCacheDictionary {
    objc_setAssociatedObject(self, @selector(kvoCacheDictionary), kvoCacheDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

@end
