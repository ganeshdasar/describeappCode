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
#import "DLikesView.h"
#import "WSModelClasses.h"
#import "DPostsViewController.h"

#define HEADER_FRAME CGRectMake(0,0,320,50)
#define CONTENT_FRAME CGRectMake(0,50.5,320,320)
#define FOOTER_FRAME CGRectMake(0,370,320,126)

@interface DPostView ()<DPostHeaderViewDelegate, DPostHeaderViewDelegate, DLikesViewDelegate, WSModelClassDelegate>
{
    DPostHeaderView *_headerView;
    DPostBodyView *_contentView;
    DPostFooterView *_footerView;
}
@end


@implementation DPostView

@synthesize delegate = _delegate;
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

        [self addRightSwipeGesture];        
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame andPost:(DPost *)post
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        _post = post;
        [self createPostHeaderView];
        [self createPostBodyView];
        [self createPostFooterView];
        
        [self addRightSwipeGesture];
    }
    return self;
}

-(void)addRightSwipeGesture
{
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeGesture:)];
    [rightSwipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:rightSwipeGesture];
}


-(void)rightSwipeGesture:(id)sender
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(showConversationOfThisPost:)])
    {
        [self.delegate showConversationOfThisPost:_post];
    }
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)reloadPost:(DPost *)post
{
    _post = post;
    [self createPostHeaderView];
    [self createPostBodyView];
    [self createPostFooterView];
}


-(void)setDelegate:(id<DPostViewDelegate>)delegate
{
    _delegate = delegate;
    
    if(_delegate != nil)
        [_headerView setDelegate:self];
}


#pragma mark View Creations -

-(void)createPostHeaderView
{
    if(_headerView == nil)
    {
        _headerView = [[DPostHeaderView alloc] initWithFrame:HEADER_FRAME];
        [self addSubview:_headerView];
    }
    
    [_headerView setDelegate:self];
    [_headerView setDuration:_post.elapsedTime];
    [_headerView setUser:_post.user];
}

-(void)createPostBodyView
{
    if(_contentView == nil)
    {
        _contentView = [[DPostBodyView alloc] initWithFrame:CONTENT_FRAME withPostImage:_post.imagePost];
        [self addSubview:_contentView];
    }
    
    return;
    
    
    [_contentView setBackgroundColor:[UIColor clearColor]];
    [_contentView setEnablePlayVideoTapnOnImage:YES];
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
    
    if(_footerView == nil)
    {
        _footerView = [[DPostFooterView alloc] initWithFrame:footerFrame withPostAttachements:_post.attachements];
        [self addSubview:_footerView];
    }
    [_footerView setPostAttachments:_post.attachements];
    [_footerView setContentDelegate:self];
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


#pragma mark Delegates -
#pragma mark Header View Delegate Methods

-(void)profileDetailsDidSelected
{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(profileDidSelectedForPost:)])
    {
        [_delegate profileDidSelectedForPost:_post];
    }
}

-(void)profileDetailsDidSelected:(DPostHeaderView *)headerView
{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(profileDidSelectedForPost:)])
    {
        [_delegate profileDidSelectedForPost:_post];
    }
}

#pragma mark Likes View Delegate

-(void)likesView:(DLikesView *)likeView didSelectedStars:(NSNumber *)stars
{
    //http://www.mirusstudent.com/service/describe-service/makeLike/format=json/UserUID=5/AuthUserUID=4/PostUID=2/likeStatus=2
    
    WSModelClasses *sharedModel = [WSModelClasses sharedHandler];
    [sharedModel setDelegate:self];
    [sharedModel likePost:[_post postId] userId:[[[WSModelClasses sharedHandler] loggedInUserModel].userID stringValue] authUserId:[[_post user] userId] status:[stars integerValue]];
}


-(void)likeStatus:(id)status withError:(NSError *)error
{
    NSLog(@"like status:%@ error:%@", status, error);
}

-(void)moreButton:(id)sender
{
    //More button action...
    NSLog(@"More Button");
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(showMoreDetailsOfThisPost:)])
    {
        [self.delegate showMoreDetailsOfThisPost:_post];
    }
    
}

-(void)likesAndComments:(id)sender
{
    //Likes and Comments action...
   
}

-(void)commentButton:(id)sender
{
    //Comments action...
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(showConversationOfThisPost:)])
    {
        [self.delegate showConversationOfThisPost:_post];
    }
}



-(void)dealloc
{
    _headerView = nil;
    _contentView = nil;
    _footerView = nil;
}

@end
