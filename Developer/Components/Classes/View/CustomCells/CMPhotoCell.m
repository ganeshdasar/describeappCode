//
//  CMPhotoCell.m
//  Composition
//
//  Created by Describe Administrator on 18/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "CMPhotoCell.h"

@implementation CMPhotoCell

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
