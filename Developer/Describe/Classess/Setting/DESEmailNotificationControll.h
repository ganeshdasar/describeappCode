//
//  DESEmailNotificationControll.h
//  Describe
//
//  Created by NuncSys on 16/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHeaderView.h"
typedef enum emailNotification
{
    Likes_onMyPost= 0,
    comments_onMyPost,
    mymentions_inComment,
    Not_follower,
    activity_updates=10,
    importent_announcements=11
}emialNotificationtype;
@interface DESEmailNotificationControll : UIViewController
@property (weak, nonatomic) IBOutlet DHeaderView *_HeaderView;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImg;
@property (weak, nonatomic) IBOutlet UITableView *emailNotificationTbl;
@property (nonatomic,assign) BOOL isLikesOnMyPost;
@property (nonatomic,assign) BOOL isCommentsOnMypost;
@property (nonatomic,assign) BOOL ismymentionInComment;
@property (nonatomic,assign) BOOL isNotfollower;
@property (nonatomic,assign) BOOL isActivityUpdates;
@property (nonatomic,assign) BOOL isImportentAnnouncements;

@property (nonatomic,assign) BOOL isChangeTheSwitch;
@end
