//
//  DLikesView.m
//  Describe
//
//  Created by LaxmiGopal on 19/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DLikesView.h"


@interface DLikesView ()
{
    UIView *_contentView;
    UITapGestureRecognizer *_singleTapGesture;
    
    NSInteger _minStars;
    NSInteger _maxStars;
    NSInteger _fressSpaceBwStars;
    NSInteger _starWidth;
    NSMutableArray *_stars;
    
    
    NSInteger starsSelected;
}

@end

@implementation DLikesView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code....
        _fressSpaceBwStars = 6;
        _minStars = 3;
        _maxStars = 3;
        _stars = [[NSMutableArray alloc] init];
        
        [self createContentView];
        [self addSingleTapGesture];
    }
    return self;
}

-(void)addSingleTapGesture
{
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    _singleTapGesture.cancelsTouchesInView = YES;
    [_singleTapGesture setNumberOfTouchesRequired:1];
    [_singleTapGesture setNumberOfTapsRequired:1];
    [_contentView addGestureRecognizer:_singleTapGesture];
    
}



-(void)createContentView
{
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_contentView];
    
    [self designStars];
}

-(void)designStars
{
    starsSelected = -1;
    _starWidth  = [self startSquareOneSide];
    [self caliculateMaxStartsByFrame:_contentView.frame];

    float x,y,w,h, freespace;
    x = 0, y = 0, h=w = _starWidth, freespace = _fressSpaceBwStars;
    for (int i=0; i<_maxStars; i++)
    {
        CGRect starRect = CGRectMake(x, y, w, h);
        
        UIImageView *star = [[UIImageView alloc] initWithFrame:starRect];
        [star setBackgroundColor:[UIColor clearColor]];
        [star setImage:[UIImage imageNamed:@"btn_star_off.png"]];
        [_contentView addSubview:star];
        
        x = x + w + freespace;
        [_stars addObject:star];
    }    
}


-(NSInteger)startSquareOneSide
{
    return (_contentView.bounds.size.width <= _contentView.bounds.size.height)?_contentView.bounds.size.width:_contentView.bounds.size.height;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark Model Methods -
-(void)deselectStars
{
    for (int i=0; i<_maxStars; i++)
    {
        UIImageView *star = _stars[i];
        if(star != nil)
        {
            [star setImage:[UIImage imageNamed:@"btn_star_off.png"]];
        }
    }
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(likesView:didSelectedStars:)])
    {
        //[self.delegate performSelector:@selector(likesView:didSelectedStars:) withObject:self withObject:[NSNumber numberWithUnsignedInt:toStar]];
    }
}


-(void)selectStars:(int)toStar
{
    for (int i=0; i<_maxStars; i++)
    {
        UIImageView *star = _stars[i];
        if(star != nil)
        {
            //Highlight star here...
            if(i<toStar)
                [star setImage:[UIImage imageNamed:@"btn_star_on.png"]];
            else
                [star setImage:[UIImage imageNamed:@"btn_star_off.png"]];
        }
    }
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(likesView:didSelectedStars:)])
    {
        [self.delegate performSelector:@selector(likesView:didSelectedStars:) withObject:self withObject:[NSNumber numberWithUnsignedInt:toStar]];
    }
}

#pragma mark Geometry Caliculations-

-(void)caliculateMaxStartsByFrame:(CGRect)frame
{
    _starWidth = [self startSquareOneSide];
    int starTotalWidth = _starWidth + _fressSpaceBwStars;
    _maxStars = frame.size.width/starTotalWidth;
}

-(void)singleTap:(UITapGestureRecognizer *)singleTapGesture
{
    CGPoint tappedLocation = [singleTapGesture locationInView:self];
    int selectedStar = [self currentSelectedStar:tappedLocation];
    
    if(selectedStar+1 == starsSelected)
    {
        //Deselect hole stars....
        [self deselectStars];
        starsSelected = -1;
    }
    else
    {
        starsSelected = selectedStar + 1;
        [self selectStars:starsSelected];
    }
}


-(unsigned int)currentSelectedStar:(CGPoint)location
{
    float x,y,w,h, freespace;
    int currentStar;
    x = 0, y = 0, h=w = _starWidth, freespace = _fressSpaceBwStars;
    for (int i=0; i<_maxStars; i++)
    {
        CGRect starRect = CGRectMake(x, y, w, h);
        
        if(CGRectContainsPoint(starRect, location))
        {
            currentStar = i;
            break;
        }
        else
            currentStar = 0;
        
        x = x + w + freespace;
    }
    return currentStar;
}


@end
