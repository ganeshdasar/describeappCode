//
//  UsersModel.h
//  Composition
//
//  Created by Describe Administrator on 01/03/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseModel.h"

@interface UsersModel : DatabaseModel

@property (nonatomic, strong) NSNumber *userID;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSNumber *dobDate;
@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic, strong) NSString *profileImageName;
@property (nonatomic, strong) NSString *canvasImageName;
@property (nonatomic, strong) NSString *snippetImageName;
@property (nonatomic, strong) NSString *snippetPosition;
@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic, strong) NSString *biodata;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSNumber *likesCount;
@property (nonatomic, strong) NSNumber *commentsCount;
@property (nonatomic, strong) NSNumber *postCount;
@property (nonatomic, strong) NSNumber *followingCount;
@property (nonatomic, strong) NSNumber *followerCount;
@property (nonatomic, assign) BOOL followingStatus;
@property (nonatomic, assign) BOOL blockedStatus;
@property (nonatomic, assign) BOOL isLoggedInUser;
@property (nonatomic,assign)  BOOL isInvitation;

- (id)initWithDictionary:(NSDictionary *)userDict;

@end
