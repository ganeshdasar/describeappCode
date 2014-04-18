//
//  DSegmentViewList.m
//  Describe
//
//  Created by Aashish Raj on 2/15/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DSegmentViewList.h"
#import "DSegment.h"
#import "DSegmentView.h"

#define SEGMENT_WIDTH 107


@interface DSegmentViewList ()<DSegementViewDelegate>
{
    UIView *_contentView;
    UIScrollView *_scrollView;
    
    DSegmentView *_previousSegment;
}
@end

@implementation DSegmentViewList
@synthesize segments = _segments;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code...
        
        
        [self createContentView];
    }
    return self;
}

-(void)designSegmentView
{
    [self createContentView];
    
    [self designSegments];
}

-(void)createContentView
{
    _contentView  = [[UIView alloc] initWithFrame:self.bounds];
    [_contentView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:_contentView];
    
    [self createScrollView];
}

-(void)createScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [_contentView addSubview:_scrollView];
}

-(void)setSegments:(NSArray *)segments
{
    _segments = nil;
    _segments = [segments copy];
    
    //[self designSegments];
}

-(void)setText:(NSString *)text forIndex:(NSInteger )index
{
    DSegment *segment = _segments[index];
    segment.subTitle = text;
    DSegmentView *segmentView = (DSegmentView *)[_scrollView viewWithTag:100+index];
    if(segmentView != nil)
        [segmentView setSegment:segment];
}


-(void)selectSegmentAtIndex:(NSInteger )index
{
    if (_previousSegment != nil)
    {
        [_previousSegment unSelectSegment];
    }
    
    int tag = index + 100;
    DSegmentView *segmentView = (DSegmentView *)[_scrollView viewWithTag:tag];
    if(segmentView != nil)
    {
        
        [segmentView selectSegment];
        _previousSegment = segmentView;
    }
}

-(void)designSegments
{
    int count = [_segments count];
    
    CGSize scrollViewContentSize = [_scrollView contentSize];
    scrollViewContentSize.width = count*SEGMENT_WIDTH;
    [_scrollView setContentSize:scrollViewContentSize];
    
    CGFloat x=0, y=0 , w = SEGMENT_WIDTH, h = 50;
    
    for (int i=0; i<count; i++)
    {
        DSegment *segment = _segments[i];
        
        DSegmentView *segmentView = [[DSegmentView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [_scrollView addSubview:segmentView];
        [segmentView setSegment:segment];
        [segmentView setDelegate:self];
        [segmentView setTag:100+i];
        
        
        UILabel *titleSeparator = [[UILabel alloc] initWithFrame:CGRectMake(x+w, 0, 0.5, 30)];
        [titleSeparator setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
        [_scrollView addSubview:titleSeparator];

        
        UILabel *countSeparator = [[UILabel alloc] initWithFrame:CGRectMake(x+w, 30, 0.5, 20)];
        [countSeparator setBackgroundColor:[UIColor whiteColor]];
        [_scrollView addSubview:countSeparator];
        
        x = x + w + 0.5;
    }
}


-(void)segmentViewDidSelected:(DSegmentView *)segmentView
{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(segmentViewDidSelected:)])
    {
        //[_delegate performSelector:@selector(segmentViewDidSelected:) withObject:segmentView];
        [_delegate performSelector:@selector(segmentViewDidSelected:atIndex:) withObject:self withObject:[NSNumber numberWithInt:[_segments indexOfObject:segmentView.segment]]];
        
    }
    
    if(_previousSegment !=nil)
    {
        [_previousSegment unSelectSegment];
    }
    _previousSegment = segmentView;    
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
