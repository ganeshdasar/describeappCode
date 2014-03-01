//
//  DESAppDelegate.h
//  Describe
//
//  Created by NuncSys on 30/12/13.
//  Copyright (c) 2013 App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DescWelcomeViewController.h"
#import "Accounts/Accounts.h"
#import <GooglePlus/GooglePlus.h>
#import <FacebookSDK/FacebookSDK.h>

@interface DESAppDelegate : UIResponder <UIApplicationDelegate,GPPDeepLinkDelegate>{
   
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,assign)     BOOL isFacebook;
@property (nonatomic,assign)     BOOL isGooglePlus;
@property (nonatomic,assign)     BOOL isTwitter;


- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)userLoggedIn;
-(void)declareNotificationsForSocialNetwork;
@end
