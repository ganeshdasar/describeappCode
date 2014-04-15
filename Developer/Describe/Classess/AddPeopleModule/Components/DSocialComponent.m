//
//  DSocialComponent.m
//  Describe
//
//  Created by NuncSys on 11/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DSocialComponent.h"
#define WIDTH       25
#define HEIGHT      25
#define FREESPACE   0
@interface DSocialComponent ()
{
    float   _totalButtonsWidth;
    
    
}
@end
@implementation DSocialComponent
@synthesize buttons = _buttons;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)designSocialNetworkConnectionsWithButtons:(NSArray *)inComponents;{
    _totalButtonsWidth = 0.0;
    _buttons = inComponents;
    //self.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:169.0/255.0 blue:155.0/255.0 alpha:1.0];
    //self.backgroundColor = [UIColor clearColor];
    //    self.alpha = 0.3;
    if(_buttons != nil)
    {
        _totalButtonsWidth = (WIDTH + FREESPACE)*_buttons.count;
    }
    [self designButtons];
    
    
}
-(void)designButtons{
    
    if(_buttons == nil)
        return;
    
    int count = _buttons.count;
    float y = 20;
    float x =160;
    // x = self.bounds.size.width - _totalButtonsWidth;
    
    for (int i=0; i<count; i++)
    {
        UIButton *button = (UIButton *)_buttons[i];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setFrame:CGRectMake(x+i*WIDTH, y, WIDTH, HEIGHT)];
        [self addSubview:button];
        x = x + WIDTH + FREESPACE;
    }

}
@end
