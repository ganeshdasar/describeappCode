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
        if (notificationDict[@"notificationId"] && [NotificationModel isValidValue:notificationDict[@"notificationId"]]) {
            self.notificationId = notificationDict[@"notificationId"];
        }
        
        if (notificationDict[@"notificationType"] && [NotificationModel isValidValue:notificationDict[@"notificationType"]]) {
            self.notificationType = [notificationDict[@"notificationType"] integerValue];
        }
        
        if (notificationDict[@"imageUrlString"] && [NotificationModel isValidValue:notificationDict[@"imageUrlString"]]) {
            self.imageUrlString = notificationDict[@"imageUrlString"];
        }
        
        if (notificationDict[@"fromUserId"] && [NotificationModel isValidValue:notificationDict[@"fromUserId"]]) {
            self.fromUserId = notificationDict[@"fromUserId"];
        }
        
        if (notificationDict[@"postId"] && [NotificationModel isValidValue:notificationDict[@"postId"]]) {
            self.postId = notificationDict[@"postId"];
        }
        
        if (notificationDict[@"fromUserName"] && [NotificationModel isValidValue:notificationDict[@"fromUserName"]]) {
            self.fromUserName = notificationDict[@"fromUserName"];
        }
        
        if (notificationDict[@"socialName"] && [NotificationModel isValidValue:notificationDict[@"socialName"]]) {
            self.socialName = notificationDict[@"socialName"];
        }
        
        if (notificationDict[@"frndSocialName"] && [NotificationModel isValidValue:notificationDict[@"frndSocialName"]]) {
            self.frndSocialName = notificationDict[@"frndSocialName"];
        }
        
        if (notificationDict[@"similarCount"] && [NotificationModel isValidValue:notificationDict[@"similarCount"]]) {
            self.similarCount = notificationDict[@"similarCount"];
        }
        
        if (notificationDict[@"similarData"] && [NotificationModel isValidValue:notificationDict[@"similarData"]]) {
            NSArray *jsonXmlArray = notificationDict[@"similarData"];
            self.similarData = [[NSMutableArray alloc] initWithCapacity:jsonXmlArray.count];
            for(int i = 0; i < jsonXmlArray.count; i++) {
                NotificationModel *model = [[NotificationModel alloc] initWithDictionary:jsonXmlArray[i]];
                [self.similarData addObject:model];
                model = nil;
            }
        }
        
        if (notificationDict[@"timeStamp"] && [NotificationModel isValidValue:notificationDict[@"timeStamp"]]) {
            self.timeStamp = notificationDict[@"timeStamp"];
        }
        
        if (notificationDict[@"serverTimeStamp"] && [NotificationModel isValidValue:notificationDict[@"serverTimeStamp"]]) {
            self.serverTimeStamp = notificationDict[@"serverTimeStamp"];
        }
        
        if (notificationDict[@"readStatus"] && [NotificationModel isValidValue:notificationDict[@"readStatus"]]) {
            self.readStatus = [notificationDict[@"readStatus"] boolValue];
        }
    }
    
    return self;
}

+ (BOOL)isValidValue:(id)value
{
    if([value isKindOfClass:[NSNull class]] || value == [NSNull null] || ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"<null>"]) || ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"(null)"])) {
        return NO;
    }
    else{
        return YES;
    }
}

@end
