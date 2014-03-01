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
#import <Twitter/Twitter.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "MBProgressHUD.h"
#import "WSModelClasses.h"
#import "DUserData.h"

#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE
#define FRAME CGRectMake(0, 0, 320, 480);
#define BUTTONFRAME CGRectMake(121, 363, 70, 26);

@interface DescWelcomeViewController ()<MBProgressHUDDelegate,WSModelClassDelegate,UIAlertViewDelegate> {
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

- (void)googlePlusSignIn {
    GPPSignIn *signedIn = [GPPSignIn sharedInstance];
    signedIn.delegate = self;
    signedIn.shouldFetchGoogleUserEmail = YES;
    signedIn.shouldFetchGooglePlusUser = YES;
    signedIn.clientID = kClientID;
    signedIn.scopes = [NSArray arrayWithObjects:kGTLAuthScopePlusLogin,kGTLAuthScopePlusMe,nil];
    signedIn.actions = [NSArray arrayWithObjects:@"http://schemas.google.com/ListenActivity",nil];
    [signedIn authenticate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [HUD hide:YES];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor headerColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_topbar.png"] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationController.navigationBar.translucent = NO;
    
}

- (IBAction)basicInfoAction:(id)sender {
    
    DescBasicinfoViewController * basic = [[DescBasicinfoViewController alloc]initWithNibName:@"DescBasicinfoViewController" bundle:Nil];
    [self.navigationController pushViewController:basic animated:YES];
    return;

    DescAddpeopleViewController * addPeople = [[DescAddpeopleViewController alloc]initWithNibName:@"DescAddpeopleViewController" bundle:Nil];
    [self.navigationController pushViewController:addPeople animated:YES];
 
    
    
    
    
}

- (IBAction)SigninClicked:(id)sender {
    
    DescSigninViewController * signin = [[DescSigninViewController alloc]initWithNibName:@"DescSigninViewController" bundle:Nil];
    [self.navigationController pushViewController:signin animated:NO];
}
-(void)buttonHidderAction:(BOOL)inHidden{
    self.twitterBtn.hidden = inHidden;
    self.facebookBtn.hidden = inHidden;
    self.googlePlusBtn.hidden = inHidden;
    self.emailBtn.hidden = inHidden;

}
- (IBAction)signUpTheUser:(id)sender {
    
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


- (IBAction)addPeople:(id)sender {
    
    DescAddpeopleViewController * addPeople = [[DescAddpeopleViewController alloc]initWithNibName:@"DescAddpeopleViewController" bundle:Nil];
    [self.navigationController pushViewController:addPeople animated:YES];
    
}
#pragma mark signUp Actions
#pragma mark Social Network integration
- (IBAction)loginWithTwitterAction:(id)sender {
    
  
}
#pragma mark FacebookIntegration
- (IBAction)loginWithFacebookAction:(id)sender {
   [self showLoadView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"faceBookButtonClicked" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getUserDetail)
                                                 name:@"getUserDetail"
                                               object:nil];
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        //,@"friends_birthday"
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info",@"user_photos",@"read_friendlists",@"email",@"user_birthday",@"friends_about_me"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             DESAppDelegate* appdelegate =(DESAppDelegate*) [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appdelegate sessionStateChanged:session state:state error:error];
         }];
    }

    
    
}
-(void)getUserDetail
{
    //NSLog (@"Successfully received the test notification!");
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me?fields=email,birthday,last_name,first_name,gender,location,picture"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  NSLog(@"%@",result);
                                  [self checkTheuserSocialIdWithDescriveServer:result];
                                  [FBRequestConnection startWithGraphPath:@"/me/friends?fields=id"
                                                        completionHandler:^(FBRequestConnection *connection1, id result1, NSError *error1) {
                                                            if (!error1){
                                                                NSLog(@"friends list%@",result1);
                                                                
                                                                for (NSDictionary* datadic in [result1 valueForKey:@"data"]) {
                                                                    ModelData * data = [[ModelData alloc]init];
                                                                    data.userId =[datadic valueForKey:@"id"];
                                                                    [self.facebookFriendsListArray addObject:data ];
                                                                }
                                                            } else {
                                                                // An error occurred, we need to handle the error
                                                                // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                                                NSLog(@"%@",[NSString stringWithFormat:@"error %@", error1.description]);
                                                            }
                                                        }];
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"%@",[NSString stringWithFormat:@"error %@", error.description]);
                              }
                          }];
}
- (IBAction)goToSetting:(id)sender {
    DESSettingsViewController * setting = [[DESSettingsViewController alloc]initWithNibName:@"DESSettingsViewController" bundle:nil];
    [self.navigationController pushViewController:setting animated:YES];
    
    
    
}

-(void)checkTheuserSocialIdWithDescriveServer:(NSMutableDictionary*)inUserDataDic{
    
    WSModelClasses * dataClass = [WSModelClasses sharedHandler];
    dataClass.delegate =self;
    self.socialUserDataDic = inUserDataDic;
    DESAppDelegate * delegate = (DESAppDelegate*)[UIApplication sharedApplication ].delegate;
    if (delegate.isFacebook) {
        [dataClass checkTheSocialIDwithDescriveServerCheckType:@"FB" andCheckValue:[inUserDataDic valueForKey:@"id"]];
        
    }else if (delegate.isGooglePlus){
        [dataClass checkTheSocialIDwithDescriveServerCheckType:@"GPLUS" andCheckValue:[inUserDataDic valueForKey:@"id"]];
        
    }
    
}
- (void)chekTheExistingUser:(NSDictionary *)responseDict error:(NSError *)error{
    
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
-(void)showAlert:(NSString*)title message:(NSString*)inMessage tag:(int)InAlertTag{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:title message:inMessage delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag =  InAlertTag;
    [alert show];
    
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    DescSigninViewController * signInView = [[DescSigninViewController alloc]initWithNibName:@"DescSigninViewController" bundle:Nil];
    [self.navigationController pushViewController:signInView animated:NO];
    
}
#pragma mark googlePlusintegration
- (IBAction)loginWithgooglePlusAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"googlePlusButtonClicked" object:nil];
    [self googlePlusSignIn];
    [self showLoadView];

}

- (IBAction)loginWithEmailAction:(id)sender {
    DescSignupViewController * signUpView = [[DescSignupViewController alloc]initWithNibName:@"DescSignupViewController" bundle:Nil];
    [self.navigationController pushViewController:signUpView animated:NO];
    
    
}
-(void)showLoadView{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Loading";
    [HUD show:YES];
}
#pragma mark ActionSheet Delegate Methods

// Google Plus
#pragma mark Get the Friends List from google plus
- (GTLServicePlus *)plusService {
    static GTLServicePlus* service = nil;
    if (!service) {
        service = [[GTLServicePlus alloc] init];
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.retryEnabled = YES;
        // Have the service object set tickets to automatically fetch additional
        // pages of feeds when the feed's maxResult value is less than the number
        // of items in the feed
        service.shouldFetchNextPages = YES;
    }
    return service;
}


/// risperidone,risperdal


- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    //    NSLog(@"Received error %@ and auth object %@",error, auth);
    NSMutableDictionary * dataDic = [[NSMutableDictionary alloc]init];
    
    if (error) {
        NSLog(@"Error is %@",[error description]);
    } else {
        __block NSArray* peoplesList;
        
        GTLPlusPerson *person = [GPPSignIn sharedInstance].googlePlusUser;
        [dataDic setObject:person.name forKey:@"name"];
        [dataDic setObject:auth.userEmail forKey:@"email"];
        [dataDic setObject:person.identifier forKey:@"id"];
        [dataDic setObject:person.displayName forKey:@"displayName"];
        [dataDic setObject:person.url forKey:@"url"];
        [dataDic setObject:person.gender forKey:@"gender"];
        
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        plusService.retryEnabled = YES;
        [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
        GTLQueryPlus *query =
        [GTLQueryPlus queryForPeopleListWithUserId:@"me"
                                        collection:kGTLPlusCollectionVisible];
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPeopleFeed *peopleFeed,
                                    NSError *error) {
                    if (error) {
                        GTMLoggerError(@"Error: %@", error);
                        return ;
                    } else {
                        peoplesList = peopleFeed.items;
                    }
                    for (GTLPlusPerson *person  in peoplesList) {
                        NSLog(@"Person name is %@", person.displayName);
                        NSLog(@"Person ID is %@", person.identifier);
                        NSLog(@"Person Image is %@", person.image);
                        ModelData * data = [[ModelData alloc]init];
                        data.userId = person.identifier;
                        [self.googlePlusFriendsListArry addObject:data];
                    }
                    
                }];
    }
    
    [self checkTheuserSocialIdWithDescriveServer:dataDic];
    
}
- (void)didDisconnectWithError:(NSError *)error {
    if (error) {
        NSLog(@"Received error %@", error);
    } else {
     
    }
}
-(void)chekInterConnectionMessage{
    
    ///Something's wrong with the network, attempting to reconnect.
    
    
}


@end
