//
//  DConversation.h
//  Describe
//
//  Created by LaxmiGopal on 31/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ConversationViewType
{
    DConversationTypeNone       = 0,
    DConversationTypeComment    = 1,
    DConversationTypeLike       = 2,
    DConversationTypeCurrentUser= 3
}ConversationType;



@interface DConversation : NSObject

@property(nonatomic, strong)NSString *postId;
@property(nonatomic, strong)NSString *userId;
@property(nonatomic, strong)NSString *username;
@property(nonatomic, strong)NSString *profilePic;
@property(nonatomic, strong)NSString *comment;
@property(nonatomic, assign)NSInteger numberOfLikes;
@property(nonatomic, strong)NSString *elapsedTime;

@property(nonatomic, assign)BOOL showFullConversation;
@property(nonatomic, assign)BOOL showAllLikes;
@property(nonatomic, assign)ConversationType type;

/*@property(nonatomic, strong)NSString *authUserUID;
 @property(nonatomic, strong)NSString *comment;
 @property(nonatomic, assign)NSInteger likeCount;
 @property(nonatomic, strong)NSString *postUID;
 @property(nonatomic, strong)NSString *conversationID;
 @property(nonatomic, strong)NSString *conversationMadeTime;
 @property(nonatomic, assign)ConversationType conversationType;
 @property(nonatomic, strong)NSString *conversationUserID;
 @property(nonatomic, strong)NSString *conversationUserProfilePicture;
 @property (nonatomic, strong) NSString * conversationUsername;*/

@end
