//
//  DPromterProfileView.m
//  Describe
//
//  Created by LaxmiGopal on 22/02/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DPromterProfileView.h"
#import "DPost.h"

@interface DPromterProfileView ()
{
    UIImageView      *_prompterImageView;
    DPrompterProfile    *_promterProfile;
}
@end

@implementation DPromterProfileView

- (id)initWithFrame:(CGRect)frame withPrompterImage:(DPrompterProfile *)prompterImage
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code...
        _promterProfile = prompterImage;
        [self designPrompterImage];
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

-(void)designPrompterImage
{
    _prompterImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [_prompterImageView setImage:[UIImage imageNamed:_promterProfile.profilePromterImageName]];
    [self addSubview:_prompterImageView];
}


@end
