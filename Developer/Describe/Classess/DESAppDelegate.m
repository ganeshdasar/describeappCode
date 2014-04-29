//
//  DESAppDelegate.m
//  Describe
//
//  Created by NuncSys on 30/12/13.
//  Copyright (c) 2013 App. All rights reserved.
//

#import "DESAppDelegate.h"
#import "DescBasicinfoViewController.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "WSModelClasses.h"
@implementation DESAppDelegate
@synthesize isFacebook;
@synthesize isGooglePlus;
@synthesize isTwitter;

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GPPSignIn sharedInstance].clientID = kClientID;
    [GPPDeepLink setDelegate:self];
    [GPPDeepLink readDeepLinkAfterInstall];
    
//    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitle:@""];
//    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setImage:[UIImage imageNamed:@"btn_cancel.png"]];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    DescWelcomeViewController * welComeView = [[DescWelcomeViewController alloc]initWithNibName:@"DescWelcomeViewController" bundle:Nil];
    
    [self declareNotificationsForSocialNetwork];
    UINavigationController * welcomeNav = [[UINavigationController alloc]initWithRootViewController:welComeView];
    
//    //****** temp code remove when no need ********//
//    DescBasicinfoViewController *binfo = [[DescBasicinfoViewController alloc] initWithNibName:@"DescBasicinfoViewController" bundle:nil];
//    welcomeNav = [[UINavigationController alloc]initWithRootViewController:binfo];
//    //*********** End for temp code ***************//
    
    
    
    [welcomeNav setNavigationBarHidden:YES];
    [self.window setRootViewController:welcomeNav];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
     /*if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        NSLog(@"Found a cached session");
        // If there's one, just open the session silently, without showing the user the login UI
       [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
        
        // If there's no cached session, we will show a login button
    }*/
    return YES;
}

- (void)didReceiveDeepLink:(GPPDeepLink *)deepLink
{
    
}

- (void)declareNotificationsForSocialNetwork{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookButtonClicked:)
                                                 name:@"faceBookButtonClicked"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(googlePlusButtonClicked:)
                                                 name:@"googlePlusButtonClicked"
                                               object:nil];

}

- (void)removeNotficationForSocialNetwork
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)facebookButtonClicked:(NSNotificationCenter*)inNotification
{
    self.isFacebook = YES;
    self.isGooglePlus = NO;
}

- (void)googlePlusButtonClicked:(NSNotificationCenter*)inNotification
{
    self.isFacebook = NO;
    self.isGooglePlus = YES;
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    if (self.isFacebook) {
        return [FBSession.activeSession handleOpenURL:url];

    }else if (self.isGooglePlus){
        return [GPPURLHandler handleURL:url
                      sourceApplication:sourceApplication
                             annotation:annotation];
    }else if (self.isTwitter){
        
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self removeNotficationForSocialNetwork];
}

#pragma mark Facebook Integration
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");

        // Show the user the logged-out UI
    }
    
    // Handle errors
    if (error) {
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                return;
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getUserDetail" object:nil];
    // Set the button title as "Log out"
}

@end
