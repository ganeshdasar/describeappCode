//
//  DESPushNotificationControl.h
//  Describe
//
//  Created by NuncSys on 16/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHeaderView.h"
typedef enum pushNotification
{
    likes_onMyPost=0,
    comments_onMypost,
    mymentions_incomment,
    not_follower
}notificationsType;
@interface DESPushNotificationControl : UIViewController{
   
}
@property (weak, nonatomic) IBOutlet DHeaderView *_HeaderView;
@property (weak, nonatomic) IBOutlet UITableView *pustNotificationTbl;

@property (weak, nonatomic) IBOutlet UIImageView *backGroundImg;
@property (nonatomic,assign) BOOL isLikesOnMyPost;
@property (nonatomic,assign) BOOL isCommentsOnMypost;
@property (nonatomic,assign) BOOL ismymentionInComment;
@property (nonatomic,assign) BOOL isNotfollower;
@property (nonatomic,assign) BOOL isChangeTheSwitch;


@end
