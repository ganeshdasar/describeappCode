//
//  DPostBodyView.h
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DPostImage;
@interface DPostBodyView : UIView


@property(nonatomic, strong)DPostImage *postImage;


- (id)initWithFrame:(CGRect)frame withPostImage:(DPostImage *)imagePost;

-(void)interchangeViews;
-(void)startAniamtion;

-(void)playVideo;
-(void)pauseVideo;

@end
