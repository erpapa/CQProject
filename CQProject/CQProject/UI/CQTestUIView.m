//
//  CQTestUIView.m
//  CQProject
//
//  Created by CharType on 2020/8/6.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "CQTestUIView.h"

@implementation CQTestUIView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL ispoint = [self pointInside:point withEvent:event];
    BOOL isalpha = self.alpha > 0.01;
    BOOL isResponse = ispoint && isalpha && !self.hidden && self.userInteractionEnabled;
    UIView *responseView = nil;
    if (isResponse) {
        responseView = self;
        for (NSInteger i= self.subviews.count - 1; i>=0; i--) {
            UIView  *tempView = self.subviews[i];
            UIView *newResponseView = [tempView hitTest:point withEvent:event];
            if (newResponseView) {
                responseView = newResponseView;
                break;
            }
        }
    }
    
    return responseView;
}

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
