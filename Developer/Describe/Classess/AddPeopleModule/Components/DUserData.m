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


-(id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if(self)
    {
        //custom initialize the data...
        self.followingStatus = [dictionary valueForKeyPath:@"FollowingStatus"];
        self.profileUserCity = [dictionary valueForKeyPath:@"ProfileUserCity"];
        self.profileUserEmail = [dictionary valueForKeyPath:@"ProfileUserEmail"];
        self.profileUserFullName = [dictionary valueForKeyPath:@"ProfileUserFullName"];
        self.profileUserProfilePicture = [dictionary valueForKeyPath:@"ProfileUserProfilePicture"];
        self.profileUserUID = [dictionary valueForKeyPath:@"ProfileUserUID"];
        self.profileUserName = [dictionary valueForKeyPath:@"ProfileUsername"];
        self.userActCout = [dictionary valueForKeyPath:@"UserActCount"];
        self.proximity = [dictionary valueForKeyPath:@"proximity"];
        
    }
    
    return self;
}


@end


@implementation ModelData
@synthesize userId;
@synthesize userPic;
@end
