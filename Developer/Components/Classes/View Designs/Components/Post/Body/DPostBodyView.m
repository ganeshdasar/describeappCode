//
//  DPostBodyView.m
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DPostBodyView.h"
#import "DPostBodyView+ImageTransitionAnimations.h"
#import <QuartzCore/QuartzCore.h>
#import "DPostView.h"
#import "DPostVideoPlayerView.h"
#import "DPost.h"
#import "CMPhotoModel.h"

#define VIDEO_FRAME CGRectMake(230, 10, 80, 80)


@interface DPostBodyView ()<DPostVideoPlayerViewDelegate>
{
    UIImageView *_backgroundView;
    UIView      *_contentView;
    
    UIImageView *_frontImageView;
    UIImageView *_backImageView;
    UIImageView *_currentImageView;
    
    UITapGestureRecognizer *_singleTapGesture;
    UITapGestureRecognizer *_doubleTapGesture;
    
    DPostVideoPlayerView *_videoPlayer;
    
    NSTimer *_transitionImageTimer;
    NSArray *_images;
    int _index;
    BOOL _isNeedToPlayImages;
    NSInteger _durationOfImages;
    NSInteger _currentVisibleImageIndex;
    CGPoint _startPoint;
    CGPoint _startPointLocationOnScreen;
    BOOL _isNeedToRewind;
    NSInteger _currentPlayedTime;
}

@end


@implementation DPostBodyView

@synthesize enablePlayVideoTapnOnImage = _enablePlayVideoTapnOnImage;
@synthesize delegate = _delegate;
@synthesize postImage = _postImage;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        _images = nil;// [[NSArray alloc] initWithObjects:@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg", nil];

        _isNeedToPlayImages = NO;
        [self createBackgroundView];
        [self createContentView];
        [self createBackImageView];
        [self createFrontImageView];
        
        _index = 0;
        
        //Temporarly placing the place holder images will remove later on
//        [_backImageView setImage:[UIImage imageNamed:_images[1]]];
//        [_frontImageView setImage:[UIImage imageNamed:_images[0]]];
        
        [self createVideoPlayer];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withPostImage:(DPostImage *)imagePost
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        _postImage = imagePost;
        _images = _postImage.images;// [[NSArray alloc] initWithObjects:@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg", nil];
        
        _durationOfImages = [self totalImageDuartions];
        
        _isNeedToPlayImages = NO;
        [self createBackgroundView];
        [self createContentView];
        [self createBackImageView];
        [self createFrontImageView];
        
        _index = 0;
        
        //Temporarly placing the place holder images will remove later on
        CMPhotoModel *firstImage = _images[0];
        CMPhotoModel *secondImage = _images[1];
        
        
        [_backImageView setImage:firstImage.editedImage];
        [_frontImageView setImage:secondImage.editedImage];
        
        [self createVideoPlayer];
        [self addSingleTapGesture];
        [self addDoubleTapGesture];
    }
    return self;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)setPostImage:(DPostImage *)postImage
{
    _postImage = postImage;
    
    CMPhotoModel *firstImage = _images[0];
    CMPhotoModel *secondImage = _images[1];
    
    [_backImageView setImage:secondImage.editedImage];
    [_frontImageView setImage:firstImage.editedImage];
    [_videoPlayer setVideo:_postImage.video];
    
}

-(void)addSingleTapGesture
{
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    _singleTapGesture.cancelsTouchesInView = YES;
    [_singleTapGesture setNumberOfTouchesRequired:1];
    [_singleTapGesture setNumberOfTapsRequired:1];
    [self addGestureRecognizer:_singleTapGesture];
}

-(void)addDoubleTapGesture
{
    _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    _doubleTapGesture.cancelsTouchesInView = YES;
    [_doubleTapGesture setNumberOfTouchesRequired:1];
    [_doubleTapGesture setNumberOfTapsRequired:2];
    [self addGestureRecognizer:_doubleTapGesture];
    
    [_singleTapGesture requireGestureRecognizerToFail: _doubleTapGesture];
}

#pragma mark View Creations -

-(void)createBackgroundView
{
    _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    [_backgroundView setBackgroundColor:[UIColor clearColor]];
    [_backgroundView setImage:[UIImage imageNamed:@""]];
    [self addSubview:_backgroundView];
}


-(void)createContentView;
{
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_contentView];
}


-(void)createFrontImageView
{
    _frontImageView = [[UIImageView alloc] initWithFrame:_contentView.bounds];
    [_frontImageView setBackgroundColor:[UIColor clearColor]];
    [_frontImageView setImage:[UIImage imageNamed:@""]];
    [_contentView addSubview:_frontImageView];
}

-(void)createBackImageView
{
    _backImageView = [[UIImageView alloc] initWithFrame:_contentView.bounds];
    [_backImageView setBackgroundColor:[UIColor clearColor]];
    [_backImageView setImage:[UIImage imageNamed:@""]];
    [_contentView addSubview:_backImageView];
}

-(void)createVideoPlayer
{
    _videoPlayer = [[DPostVideoPlayerView alloc] initWithFrame:VIDEO_FRAME];
    [_videoPlayer setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_videoPlayer];
    [_videoPlayer setDelegate:self];
    
    [_videoPlayer.layer setMasksToBounds:YES];
    [_videoPlayer.layer setCornerRadius:8.0];
    [_videoPlayer.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_videoPlayer.layer setBorderWidth:1.0];

    [_videoPlayer setVideo:_postImage.video];
    [_videoPlayer videoPlayer];
    
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [panGesture setMinimumNumberOfTouches:1];
    [self addGestureRecognizer:panGesture];
}


-(void)panGestureRecognizer:(UIPanGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self];
    //NSLog(@"pan gesture:%@", NSStringFromCGPoint(point));
    
    //NSLog(@"Point:%@ %d",NSStringFromCGPoint(point), _isNeedToRewind);

    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            _startPoint = point;
            _startPointLocationOnScreen = point;
            //Caliculate whole percentage...
            if(CGRectContainsPoint(VIDEO_FRAME, point))
            {
                _isNeedToRewind = YES;
                //NSLog(@"Rewind Frame:%@ Point:%@ %d",NSStringFromCGRect(VIDEO_FRAME), NSStringFromCGPoint(point), _isNeedToPlayImages);

            }
            else
            {
                _isNeedToRewind = NO;
            }
            
            _currentPlayedTime = [_videoPlayer videoCurrentTime];
            
            break;
        case UIGestureRecognizerStateChanged:
            if(_isNeedToRewind)
            {
                if([self isMovingToLeftDirection:point])
                {
                    
                    //Caliculate the remaing percentage...
                    int percentage = [self currentPercentage:point];
                    Float64 timeValue = [_videoPlayer videoCurrentTime];
                    NSLog(@"Current Time:%f currect Percentage:%d index:%d",timeValue,percentage, _index);

                    //percentage = timeValue*percentage/100;
                    //NSLog(@"222percentage its moving:%d",percentage);

                    [_videoPlayer seekVideoFileToPercentage:percentage];
                    [self seekContentToPercentage:[NSNumber numberWithInteger:percentage]];
                    
                    
                    //Update video player content...
                    {
                        CGRect videoFrame = _videoPlayer.frame;
                        videoFrame.origin.x = (VIDEO_FRAME.origin.x*percentage)/100;
                        //[_videoPlayer setFrame:videoFrame];
                        [UIView animateWithDuration:0.0 animations:^{ [_videoPlayer setFrame:videoFrame];} completion:^(BOOL finished)
                         {
                         }];
                    }
                }
            }
          
            break;
        case UIGestureRecognizerStateEnded:
            if(_isNeedToRewind)
            {
                [UIView animateWithDuration:0.25 animations:^{ [_videoPlayer setFrame:VIDEO_FRAME];} completion:^(BOOL finished)
                {
                    [UIView animateWithDuration:0.25 animations:^{
                        CGRect videoFrame = _videoPlayer.frame;
                        videoFrame.origin.x = videoFrame.origin.x - 10;;
                        [_videoPlayer setFrame:videoFrame];
                    
                    } completion:^(BOOL finished)
                     {
                         [UIView animateWithDuration:0.25 animations:^{
                             [_videoPlayer setFrame:VIDEO_FRAME];
                             
                         } completion:^(BOOL finished)
                          {
                              if(finished)
                              {
                                
                              }
                              
                          }];

                         
                     }];
                    
                }];
                _isNeedToRewind = NO;
            }
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
-(NSInteger)currentPercentage:(CGPoint)point
{
    CGPoint currentLocation = point;//[self currentLocationOnScreen:point];
    return (currentLocation.x/_startPointLocationOnScreen.x)*100;
}

-(void)playVideo
{
    [_videoPlayer playVideo];
}

-(void)pauseVideo
{
    [_videoPlayer pauseVideo];
}

#pragma mark View Designs -
#pragma mark View Operations -




-(void)interchangeViews
{
    [self bringSubviewToFront:_backImageView];
    [self sendSubviewToBack:_frontImageView];
    
    _currentImageView = _frontImageView;
    _frontImageView = _backImageView;
    _backImageView = _currentImageView;
    
    //_index++;
    if(_index+1 >= _postImage.images.count)
    {
        _index = 0;
    }
    CMPhotoModel *photoModel = _postImage.images[_index];
    [_backImageView setImage:photoModel.editedImage];

}

#pragma mark Model Operations -

-(UIImageView *)frontImageView
{
    return _frontImageView;
}

-(UIImageView *)backImageView
{
    return _backImageView;
}


#pragma mark Viedeo Delegate Methods -

//Temporarly keeping for having animations...
-(void)startAniamtion
{
    [self performSelector:@selector(transitionNewImage) withObject:nil afterDelay:1.0];
}

-(void)transitionNewImage
{
    [self presentView:(UIView *)_frontImageView onView:(UIView *)_backImageView];
    
    if(_isNeedToPlayImages)
    {
        if(_index+1 >= _postImage.images.count)
        {
            _index = 0;
        }
        CMPhotoModel *photoModel = [_postImage images][_index];
        float duration = photoModel.duration;// [_postImage.durationList[_index] floatValue];
        
        if(_transitionImageTimer != nil)
        {
            [_transitionImageTimer invalidate];
            _transitionImageTimer = nil;
        }
        
        _transitionImageTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(transitionNewImage) userInfo:Nil repeats:NO];
        
        _index++;
    }
}



#pragma mark PostDelegate Methods -

-(void)didStartPlayingVideo
{
    //Start image animations....
    if(!_isNeedToPlayImages)
    {
        _isNeedToPlayImages = YES;
        [self performSelector:@selector(transitionNewImage) withObject:nil afterDelay:0.0];
    }
    
//   if(!_enablePlayVideoTapnOnImage)
//   {
//       if(_delegate != nil && [_delegate respondsToSelector:@selector(postBodyViewDidTapOnImage:)])
//       {
//           [_delegate postBodyViewDidTapOnImage:self];
//       }
//   }
}

-(void)didPausePlayingVideo
{
    //pause image animations....    
    _isNeedToPlayImages = NO;
    if(_transitionImageTimer != nil)
    {
        [_transitionImageTimer invalidate];
        _transitionImageTimer = nil;
    }
    
//    if(!_enablePlayVideoTapnOnImage)
//    {
//        if(_delegate != nil && [_delegate respondsToSelector:@selector(postBodyViewDidTapOnImage:)])
//        {
//            [_delegate postBodyViewDidTapOnImage:self];
//        }
//    }
}

-(void)didEndPlayingVideo
{
    //pause image animations....
    _isNeedToPlayImages = NO;
}


-(void)singleTap:(id)sender
{
    if(_enablePlayVideoTapnOnImage)
    {
        if([_videoPlayer isPlayingVideo])
        {
            [_videoPlayer pauseVideo];
        }
        else
        {
            [_videoPlayer playVideo];
        }
    }
    else
    {
        if(_delegate != nil && [_delegate respondsToSelector:@selector(postBodyViewDidTapOnImage:)])
        {
            [_delegate postBodyViewDidTapOnImage:self];
        }
    }
}


-(void)doubleTap:(id)sender
{
    [_videoPlayer stopPlayingVideo];
    [_videoPlayer playVideo];
}

-(void)seekToTimeWithPercentage:(NSNumber *)percentage
{
    
}

-(void)seekContentToPercentage:(NSNumber *)percentage
{
    
    
    NSInteger currentTime = (_currentPlayedTime*[percentage integerValue])/100;
    //NSInteger actualTime = _durationOfImages - currentTime;
    
    NSLog(@"Current Time:%d",currentTime);
    
    
    
    
    
    //return;
    
    NSInteger index = [self indexForTime:currentTime];
    
    
    
    
    NSLog(@"Current Index:%d index:%d", _index, index);
    
    // NSLog(@"Percentage:%d Duration:%d CurrentTime:%d actual:%d Index:%d dur:%d",[percentage integerValue],_durationOfImages, currentTime, actualTime, index, [_postImage.durationList[index] integerValue]);
    if(index)
    {
        if(_currentVisibleImageIndex != index)
        {
            CMPhotoModel *prevPhotoModel = _postImage.images[index-1];
            CMPhotoModel *nextPhotoModel = _postImage.images[index];
            
            //Apply whenever the changes occur...
            [_frontImageView setImage:nextPhotoModel.editedImage];
            [_backImageView setImage:prevPhotoModel.editedImage];
            
            //[self presentView:(UIView *)_frontImageView onView:(UIView *)_backImageView];
        }
        
    }
    
    _currentVisibleImageIndex = index;
   
    

}

-(NSInteger)totalImageDuartions
{
    NSInteger duration = 0;
    
    NSInteger count = [[_postImage images]  count];
    for (int i=0; i<count; i++)
    {
        CMPhotoModel *photoModel = [_postImage images][i];
        duration = duration + photoModel.duration;//[[_postImage durationList][i] integerValue];
    }
    
    
    return duration;
}
-(NSInteger)indexForTime:(NSInteger )currentTime
{
    NSInteger currentIndex = [[_postImage images]  count] - 1;
    NSInteger value = currentTime;
    NSInteger count = [[_postImage images]  count];
    for (int i=0; i<count; i++)
    {
        
        CMPhotoModel *photoModel = [_postImage images][i];
        NSInteger duration = photoModel.duration;//[[_postImage images][i] integerValue];
        
        NSLog(@"Current Time:%d, duration:%d value:%d",currentTime, duration, value);
        value = value - duration;
        
        if(value <=0)
        {
            currentIndex = i;
            break;
        }
    }
    
    
    // NSLog(@"Returing Index:%d",currentIndex); 9866465018
    return currentIndex;
}

-(NSInteger)currentImageIndex:(NSInteger )currentTime
{
    NSInteger currentIndex = [[_postImage images]  count] - 1;
    NSInteger value = currentTime;
    NSInteger count = [[_postImage images]  count];
    for (int i=0; i<count; i++)
    {
        currentIndex = count - (i+1);
        
        CMPhotoModel *photoModel = [_postImage images][i];
        NSInteger duration = photoModel.duration;//[[_postImage images][currentIndex] integerValue];
        value = duration - value   ;
        NSLog(@"index:%d value:%d",currentIndex,value);
        if(value > 0)
        {
            //keep as it is...
            break;
        }
        else
        {
            value = 0-value;
        }
    }
    
    
    // NSLog(@"Returing Index:%d",currentIndex); 9866465018
    return currentIndex;
}




-(NSInteger)currentImageIndex1:(NSInteger )currentTime
{
    NSInteger currentIndex = [[_postImage images]  count] - 1;
    NSInteger value = currentTime;
    NSInteger count = [[_postImage images]  count];
    for (int i=0; i<count; i++)
    {
        currentIndex = count - (i+1);
        CMPhotoModel *photoModel = [_postImage images][currentIndex];
        NSInteger duration = photoModel.duration;// [[_postImage durationList][currentIndex] integerValue];
         value = duration - value   ;
        //NSLog(@"index:%d value:%d",currentIndex,value);
        if(value > 0)
        {
            //keep as it is...
            break;
        }
        else
        {
            value = 0-value;
        }
    }
    
    
   // NSLog(@"Returing Index:%d",currentIndex);
    return currentIndex;
}

-(void)dealloc
{
    
    _backgroundView = nil;
    _contentView = nil;
    
    _frontImageView = nil;
    _backImageView = nil;
    _currentImageView = nil;
    
    _singleTapGesture = nil;
    _doubleTapGesture = nil;
    
    _videoPlayer = nil;
    
}

@end
