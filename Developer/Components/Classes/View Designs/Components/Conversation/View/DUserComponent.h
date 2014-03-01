//
//  DUserComponent.h
//  Describe
//
//  Created by NuncSys on 26/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DUserData.h"
@interface DUserComponent : UIView
@property (nonatomic,retain) DUserData *_userData;
@property (nonatomic,retain) SearchPeopleData* data;
@property (nonatomic,strong) UIImageView * thumbnailImg;
-(id)initWithFrame:(CGRect)frame AndUserData:(SearchPeopleData*)inUserData;
-(void)createUserComponent;
@end
