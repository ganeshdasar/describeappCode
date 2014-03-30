//
//  DPost.h
//  Describe
//
//  Created by LaxmiGopal on 13/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DUser.h"

typedef enum post_type
{
    DPostTypeNone = -1,
    DpostTypePost = 0,
    DpostTypePrompter = 1
    
}DpostType;

#define POST_RIGHT_SWIPE_GESTURE_NOTIFICATION_KEY       @"RightSwipeGesture"
#define POST_MORE_BUTTON_NOTIFICATION_KEY               @"MoreEventAction"
#define POST_LIKES_BUTTON_NOTIFICATION_KEY              @"CommentLikes"
#define POST_COMMENT_BUTTON_NOTIFICATION_KEY            @"Comment"



@class DPostImage, DPostAttachments;
@interface DPost : NSObject
@property(nonatomic, assign)DpostType type;
@property(nonatomic, strong)NSString *postId;
@property(nonatomic, strong)DUser *user;
@property(nonatomic, strong)DPostImage *imagePost;
@property(nonatomic, strong)DPostAttachments *attachements;
@property(nonatomic, strong)NSArray *prompters;
@property(nonatomic, strong)NSString *elapsedTime;
@end



@class DPostVideo;
@interface DPostImage : NSObject

@property(nonatomic, strong)NSString *postId;
@property(nonatomic, strong)NSString *userId;
@property(nonatomic, strong)NSArray  *durationList;
@property(nonatomic, strong)NSString *numberOfImages;
@property(nonatomic, strong)NSArray *images;

@property(nonatomic, strong)DPostVideo *video;

@end



@interface DPostVideo : NSObject

@property(nonatomic, strong)NSString *postId;
@property(nonatomic, strong)NSString *userId;
@property(nonatomic, strong)NSString *url;
@property(nonatomic, strong)NSString *duration;

@end


@interface DPostAttachments : NSObject

@property(nonatomic, strong)NSString *postId;
@property(nonatomic, strong)NSArray *tagsList;
@property(nonatomic, assign)NSInteger likeRating;//Value from 0 to 3, where 0 is none.
@property(nonatomic, assign)NSInteger numberOfLikes;
@property(nonatomic, assign)NSInteger numberOfComments;

@end


@interface DPostTag : NSObject


@property(nonatomic, strong)NSString *tagId;
@property(nonatomic, strong)NSString *tagName;
@property(nonatomic, strong)NSString *postedByUserId;


@end


@interface DPrompterProfile : NSObject

@property(nonatomic, strong)NSString *profilePromterImageName;
@end
