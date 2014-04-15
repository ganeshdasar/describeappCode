//
//  DUserData.m
//  Describe
//
//  Created by NuncSys on 26/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DUserData.h"

@implementation DUserData
@synthesize userName;
@synthesize subTitle;
@synthesize imageUrl;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

@end
@implementation SearchPeopleData
@synthesize followingStatus;
@synthesize profileUserCity;
@synthesize profileUserEmail;
@synthesize profileUserFullName;
@synthesize profileUserName;
@synthesize profileUserProfilePicture;
@synthesize profileUserUID;
@synthesize proximity;
@synthesize gateWayToken;
@synthesize gateWayType;


@end


@implementation ModelData
@synthesize userId;
@synthesize userPic;
@end
