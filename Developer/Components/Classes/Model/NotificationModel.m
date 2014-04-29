//
//  NotificationModel.m
//  Composition
//
//  Created by Describe Administrator on 17/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "NotificationModel.h"

@implementation NotificationModel

- (id)initWithDictionary:(NSDictionary *)notificationDict
{
    if (self = [super init]) {
        self.shouldLoadNextPage = NO;
        self.pageNumber = 0;
        self.pageLoadNotificationId = nil;
        
        if (notificationDict[NOTIFICATION_MODEL_KEY_NOTIFICATIONID] && [NotificationModel isValidValue:notificationDict[NOTIFICATION_MODEL_KEY_NOTIFICATIONID]]) {
            if([notificationDict[NOTIFICATION_MODEL_KEY_NOTIFICATIONID] isKindOfClass:[NSNumber class]]) {
                self.notificationId = notificationDict[NOTIFICATION_MODEL_KEY_NOTIFICATIONID];
            }
            else {
                self.notificationId = [NSNumber numberWithInteger:[notificationDict[NOTIFICATION_MODEL_KEY_NOTIFICATIONID] integerValue]];
            }
        }
        
        if (notificationDict[NOTIFICATION_MODEL_KEY_NOTIFICATIONTYPE] && [NotificationModel isValidValue:notificationDict[NOTIFICATION_MODEL_KEY_NOTIFICATIONTYPE]]) {
            self.notificationType = (NotificationType)[notificationDict[NOTIFICATION_MODEL_KEY_NOTIFICATIONTYPE] integerValue];
            
            if(self.notificationType == kNotificationTypeFBFriendJoined) {
                self.socialName = @"Facebook";
            }
            else if(self.notificationType == kNotificationTypeGPFriendsJoined) {
                self.socialName = @"Google+";
            }
            
        }
        
        if(self.notificationType == kNotificationTypeComment || self.notificationType == kNotificationTypeLike) {
            if (notificationDict[NOTIFICATION_MODEL_KEY_POSTIMAGE] && [NotificationModel isValidValue:notificationDict[NOTIFICATION_MODEL_KEY_POSTIMAGE]]) {
                self.imageUrlString = notificationDict[NOTIFICATION_MODEL_KEY_POSTIMAGE];
            }
        }
        else {
            if (notificationDict[NOTIFICATION_MODEL_KEY_IMAGEURL] && [NotificationModel isValidValue:notificationDict[NOTIFICATION_MODEL_KEY_IMAGEURL]]) {
                self.imageUrlString = notificationDict[NOTIFICATION_MODEL_KEY_IMAGEURL];
            }
        }
        
        if (notificationDict[NOTIFICATION_MODEL_KEY_PROFILEUSERUID] && [NotificationModel isValidValue:notificationDict[NOTIFICATION_MODEL_KEY_PROFILEUSERUID]]) {
            self.fromUserId = notificationDict[NOTIFICATION_MODEL_KEY_PROFILEUSERUID];
            if([notificationDict[NOTIFICATION_MODEL_KEY_PROFILEUSERUID] isKindOfClass:[NSNumber class]]) {
                self.fromUserId = notificationDict[NOTIFICATION_MODEL_KEY_PROFILEUSERUID];
            }
            else {
                self.fromUserId = [NSNumber numberWithInteger:[notificationDict[NOTIFICATION_MODEL_KEY_PROFILEUSERUID] integerValue]];
            }
        }
        
        if (notificationDict[NOTIFICATION_MODEL_KEY_POSTUID] && [NotificationModel isValidValue:notificationDict[NOTIFICATION_MODEL_KEY_POSTUID]]) {
            self.postId = notificationDict[NOTIFICATION_MODEL_KEY_POSTUID];
            if([notificationDict[NOTIFICATION_MODEL_KEY_POSTUID] isKindOfClass:[NSNumber class]]) {
                self.postId = notificationDict[NOTIFICATION_MODEL_KEY_POSTUID];
            }
            else {
                self.postId = [NSNumber numberWithInteger:[notificationDict[NOTIFICATION_MODEL_KEY_POSTUID] integerValue]];
            }
        }
        
        if (notificationDict[NOTIFICATION_MODEL_KEY_USERNAME] && [NotificationModel isValidValue:notificationDict[NOTIFICATION_MODEL_KEY_USERNAME]]) {
            self.fromUserName = notificationDict[NOTIFICATION_MODEL_KEY_USERNAME];
        }
        
//        if (notificationDict[@"socialName"] && [NotificationModel isValidValue:notificationDict[@"socialName"]]) {
//            self.socialName = notificationDict[@"socialName"];
//        }
//        
//        if (notificationDict[@"frndSocialName"] && [NotificationModel isValidValue:notificationDict[@"frndSocialName"]]) {
//            self.frndSocialName = notificationDict[@"frndSocialName"];
//        }
        
        if (notificationDict[NOTIFICATION_MODEL_KEY_TOTALCOUNT] && [NotificationModel isValidValue:notificationDict[NOTIFICATION_MODEL_KEY_TOTALCOUNT]]) {
            if([notificationDict[NOTIFICATION_MODEL_KEY_TOTALCOUNT] isKindOfClass:[NSNumber class]]) {
                self.similarCount = notificationDict[NOTIFICATION_MODEL_KEY_TOTALCOUNT];
            }
            else {
                self.similarCount = [NSNumber numberWithInteger:[notificationDict[NOTIFICATION_MODEL_KEY_TOTALCOUNT] integerValue]];
            }
            
            if([self.similarCount integerValue] > 1) {
                self.shouldLoadNextPage = YES;
            }
        }
        
//        if (notificationDict[@"similarData"] && [NotificationModel isValidValue:notificationDict[@"similarData"]]) {
//            NSArray *jsonXmlArray = notificationDict[@"similarData"];
//            self.similarData = [[NSMutableArray alloc] initWithCapacity:jsonXmlArray.count];
//            for(int i = 0; i < jsonXmlArray.count; i++) {
//                NotificationModel *model = [[NotificationModel alloc] initWithDictionary:jsonXmlArray[i]];
//                [self.similarData addObject:model];
//                model = nil;
//            }
//        }
        
        if (notificationDict[@"timeStamp"] && [NotificationModel isValidValue:notificationDict[@"timeStamp"]]) {
            self.timeStamp = notificationDict[@"timeStamp"];
        }
        
        if (notificationDict[@"serverTimeStamp"] && [NotificationModel isValidValue:notificationDict[@"serverTimeStamp"]]) {
            self.serverTimeStamp = notificationDict[@"serverTimeStamp"];
        }
        
        if (notificationDict[NOTIFICATION_MODEL_KEY_READSTATUS] && [NotificationModel isValidValue:notificationDict[NOTIFICATION_MODEL_KEY_READSTATUS]]) {
            self.readStatus = [notificationDict[NOTIFICATION_MODEL_KEY_READSTATUS] boolValue];
        }
    }
    
    return self;
}

+ (BOOL)isValidValue:(id)value
{
    if([value isKindOfClass:[NSNull class]] ||
       value == [NSNull null] ||
       ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"<null>"]) ||
       ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"(null)"]) ||
       ([value isKindOfClass:[NSString class]] && [value length] == 0))
    {
        return NO;
    }
    else{
        return YES;
    }
}

@end
