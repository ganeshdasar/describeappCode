//
//  DUserData.h
//  Describe
//
//  Created by NuncSys on 26/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DUserData : UIView
@property (nonatomic,retain) NSString * userName;
@property (nonatomic,retain) NSString * subTitle;
@property (nonatomic,retain) NSString * imageUrl;

@end
@interface SearchPeopleData : NSString
{
    
}
@property (nonatomic,retain) NSString * followingStatus;
@property (nonatomic,retain) NSString * profileUserCity;
@property (nonatomic ,retain) NSString *gateWayToken;
@property (nonatomic ,retain) NSString *gateWayType;
@property (nonatomic,retain) NSString * profileUserEmail;
@property (nonatomic,retain) NSString * profileUserFullName;
@property (nonatomic,retain) NSString * profileUserProfilePicture;
@property (nonatomic,retain) NSString * profileUserUID;
@property (nonatomic,retain) NSString * profileUserName;
@property (nonatomic,retain) NSString * userActCout;
@property (nonatomic,retain) NSString * proximity;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end


@interface ModelData : NSObject{
}
@property (nonatomic,strong) NSString * userId;
@property (nonatomic,strong)NSString * userPic;
@end


/*                FollowingStatus = 1;
 ProfileUserCity = "";
 ProfileUserEmail = "shekaranumalla@gmail.com5";
 ProfileUserFullName = "shekar anumalla";
 ProfileUserProfilePicture = "http://mirusstudent.com/service/postimages/no_image.png";
 ProfileUserUID = 5;
 ProfileUsername = shekar5;
 UserActCount = 1019;
 proximity = 1;
 */