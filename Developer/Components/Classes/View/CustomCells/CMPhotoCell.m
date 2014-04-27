//
//  CMPhotoCell.m
//  Composition
//
//  Created by Describe Administrator on 18/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "CMPhotoCell.h"
#import "UIColor+DesColors.h"
@implementation CMPhotoCell
-(void)awakeFromNib
{
    self.capturedImageView.layer.borderWidth = 0.5;
    self.capturedImageView.layer.borderColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0].CGColor;
}

- (void)setDataModel:(CMPhotoModel *)dataModel
{
    _dataModel = dataModel;
    self.numberLabel.text = [NSString stringWithFormat:@"%d", _dataModel.indexNumber];
    if(_dataModel.originalImage) {
        self.capturedImageView.image = _dataModel.editedImage;
    }
    else {
        self.capturedImageView.image = nil;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self.capturedImageView setAlpha:highlighted? 0.75 : 1.0];
    [self.numberLabel setAlpha:highlighted? 0.75 : 1.0];
}

@end
