//
//  DPostHeaderView.m
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DPostHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "DPost.h"

#define USER_ICON_FRAME                 CGRectMake(5, 5, 40, 40)

#define TITLE_FRAME                     CGRectMake(51, 6, 290, 20)
#define TITLE_TEXT_COLOR                [UIColor whiteColor]

#define SUBTITLE_FRAME                  CGRectMake(51, 27, 290, 18)
#define SUBTITLE_TEXT_COLOR                [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0]

#define DURATION_FRAME                  CGRectMake(275, 12, 36, 14)
#define DURATION_TEXT_COLOR             [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0]

#define TITLE_CENTER_FRAME              CGRectMake(51, 16, 200, 20)
#define DURATION_CENTER_FRAME           CGRectMake(220, 16, 80, 20)


@interface DPostHeaderView ()
{
    UIImageView *_backgroundView;
    
    UIImageView *_userIcon;
    
    UIView *_contentView;
    UILabel *_title;
    UILabel *_subTitle;
    UILabel *_durationLbl;
    
}

@end


@implementation DPostHeaderView

@synthesize user = _user;
@synthesize duration = _duration;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        [self createBackgroundView];
        [self createContentView];
        
        [self designBodyView];
        
    }
    return self;
}

#pragma mark Create Views -

-(void)createBackgroundView
{
    _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    [_backgroundView setBackgroundColor:[UIColor clearColor]];
    [_backgroundView setImage:[UIImage imageNamed:@"12.png"]];
    [self addSubview:_backgroundView];
}


-(void)createContentView
{
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_contentView];
    
}

-(void)createUserIcon
{
    _userIcon = [[UIImageView alloc] initWithFrame:USER_ICON_FRAME];
    [_userIcon setBackgroundColor:[UIColor clearColor]];
    [_userIcon setImage:[UIImage imageNamed:@"apple.jpg"]];//Place the user image based on user model...
    [_contentView addSubview:_userIcon];
    
    [_userIcon.layer setMasksToBounds:YES];
    [_userIcon.layer setCornerRadius:20.0];
}


-(UILabel *)labelOnView:(UIView *)view withFrame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setBackgroundColor:[UIColor clearColor]];
    [view addSubview:label];
    [label setTextColor:[UIColor redColor]];
    return label;
}

#pragma mark Design Views -

-(void)designBodyView
{
    [self createUserIcon];
    
    [self designTitle];
    [self designSubtitle];
    [self designDuration];
}


-(void)designTitle
{
    _title = [self labelOnView:_contentView withFrame:TITLE_FRAME];
    [_title setTextColor:TITLE_TEXT_COLOR];
    [_title setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
}

-(void)designSubtitle
{
    _subTitle = [self labelOnView:_contentView withFrame:SUBTITLE_FRAME];
    [_subTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]];
    [_subTitle setTextColor:SUBTITLE_TEXT_COLOR];
}

-(void)designDuration
{
    _durationLbl = [self labelOnView:_contentView withFrame:DURATION_FRAME];
    [_durationLbl setTextAlignment:NSTextAlignmentRight];
    [_durationLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.0]];
    [_durationLbl setTextColor:DURATION_TEXT_COLOR];
    
}


#pragma mark View Operations -


#pragma mark Model Operations -

-(void)setUser:(DUser *)user
{
    _user = user;
    
    //Update the ui here...
    if(user != nil && ( user.address != nil && user.address.length))//Title and Subtitle Available...
    {        
        [_title setFrame:TITLE_FRAME];               
        [_durationLbl setFrame:DURATION_FRAME];       
        
    }
    else//Only Title Available...
    {        
        [_title setFrame:TITLE_CENTER_FRAME];              
        [_durationLbl setFrame:DURATION_CENTER_FRAME];
    }
    
    [_title setText:user.name];//Have to use update the title based on user details...
    [_subTitle setText:user.address];//Have to use update the title based on user details...
    [_durationLbl setText:[NSString stringWithFormat:@"%@ s",_duration]];//Have to update the duration based on user details...

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
