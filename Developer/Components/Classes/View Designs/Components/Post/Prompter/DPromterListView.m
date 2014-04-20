//
//  DPromterListView.m
//  Describe
//
//  Created by LaxmiGopal on 22/02/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DPromterListView.h"
#import "DPromterProfileView.h"

#define PROMPTER_SCROLL_FRAME   CGRectMake(0, 0, 320, 400)
#define PROFILE_FRAME           CGRectMake(0, 320, 320, 80)

@interface DPromterListView  ()<UIScrollViewDelegate>
{
    UIScrollView    *_scrollView;
    UIButton        *_footerButton;
    NSArray         *_profileImages;
    BOOL            _isChangingLeftOffset;
}

@end

@implementation DPromterListView

- (id)initWithFrame:(CGRect)frame withPrompterImages:(NSArray *)prompterImages
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _profileImages = prompterImages;
        [self designPromterScrollView];
        [self designFooterView];
    }
    return self;
}

-(void)designPromterScrollView
{   
    _scrollView = [[UIScrollView alloc] initWithFrame:PROMPTER_SCROLL_FRAME];
    [_scrollView setDelegate:self];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [self addSubview:_scrollView];
    
    
    //[_scrollView removeObserver:self forKeyPath:@"contentOffset" context:nil];

    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self designContentOfProfile];
}

-(void)designContentOfProfile
{
    NSInteger count = [_profileImages count];
    float x,y,w,h;
    x = 0, y = 0, w = 228, h = 338;
    for (int i=0; i<count; i++)
    {
        DPromterProfileView *profileView = [[DPromterProfileView alloc] initWithFrame:CGRectMake(x, y, w, h) withPrompterImage:_profileImages[i]];
        [_scrollView addSubview:profileView];
        [profileView setTag:i+100];
        
        x = x + w;
    }
    
    
    CGFloat sizeOfProfiles = count * 228;
    [_scrollView setContentSize:CGSizeMake(sizeOfProfiles, 320)];
    [_scrollView setContentOffset:CGPointMake(228, 0)];
}

-(void)designFooterView
{
    _footerButton  = [[UIButton alloc] initWithFrame:PROFILE_FRAME];
    [_footerButton setTitle:@"complete your profile" forState:UIControlStateNormal];
    [_footerButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_footerButton addTarget:self action:@selector(completeProfile:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_footerButton];
}




-(void)completeProfile:(id)sender
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //CGPoint contentOffset = scrollView.contentOffset;
    //NSLog(@"contentOffset:%@",NSStringFromCGPoint(contentOffset));
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGFloat newOffset = [[change objectForKey:@"new"] CGPointValue].x;
    CGFloat oldOffset = [[change objectForKey:@"old"] CGPointValue].x;
    
    if(newOffset > oldOffset && !_isChangingLeftOffset)//Left...
    {
        _isChangingLeftOffset = NO;
        
        //Moving right...
        CGSize  contentSize = [_scrollView contentSize];
        newOffset = newOffset + 320;
        
        
        if(newOffset >= contentSize.width)
        {
            //NSLog(@"contentOffset X:%f size:%f",newOffset, contentSize.width);
            
            CGFloat diff =  newOffset - oldOffset;
            CGFloat offset = diff - 320;
            NSLog(@"diff:%f offSet:%f",diff, offset);

            
            
            CGPoint contentOffset = _scrollView.contentOffset;
            contentOffset.x = 126-(offset*1.2);
            [_scrollView setContentOffset:contentOffset];

        }
        
    }
    else
    {
        //Moving right...
        if(oldOffset < 0)
        {
            _isChangingLeftOffset = YES;
            
            CGPoint contentOffset = _scrollView.contentOffset;
            contentOffset.x = [_scrollView contentSize].width-(456 );
            [_scrollView setContentOffset:contentOffset];
        }
        else
            _isChangingLeftOffset = NO;
    }
    
    

}


-(void)dealloc
{
    //[_scrollView removeObserver:self forKeyPath:@"contentOffset" context:nil];
    
}

@end
