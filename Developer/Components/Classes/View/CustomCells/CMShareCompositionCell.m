//
//  CMShareCompositionCell.m
//  Composition
//
//  Created by Describe Administrator on 29/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "CMShareCompositionCell.h"
#import "DPost.h"
#import "DPostBodyView.h"

@interface CMShareCompositionCell ()<DPostBodyViewDelegate>
{
    UITapGestureRecognizer *tapGesture;
    DPostBodyView *_postBodyView;
}


@end

@implementation CMShareCompositionCell

@synthesize postImage = _postImage;






- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withPostImage:(DPostImage *)postImage
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code...
        _postImage = postImage;
        [self createPostBodyView];
        
    }
    return self;
}

-(void)createPostBodyView
{
    if(_postBodyView == nil)
        
    {
        _postBodyView =  [[DPostBodyView alloc] initWithFrame:CGRectMake(0,0,320,320) withPostImage:_postImage];
        [_postBodyView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_postBodyView];
    }
    [_postBodyView setDelegate:self];
    [_postBodyView setPostImage:_postImage];
}

- (void)awakeFromNib
{
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapActionPerformed:)];
    [self.contentView addGestureRecognizer:tapGesture];
    
}

-(void)setPostImage:(DPostImage *)postImage
{
    _postImage = postImage;
    [self createPostBodyView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)tapActionPerformed:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(compositionCellIsTapped)]) {
        [self.delegate compositionCellIsTapped];
    }
}


-(void)postBodyViewDidTapOnImage:(DPostBodyView *)bodyView
{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(compositionCellIsTapped)])
    {
        [_delegate compositionCellIsTapped];
    }
}

@end
