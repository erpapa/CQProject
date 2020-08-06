//
//  CQTestUIView.m
//  CQProject
//
//  Created by CharType on 2020/8/6.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQTestUIView.h"

@implementation CQTestUIView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL ispoint = [super pointInside:point withEvent:event];
    if (ispoint == NO) {
        for (UIView *view in self.subviews) {
            if(CGRectContainsPoint(view.frame,point)) {
                return YES;
            }
        }
    }
    return ispoint;
}

@end
