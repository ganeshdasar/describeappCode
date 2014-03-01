//
//  DPostVideoPlayerView.h
//  Describe
//
//  Created by LaxmiGopal on 13/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPostVideoPlayerViewDelegate;

@class DPostVideo;
@interface DPostVideoPlayerView : UIView

@property(nonatomic, strong)DPostVideo *video;
@property(nonatomic, strong)id<DPostVideoPlayerViewDelegate> delegate;

-(void)videoPlayer;

-(void)playVideo;
-(void)pauseVideo;
-(void)stopPlayingVideo;
-(BOOL)isPlayingVideo;
-(Float64)videoCurrentTime;
-(void)seekVideoFileToPercentage:(NSInteger)percentage;
-(NSInteger )playedPercentage;
@end



@protocol DPostVideoPlayerViewDelegate <NSObject>

-(void)didStartPlayingVideo;
-(void)didPausePlayingVideo;
-(void)didEndPlayingVideo;

-(void)seekContentToPercentage:(NSNumber *)percentage;

@end
