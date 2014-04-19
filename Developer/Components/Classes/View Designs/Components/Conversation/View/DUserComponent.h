//
//  DUserComponent.h
//  Describe
//
//  Created by NuncSys on 26/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DUserData.h"
#import "WSModelClasses.h"

@protocol DUserComponentDelegate;

@interface DUserComponent : UIView <WSModelClassDelegate>


@property (nonatomic, retain) DUserData *_userData;
@property (nonatomic, retain) SearchPeopleData* data;
@property (nonatomic, retain) UIButton * _followUnfollowBtn;
@property (nonatomic, strong) UIImageView * thumbnailImg;
@property (nonatomic, assign) id <DUserComponentDelegate> delegate;

- (id)initWithFrame:(CGRect)frame AndUserData:(SearchPeopleData*)inUserData;
- (void)createUserComponent;
- (void)updateContent:(SearchPeopleData *)userData;

@end


@protocol DUserComponentDelegate <NSObject>

@optional
- (void)statusChange;

@end