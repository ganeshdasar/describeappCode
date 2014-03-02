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
#define FRAME CGRectMake(0, 0, 320, 480);
#define BUTTONFRAME CGRectMake(121, 363, 70, 26);

@interface DescWelcomeViewController ()<MBProgressHUDDelegate,WSModelClassDelegate,UIAlertViewDelegate,DESocialConnectiosDelegate> {
    GPPSignIn *signIn;
    MBProgressHUD * HUD;
}
@end

@implementation DescWelcomeViewController
@synthesize facebookFriendsListArray;
@synthesize socialUserDataDic;
@synthesize googlePlusFriendsListArry;


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


#pragma mark Life Cycles -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    isClicked = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    self.facebookFriendsListArray = [[NSMutableArray alloc]init];
    self.socialUserDataDic = [[NSMutableDictionary alloc]init];
    self.googlePlusFriendsListArry = [[NSMutableArray alloc]init];
    if (isiPhone5)
    {
        // this is iphone 4 inch
        self.welcomeScrennImage.image = [UIImage imageNamed:@"bg_wc_4in.png"];
        self.facebookBtn.frame = BUTTONFRAME;
        self.twitterBtn.frame = BUTTONFRAME;
        self.googlePlusBtn.frame = BUTTONFRAME;
        self.emailBtn.frame = BUTTONFRAME;
    }
    else
    {
        self.welcomeScrennImage.frame = FRAME;
        self.welcomeScrennImage.image = [UIImage imageNamed:@"bg_wc_3.5in.png"];
        
        
        //Iphone  3.5 inch
    }
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [HUD hide:YES];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor headerColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_topbar.png"] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationController.navigationBar.translucent = NO;
    
}

#pragma mark Event Actions -

- (IBAction)basicInfoAction:(id)sender
{
    
    DescBasicinfoViewController * basic = [[DescBasicinfoViewController alloc]initWithNibName:@"DescBasicinfoViewController" bundle:Nil];
    [self.navigationController pushViewController:basic animated:YES];
    return;
    
    DescAddpeopleViewController * addPeople = [[DescAddpeopleViewController alloc]initWithNibName:@"DescAddpeopleViewController" bundle:Nil];
    [self.navigationController pushViewController:addPeople animated:YES];
    
}

- (IBAction)SigninClicked:(id)sender
{
    
    DescSigninViewController * signin = [[DescSigninViewController alloc]initWithNibName:@"DescSigninViewController" bundle:Nil];
    [self.navigationController pushViewController:signin animated:NO];
}
-(void)buttonHidderAction:(BOOL)inHidden
{
    self.twitterBtn.hidden = inHidden;
    self.facebookBtn.hidden = inHidden;
    self.googlePlusBtn.hidden = inHidden;
    self.emailBtn.hidden = inHidden;
}
- (IBAction)signUpTheUser:(id)sender
{
    if (!isClicked) {
        self.twitterBtn.frame = BUTTONFRAME;
        self.facebookBtn.frame = BUTTONFRAME;
        self.googlePlusBtn.frame = BUTTONFRAME;
        self.emailBtn.frame = BUTTONFRAME;
        [self buttonHidderAction:NO];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration: 1.0];
        self.twitterBtn.frame = CGRectMake(125, 388, 70, 26);
        self.facebookBtn.frame =CGRectMake(125, 316, 70, 26);
        self.googlePlusBtn.frame = CGRectMake(125, 352, 70, 26);;
        self.emailBtn.frame = CGRectMake(125, 424, 70, 26);
        self.signUpBtn.frame = CGRectMake(110, 270, 100, 36);
        self.signInBtn.frame = CGRectMake(110, 490, 100, 36);
        [UIView commitAnimations];
        isClicked = YES;
    }
    
}

- (IBAction)addPeople:(id)sender
{
    DescAddpeopleViewController * addPeople = [[DescAddpeopleViewController alloc]initWithNibName:@"DescAddpeopleViewController" bundle:Nil];
    [self.navigationController pushViewController:addPeople animated:YES];
}

- (IBAction)goToSetting:(id)sender
{
    DESSettingsViewController * setting = [[DESSettingsViewController alloc]initWithNibName:@"DESSettingsViewController" bundle:nil];
    [self.navigationController pushViewController:setting animated:YES];
}

#pragma mark Social Network integration

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
        self.facebookFriendsListArray = inFriendsList;
        [dataClass checkTheSocialIDwithDescriveServerCheckType:@"FB" andCheckValue:[responseDict valueForKey:@"id"]];
        
    }else if (delegate.isGooglePlus){
        self.googlePlusFriendsListArry = inFriendsList;
        [dataClass checkTheSocialIDwithDescriveServerCheckType:@"GPLUS" andCheckValue:[responseDict valueForKey:@"id"]];
        
    }
    
}

- (void)chekTheExistingUser:(NSDictionary *)responseDict error:(NSError *)error
{
    
    DESAppDelegate * delegate = (DESAppDelegate*)[UIApplication sharedApplication ].delegate;
    
    if ([[[responseDict valueForKeyPath:@"DataTable.UserData.Msg"]objectAtIndex:0] isEqualToString:@"TRUE"]) {
        [HUD hide:YES];
        
        DescSignupViewController * signUpView = [[DescSignupViewController alloc]initWithNibName:@"DescSignupViewController" bundle:Nil];
        
        if (delegate.isFacebook) {
            signUpView.userDataDic =  self.socialUserDataDic;
            signUpView.socialUserFriendsList = self.facebookFriendsListArray;
            [self.navigationController pushViewController:signUpView animated:NO];
            
        }else if (delegate.isGooglePlus){
            signUpView.userDataDic =  self.socialUserDataDic;
            signUpView.socialUserFriendsList = self.googlePlusFriendsListArry;
            [self.navigationController pushViewController:signUpView animated:NO];
        }
        
    }else{
        if (delegate.isFacebook) {
            [self showAlert:@"Describe" message:@"Sorry, this Facebook account is already associated with another Describe Identity" tag:100];
            
        }else if (delegate.isGooglePlus){
            [self showAlert:@"Describe" message:@"Sorry, this Google+ account is already associated with another Describe Identity" tag:100];
            
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
    DescSigninViewController * signInView = [[DescSigninViewController alloc]initWithNibName:@"DescSigninViewController" bundle:Nil];
    [self.navigationController pushViewController:signInView animated:NO];
}

#pragma mark googlePlusintegration
- (IBAction)loginWithgooglePlusAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"googlePlusButtonClicked" object:nil];
    [[DESocialConnectios sharedInstance] googlePlusSignIn];
    [DESocialConnectios sharedInstance].delegate = self;
    [self showLoadView];
    
}

- (IBAction)loginWithEmailAction:(id)sender
{
    DescSignupViewController * signUpView = [[DescSignupViewController alloc]initWithNibName:@"DescSignupViewController" bundle:Nil];
    [self.navigationController pushViewController:signUpView animated:NO];
}

-(void)showLoadView
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
        NSLog(@"Received error %@", error);
    } else {
        
    }
}

- (void)chekInterConnectionMessage
{
    ///Something's wrong with the network, attempting to reconnect.
}


@end
