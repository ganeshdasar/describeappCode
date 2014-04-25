//
//  DESAnimation.m
//  Describe
//
//  Created by Describe Administrator on 24/04/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DESAnimation.h"

@implementation DESAnimation

+ (void)scaleView:(UIView *)aView
          toScale:(CGFloat)toScale
            alpha:(CGFloat)alphaVal
     withDuration:(NSTimeInterval)time
       completion:(void (^)(BOOL success))completion
{
    [UIView animateWithDuration:time
                     animations:^{
                         aView.alpha = alphaVal;
                         aView.transform = CGAffineTransformMakeScale(toScale, toScale);
                     }
                     completion:^(BOOL finished) {
                         if(completion != nil)
                             completion(finished);
                     }];
}

+ (void)fadeInView:(UIView *)aView
             value:(CGFloat)fadeInVal
          duration:(NSTimeInterval)time
        completion:(void (^)(BOOL success))completion
{
    [UIView animateWithDuration:time
                     animations:^{
                         aView.alpha = fadeInVal;
                     }
                     completion:^(BOOL finished) {
                         if(completion != nil)
                             completion(finished);
                     }];
}

+ (CABasicAnimation *)fadeFrom:(CGFloat)fromVal
                            to:(CGFloat)toVal
                      duration:(CFTimeInterval)duration
                     beginTime:(CFTimeInterval)beginTime
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:fromVal];
    animation.toValue = [NSNumber numberWithFloat:toVal];
    animation.duration = duration;
    animation.beginTime = beginTime;
    
    return animation;
}

+ (CABasicAnimation *)scaleFrom:(CGFloat)fromVal
                             to:(CGFloat)toVal
                       duration:(CFTimeInterval)duration
                      beginTime:(CFTimeInterval)beginTime
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = [NSNumber numberWithFloat:fromVal];
    animation.toValue = [NSNumber numberWithFloat:toVal];
    animation.duration = duration;
    animation.beginTime = beginTime;
    
    return animation;
}

@end
