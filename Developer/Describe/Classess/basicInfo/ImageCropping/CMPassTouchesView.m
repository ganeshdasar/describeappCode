//
//  CMPassTouchesView.m
//  Composition
//
//  Created by Describe Administrator on 20/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "CMPassTouchesView.h"

@implementation CMPassTouchesView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self && !_dontPassTouch) {
        return nil;
    }
    
    return hitView;
}

@end
