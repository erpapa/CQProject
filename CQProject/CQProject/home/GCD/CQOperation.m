//
//  CQOperation.m
//  CQProject
//
//  Created by CharType on 2020/7/22.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQOperation.h"

@implementation CQOperation
- (void)main {
    for (int i = 0; i < 10000; i++) {
        if (self.isCancelled) {
            return;
        }
        NSLog(@"%d",i);
    }
}
@end
