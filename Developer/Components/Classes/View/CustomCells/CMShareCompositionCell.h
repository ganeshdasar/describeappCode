//
//  CMShareCompositionCell.h
//  Composition
//
//  Created by Describe Administrator on 29/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CMShareCompositionCellDelegate ;


@class DPostBodyView, DPost, DPostImage;
@interface CMShareCompositionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *compositionImageView;
@property (weak, nonatomic) IBOutlet UIView *compositionContainerView;
@property (weak, nonatomic) id <CMShareCompositionCellDelegate> delegate;
@property (strong, nonatomic) DPostImage *postImage;
@property (weak, nonatomic) IBOutlet UIView *postBodyContainerView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withPostImage:(DPostImage *)postImage;

@end



@protocol CMShareCompositionCellDelegate <NSObject>


@optional
- (void)compositionCellIsTapped;

@end