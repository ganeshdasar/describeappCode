//
//  DPostView.m
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DPostView.h"
#import "DPostHeaderView.h"
#import "DPostBodyView.h"
#import "DPostFooterView.h"
#import "DPost.h"


#define HEADER_FRAME CGRectMake(0,0,320,50)
#define CONTENT_FRAME CGRectMake(0,50.5,320,320)
#define FOOTER_FRAME CGRectMake(0,370,320,126)

@interface DPostView ()
{
    DPostHeaderView *_headerView;
    DPostBodyView *_contentView;
    DPostFooterView *_footerView;
}
@end


@implementation DPostView


@synthesize post = _post;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        [self createPostHeaderView];
        [self createPostBodyView];
        [self createPostFooterView];
    
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame andPost:(DPost *)post
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blueColor];
        
        _post = post;
        [self createPostHeaderView];
        [self createPostBodyView];
        [self createPostFooterView];
        
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

#pragma mark View Creations -

-(void)createPostHeaderView
{
    _headerView = [[DPostHeaderView alloc] initWithFrame:HEADER_FRAME];
    [_headerView setUser:nil];
    [self addSubview:_headerView];
    [_headerView setDuration:_post.imagePost.video.duration];
    [_headerView setUser:_post.user];
}

-(void)createPostBodyView
{
    _contentView = [[DPostBodyView alloc] initWithFrame:CONTENT_FRAME withPostImage:_post.imagePost];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_contentView];
    [_contentView setPostImage:_post.imagePost];
}

-(void)createPostFooterView
{
    float height = 76;
    
    NSArray *tags =  _post.attachements.tagsList;
    if(tags != nil)
    {
        int count = tags.count;
        height = height + count*20;
    }
    CGRect footerFrame = CGRectMake(0,370,320,height);

    _footerView = [[DPostFooterView alloc] initWithFrame:footerFrame withPostAttachements:_post.attachements];
    [self addSubview:_footerView];
}


#pragma mark View Designs -

-(void)designPostView
{
    self.backgroundColor = [UIColor whiteColor];
    
    [self createPostHeaderView];
    [self createPostBodyView];
    [self createPostFooterView];
    
}



#pragma mark View Operations -
#pragma mark Model Operations -


-(void)startAnimation
{
    [_contentView startAniamtion];
}

-(void)playVideo
{
    [_contentView playVideo];
}
-(void)pauseVideo
{
    [_contentView pauseVideo];
}

-(void)dealloc
{
    _headerView = nil;
    _contentView = nil;
    _footerView = nil;
}

@end
