//
//  DSocialMediaListView.m
//  Describe
//
//  Created by Aashish Raj on 4/9/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DSocialMediaListView.h"
#import "UIColor+DesColors.h"

@interface DSocialMediaListView ()
{
    CGSize _mediaItemSize;
    CGFloat _freeSpace;
    UIView *_contentView;
    UILabel *_titleLbl;
    
    NSArray *_mediaList;
}
@end


@implementation DSocialMediaListView

- (id)initWithFrame:(CGRect)frame withMediaList:(NSArray *)medias
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _mediaList = [[NSArray alloc] initWithArray:medias];
        [self configureSettings];
        [self createContentView];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code        
        [self configureSettings];
        
    }
    return self;
}

-(void)configureSettings
{
    _mediaItemSize = CGSizeMake(25.f, 25.f);
    _freeSpace = 10.f;
    self.backgroundColor = [UIColor clearColor];
    
}

-(void)setMedaiList:(NSArray *)medias
{
    [_contentView removeFromSuperview];
    [self configureSettings];
    _mediaList = [[NSArray alloc] initWithArray:medias];
    [self createContentView];
}


-(void)createContentView
{
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_contentView];
    
    [self designContentView];
}

-(void)designContentView
{
    
    {
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, self.bounds.size.width, 30.f)];
        [_titleLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f]];
        [_titleLbl setText:@"To see more people you know, connect to"];
        [_titleLbl setTextAlignment:NSTextAlignmentCenter];
        [_contentView addSubview:_titleLbl];
        [_titleLbl setTextColor:[UIColor colorWithValue:150.0]];
    }
    
    
    
    int count = _mediaList.count;
    CGFloat mediaItemsOccupingWidth = count*_mediaItemSize.width + (count -1)*_freeSpace;
    CGFloat availWidth = self.bounds.size.width;
    CGFloat x = availWidth/2 - mediaItemsOccupingWidth/2, y = 30.f;
    
    for (int i=0; i<count; i++)
    {
        NSDictionary *item = _mediaList[i];
        
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, _mediaItemSize.width, _mediaItemSize.height)];
        [_contentView addSubview:button];
        [button setTag:i];
        [button addTarget:self action:@selector(mediaItemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:item[@"ImageNormal"]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:item[@"ImageSelected"]] forState:UIControlStateSelected];
        [button setSelected:[item[@"Selected"] integerValue]];
        x = x  + _mediaItemSize.width + _freeSpace;
    }
}

-(void)mediaItemSelected:(UIButton *)sender
{
    sender.selected = YES;
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(mediaItemSelected:)])
    {
        [self.delegate socailMediaDidSelectedItemAtIndex:[sender tag]];
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
