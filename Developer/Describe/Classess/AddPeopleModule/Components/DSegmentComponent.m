//
//  DSegmentComponent.m
//  Describe
//
//  Created by NuncSys on 26/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DSegmentComponent.h"
#define WIDTH       150
#define HEIGHT      30
#define FREESPACE   0

@interface DSegmentComponent ()
{
    float   _totalButtonsWidth;
    
    
}
@end
@implementation DSegmentComponent
@synthesize buttons = _buttons;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)designSegmentControllerWithButtons:(NSArray *)inSegments{
    _totalButtonsWidth = 0.0;
    _buttons = inSegments;
    //self.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:169.0/255.0 blue:155.0/255.0 alpha:1.0];
    //self.backgroundColor = [UIColor clearColor];
    //    self.alpha = 0.3;
    if(_buttons != nil)
    {
        _totalButtonsWidth = (WIDTH + FREESPACE)*_buttons.count;
    }
    // [self createTitleLabel];
    [self designSegmets];
    
    
}
-(void)designSegmets
{
    if(_buttons == nil)
        return;
    
    int count = _buttons.count;
    float x, y = 0;
   // x = self.bounds.size.width - _totalButtonsWidth;
    
    for (int i=0; i<count; i++)
    {
        UIButton *button = (UIButton *)_buttons[i];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setFrame:CGRectMake(x, y, WIDTH, HEIGHT)];
        [self addSubview:button];
        x = x + WIDTH + FREESPACE;
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

@end
