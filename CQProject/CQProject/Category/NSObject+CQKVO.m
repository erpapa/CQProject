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

@interface SZYObserVerTarget : NSObject
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, weak) id observer;
@property (nonatomic, weak) id target;
@end

@implementation SZYObserVerTarget
- (void)dealloc {
    NSLog(@"%s",__func__);
}
+ (SZYObserVerTarget *)obserVer:(id)obServer target:(id)target keyPath:(NSString *)keyPath {
    SZYObserVerTarget *szyObserver = [[SZYObserVerTarget alloc] init];
    szyObserver.keyPath = keyPath;
    szyObserver.target = target;
    szyObserver.observer = obServer;
    return szyObserver;
}
@end

@interface NSObject()
@property (nonatomic, strong) NSMutableDictionary<NSString *,NSMutableArray *> *kvoCacheDictionary;
@end


@implementation NSObject (CQKVO)
- (void)addHookDeallocMethodKeyPath:(NSString * _Nonnull)keyPath observer:(SZYObserVerTarget *)observer {
    NSMutableArray<SZYObserVerTarget *> *observerTargets = self.kvoCacheDictionary[keyPath];
    if (!observerTargets) {
        observerTargets = [NSMutableArray array];
    }
    if (observerTargets.count == 0) {
        SEL deallocSelect = NSSelectorFromString(@"dealloc");
        Method oldDeallocMethod = class_getInstanceMethod([self class], deallocSelect);
        void(*oldDeallocImp)(id,SEL) = (typeof(oldDeallocImp))method_getImplementation(oldDeallocMethod);
        void(^newDealloc)(id) = ^(__unsafe_unretained NSObject *dellocObject){
            [dellocObject.kvoCacheDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *keyPath, NSMutableArray *observerTagets, BOOL * _Nonnull stop) {
                [dellocObject removeObserverBlocksForKeyPath:keyPath];
            }];
            oldDeallocImp(dellocObject,deallocSelect);
        };
        IMP newDeallocImp = imp_implementationWithBlock(newDealloc);
        class_replaceMethod([self class], deallocSelect, newDeallocImp, method_getTypeEncoding(oldDeallocMethod));
    }
    [observerTargets addObject:observer];
    self.kvoCacheDictionary[keyPath] = observerTargets;
}

- (void)szy_addObserverBlockForKeyPath:(NSString *)keyPath block:(void (^)(id _Nonnull, id _Nonnull, id _Nonnull))block {
    if (![keyPath isNotBlank] || !block) return;
    if (!self.kvoCacheDictionary) {
        self.kvoCacheDictionary = [NSMutableDictionary  dictionary];
    }
    [self addObserverBlockForKeyPath:keyPath block:block];
    
    SZYObserVerTarget *observer = [SZYObserVerTarget obserVer:self target:self keyPath:keyPath];
    
    [self addHookDeallocMethodKeyPath:keyPath observer:observer];
    return;
}

- (void)szy_addObserverBlockForKeyPath:(NSString *)keyPath target:(id)target block:(void (^)(id _Nonnull, id _Nonnull, id _Nonnull))block {
    if (![keyPath isNotBlank] || !block) return;
    [self addObserverBlockForKeyPath:keyPath block:block];
    if (!self.kvoCacheDictionary) {
        self.kvoCacheDictionary = [NSMutableDictionary  dictionary];
    }
    SZYObserVerTarget *observer = [SZYObserVerTarget obserVer:self target:target keyPath:keyPath];
    [self addHookDeallocMethodKeyPath:keyPath observer:observer];
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

- (NSMutableDictionary *)kvoCacheDictionary {
    return objc_getAssociatedObject(self, @selector(kvoCacheDictionary));
}

- (void)setKvoCacheDictionary:(NSMutableDictionary<NSString *,NSMutableArray *> *)kvoCacheDictionary {
    objc_setAssociatedObject(self, @selector(kvoCacheDictionary), kvoCacheDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

@end
