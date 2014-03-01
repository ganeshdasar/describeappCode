//
//  DPostView.h
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPostViewDelegate;

@class DPost;
@interface DPostView : UIView

@property(nonatomic, strong)DPost *post;
@property(nonatomic, assign)id<DPostViewDelegate> delegate;



- (id)initWithFrame:(CGRect)frame andPost:(DPost *)post;
-(void)designPostView;

-(void)startAnimation;

-(void)playVideo;
-(void)pauseVideo;

@end


@protocol DPostViewDelegate <NSObject>

-(void)profileDidSelected;

@end
