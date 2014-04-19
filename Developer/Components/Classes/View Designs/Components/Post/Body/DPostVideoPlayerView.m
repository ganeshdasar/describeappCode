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
#import "DPostBodyView.h"

@interface DPostVideoPlayerView ()
{
    AVPlayer *avPlayer;
    AVPlayerItem *avPlayerItem;
    UITapGestureRecognizer *_singleTapGesture;
    BOOL _isPlaying;
    
    CGPoint _startPoint;
    CGPoint _startPointLocationOnScreen;
    CMTime  _videoDuration;
    
    UIView *_conentView;
    float _initial_x;
    float _diff;
    
    BOOL _isNeedToShowVideoLandingAnimation;
    CGFloat _onePercentage;
    CGFloat _currentDuration;
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
        
        
        _conentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_conentView];
        //[_conentView setBackgroundColor:[[UIColor yellowColor] colorWithAlphaComponent:0.8]];
        
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        [panGesture setMinimumNumberOfTouches:1];
        [self addGestureRecognizer:panGesture];
        
        
    }
    return self;
}






-(void)videoPlayer
{
    _conentView.backgroundColor = [UIColor blackColor];
    [_conentView.layer setMasksToBounds:YES];
    [_conentView.layer setCornerRadius:10];
    [_conentView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_conentView.layer setBorderWidth:1.0];
    
    
    
    NSLog(@"File url:%@",_video.url);
    if(_video.url == nil)
        return;
    
    
    if([_video.url hasPrefix:@"http"]) {
        avPlayerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_video.url]];//[NSURL fileURLWithPath:_video.url]
    }
    else {
        avPlayerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:_video.url]];
    }
    
    avPlayer = [AVPlayer playerWithPlayerItem:avPlayerItem] ;
    AVPlayerLayer *avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer] ;    
    avPlayerLayer.frame = _conentView.bounds;
    [_conentView.layer addSublayer:avPlayerLayer];
    
    [avPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];

    
    avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    _isPlaying = NO;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[avPlayer currentItem]];
    
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == avPlayer && [keyPath isEqualToString:@"status"])
    {
        if (avPlayer.status == AVPlayerStatusReadyToPlay) {
            
            NSLog(@"Ready to play this video");
            
            //[self playVideo];
//            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didStartPlayingVideo)])
//            {
//                [self.delegate performSelector:@selector(didStartPlayingVideo)];
//            }
        } else if (avPlayer.status == AVPlayerStatusFailed) {
            // something went wrong. player.error should contain some information
        }
    }
}

-(void)layoutSubviews
{
    CGRect rect = _conentView.frame;
    [_conentView setFrame:rect];
    
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
    _videoDuration = [avPlayerItem duration];

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
    CGPoint point1 = [self convertPoint:point toView:[self superview]];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            _startPoint = point;
        {
            //[_conentView setBackgroundColor:[UIColor redColor]];
            CGRect frame = self.frame;
            [_conentView setFrame:frame];
            
            [[self superview] addSubview:_conentView];
            [[self superview] bringSubviewToFront:_conentView];
            //[[self superview] setAlpha:0.2];
        }
            
            _startPointLocationOnScreen = [self currentLocationOnScreen:point];
            //Caliculate whole percentage...
            _initial_x = point1.x;
            _diff = _initial_x - self.frame.origin.x;
            _startPointLocationOnScreen.x = _startPointLocationOnScreen.x - _diff;
            
            _currentDuration = [self videoCurrentTime];
            _isNeedToShowVideoLandingAnimation = (_currentDuration>0);
                
            
            _onePercentage = 230/[self videoDuration];
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGRect frame = _conentView.frame;
            frame.origin.x =  point1.x-_diff;
            if(frame.origin.x < 0)
                return;
           
            
            
            CGFloat diff = _startPoint.x - point.x;
            CGFloat secs = diff/_onePercentage;

            
            CGFloat requiredSeconds = _currentDuration - secs;
            requiredSeconds = (requiredSeconds >= 0)?requiredSeconds:0;            
            NSLog(@"Req Sec:%f",requiredSeconds);
            [avPlayer seekToTime:CMTimeMake(requiredSeconds, 1)];
            
            
            //[self videoFileSeekToDurationFromTime:secs];
            [(DPostBodyView *)[self superview] seekSeconds:requiredSeconds];
            if(requiredSeconds <= 0)
                return;
            
            
            
            [_conentView setFrame:frame];
            
            return;
            
            //Caliculate the remaing percentage...
            NSInteger percentage = [self currentPercentage:point];
            Float64 timeValue = [self videoCurrentTime];
            NSLog(@"Current Time:%f currect Percentage:%d index:%d",timeValue,percentage, 1);
            
            //percentage = timeValue*percentage/100;
            //NSLog(@"222percentage its moving:%d",percentage);
            
            [self seekVideoFileToPercentage:percentage];
            [(DPostBodyView *)[self superview] seekContentToPercentage:[NSNumber numberWithInteger:percentage]];
        }
            
            break;
        case UIGestureRecognizerStateEnded:
            _initial_x = 0;
        {
            if(!_isNeedToShowVideoLandingAnimation)
                return;
            
            [UIView animateWithDuration:0.25 animations:^{ [_conentView setFrame:self.frame];} completion:^(BOOL finished)
             {
                 [UIView animateWithDuration:0.25 animations:^{
                     CGRect videoFrame = _conentView.frame;
                     videoFrame.origin.x = videoFrame.origin.x - 10;;
                     [_conentView setFrame:videoFrame];
                     
                 } completion:^(BOOL finished)
                  {
                      [UIView animateWithDuration:0.25 animations:^{
                          [_conentView setFrame:self.frame];
                          
                      } completion:^(BOOL finished)
                       {
                           if(finished)
                           {
                               CGRect videoFrame = _conentView.frame;
                               videoFrame.origin.x = 0;
                               videoFrame.origin.y = 0;
                               [_conentView setFrame:videoFrame];
                               
                               
                               [self addSubview:_conentView];
                           }
                           
                       }];
                      
                      
                  }];
                 
             }];
        }
            break;
        default:
            break;
    }
}


//-(void)seekContentToPercentage:(NSNumber *)percentage
//{
//    NSInteger currentTime = (_currentPlayedTime*[percentage integerValue])/100;
//    NSLog(@"Current Time:%d",currentTime);
//
//    NSInteger index = [self indexForTime:currentTime];
//    NSLog(@"Current Index:%d index:%d", _index, index);
//
//    // NSLog(@"Percentage:%d Duration:%d CurrentTime:%d actual:%d Index:%d dur:%d",[percentage integerValue],_durationOfImages, currentTime, actualTime, index, [_postImage.durationList[index] integerValue]);
//    if(index)
//    {
//        if(_currentVisibleImageIndex != index)
//        {
//            CMPhotoModel *prevPhotoModel = _postImage.images[index-1];
//            CMPhotoModel *nextPhotoModel = _postImage.images[index];
//
//            //Apply whenever the changes occur...
//            [_frontImageView setImage:nextPhotoModel.editedImage];
//            [_backImageView setImage:prevPhotoModel.editedImage];
//
//            //[self presentView:(UIView *)_frontImageView onView:(UIView *)_backImageView];
//        }
//
//    }
//
//    _currentVisibleImageIndex = index;
//}


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
    
    //Will give the exact origin position of the x location...
    currentLocation.x = currentLocation.x-_diff;
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

-(CGFloat)videoDuration
{
    return CMTimeGetSeconds(avPlayerItem.duration);
}


-(void)seekVideoFileToPercentage:(NSInteger)percentage
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(seekContentToPercentage:)])
    {
        [self.delegate performSelector:@selector(seekContentToPercentage:) withObject:[NSNumber numberWithInteger:percentage]];
        
        Float64 currentPlayingseconds = [self videoCurrentTime];//  CMTimeGetSeconds(_videoDuration);
        Float64 videoDuration = CMTimeGetSeconds(_videoDuration);;
        NSInteger percentageSeconds = (videoDuration*(100 - percentage))/100;
        NSInteger seekingSeconds = currentPlayingseconds - percentageSeconds;
        seekingSeconds = (seekingSeconds>=0)?seekingSeconds:0;
        
        [avPlayer seekToTime:CMTimeMake(seekingSeconds, 1)];
    }
}

-(void)videoFileSeekToDurationFromTime:(CGFloat)minusDuration
{
    CGFloat currentDuration = _currentDuration;
    CGFloat requiredSeconds = currentDuration - minusDuration;
    
    requiredSeconds = (requiredSeconds >= 0)?requiredSeconds:0;
    
    ///NSLog(@"Req Sec:%f",requiredSeconds);
    
    [avPlayer seekToTime:CMTimeMake(requiredSeconds, 1)];
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
