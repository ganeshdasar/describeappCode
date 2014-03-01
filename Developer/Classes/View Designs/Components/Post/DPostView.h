//
//  DPostView.h
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>




@class DPost;
@interface DPostView : UIView

@property(nonatomic, strong)DPost *post;

- (id)initWithFrame:(CGRect)frame andPost:(DPost *)post;
-(void)designPostView;

-(void)startAnimation;

-(void)playVideo;
-(void)pauseVideo;

@end
