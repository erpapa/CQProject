//
//  Person.m
//  CQProject
//
//  Created by CharType on 2020/7/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "Person.h"

@implementation Person
- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"触发了Kvo");
}

- (void)setAge:(NSInteger)age {
    _age = age;
}

- (NSInteger)getInteger {
    return 2;
}
@end
