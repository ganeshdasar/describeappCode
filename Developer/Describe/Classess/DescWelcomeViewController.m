//
//  DescWelcomeViewController.m
//  Describe
//
//  Created by NuncSys on 30/12/13.
//  Copyright (c) 2013 App. All rights reserved.
//

#import "DescWelcomeViewController.h"
#import "DescSignupViewController.h"
#import "DescSigninViewController.h"
#import "DESAppDelegate.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "MBProgressHUD.h"
#import "WSModelClasses.h"
#import "DUserData.h"
#import "Constant.h"
#import "DESocialConnectios.h"
#import "UsersModel.h"
#import "NSString+DateConverter.h"
#import "DPostsViewController.h"

#import "ProfileViewController.h"

#define FRAME CGRectMake(0, 0, 320, 480);
#define BUTTONFRAME CGRectMake(121, CGRectGetHeight([[UIScreen mainScreen] bounds])-205.0, 70, 26);

@interface DescWelcomeViewController ()<MBProgressHUDDelegate,WSModelClassDelegate,UIAlertViewDelegate,DESocialConnectiosDelegate> {
    GPPSignIn *signIn;
    MBProgressHUD * HUD;
    
    DPostsViewController *_postViewController;
}
@end

@implementation DescWelcomeViewController
@synthesize facebookFriendsListArray;
@synthesize socialUserDataDic;
@synthesize googlePlusFriendsListArry;

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(BOOL)checkTheSessionId
{
    NSMutableDictionary *dic = (NSMutableDictionary*)[[NSUserDefaults standardUserDefaults]valueForKey:USERSAVING_DATA_KEY];
    NSDictionary*dataDic = [dic valueForKeyPath:@"ResponseData.DataTable.UserData"][0];
    if (dataDic[USER_MODAL_KEY_UID]) {
        UsersModel *userModelObj = [[UsersModel alloc] initWithDictionary:dataDic];
        [WSModelClasses sharedHandler].loggedInUserModel = [[UsersModel alloc]init];
        [[WSModelClasses sharedHandler]updateTheuserModelObject:userModelObj];
        return YES;
    }
    return NO;
}

#pragma mark Life Cycles -
-  (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}


-  (void)viewDidLoad
{
    [self setNeedsStatusBarAppearanceUpdate];
    self.facebookFriendsListArray = [[NSMutableArray alloc]init];
    self.socialUserDataDic = [[NSMutableDictionary alloc]init];
    self.googlePlusFriendsListArry = [[NSMutableArray alloc]init];
    
    self.facebookBtn.frame = BUTTONFRAME;
    self.googlePlusBtn.frame = BUTTONFRAME;
    self.emailBtn.frame = BUTTONFRAME;
    
    if (isiPhone5)
    {
        // this is iphone 4 inch
        self.welcomeScrennImage.image = [UIImage imageNamed:@"bg_wc_4in.png"];
    }
    else
    {
//        self.welcomeScrennImage.frame = FRAME;
        self.welcomeScrennImage.image = [UIImage imageNamed:@"bg_wc_3.5in.png"];
        //Iphone  3.5 inch
    }
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}



-  (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-  (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [HUD hide:YES];
    return;
    
    ProfileViewController *profile = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    [self.navigationController pushViewController:profile animated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor headerColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_topbar.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationController.navigationBar.translucent = NO;

    if([self checkTheSessionId])
    {
        _postViewController = [DPostsViewController sharedFeedController];
        [_postViewController loadFeedDetails];
        [self.navigationController pushViewController:_postViewController animated:YES];
    }

}


#pragma mark Event Actions -
-  (IBAction)SigninClicked:(id)sender
{
    DescSigninViewController * signin = [[DescSigninViewController alloc]initWithNibName:@"DescSigninViewController" bundle:Nil];
    [self.navigationController pushViewController:signin animated:NO];
}


- (void)buttonHidderAction:(BOOL)inHidden
{
    self.facebookBtn.hidden = inHidden;
    self.googlePlusBtn.hidden = inHidden;
    self.emailBtn.hidden = inHidden;
}


-  (IBAction)signUpTheUser:(id)sender
{
    if (self.facebookBtn.isHidden == YES) {
        [self buttonHidderAction:NO];
        
        [UIView animateWithDuration:1.0
                         animations:^{
                             self.facebookBtn.alpha = 1.0;
                             self.googlePlusBtn.alpha = 1.0;
                             self.emailBtn.alpha = 1.0;
                             
                             CGRect windowFrame  = [[UIScreen mainScreen] bounds];
                             
                             self.facebookBtn.frame = CGRectMake(125, CGRectGetHeight(windowFrame)-252.0, 70, 26);
                             self.googlePlusBtn.frame = CGRectMake(125, CGRectGetHeight(windowFrame)-216.0, 70, 26);;
                             self.emailBtn.frame = CGRectMake(125, CGRectGetHeight(windowFrame)-144.0, 70, 26);
                             self.signUpBtn.frame = CGRectMake(110, CGRectGetHeight(windowFrame)-298.0, 100, 36);
                             self.signInBtn.frame = CGRectMake(110, CGRectGetHeight(windowFrame)-78.0, 100, 36);
                         }
                         completion:nil];
    }
    else {
        [UIView animateWithDuration:1.0
                         animations:^{
                             self.facebookBtn.frame = BUTTONFRAME;
                             self.googlePlusBtn.frame = BUTTONFRAME;
                             self.emailBtn.frame = BUTTONFRAME;
                             
                             self.facebookBtn.alpha = 0.0;
                             self.googlePlusBtn.alpha = 0.0;
                             self.emailBtn.alpha = 0.0;
                             
                             CGRect windowFrame  = [[UIScreen mainScreen] bounds];
                             
                             self.signUpBtn.frame = CGRectMake(110, CGRectGetHeight(windowFrame)-232.0, 100, 36);
                             self.signInBtn.frame = CGRectMake(110, CGRectGetHeight(windowFrame)-175.0, 100, 36);
                         }
                         completion:^(BOOL finished) {
                             [self buttonHidderAction:YES];
                         }];
    }
    
}


#pragma mark FacebookIntegration
-  (IBAction)loginWithFacebookAction:(id)sender
{
    [self showLoadView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"faceBookButtonClicked" object:nil];
    [[DESocialConnectios sharedInstance] facebookSignIn];
    [DESocialConnectios sharedInstance].delegate =self;
}


#pragma mark socialConnection Delegate methods
-  (void)googlePlusResponce:(NSMutableDictionary *)responseDict andFriendsList:(NSMutableArray*)inFriendsList
{

    WSModelClasses * dataClass = [WSModelClasses sharedHandler];
    dataClass.delegate =self;
    self.socialUserDataDic = responseDict;
    DESAppDelegate * delegate = (DESAppDelegate*)[UIApplication sharedApplication ].delegate;
    if (delegate.isFacebook) {
        [dataClass checkTheSocialIDwithDescriveServerCheckType:@"fb" andCheckValue:[responseDict valueForKey:@"id"]];
    }else if (delegate.isGooglePlus){
        [dataClass checkTheSocialIDwithDescriveServerCheckType:@"gplus" andCheckValue:[responseDict valueForKey:@"id"]];
    }
}


-(void)saveTheUserDetailsOfFacebook:(NSDictionary*)inDic
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    [dic setValue: [inDic valueForKey:@"email"] forKey:USER_MODAL_KEY_EMAIL];
    [dic setValue: [inDic valueForKey:@"first_name"] forKey:USER_MODAL_KEY_USERNAME];
    [dic setValue: [inDic valueForKey:@"last_name"] forKey:USER_MODAL_KEY_FULLNAME];
    if ([[inDic valueForKey:@"gender"]isEqualToString:@"male"]) {
        [dic setValue:[NSNumber numberWithInteger:1] forKey:USER_MODAL_KEY_GENDER];
    }else{
        [dic setValue:[NSNumber numberWithInteger:0] forKey:USER_MODAL_KEY_GENDER];
    }
    [dic setValue: [inDic valueForKey:@"location.name"] forKey:USER_MODAL_KEY_CITY];
    [dic setValue: [NSString convertThesocialNetworkDateToepochtime:[dic valueForKey:@"birthday"]] forKey:USER_MODAL_KEY_DOB];
    [dic setValue: [inDic valueForKeyPath:@"picture.data.url"] forKey:USER_MODAL_KEY_PROFILEPIC];
    UsersModel * data = [[UsersModel alloc]initWithDictionary:dic];
    [WSModelClasses sharedHandler].loggedInUserModel = data;
    
}

-(void)saveTheUserDetailsOfGooglePlus:(NSDictionary *)inDic
{

    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    [dic setValue: [inDic valueForKey:@"email"] forKey:USER_MODAL_KEY_EMAIL];
    [dic setValue: [inDic valueForKey:@"name"] forKey:USER_MODAL_KEY_USERNAME];
    [dic setValue: [inDic valueForKey:@"displayName"] forKey:USER_MODAL_KEY_FULLNAME];
    if ([[inDic valueForKey:@"gender"]isEqualToString:@"male"]) {
        [dic setValue:[NSNumber numberWithInteger:1] forKey:USER_MODAL_KEY_GENDER];
    }else{
        [dic setValue:[NSNumber numberWithInteger:0] forKey:USER_MODAL_KEY_GENDER];
    }
    [dic setValue: [inDic valueForKey:@"city"] forKey:USER_MODAL_KEY_CITY];
    [dic setValue: [inDic valueForKey:@"dob"] forKey:USER_MODAL_KEY_DOB];
    [dic setValue: [inDic valueForKeyPath:@"url"] forKey:USER_MODAL_KEY_PROFILEPIC];
    UsersModel * data = [[UsersModel alloc]initWithDictionary:dic];
    [WSModelClasses sharedHandler].loggedInUserModel = data;
 
    
}
- (void)chekTheExistingUser:(NSDictionary *)responseDict error:(NSError *)error
{
    DESAppDelegate * delegate = (DESAppDelegate*)[UIApplication sharedApplication ].delegate;
    [HUD hide:YES];
    if ([[[responseDict valueForKeyPath:@"DataTable.UserData.Msg"]objectAtIndex:0] isEqualToString:@"TRUE"]) {
        DescSignupViewController * signUpView = [[DescSignupViewController alloc]initWithNibName:@"DescSignupViewController" bundle:Nil];
        if (delegate.isFacebook) {
            signUpView.userDataDic =  self.socialUserDataDic;
            [self saveTheUserDetailsOfFacebook:self.socialUserDataDic];
            [self.navigationController pushViewController:signUpView animated:NO];
        }else if (delegate.isGooglePlus){
            signUpView.userDataDic =  self.socialUserDataDic;
            [self saveTheUserDetailsOfGooglePlus:self.socialUserDataDic];
            [self.navigationController pushViewController:signUpView animated:NO];
        }
    }else{
        if (delegate.isFacebook) {
            NSString * messageStr = [NSString stringWithFormat:@"This Facebook account is already associated with another Describe Identity. Do you want to sign in as \"%@\" instead.",[[responseDict valueForKeyPath:@"DataTable.UserData.Username"]objectAtIndex:0]];
            [self showAlert:@"Describe" message:messageStr  tag:100];
        }else if (delegate.isGooglePlus){
            NSString * messageStr = [NSString stringWithFormat:@"This Google+ account is already associated with another Describe Identity. Do you want to sign in as \"%@\" instead.",[[responseDict valueForKeyPath:@"DataTable.UserData.Username"]objectAtIndex:0]];
            [self showAlert:@"Describe" message:messageStr tag:100];
        }
    }
}


#pragma mark Alerview And delegate methods
-(void)showAlert:(NSString*)title message:(NSString*)inMessage tag:(int)InAlertTag
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:title message:inMessage delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag =  InAlertTag;
    [alert show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:{
            DESAppDelegate * delegate = (DESAppDelegate*)[UIApplication sharedApplication ].delegate;
            if (delegate.isFacebook){
                [WSModelClasses sharedHandler].delegate = self;
                [[WSModelClasses sharedHandler]signInWithSocialNetwork:@"fb" andGateWauTokern:[[NSUserDefaults standardUserDefaults]valueForKey:FACEBOK_ID]];
                
            }else if (delegate.isGooglePlus){
                [WSModelClasses sharedHandler].delegate = self;
                [[WSModelClasses sharedHandler]signInWithSocialNetwork:@"gplus" andGateWauTokern:[[NSUserDefaults standardUserDefaults]valueForKey:Google_plus_ID]];
            }
        }
            break;
            case 1:
            
            break;
        default:
            break;
    }
}

- (void)didFinishWSConnectionWithResponse:(NSDictionary *)responseDict
{
    WebservicesType serviceType = (WebservicesType)[responseDict[WS_RESPONSEDICT_KEY_SERVICETYPE] integerValue];
    if(responseDict[WS_RESPONSEDICT_KEY_ERROR]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Describe", @"") message:NSLocalizedString(@"Error while communicating to server. Please try again later.", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [HUD hide:YES];
        return;
    }
    switch (serviceType) {
        case kWebserviesType_SignIn:
        {
            [HUD hide:YES];
            if ([[[responseDict valueForKeyPath:@"ResponseData.DataTable.UserData.Msg"]objectAtIndex:0] isEqualToString:@"TRUE"]) {
                [self gotoAddpeopleScreen];
            }else{
                
            }
            break;
        }
        default:
            break;
    }
}

-(void)gotoAddpeopleScreen
{
    DescAddpeopleViewController * addPeople = [[DescAddpeopleViewController alloc]initWithNibName:@"DescAddpeopleViewController" bundle:nil];
    [self.navigationController pushViewController:addPeople animated:YES];
    
}
#pragma mark googlePlusintegration
- (IBAction)loginWithgooglePlusAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"googlePlusButtonClicked" object:nil];
    [[DESocialConnectios sharedInstance] googlePlusSignIn];
    [DESocialConnectios sharedInstance].delegate = self;
    [self showLoadView];
}


-  (IBAction)loginWithEmailAction:(id)sender
{
    DescSignupViewController * signUpView = [[DescSignupViewController alloc]initWithNibName:@"DescSignupViewController" bundle:Nil];
    [self.navigationController pushViewController:signUpView animated:NO];
}


- (void)showLoadView
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Loading";
    [HUD show:YES];
}


#pragma mark ActionSheet Delegate Methods
-  (void)didDisconnectWithError:(NSError *)error
{
    if (error) {
    } else {
    }
}


-  (void)chekInterConnectionMessage
{
    ///Something's wrong with the network, attempting to reconnect.
}
@end
