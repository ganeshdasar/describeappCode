//
//  DPostBodyView.h
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DPostBodyViewDelegate;
@class DPostImage;
@interface DPostBodyView : UIView


@property(nonatomic, assign)BOOL    enablePlayVideoTapnOnImage;
@property(nonatomic, strong)DPostImage *postImage;
@property(nonatomic, assign)id<DPostBodyViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame withPostImage:(DPostImage *)imagePost;

-(void)interchangeViews;
-(void)startAniamtion;

-(void)playVideo;
-(void)pauseVideo;
-(void)seekContentToPercentage:(NSNumber *)percentage;
@end


@protocol DPostBodyViewDelegate <NSObject>

@optional
-(void)postBodyViewDidTapOnImage:(DPostBodyView *)bodyView;

@end