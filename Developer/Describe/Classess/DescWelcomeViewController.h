//
//  DescWelcomeViewController.h
//  Describe
//
//  Created by NuncSys on 30/12/13.
//  Copyright (c) 2013 App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+DesColors.h"
#import "DescAddpeopleViewController.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <FacebookSDK/FacebookSDK.h>
#import "DESSettingsViewController.h"
@class DESAppDelegate;

//@class GPPSignInButton;
@class GTLServicePlus;
@class GTLQuery;
@class GTLPlusMoment;
@class GTLPlusPerson;
@class GTLPlusPersonEmailsItem;
@class GTLAuthScopePlusUserinfoEmail;
@class GPPSignInButton;
@class DESocialConnectios;

@interface DescWelcomeViewController : UIViewController<UIActionSheetDelegate,GPPSignInDelegate>{
    DESAppDelegate *appDelegate;
    BOOL isClicked;
    
}

@property (weak, nonatomic) IBOutlet UIButton *signUpBtn;
@property (weak, nonatomic) IBOutlet UIButton *signInBtn;
@property (weak, nonatomic) IBOutlet UIButton *facebookBtn;
@property (weak, nonatomic) IBOutlet UIButton *emailBtn;
@property (weak, nonatomic) IBOutlet UIButton *googlePlusBtn;
@property (weak, nonatomic) IBOutlet UIImageView *welcomeScrennImage;

@property (nonatomic,strong) NSMutableArray * facebookFriendsListArray;
@property (nonatomic,strong) NSMutableDictionary *socialUserDataDic;
@property (nonatomic,strong) NSMutableArray * googlePlusFriendsListArry;

- (IBAction)SigninClicked:(id)sender;
- (IBAction)signUpTheUser:(id)sender;
- (IBAction)loginWithFacebookAction:(id)sender;
- (IBAction)loginWithgooglePlusAction:(id)sender;
- (IBAction)loginWithEmailAction:(id)sender;

@end
