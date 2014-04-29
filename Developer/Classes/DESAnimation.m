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

+ (void)bounceEffecForFollowButton:(UIButton *)aButton
                      withNewImage:(NSString *)newImgName
                  animationKeyPath:(NSString *)animationKeyPath
{
    // 1. Scale from 1.0 to 1.1 in 0.18s
    // 2. Scale from 1.1 to 0.95  in 0.18s
    // 3. Call selector method to changeImage for the button
    // 4. Scale from 0.95 to 1.05 in 0.18s
    // 5. Scale from 1.05 to 1.0 in 0.18s
    
    CFTimeInterval startTime = 0.0;
    CFTimeInterval duration = 0.12;
    
    CABasicAnimation *scale_1_2 = [DESAnimation scaleFrom:1.0 to:1.2 duration:duration beginTime:startTime];
    
    startTime += duration;
    CABasicAnimation *scale_0_9 = [DESAnimation scaleFrom:1.2 to:0.9 duration:duration beginTime:startTime];
    
    startTime += duration;
    
    [UIView animateWithDuration:0.0
                          delay:startTime
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect btnFrame = aButton.frame;
                         btnFrame.origin.y -= 0.5;
                         aButton.frame = btnFrame;
                     }
                     completion:^(BOOL finished) {
                         CGRect btnFrame = aButton.frame;
                         btnFrame.origin.y += 0.5;
                         aButton.frame = btnFrame;
                         [aButton setBackgroundImage:[UIImage imageNamed:newImgName] forState:UIControlStateNormal];
                     }];
    
    CABasicAnimation *scale_1_1 = [DESAnimation scaleFrom:0.9 to:1.1 duration:duration beginTime:startTime];
    
    startTime += duration;
    CABasicAnimation *scale_1_0 = [DESAnimation scaleFrom:1.1 to:1.0 duration:duration beginTime:startTime];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = startTime + duration;
    animationGroup.delegate = self;
    animationGroup.animations = [NSArray arrayWithObjects:scale_1_2, scale_0_9, scale_1_1, scale_1_0, nil];
    
    if([aButton.layer animationForKey:animationKeyPath]) {
        [aButton.layer removeAnimationForKey:animationKeyPath];
    }
    
    [aButton.layer addAnimation:animationGroup forKey:animationKeyPath];
}

@end
