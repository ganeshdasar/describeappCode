//
//  DSegmentView.m
//  Describe
//
//  Created by Aashish Raj on 2/15/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DSegmentView.h"
#import "DSegment.h"


#define TITLE_BACKGROUND_NONSELECTED_COLOR [UIColor whiteColor]
#define TITLE_BACKGROUND_SELECTED_COLOR [UIColor whiteColor]

#define TITLE_SELECTED_COLOR [UIColor colorWithRed:53.0/255.0 green:168.0/255.0 blue:157.0/255.0 alpha:1.0]
#define TITLE_UN_SELECTED_COLOR [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]


#define SUB_TITLE_SELECTED_COLOR [UIColor colorWithRed:53.0/255.0 green:168.0/255.0 blue:157.0/255.0 alpha:1.0]
#define SUB_TITLE_UN_SELECTED_COLOR [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]


#define SUB_TITLE_BACKGROUND_NONSELECTED_COLOR [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]
#define SUB_TITLE_BACKGROUND_SELECTED_COLOR [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]



#define TITLE_TEXT_SELECTED_COLOR        [UIColor colorWithRed:53.0/255.0 green:168.0/255.0 blue:157.0/255.0 alpha:1.0]
#define TITLE_TEXT_UN_SELECTED_COLOR     [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]

#define SUB_TITLE_TEXT_SELECTED_COLOR    [UIColor whiteColor]
#define SUB_TITLE_TEXT_UN_SELECTED_COLOR [UIColor whiteColor]



@interface DSegmentView ()
{
    UIView *_contentView;
    UIView *_titleBacgroundView;
    UILabel *_titleLabel;
    UIView *_subTitleBackgroundView;
    UILabel *_subTitleLabel;
}

@end


@implementation DSegmentView

@synthesize segment = _segment;
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code...
        
        [self createContentView];
        [self addSingleTapGesture];
    }
    return self;
}

-(void)createContentView
{
    _contentView  = [[UIView alloc] initWithFrame:self.bounds];
    [_contentView setBackgroundColor:[UIColor redColor]];
    [self addSubview:_contentView];
    
    [self createTitleView];
    [self createSubTitleView];
    
    [_titleBacgroundView setUserInteractionEnabled:NO];
    [_subTitleBackgroundView setUserInteractionEnabled:NO];
    
    
    [self dessignColors];
}

-(void)addSingleTapGesture
{
    UITapGestureRecognizer *_singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    _singleTapGesture.cancelsTouchesInView = YES;
    [_singleTapGesture setNumberOfTouchesRequired:1];
    [_singleTapGesture setNumberOfTapsRequired:1];
    [_contentView addGestureRecognizer:_singleTapGesture];
    
}

-(void)singleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(segmentViewDidSelected:)])
    {
        [_delegate performSelector:@selector(segmentViewDidSelected:) withObject:self];
    }
    [self selectSegment];
}


-(void)unSelectSegment
{
    [_titleBacgroundView setBackgroundColor:TITLE_BACKGROUND_NONSELECTED_COLOR];
    [_subTitleBackgroundView setBackgroundColor:SUB_TITLE_BACKGROUND_NONSELECTED_COLOR];
    
    [_titleLabel setTextColor:TITLE_TEXT_UN_SELECTED_COLOR];
    [_subTitleLabel setTextColor:SUB_TITLE_TEXT_UN_SELECTED_COLOR];
    
}

-(void)selectSegment
{
    [_titleBacgroundView setBackgroundColor:TITLE_BACKGROUND_SELECTED_COLOR];
    [_subTitleBackgroundView setBackgroundColor:SUB_TITLE_BACKGROUND_SELECTED_COLOR];
    
    [_titleLabel setTextColor:TITLE_TEXT_SELECTED_COLOR];
    [_subTitleLabel setTextColor:SUB_TITLE_TEXT_SELECTED_COLOR];
}

-(void)dessignColors
{
    [_titleBacgroundView setBackgroundColor:TITLE_BACKGROUND_NONSELECTED_COLOR];
    [_subTitleBackgroundView setBackgroundColor:SUB_TITLE_BACKGROUND_NONSELECTED_COLOR];
    
    [_titleLabel setTextColor:TITLE_TEXT_UN_SELECTED_COLOR];
    [_subTitleLabel setTextColor:SUB_TITLE_UN_SELECTED_COLOR];
}

-(void)createTitleView
{
    _titleBacgroundView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contentView.bounds.size.width, 30)];
    [_titleBacgroundView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_titleBacgroundView];
    
    _titleLabel = [self createLabelOnView:_titleBacgroundView withText:_segment.title atRect:_titleBacgroundView.bounds];
    [_titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0]];
}

-(void)createSubTitleView
{
    _subTitleBackgroundView  = [[UIView alloc] initWithFrame:CGRectMake(0, 30, _contentView.bounds.size.width, 20)];
    [_subTitleBackgroundView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_subTitleBackgroundView];
    
     _subTitleLabel = [self createLabelOnView:_subTitleBackgroundView withText:_segment.subTitle atRect:_subTitleBackgroundView.bounds];
    [_subTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]];
}


-(UILabel *)createLabelOnView:(UIView *)view withText:(NSString *)text atRect:(CGRect)rect
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:text];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0]];
    [titleLabel setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:titleLabel];
    
    return titleLabel;
}


-(void)setSegment:(DSegment *)segment
{
    if(segment != _segment)
    {
        _segment = nil;
        _segment = segment;
    }
    
    [_titleLabel setText:_segment.title];
    [_subTitleLabel setText:_segment.subTitle];
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
