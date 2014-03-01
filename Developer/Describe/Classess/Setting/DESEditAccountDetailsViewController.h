//
//  DESEditAccountDetailsViewController.h
//  Describe
//
//  Created by NuncSys on 16/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DESecurityViewCnt.h"

typedef enum accountType
{
   DUserInformation = 0,
    DUserCity = 1,
    DUserBio = 2,
    DUserSecurity  = 3,
    DUserSignOut = 4,
    DUerNameTxt = 0,
    DUserGenderTxt = 1,
    DUserBirhDayTxt = 2,
    DMaleTag = 100,
    DdateTag = 101,
    DGenderLblTag = 200,
    DdateLblTag = 300
    

    
    
}editAccountTyopes;
@interface DESEditAccountDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *acountDetailsTableView;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImg;

@property (nonatomic, retain) UIPickerView *optionsPickerView;
@property (nonatomic, retain) UIActionSheet *pickerActionSheet;
@property (nonatomic, retain) NSMutableArray *optionsArr;

@property (nonatomic,strong) NSString * genderSting;

@property (nonatomic,strong) NSString * dateString;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end
