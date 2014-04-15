//
//  DESSettingsViewController.h
//  Describe
//
//  Created by NuncSys on 21/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum types
{
    DSettingTypeNone = 5,
    DSettingTypeAccount = 0,
    DSettingSocialServices =1,
    DSettingNetwork=2,
    DSettingNotification = 3,
    wifi_setting = 0,
    cellular_netWork=1
    
} settingType;
@interface DESSettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImg;
@property (weak, nonatomic) IBOutlet UITableView *settingTableView;

@end
