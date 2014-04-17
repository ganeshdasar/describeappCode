//
//  DPostBodyView+ImageTransitionAnimations.m
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DPostBodyView+ImageTransitionAnimations.h"
#define VIEW_TRANSITION_DURATION 0.5

@implementation DPostBodyView (ImageTransitionAnimations)


-(void)presentView:(UIView *)frontView onView:(UIView *)secondView
{
    [secondView setAlpha:0.0];
    [UIView animateWithDuration:VIEW_TRANSITION_DURATION animations:^
    {
        //Start animation here....
        frontView.alpha = 0.0;
        secondView.alpha = 1.0;
        
    } completion:^(BOOL finished)
     {
         if(finished)
         { 
             [self interchangeViews];
         }
     }];
}


-(void)reversePresentView:(UIView *)frontView onView:(UIView *)secondView
{
    [secondView setAlpha:0.0];
    [UIView animateWithDuration:VIEW_TRANSITION_DURATION animations:^
     {
         //Start animation here....
         frontView.alpha = 0.0;
         secondView.alpha = 1.0;
         
     } completion:^(BOOL finished)
     {
         if(finished)
         {
             [self reverseInterchangeViews];
         }
     }];
}


@end
