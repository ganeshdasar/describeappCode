//
//  DesPeopleSortingComponent.h
//  Describe
//
//  Created by NuncSys on 11/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DesPeopleSortingComponent : NSObject


+(NSMutableArray*)facebookFriendsListFiltring:(NSMutableArray*)inListFromServer andLocalfacebookFriendsList:(NSMutableArray*)inLocalFriendsLsit;

+(NSString *)appendingTheFriendsIDsWithComma:(NSMutableArray*)inFriensList;

@end
