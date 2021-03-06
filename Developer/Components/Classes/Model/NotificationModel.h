//
//  NotificationModel.h
//  Composition
//
//  Created by Describe Administrator on 17/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kNotificationTypeComment = 0,
    kNotificationTypeLike,
    kNotificationTypeFollowing,
    kNotificationTypeFBFriendJoined,
    kNotificationTypeMentionedInCommment,
    kNotificationTypeGPFriendsJoined,
} NotificationType;

@interface NotificationModel : NSObject

@property (nonatomic, strong) NSNumber *notificationId;
@property (nonatomic, assign) NotificationType notificationType;
@property (nonatomic, strong) NSString *imageUrlString;
@property (nonatomic, strong) NSNumber *fromUserId;
@property (nonatomic, strong) NSNumber *postId;
@property (nonatomic, strong) NSString *fromUserName;
@property (nonatomic, strong) NSString *socialName;
@property (nonatomic, strong) NSString *frndSocialName;
@property (nonatomic, strong) NSNumber *similarCount;
@property (nonatomic, strong) NSMutableArray *similarData;
@property (nonatomic, strong) NSNumber *timeStamp;
@property (nonatomic, strong) NSNumber *serverTimeStamp;
@property (nonatomic, assign) BOOL readStatus;

@property (assign) NSInteger pageNumber;
@property (assign) BOOL shouldLoadNextPage;
@property (nonatomic, strong) NSNumber *pageLoadNotificationId;

- (id)initWithDictionary:(NSDictionary *)notificationDict;
+ (BOOL)isValidValue:(id)value;

@end
