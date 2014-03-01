//
//  DESPushNotificationControl.h
//  Describe
//
//  Created by NuncSys on 16/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHeaderView.h"
@interface DESPushNotificationControl : UIViewController
@property (weak, nonatomic) IBOutlet DHeaderView *_HeaderView;
@property (weak, nonatomic) IBOutlet UITableView *pustNotificationTbl;

@property (weak, nonatomic) IBOutlet UIImageView *backGroundImg;
@end
