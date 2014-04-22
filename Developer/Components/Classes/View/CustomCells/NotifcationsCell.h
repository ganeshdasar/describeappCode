//
//  NotifcationsCell.h
//  Composition
//
//  Created by Describe Administrator on 17/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationModel.h"

@protocol NotificationsCellDelegate <NSObject>

@optional
- (void)notificationTitleSelectedAtIndexpath:(NSIndexPath *)indexpath;
- (void)notificationImageSelectedAtIndexpath:(NSIndexPath *)indexpath;
- (void)notificationFriendsJoinedSelectedAtIndexpath:(NSIndexPath *)indexpath;

@end

@interface NotifcationsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *notificationImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLable;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsTypeLabel;

@property (weak, nonatomic) id <NotificationsCellDelegate> delegate;

- (void)setData:(NotificationModel *)dataModel;

- (IBAction)notificationImageTapped:(id)sender;
- (IBAction)notificationTitleLabelTapped:(id)sender;
- (IBAction)friendsLabelTapped:(id)sender;

@end
