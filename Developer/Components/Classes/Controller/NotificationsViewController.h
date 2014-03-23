//
//  NotificationsViewController.h
//  Composition
//
//  Created by Describe Administrator on 17/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotifcationsCell.h"

@interface NotificationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NotificationsCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *notificationTableview;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *emptyMsgLabel;

- (IBAction)refreshNotificationData:(id)sender;
- (IBAction)showMenuOptions:(id)sender;

@end
