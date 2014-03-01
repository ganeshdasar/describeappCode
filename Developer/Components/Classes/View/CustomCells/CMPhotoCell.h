//
//  CMPhotoCell.h
//  Composition
//
//  Created by Describe Administrator on 18/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPhotoModel.h"

@interface CMPhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *capturedImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (nonatomic, strong) CMPhotoModel *dataModel;

@end
