//
//  DPostVideoPlayerView.m
//  Describe
//
//  Created by LaxmiGopal on 13/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DPostVideoPlayerView.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "DPost.h"

@interface DPostVideoPlayerView ()
{
    AVPlayer *avPlayer;
    AVPlayerItem *avPlayerItem;
    UITapGestureRecognizer *_singleTapGesture;
    BOOL _isPlaying;
    
    CGPoint _startPoint;
    CGPoint _startPointLocationOnScreen;
    CMTime  _videoDuration;
}
@end

@implementation DPostVideoPlayerView

@synthesize delegate = _delegate;
@synthesize video = _video;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //Single Tap gesture....
        _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        _singleTapGesture.cancelsTouchesInView = YES;
        [_singleTapGesture setNumberOfTouchesRequired:1];
        [_singleTapGesture setNumberOfTapsRequired:1];
        [self addGestureRecognizer:_singleTapGesture];
        
        
        //Swipe gesture recognizer...
        //        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]
        //                                             initWithTarget:self action:@selector(handleSwipeFrom:)];
        //        [swipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
        //        [self addGestureRecognizer:swipeGesture];
        
        //        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        //        [panGesture setMinimumNumberOfTouches:1];
        //        [self addGestureRecognizer:panGesture];
        
        
    }
    return self;
}






-(void)videoPlayer
{
    self.backgroundColor = [UIColor blackColor];
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:10];
    [self.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.layer setBorderWidth:2.0];
    
    //NSLog(@"File url:%@",_video.url);
    if(_video.url == nil)
        return;
    
    avPlayerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_video.url]];//[NSURL fileURLWithPath:_video.url]
    avPlayer = [AVPlayer playerWithPlayerItem:avPlayerItem] ;
    AVPlayerLayer *avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer] ;
    
    avPlayerLayer.frame = self.bounds;
    [self.layer addSublayer:avPlayerLayer];
    
    
    
    avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    _isPlaying = NO;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[avPlayer currentItem]];
    
}


-(void)playerItemDidReachEnd:(id)notification
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didEndPlayingVideo)])
    {
        [self.delegate performSelector:@selector(didEndPlayingVideo)];
    }
    
    [self stopPlayingVideo];
}

-(void)stopPlayingVideo
{
    [avPlayer seekToTime:CMTimeMake(0, 1)];
    [avPlayer pause];
    _isPlaying = NO;
}


-(BOOL)isPlayingVideo
{
    return _isPlaying;
}


-(void)playVideo
{
    [avPlayer play];
    _isPlaying = YES;
    //NSLog(@"Playing");
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didStartPlayingVideo)])
    {
        [self.delegate performSelector:@selector(didStartPlayingVideo)];
    }
}

-(void)pauseVideo
{
    [avPlayer pause];
    _isPlaying = NO;
    //NSLog(@"Pausing");
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didPausePlayingVideo)])
    {
        [self.delegate performSelector:@selector(didPausePlayingVideo)];
    }
}

-(void)singleTap:(id)sender
{
    if(_isPlaying)
    {
        [avPlayer pause];
        _isPlaying = NO;
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didPausePlayingVideo)])
        {
            [self.delegate performSelector:@selector(didPausePlayingVideo)];
        }
    }
    else
    {
        [avPlayer play];
        _isPlaying = YES;
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didStartPlayingVideo)])
        {
            _videoDuration = [avPlayerItem duration];
            //Float64 durationInSeconds = CMTimeGetSeconds(_videoDuration);
            
            
            [self.delegate performSelector:@selector(didStartPlayingVideo)];
        }
    }
}




- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
    }
}

-(void)panGestureRecognizer:(UIPanGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self];
    //NSLog(@"pan gesture:%@", NSStringFromCGPoint(point));
    
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            _startPoint = point;
            _startPointLocationOnScreen = [self currentLocationOnScreen:point];
            //Caliculate whole percentage...
            
            break;
        case UIGestureRecognizerStateChanged:
            if([self isMovingToLeftDirection:point])
            {
                //Caliculate the remaing percentage...
                int percentage = [self currentPercentage:point];
                //NSLog(@"percentage its moving:%d",percentage);
                [self seekVideoFileToPercentage:percentage];
            }
            break;
        case UIGestureRecognizerStateEnded:
            
            break;
        default:
            break;
    }
}


-(BOOL)isMovingToLeftDirection:(CGPoint )point
{
    if(point.x < _startPoint.x)
    {
        return YES;
    }
    
    return NO;
}

-(CGPoint)currentLocationOnScreen:(CGPoint)point
{
    CGPoint viewOrigin = self.frame.origin;
    
    return CGPointMake(viewOrigin.x + point.x, point.y);
}

-(NSInteger)currentPercentage:(CGPoint)point
{
    CGPoint currentLocation = [self currentLocationOnScreen:point];
    return (currentLocation.x/_startPointLocationOnScreen.x)*100;
}

-(Float64)videoCurrentTime
{
    Float64 seconds = CMTimeGetSeconds(avPlayerItem.currentTime);
    return seconds;
}

-(NSInteger )playedPercentage
{
    
    Float64 currentTime = [self videoCurrentTime];
    Float64 totalDuration = CMTimeGetSeconds(avPlayerItem.duration);
    
    return currentTime/totalDuration * 100;
}

-(void)seekVideoFileToPercentage:(NSInteger)percentage
{
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(seekContentToPercentage:)])
    {
        [self.delegate performSelector:@selector(seekContentToPercentage:) withObject:[NSNumber numberWithInteger:percentage]];
        
        Float64 seconds = [self videoCurrentTime];//  CMTimeGetSeconds(_videoDuration);
        NSInteger currentSeekingSeconds = (seconds*percentage)/100;
        [avPlayer seekToTime:CMTimeMake(currentSeekingSeconds, 1)];
        
    }
    
    
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:AVPlayerItemDidPlayToEndTimeNotification];

    [self stopPlayingVideo];
    avPlayer = nil;
    avPlayerItem = nil;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
