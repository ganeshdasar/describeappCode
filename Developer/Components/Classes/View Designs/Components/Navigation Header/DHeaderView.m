//
//  DHeaderView.m
//  Describe
//
//  Created by LaxmiGopal on 23/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DHeaderView.h"

#define WIDTH       35
#define FREESPACE   5

@interface DHeaderView ()
{
    float   _totalButtonsWidth;
    CGRect  _titleFrame;
    
    UILabel *_titleLabel;
    UIImageView* imageView;
    
}
@end

@implementation DHeaderView
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@synthesize title = _title;
@synthesize buttons = _buttons;

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title andWithButtons:(NSArray *)buttons
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code...
        _totalButtonsWidth = 0.0;
        _title = title;
        _buttons = buttons;
        self.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:169.0/255.0 blue:155.0/255.0 alpha:1.0];
        
        if(_buttons != nil)
        {
            _totalButtonsWidth = (WIDTH + FREESPACE)*_buttons.count;
        }
        _titleFrame = CGRectMake(5, 30, self.bounds.size.width-_totalButtonsWidth, 30);
        

        [self createTitleLabel];
        [self designButtons];
        
    }
    return self;
}

-(void)designHeaderViewWithTitle:(NSString *)title andWithButtons:(NSArray *)buttons
{
    // Initialization code...
    _totalButtonsWidth = 0.0;
    _title = title;
    _buttons = buttons;
    self.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:169.0/255.0 blue:155.0/255.0 alpha:1.0];
    //self.backgroundColor = [UIColor redColor];
    
    //    self.alpha = 0.3;
    
    if(_buttons != nil)
    {
        _totalButtonsWidth = (WIDTH + FREESPACE)*_buttons.count;
    }
    _titleFrame = CGRectMake(4, 25, self.bounds.size.width-_totalButtonsWidth, 30);
    
  //  [self setTheBackgroundImage];
    [self createTitleLabel];
    [self designButtons];
    
}

-(void)reachMe
{
    NSLog(@"Reaching");
}

-(void)setTheBackgroundImage{
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 65)];
    imageView.image = [UIImage imageNamed:@"bg_nav_std.png"];
    [self addSubview:imageView];
}
-(void)createTitleLabel
{
    _titleLabel = [[UILabel alloc] initWithFrame:_titleFrame];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setText:_title];
    [_titleLabel setTextAlignment:NSTextAlignmentLeft];
    [_titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:25.0]];
    [_titleLabel setTextColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [self addSubview:_titleLabel];
}
-(void)removeSubviewFromHedderView{
    
    [_titleLabel removeFromSuperview];
    for (UIButton* btn in _buttons) {
        [btn removeFromSuperview];
    }
}

-(void)designButtons
{
    if(_buttons == nil)
        return;
    
    int count = _buttons.count;
    float x= 20;
    float y = 24;
    x = self.bounds.size.width - _totalButtonsWidth;
    
    for (int i=0; i<count; i++)
    {
        UIButton *button = (UIButton *)_buttons[i];
       [button setBackgroundColor:[UIColor clearColor]];
        [button setFrame:CGRectMake(x, y, WIDTH, WIDTH)];
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
