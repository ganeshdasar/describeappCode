//
//  DESAnimation.h
//  Describe
//
//  Created by Describe Administrator on 24/04/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DESAnimation : NSObject

+ (void)scaleView:(UIView *)aView
          toScale:(CGFloat)toScale
            alpha:(CGFloat)alphaVal
     withDuration:(NSTimeInterval)time
       completion:(void (^)(BOOL success))completion;

+ (void)fadeInView:(UIView *)aView
             value:(CGFloat)fadeInVal
          duration:(NSTimeInterval)time
        completion:(void (^)(BOOL success))completion;

+ (CABasicAnimation *)fadeFrom:(CGFloat)fromVal
                            to:(CGFloat)toVal
                      duration:(CFTimeInterval)duration
                     beginTime:(CFTimeInterval)beginTime;

+ (CABasicAnimation *)scaleFrom:(CGFloat)fromVal
                             to:(CGFloat)toVal
                       duration:(CFTimeInterval)duration
                      beginTime:(CFTimeInterval)beginTime;

@end
