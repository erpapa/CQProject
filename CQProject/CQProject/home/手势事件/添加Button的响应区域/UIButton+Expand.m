//
//  UIButton+Expand.m
//  CQProject
//
//  Created by CharType on 2020/7/21.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "UIButton+Expand.h"

@implementation UIButton (Expand)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGFloat left = MIN(self.expandEdgeInsets.left, self.expandLeft);
    CGFloat top = MIN(self.expandEdgeInsets.top, self.expandTop);
    CGFloat right = MIN(self.expandEdgeInsets.right, self.expandRight);
    CGFloat bottom = MIN(self.expandEdgeInsets.bottom, self.expandBottom);
    if (point.x > left && point.y > top &&
        point.x < (fabs(right) + self.width) &&
        point.y < (fabs(bottom) + self.height)) {
        return YES;
    }
    return NO;
}

- (CGFloat)expandTop {
    return [[self getAssociatedValueForKey:@selector(expandTop)] floatValue];
}

- (void)setExpandTop:(CGFloat)expandTop {
    [self setAssociateValue:@(expandTop) withKey:@selector(expandTop)];
}

- (CGFloat)expandLeft {
    return [[self getAssociatedValueForKey:@selector(expandLeft)] floatValue];
}

- (void)setExpandLeft:(CGFloat)expandLeft {
    [self setAssociateValue:@(expandLeft) withKey:@selector(expandLeft)];
}


- (CGFloat)expandRight {
    return [[self getAssociatedValueForKey:@selector(expandRight)] floatValue];
}

- (void)setExpandRight:(CGFloat)expandRight {
    [self setAssociateValue:@(expandRight) withKey:@selector(expandRight)];
}

- (CGFloat)expandBottom {
    return [[self getAssociatedValueForKey:@selector(expandBottom)] floatValue];
}

- (void)setExpandBottom:(CGFloat)expandBottom {
    [self setAssociateValue:@(expandBottom) withKey:@selector(expandBottom)];
}

- (UIEdgeInsets)expandEdgeInsets {
    NSValue *value = [self getAssociatedValueForKey:@selector(expandEdgeInsets)];
    return value.UIEdgeInsetsValue;
}

- (void)setExpandEdgeInsets:(UIEdgeInsets)expandEdgeInsets {
    NSValue *value = [NSValue valueWithUIEdgeInsets:expandEdgeInsets];
    [self setAssociateValue:value withKey:@selector(expandEdgeInsets)];
}

@end
