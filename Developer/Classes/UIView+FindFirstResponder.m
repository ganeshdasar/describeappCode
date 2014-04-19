//
//  UIView+FindFirstResponder.m
//  SpotOWord
//
//  Created by [x]cube LABS on 9/11/13.
//  Copyright (c) 2013 KPT. All rights reserved.
//
//  Class Description:
//  This class over-rides the super UIView Class. In this we are adding a method to identify the first responder
//  from the subViews on the view. It can be itself also as firstResponder.

#import "UIView+FindFirstResponder.h"
#import <UIKit/UIKit.h>

@implementation UIView (FindFirstResponder)

- (UIView *)findFirstResponder
{
    if (self.isFirstResponder) {        
        return self;     
    }
	
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findFirstResponder];
		
        if (firstResponder != nil) {
			return firstResponder;
        }
    }
	
    return nil;
}

-(void)registerToResignKeyboard
{
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesture:)];
    [self addGestureRecognizer:singleTapGesture];
}

-(void)singleTapGesture:(UITapGestureRecognizer *)gesture
{
    UIView *view = [self findFirstResponder];
    if(view != nil)
    {
        [view resignFirstResponder];
    }
}

@end
