//
//  DHeaderView.m
//  Describe
//
//  Created by LaxmiGopal on 23/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DHeaderView.h"
#import "DESAnimation.h"

#define WIDTH       35
#define FREESPACE   5

@interface DHeaderView ()
{
    float   _totalButtonsWidth;
    CGRect  _titleFrame;
    
    UILabel *_titleLabel;
    UIImageView* imageView;
    
    NSArray *_menuButtons;
    UIView *_contentView;
    
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
        //self.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:169.0/255.0 blue:155.0/255.0 alpha:1.0];
        
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
  
    [self designHeaderViewWithTitle:title andWithButtons:buttons andMenuButtons:nil];
    
}

-(void)setbackgroundImage:(UIImage *)image
{
    imageView.image = image;
}

-(void)designHeaderViewWithTitle:(NSString *)title andWithButtons:(NSArray *)buttons andMenuButtons:(NSArray *)menuButtons
{
    // Initialization code...
    [self setTheBackgroundImage];
    _menuButtons = menuButtons;
    
        if(_contentView != nil)
    {
        [_contentView removeFromSuperview];
        _contentView = nil;
    }
    
    if(_contentView == nil)
    {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        [_contentView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_contentView];
    }
    
    _totalButtonsWidth = 0.0;
    _title = title;
    _buttons = buttons;
    //self.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:169.0/255.0 blue:155.0/255.0 alpha:1.0];
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
    [self showDefaultButtons];
}

-(void)hideButton:(UIButton *)hideButton
{
    if(_buttons == nil)
        return;
    
    int count = _buttons.count-1;
    float x= 20;
    float y = 24;
    _totalButtonsWidth = (WIDTH + FREESPACE)*count;
    x = self.bounds.size.width - _totalButtonsWidth;
    
    //default Buttons....
    for (int i=0; i<count; i++)
    {
        UIButton *button = (UIButton *)_buttons[i];
        
        if(button.tag == hideButton.tag)
        {
            [button setHidden:YES];
            continue;
        }
        [button setBackgroundColor:[UIColor clearColor]];
        [button setFrame:CGRectMake(x, y, WIDTH, WIDTH)];
        //[self addSubview:button];
        x = x + WIDTH + FREESPACE;
        
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)showButton:(UIButton *)button
{
    
}

-(void)reachMe
{
    NSLog(@"Reaching");
}

-(void)setTheBackgroundImage
{
    if(imageView == nil)
    {
        imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        imageView.image = [UIImage imageNamed:@"bg_nav_std.png"];
        [self addSubview:imageView];
    }
}
-(void)createTitleLabel
{
    
    _titleLabel = [[UILabel alloc] initWithFrame:_titleFrame];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setText:_title];
    [_titleLabel setTextAlignment:NSTextAlignmentLeft];
    [_titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:25.0]];
    [_titleLabel setTextColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [_contentView addSubview:_titleLabel];
}
-(void)removeSubviewFromHedderView{
    
    [_titleLabel removeFromSuperview];
    for (UIButton* btn in _buttons) {
        [btn removeFromSuperview];
    }
}

-(void)designButtons
{
    [self bringSubviewToFront:_contentView];
    
    if(_buttons == nil)
        return;
    
    int count = _buttons.count;
    float x= 20;
    float y = 22;
    x = self.bounds.size.width - _totalButtonsWidth;
    
    //default Buttons....
    for (int i=0; i<count; i++)
    {
        UIButton *button = (UIButton *)_buttons[i];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setFrame:CGRectMake(x, y, WIDTH, WIDTH)];
        [_contentView addSubview:button];
        x = x + WIDTH + FREESPACE;
        
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //menu options...
    if(_menuButtons == nil || !_menuButtons.count)
        return;
    
    _totalButtonsWidth = (WIDTH + FREESPACE)*_menuButtons.count;
    count = _menuButtons.count;
    x= 20;
    y = 24;
    x = self.bounds.size.width - _totalButtonsWidth;
    for (int i=0; i<count; i++)
    {
        UIButton *button = (UIButton *)_menuButtons[i];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setFrame:CGRectMake(x, y, WIDTH, WIDTH)];
        [_contentView addSubview:button];
        x = x + WIDTH + FREESPACE;
        
        [button setAlpha:0.0];
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    
 
}



-(void)buttonSelected:(id)sender
{
    HeaderButtonType buttonType = (HeaderButtonType)[sender tag];
    if(buttonType == HeaderButtonTypeMenu)
    {
        //show the menu here...
        [self showMenuButtons];
    }
    else if(buttonType == HeaderButtonTypeClose)
    {
        //Show the default buttons here...
        if(_menuButtons != nil)
            [self showDefaultButtons];
        else
        {
            [self.delegate headerView:self didSelectedHeaderViewButton:sender];
        }

    }
    else
    {
        //Send the neccessary actions to the delegate...
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(headerView:didSelectedHeaderViewButton:)])
        {
            if(_menuButtons != nil)
                [self showDefaultButtons];
            [self.delegate headerView:self didSelectedHeaderViewButton:sender];
        }
    }
    
    
}

-(void)startAnimate
{
    [self animateOnViews:_buttons atIndex:_buttons.count-1];
}

-(void)dissmissAllFromTheView:(NSArray *)buttons
{
    for (int i =0; i<buttons.count; i++)
    {
        UIButton *button = buttons[i];
        button.alpha = 0.0;
    }

    
}

-(void)showDefaultButtons
{
    [_titleLabel setAlpha:1.0];
    [self dissmissAllFromTheView:_menuButtons];
    [self performSelector:@selector(showButtons:) withObject:_buttons afterDelay:0.1];
}

-(void)showMenuButtons
{
    [_titleLabel setAlpha:0.0];
    [self dissmissAllFromTheView:_buttons];
    [self performSelector:@selector(showButtons:) withObject:_menuButtons afterDelay:0.1];
}


- (void)showButtons:(NSArray *)buttons
{
    _contentView.userInteractionEnabled = NO;
    
    CFTimeInterval timeInterval = 0;
    for (NSInteger index = buttons.count - 1; index >= 0; index--) {
        UIView *aView = (UIView *)buttons[index];
        [self bounceOutView:aView withDelay:timeInterval withKeypath:[NSString stringWithFormat:@"BounceOutAnimationKeypath%ld", (long)index] isLast:index == 0 ? YES : NO];
        timeInterval += 0.1;
    }
    return;
    
    [self animateOnViews:buttons atIndex:buttons.count-1];
    
    return;
    for (int i =0; i<buttons.count; i++)
    {
        UIButton *button = buttons[i];
        button.alpha = 1.0;
    }
}

- (void)showAlphaOfView:(UIView *)aView
{
    aView.alpha = 1.0;
}

- (void)bounceOutView:(UIView *)aView withDelay:(CFTimeInterval)time withKeypath:(NSString *)animationKeyPath isLast:(BOOL)lastFlag
{
    aView.alpha = 0;
    CFTimeInterval startTime = time;
    
    CABasicAnimation *scaleAnimation1 = [DESAnimation scaleFrom:1.0 to:0.6 duration:0.0 beginTime:startTime];// [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    CABasicAnimation *fadeAnimation = [DESAnimation fadeFrom:0.0 to:1.0 duration:0.3 beginTime:startTime];//[CABasicAnimation animationWithKeyPath:@"opacity"];
    startTime += 0.3;

    [self performSelector:@selector(showAlphaOfView:) withObject:aView afterDelay:startTime];
    
    CABasicAnimation *scaleAnimation2 = [DESAnimation scaleFrom:0.6 to:1.1 duration:0.2 beginTime:startTime];
    startTime += 0.2;
    
    CABasicAnimation *scaleAniamtion3 = [DESAnimation scaleFrom:1.1 to:1.0 duration:0.15 beginTime:startTime];
    startTime += 0.15;
    
    CABasicAnimation *scaleAnimation4 = [DESAnimation scaleFrom:1.0 to:1.05 duration:0.1 beginTime:startTime];
    startTime += 0.1;
    
    CABasicAnimation *scaleAnimation5 = [DESAnimation scaleFrom:1.05 to:1.0 duration:0.05 beginTime:startTime];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = startTime + 0.05;
    animationGroup.delegate = self;
    animationGroup.animations = [NSArray arrayWithObjects:scaleAnimation1, fadeAnimation, scaleAnimation2, scaleAniamtion3, scaleAnimation4, scaleAnimation5, nil];
    [animationGroup setValue:[NSNumber numberWithBool:lastFlag] forKeyPath:@"IsLastAnimationFlag"];
    
    if([aView.layer animationForKey:animationKeyPath]) {
        [aView.layer removeAnimationForKey:animationKeyPath];
    }
    
    [aView.layer addAnimation:animationGroup forKey:animationKeyPath];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CAAnimationGroup *animGroup = (CAAnimationGroup *)anim;
    if([[animGroup valueForKey:@"IsLastAnimationFlag"] boolValue] == YES) {
        _contentView.userInteractionEnabled = YES;
    }
}

-(void)animateOnViews:(NSArray *)views atIndex:(NSUInteger )index
{
    UIView *animatedView = views[index];
    animatedView.alpha = 0;
    
    [UIView animateWithDuration:0.3
                          delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         animatedView.transform = CGAffineTransformMakeScale(.6, 0.6);
                         animatedView.alpha = 1.0;
                     } completion:^(BOOL finished){
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              animatedView.transform = CGAffineTransformMakeScale(1.10, 1.10);
                                              //Start animate another view if any
                                              int prevElementIndex = index - 1;
                                              if(prevElementIndex >= 0)
                                              {
                                                  [self animateOnViews:views atIndex:prevElementIndex];
                                              }
                                          }
                                          completion:^(BOOL finished3){
                                              [UIView animateWithDuration:0.15
                                                               animations:^{
                                                                   animatedView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                                   
                                                                   
                                                               }
                                                               completion:^(BOOL finished4){
                                                                   [UIView animateWithDuration:0.1
                                                                                    animations:^{
                                                                                        animatedView.transform = CGAffineTransformMakeScale(1.05, 1.05);
                                                                                        
                                                                                        
                                                                                    }
                                                                                    completion:^(BOOL finished6){
                                                                                        
                                                                                        [UIView animateWithDuration:0.05
                                                                                                         animations:^{
                                                                                                             animatedView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                                                                         }
                                                                                                         completion:^(BOOL finished7){
                                                                                                         }];
                                                                                    }];
                                                               }];
                                          }];
                         
                     }];
    
    
}
@end
