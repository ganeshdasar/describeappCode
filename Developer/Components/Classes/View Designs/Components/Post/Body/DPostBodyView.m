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
//#import "UIImageView+AFNetworking.h"
#import <SDWebImage/SDWebImagePrefetcher.h>
#import <SDWebImage/UIImageView+WebCache.h>

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
    NSInteger _count;
    
    
    SDWebImagePrefetcher *_prefetcher;
    CGFloat _onePercentage;
    
    
    
    
    NSUInteger  _runningSeconds;
    NSUInteger  _totalTime;
    NSTimer     *_scheduleTimer;
    BOOL        _isPlaying;
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
        
        _runningSeconds = 0;
        [self createVideoPlayer];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withPostImage:(DPostImage *)imagePost
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        //return self;
        
        self.backgroundColor = [UIColor clearColor];
        
        _postImage = imagePost;
        _images = _postImage.images;// [[NSArray alloc] initWithObjects:@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg", nil];
        
        _durationOfImages = [self totalImageDuartions];
        
        _isNeedToPlayImages = NO;
        [self createBackgroundView];
        [self createContentView];
        [self createBackImageView];
        [self createFrontImageView];
        
        _runningSeconds = 0;
        _index = 0;
        
        //Temporarly placing the place holder images will remove later on
        _count = _images.count;
        
        CMPhotoModel *firstImage = nil;
        CMPhotoModel *secondImage = nil;
        if(_count)
            firstImage = _images[0];
        if(_count > 1)
            secondImage = _images[1];
        
        
        NSLog(@"front image:%@\n back:%@",firstImage.imageUrl, secondImage.imageUrl);
        
        [_frontImageView setImageWithURL:[NSURL URLWithString:firstImage.imageUrl]];
        [_backgroundView setImageWithURL:[NSURL URLWithString:secondImage.imageUrl]];
     
        
        //[_frontImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"22_%d.png",1]]];
        //[_backgroundView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"22_%d.png",2]]];
        
        
        
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
    
    _runningSeconds = 0;
    _postImage = postImage;
    _images = _postImage.images;
    
    CMPhotoModel *firstImage = nil;
    CMPhotoModel *secondImage = nil;
    if(_count)
        firstImage = _images[0];
    if(_count > 1)
        secondImage = _images[1];
    
    [_backImageView setImage:secondImage.editedImage];
    [_frontImageView setImage:firstImage.editedImage];
    
    if(secondImage != nil && secondImage.imageUrl != nil) {
        [_backgroundView setImageWithURL:[NSURL URLWithString:secondImage.imageUrl]];
    }
    if(firstImage != nil && firstImage.imageUrl != nil) {
        [_frontImageView setImageWithURL:[NSURL URLWithString:firstImage.imageUrl]];
    }
    [_contentView bringSubviewToFront:_frontImageView];
    [_videoPlayer setVideo:_postImage.video];
    
    
    _totalTime = [self totalImageDuartions];
    _scheduleTimer = [NSTimer scheduledTimerWithTimeInterval:0.95 target:self selector:@selector(scheduleTimer:) userInfo:nil repeats:YES];
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
    [_frontImageView setContentMode:UIViewContentModeScaleToFill];
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
    
    
    //    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    //    [panGesture setMinimumNumberOfTouches:1];
    //    [self addGestureRecognizer:panGesture];
}


-(void)panGestureRecognizer:(UIPanGestureRecognizer *)gesture point:(CGPoint)point andView:(UIView *)view
{
    //CGPoint point = [gesture locationInView:self];
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
            _onePercentage = 230/[_videoPlayer videoDuration];
            
            break;
        case UIGestureRecognizerStateChanged:
            if(_isNeedToRewind)
            {
                if([self isMovingToLeftDirection:point])
                {
                    
                    CGFloat diff = _startPoint.x - point.x;
                    CGFloat secs = diff/_onePercentage;
                    [_videoPlayer videoFileSeekToDurationFromTime:secs];
                    
                    
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
    [_contentView bringSubviewToFront:_backImageView];
    //[_contentView sendSubviewToBack:_frontImageView];
    

    if(_index >= _postImage.images.count)
    {
        //_index = 0;
        return;
    }
    
    CMPhotoModel *photoModel = _postImage.images[_index];
    [_frontImageView setImageWithURL:[NSURL URLWithString:photoModel.imageUrl]];
    //[_frontImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"22_%d.png",_index+1]]];
    
    _currentImageView = _frontImageView;
    _frontImageView = _backImageView;
    _backImageView = _currentImageView;
    
    
    float duration = photoModel.duration;
    if(_transitionImageTimer != nil)
    {
        [_transitionImageTimer invalidate];
        _transitionImageTimer = nil;
    }
    
    NSLog(@"-------------------Index:%d duration:%f",_index,duration);
    _transitionImageTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(transitionNewImage) userInfo:Nil repeats:NO];
    _index++;
    
}

-(void)reverseInterchangeViews
{
    [_contentView bringSubviewToFront:_backImageView];
    
    if(_index-1 < 0)
    {
        //_index = 0;
        return;
    }
    
    CMPhotoModel *photoModel = _postImage.images[_index-1];
    [_frontImageView setImageWithURL:[NSURL URLWithString:photoModel.imageUrl]];
    NSLog(@"Current Index:%d Photomodel:%d ", _index, _index-1);
    
    _currentImageView = _frontImageView;
    _frontImageView = _backImageView;
    _backImageView = _currentImageView;
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
    _index ++;
    [self transitionNewImage];
}

-(void)transitionNewImage
{    
    if(_isNeedToPlayImages)
    {
        if(_index != 0)
            [self presentView:(UIView *)_frontImageView onView:(UIView *)_backImageView];
        else
        {
            if(_postImage.images.count)
            {
                CMPhotoModel *photoModel = _postImage.images[_index];
                _transitionImageTimer = [NSTimer scheduledTimerWithTimeInterval:photoModel.duration target:self selector:@selector(startAniamtion) userInfo:Nil repeats:NO];
            }
        }
        NSLog(@"Transition--- index:%d",_index);
    }
}



#pragma mark PostDelegate Methods -

-(void)didStartPlayingVideo
{
    if(_runningSeconds == 0)
    {
        [_scheduleTimer fire];
    }
    
    
    return;
    //Start image animations....
    if(!_isNeedToPlayImages)
    {
        _isNeedToPlayImages = YES;
        [_contentView bringSubviewToFront:_frontImageView];
        [_backgroundView setImage:nil];
        

        NSLog(@"################Index:%d", _index);
        [self transitionNewImage];
        //[self performSelector:@selector(transitionNewImage) withObject:nil afterDelay:0.0];
    }
    
    _prefetcher = [SDWebImagePrefetcher sharedImagePrefetcher];
    
    NSMutableArray *imageUrls = [[NSMutableArray alloc] init];
    for (int i=0; i<_postImage.images.count; i++)
    {
        CMPhotoModel *model = _postImage.images[i];
        if(model!=nil && model.imageUrl != nil)
            [imageUrls addObject:model.imageUrl];
    }
    if(_index== 0 && _postImage.images.count)
    {
        CMPhotoModel *model = _postImage.images[0];
        [_frontImageView setImageWithURL:[NSURL URLWithString:[model imageUrl]]];
       // [_frontImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"22_%d.png",1]]];
       // [_backgroundView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"22_%d.png",2]]];
    }
    NSLog(@"image urls:%@",imageUrls);
    [_prefetcher prefetchURLs:imageUrls];
    
    //   if(!_enablePlayVideoTapnOnImage)
    //   {
    //       if(_delegate != nil && [_delegate respondsToSelector:@selector(postBodyViewDidTapOnImage:)])
    //       {
    //           [_delegate postBodyViewDidTapOnImage:self];
    //       }
    //   }
}

-(void)playingConitnue
{
    
}

-(void)didPausePlayingVideo
{
    //pause image animations....
    _isNeedToPlayImages = NO;
    _currentPlayedTime = [_videoPlayer videoCurrentTime];
    
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
    _index = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        [_frontImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"22_%d.png",1]]];
        [_backgroundView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"22_%d.png",2]]];
        
        _frontImageView.image = nil;
        _backgroundView.image = nil;
        
        NSLog(@"Did End playing vedio 2222222222222222222 ########################### CT:%@, MT:%@",[NSThread currentThread], [NSThread mainThread]);

    });
  
    //[self setPostImage:_postImage];
    
    NSLog(@"Did End playing vedio ########################### CT:%@, MT:%@",[NSThread currentThread], [NSThread mainThread]);
}


-(void)singleTap:(id)sender
{
    //if(_enablePlayVideoTapnOnImage)
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
//    else
//    {
//        if(_delegate != nil && [_delegate respondsToSelector:@selector(postBodyViewDidTapOnImage:)])
//        {
//            [_delegate postBodyViewDidTapOnImage:self];
//        }
//    }
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
    NSLog(@"Current Time:%d",currentTime);
    
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


-(void)seekSeconds:(CGFloat)seconds
{
   // NSLog(@"The current Index:%d",_index);
    int tempIndex = _index;
    //int count = _postImage.images.count;
    int duration = 0, index;
    for (index=0; index<tempIndex; index++)
    {
        CMPhotoModel *prevPhotoModel = _postImage.images[index];
        duration = duration  + prevPhotoModel.duration;
        
        int diffDuration = seconds - duration;
        if(diffDuration <= 0)
        {
            //Required index is this...
            break;
        }
    }
    
    //now here the i is index...
 
    if(_index != index)
    {
        NSLog(@"---------------------reverse Index:%d _index:%d",index, _index);

        
        [_contentView bringSubviewToFront:_frontImageView];
        [_frontImageView setImageWithURL:[NSURL URLWithString:[_postImage.images[index] imageUrl]]];
        //change animation in reverse order...
        //[self reversePresentView:_frontImageView onView:_backImageView];
        _index = index;
    }
    
    

    
    
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


#pragma mark Timer Methods -

-(void)scheduleTimer:(NSTimer *)timer
{
    //Schedule timer running...
    _runningSeconds++;
    
    if(_isPlaying)
    {
        //Playing the video...
    }
    else
    {
        //Pause the video...
    }
}


@end