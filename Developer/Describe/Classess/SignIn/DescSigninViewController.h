//
//  DescSigninViewController.h
//  Describe
//
//  Created by NuncSys on 30/12/13.
//  Copyright (c) 2013 App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DescBasicinfoViewController.h"
#import "DESAppDelegate.h"
typedef  enum{
    FAcebook_connected = 0,
    Googleplus_connected = 1
    
}socialConnections;
@interface DescSigninViewController : UIViewController<UIAlertViewDelegate>
{
    DESAppDelegate *appDelegate;
    socialConnections connection;


}
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImage;
@property (weak, nonatomic) IBOutlet UITextField *txtusername;
@property (weak, nonatomic) IBOutlet UITextField *txtpassword;
@property (weak, nonatomic) IBOutlet UIButton *btnforgetpwd;
@property (retain, nonatomic)NSMutableData* loginresponseData;
@property (retain, nonatomic)NSMutableArray *loginjsonArray;

- (IBAction)forgetpwdClicked:(id)sender;
-(void)goToNext:(id)sender;

@end
