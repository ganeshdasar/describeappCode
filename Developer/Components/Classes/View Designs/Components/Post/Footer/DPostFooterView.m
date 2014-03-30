//
//  DPostFooterView.m
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DPostFooterView.h"
#import "DPost.h"
#import "DLikesView.h"
#import <QuartzCore/QuartzCore.h>



#define CONTENT_FRAME CGRectMake(0,0,320,82)

@interface DPostFooterView ()<DLikesViewDelegate>
{
    CGRect tagsFrame;
    CGRect starFrame;
    CGRect likesFrame;
    CGRect commentFrame;
    CGRect moreFrame;
    CGRect likeAndCommentFrame;
    
    UIView *_tagsView;
    UIView *_contentView;
    DLikesView *_likesView;
    UIButton *_moreButton, *_commentButton, *_likesAndCommentButton;
    UIImageView *_shadowImage;
}


@end

@implementation DPostFooterView

@synthesize postAttachments = _postAttachments;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        [self geometryCalculations];
        [self createConenteView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withPostAttachements:(DPostAttachments *)attachements
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _postAttachments = attachements;
        
        
        [self geometryCalculations];
        [self createConenteView];
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

-(void)createConenteView
{
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    [_contentView setUserInteractionEnabled:YES];
    [self addSubview:_contentView];
    
    //Design star view...
    [self designContentView];
}

-(void)createTagsList
{
    _tagsView = [[UIView alloc] initWithFrame:tagsFrame];
    [_tagsView setBackgroundColor:[UIColor clearColor]];
    [_contentView addSubview:_tagsView];
    
    [self designTagsView];
}

-(void)designTagsView
{
    float x,y,w,h;
    int count = 0;
    x = 0, y = 0, w = 320, h = 20;
    if(_postAttachments.tagsList != nil)
        count = _postAttachments.tagsList.count;
    
    for (int i=0; i<count; i++)
    {
        CGRect frame = CGRectMake(x, y, w, h);
        
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        [label setBackgroundColor:[UIColor clearColor]];
        [_tagsView addSubview:label];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor colorWithRed:140.0/255.0 green:185.0/255.0 blue:210.0/255.0 alpha:1]];
        [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]];
        
        DPostTag *tag= _postAttachments.tagsList[i];
        if(tag != nil && tag.tagName != nil)
            [label setText:tag.tagName];
        
        y = y + h;
    }
}


-(void)createStarView
{
    _likesView = [[DLikesView alloc] initWithFrame:likesFrame];
    //_likesView.delegate = self;
    [_likesView selectStars:_postAttachments.likeRating];
    [_contentView addSubview:_likesView];
    
}

-(void)createMoreButton
{
    _moreButton = [[UIButton alloc] initWithFrame:moreFrame];
    [_moreButton setBackgroundImage:[UIImage imageNamed:@"btn_overflow.png"] forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreButton:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_moreButton];
}

-(void)createComentButton
{
    _commentButton = [[UIButton alloc] initWithFrame:commentFrame];
    [_commentButton setBackgroundColor:[UIColor clearColor]];
    [_commentButton setTitle:@"comment" forState:UIControlStateNormal];
    [_commentButton setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [_commentButton addTarget:self action:@selector(commentButton:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_commentButton];
    [_commentButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    
    _commentButton.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2].CGColor;
    _commentButton.layer.borderWidth = 1.0;
    _commentButton.layer.cornerRadius = 10.0;
}

-(void)createLikesAndCommentButton
{
    _likesAndCommentButton = [[UIButton alloc] initWithFrame:likeAndCommentFrame];
    [_likesAndCommentButton setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.1]];
    [_likesAndCommentButton setTitle:[NSString stringWithFormat:@"%d likes, %d comments",_postAttachments.numberOfLikes, _postAttachments.numberOfComments] forState:UIControlStateNormal];
    [_likesAndCommentButton setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    [_likesAndCommentButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]];
    
    [_likesAndCommentButton addTarget:self action:@selector(likesAndComments:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_likesAndCommentButton];
    
    _likesAndCommentButton.layer.cornerRadius = 10.0;
}

-(void)createShadowOnPostCard
{
    CGRect shadowRect = CGRectMake(0, self.bounds.size.height-1, 320, 1);
    
    UIImageView *shadowImageView = [[UIImageView alloc]initWithFrame:shadowRect];
    [shadowImageView setBackgroundColor:[UIColor clearColor]];
    [shadowImageView setImage:[UIImage imageNamed:@"shadow_postcard.png"]];
    [self addSubview:shadowImageView];
}


#pragma mark View Designs -

-(void)designContentView
{
    [self createTagsList];
    
    [self createStarView];
    [self createMoreButton];
    [self createLikesAndCommentButton];
    [self createComentButton];
    [self createShadowOnPostCard];
}

#pragma mark View Operations -
#pragma mark Model Operations -

#pragma mark Geometry Caliculations -


-(void)geometryCalculations
{
    CGRect bounds = self.bounds;
    
    float x,y,w,h;
    int count = 0;
    x = 0, y = 6, w = 320, h = 20;
    if(_postAttachments.tagsList != nil)
        count = _postAttachments.tagsList.count;
    
    if(count == 0)
        tagsFrame = CGRectZero;
    
    for (int i=0; i<count; i++)
    {
        tagsFrame = CGRectMake(x, y, w, h);
        h = y + h;
    }
    
    likesFrame = CGRectMake(110, bounds.size.height-64, 80, 20);
    moreFrame = CGRectMake(20, bounds.size.height-32, 19, 5);
    likeAndCommentFrame = CGRectMake(80, bounds.size.height-38, 140, 20);
    commentFrame = CGRectMake(320-80, bounds.size.height-38, 70, 20);
    
}

#pragma mark Likes Delegate -
-(void)likesView:(DLikesView *)likeView didSelectedStars:(NSNumber *)stars
{
    //will get the number of likes here...
    //http://www.mirusstudent.com/service/describe-service/makeLike/format=json/UserUID=5/AuthUserUID=4/PostUID=2/likeStatus=2  
    
    
}
-(void)setContentDelegate:(id)sender
{
    if(sender != nil)
    {
        _likesView.delegate = sender;
        [_moreButton addTarget:sender action:@selector(moreButton:) forControlEvents:UIControlEventTouchUpInside];
        [_commentButton addTarget:sender action:@selector(commentButton:) forControlEvents:UIControlEventTouchUpInside];
        [_likesAndCommentButton addTarget:sender action:@selector(likesAndComments:) forControlEvents:UIControlEventTouchUpInside];
    }
}


-(void)moreButton:(id)sender
{
    //[self postNotification:POST_MORE_BUTTON_NOTIFICATION_KEY];
    
    NSLog(@"");
}


-(void)likesAndComments:(id)sender
{
  // [self postNotification:POST_LIKES_BUTTON_NOTIFICATION_KEY];
}



-(void)commentButton:(id)sender
{
    //[self postNotification:POST_COMMENT_BUTTON_NOTIFICATION_KEY];
}

-(void)postNotification:(NSString *)key
{
    NSString *postId = _postAttachments.postId;
    if(postId == nil) postId = @"123";
    NSDictionary *dictionary = @{postId:@"PostID"};
    [[NSNotificationCenter defaultCenter] postNotificationName:key object:dictionary];
}


@end
