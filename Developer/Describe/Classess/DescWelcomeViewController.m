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
#import "DESAnimation.h"

#define FRAME CGRectMake(0, 0, 320, 480);
#define BUTTONFRAME CGRectMake(125, CGRectGetHeight([[UIScreen mainScreen] bounds])*SingUpButtonClosePersentage, 70, 26);

#define FaceBookButtonPersentage 316.0f/568.0f
#define GooglePlusButtonPersentage 352.f/568.0f
#define EmailButtonPersentage 388.f/568.0f
#define SingUpButtonClosePersentage 337.f/568.0f
#define SignInButtonClosePersentage 393.f/568.0f

#define SingUpButtonOpenPersentage 454.f/568.0f
#define SignInButtonOpenPersentage 270.f/568.0f

#define FACEBOOK_BOUNCEOUT_KEYPATH                  @"FacebookBounceOut"
#define GOOGLEPLUS_BOUNCEOUT_KEYPATH                @"GoogleBounceOut"
#define EMAIL_BOUNCEOUT_KEYPATH                     @"EmailBounceOut"
#define SIGNUP_BOUNCEOUT_KEYPATH                    @"SignUpBounceOut"
#define SIGNIN_BOUNCEOUT_KEYPATH                    @"SignInBounceOut"

#define FACEBOOK_BOUNCEIN_KEYPATH                   @"FacebookBounceIn"
#define GOOGLEPLUS_BOUNCEIN_KEYPATH                 @"GoogleBounceIn"
#define EMAIL_BOUNCEIN_KEYPATH                      @"EmailBounceIn"


@interface DescWelcomeViewController ()<MBProgressHUDDelegate,WSModelClassDelegate,UIAlertViewDelegate,DESocialConnectiosDelegate>
{
    MBProgressHUD * HUD;
    DPostsViewController *_postViewController;
}

@end

@implementation DescWelcomeViewController
@synthesize facebookFriendsListArray;
@synthesize socialUserDataDic;
@synthesize googlePlusFriendsListArry;


- (BOOL)checkTheSessionId
{
    NSMutableDictionary *dic = (NSMutableDictionary*)[[NSUserDefaults standardUserDefaults]valueForKey:USERSAVING_DATA_KEY];
    NSDictionary*dataDic = [dic valueForKeyPath:@"ResponseData.DataTable.UserData"][0];
    if (!dataDic) {
        dataDic =  [dic valueForKeyPath:@"DataTable.UserData"][0];

    }
    if (dataDic[USER_MODAL_KEY_UID]) {
        UsersModel *userModelObj = [[UsersModel alloc] initWithDictionary:dataDic];
        [WSModelClasses sharedHandler].loggedInUserModel = [[UsersModel alloc]init];
        [[WSModelClasses sharedHandler]updateTheuserModelObject:userModelObj];
        return YES;
    }
    return NO;
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
    [super viewDidLoad];

    self.facebookFriendsListArray = [[NSMutableArray alloc]init];
    self.socialUserDataDic = [[NSMutableDictionary alloc]init];
    self.googlePlusFriendsListArry = [[NSMutableArray alloc]init];
    [self setUpThePosttionOfbuttonsFrame];
    
    if (isiPhone5) {
        // this is iphone 4 inch
        self.welcomeScrennImage.image = [UIImage imageNamed:@"bg_wc_4in.png"];
    }
    else {
//        self.welcomeScrennImage.frame = FRAME;
        self.welcomeScrennImage.image = [UIImage imageNamed:@"bg_wc_3.5in.png"];
        //Iphone  3.5 inch
    }
   // [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.view.backgroundColor = [UIColor whiteColor];
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewWillAppear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor headerColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_topbar.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationController.navigationBar.translucent = NO;

    if([self checkTheSessionId]) {
    [self showNextScreen:(NSMutableDictionary*)[[NSUserDefaults standardUserDefaults]valueForKey:USERSAVING_DATA_KEY]];
    }
    if (self.facebookBtn.isHidden == YES) {
        CGRect windowFrame  = [[UIScreen mainScreen] bounds];
        self.signUpBtn.frame = CGRectMake(110, CGRectGetHeight(windowFrame)*SingUpButtonClosePersentage, 100, 36);
        self.signInBtn.frame = CGRectMake(110, CGRectGetHeight(windowFrame)*SignInButtonClosePersentage, 100, 36);
        
        self.facebookBtn.frame = BUTTONFRAME;
        self.googlePlusBtn.frame = BUTTONFRAME;
        self.emailBtn.frame = BUTTONFRAME;
    }

}


- (void)saveUserDataInUserDefaults:(NSDictionary*)dictionary
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:dictionary forKeyPath:USERSAVING_DATA_KEY];
    [[NSUserDefaults standardUserDefaults]synchronize ];
}

- (void)showNextScreen:(NSDictionary*)userData
{
    
    if(![self checkTheuserBasicInfoDataEmptyOrNot:userData])//Check for the condition where the basic info line is empty or not.
    {
        DescBasicinfoViewController * basicInfo = [[DescBasicinfoViewController alloc]initWithNibName:@"DescBasicinfoViewController" bundle:nil];
        [self.navigationController pushViewController:basicInfo animated:YES];
    }
    else
    {
        if([self checkTheUserFollowingCount:userData])//is he is following any one or not?
        {
            DPostsViewController *postViewController = [[DPostsViewController alloc] initWithNibName:@"DPostsViewController" bundle:nil];
            [postViewController loadFeedDetails];
            [self.navigationController pushViewController:postViewController animated:YES];
        }
        else
        {
            DescAddpeopleViewController * addPeople = [[DescAddpeopleViewController alloc]initWithNibName:@"DescAddpeopleViewController" bundle:nil];
            [self.navigationController pushViewController:addPeople animated:YES];
            
        }
    }
}

- (BOOL)checkTheuserBasicInfoDataEmptyOrNot:(NSDictionary*)userData
{
    NSString * city = [[userData valueForKeyPath:@"ResponseData.DataTable.UserData.UserCity"]objectAtIndex:0];
    NSString * imagedata = [[userData valueForKeyPath:@"ResponseData.DataTable.UserData.UserProfilePicture"]objectAtIndex:0];
    NSString * userBio = [[userData valueForKeyPath:@"ResponseData.DataTable.UserData.UserBiodata"]objectAtIndex:0];
    NSString * birthday = [[userData valueForKeyPath:@"ResponseData.DataTable.UserData.UserDOB"]objectAtIndex:0];
    if ([city isEqualToString:@""] || [imagedata isEqualToString:@""] ||[userBio isEqualToString:@""] ||[birthday isEqualToString:@""] )
        return NO;
    return YES;
    
}

- (BOOL)checkTheUserFollowingCount:(NSDictionary*)userData
{
    NSString * followingCount = [[userData valueForKeyPath:@"ResponseData.DataTable.UserData.UserFollowingCount"]objectAtIndex:0];
    if (!followingCount) {
      followingCount = [[userData valueForKeyPath:@"DataTable.UserData.UserFollowingCount"]objectAtIndex:0];
    }
    if ([followingCount isEqualToString:@"0"])
        return NO;
    return YES;
}

#pragma mark Event Actions -
- (IBAction)SigninClicked:(id)sender
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

- (IBAction)signUpTheUser:(id)sender
{
    if (self.facebookBtn.isHidden == YES) {
        [self buttonHidderAction:NO];
        self.facebookBtn.alpha = 0.0;
        self.googlePlusBtn.alpha = 0.0;
        self.emailBtn.alpha = 0.0;
//        self.facebookBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
//        self.googlePlusBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
//        self.emailBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
        
        [UIView animateWithDuration:0.5
                         animations:^{
//                             self.facebookBtn.alpha = 1.0;
//                             self.googlePlusBtn.alpha = 1.0;
//                             self.emailBtn.alpha = 1.0;
                             
                             CGRect windowFrame  = [[UIScreen mainScreen] bounds];
                             self.signUpBtn.frame = CGRectMake(110, CGRectGetHeight(windowFrame)*SignInButtonOpenPersentage, 100, 36);
                             
                             self.facebookBtn.frame = CGRectMake(125, CGRectGetMinY(self.signUpBtn.frame) + 46.0, 70, 26);
                             self.googlePlusBtn.frame = CGRectMake(125, CGRectGetMinY(self.facebookBtn.frame) + 36.0, 70, 26);;
                             self.emailBtn.frame = CGRectMake(125, CGRectGetMinY(self.googlePlusBtn.frame) + 36.0, 70, 26);
                             
                             self.signInBtn.frame = CGRectMake(110, CGRectGetMinY(self.emailBtn.frame) + 66.0, 100, 36);
                         }
                         completion:nil];
        
        [self bounceOutAnimation:self.facebookBtn withDuration:0.25 withKeypath:FACEBOOK_BOUNCEOUT_KEYPATH withFadeAniamtion:YES];
        [self bounceOutAnimation:self.googlePlusBtn withDuration:0.2 withKeypath:GOOGLEPLUS_BOUNCEOUT_KEYPATH withFadeAniamtion:YES];
        [self bounceOutAnimation:self.emailBtn withDuration:0.3 withKeypath:EMAIL_BOUNCEOUT_KEYPATH withFadeAniamtion:YES];
        
        [self bounceOutAnimation:self.signUpBtn withDuration:0.5 withKeypath:SIGNUP_BOUNCEOUT_KEYPATH withFadeAniamtion:NO];
        [self bounceOutAnimation:self.signInBtn withDuration:0.5 withKeypath:SIGNIN_BOUNCEOUT_KEYPATH withFadeAniamtion:NO];
    }
    else {
        [UIView animateWithDuration:0.3
                              delay:0.2
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.facebookBtn.frame = BUTTONFRAME;
                             self.googlePlusBtn.frame = BUTTONFRAME;
                             self.emailBtn.frame = BUTTONFRAME;

                             CGRect windowFrame  = [[UIScreen mainScreen] bounds];
                             self.signUpBtn.frame = CGRectMake(110, CGRectGetHeight(windowFrame)*SingUpButtonClosePersentage, 100, 36);
                             self.signInBtn.frame = CGRectMake(110, CGRectGetHeight(windowFrame)*SignInButtonClosePersentage, 100, 36);
                         }
                         completion:^(BOOL finished) {
                             [self buttonHidderAction:YES];
                         }];
        
        [self bounceInAnimation:self.facebookBtn withDuration:0.05 withKeyPath:FACEBOOK_BOUNCEIN_KEYPATH];
        [self bounceInAnimation:self.googlePlusBtn withDuration:0.1 withKeyPath:GOOGLEPLUS_BOUNCEIN_KEYPATH];
        [self bounceInAnimation:self.emailBtn withDuration:0.0 withKeyPath:EMAIL_BOUNCEIN_KEYPATH];
        
        [self bounceOutAnimation:self.signUpBtn withDuration:0.6 withKeypath:SIGNUP_BOUNCEOUT_KEYPATH withFadeAniamtion:NO];
        [self bounceOutAnimation:self.signInBtn withDuration:0.6 withKeypath:SIGNIN_BOUNCEOUT_KEYPATH withFadeAniamtion:NO];
    }
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
//    if(anim == [self.facebookBtn.layer animationForKey:FACEBOOK_BOUNCEIN_KEYPATH]) {
//        
//    }
    
}

- (void)showAlphaOfView:(UIView *)aView
{
    aView.alpha = 1.0;
}

- (void)bounceOutAnimation:(UIView *)aView withDuration:(NSTimeInterval)time withKeypath:(NSString *)animationKeyPath withFadeAniamtion:(BOOL)doFade
{
    CFTimeInterval startTime = 0;
    
    CABasicAnimation *scaleAnimation1 = [DESAnimation scaleFrom:1.0 to:0.9 duration:time beginTime:startTime];// [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    startTime += time;
    
    CABasicAnimation *fadeAnimation = [DESAnimation fadeFrom:0.0 to:1.0 duration:0.25 beginTime:startTime];//[CABasicAnimation animationWithKeyPath:@"opacity"];
    [self performSelector:@selector(showAlphaOfView:) withObject:aView afterDelay:startTime+0.25];
    
    CABasicAnimation *scaleAnimation2 = [DESAnimation scaleFrom:0.9 to:1.1 duration:0.25 beginTime:startTime];
    startTime += 0.25;
    
    CABasicAnimation *scaleAniamtion3 = [DESAnimation scaleFrom:1.1 to:0.95 duration:0.15 beginTime:startTime];
    startTime += 0.15;
    
    CABasicAnimation *scaleAnimation4 = [DESAnimation scaleFrom:0.95 to:1.05 duration:0.12 beginTime:startTime];
    startTime += 0.12;
    
    CABasicAnimation *scaleAnimation5 = [DESAnimation scaleFrom:1.05 to:1.0 duration:0.1 beginTime:startTime];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = startTime + 0.1;
    animationGroup.delegate = self;
    if(doFade == YES) {
        animationGroup.animations = [NSArray arrayWithObjects:scaleAnimation1, fadeAnimation, scaleAnimation2, scaleAniamtion3, scaleAnimation4, scaleAnimation5, nil];
    }
    else {
        animationGroup.animations = [NSArray arrayWithObjects:scaleAnimation1, scaleAnimation2, scaleAniamtion3, scaleAnimation4, scaleAnimation5, nil];
    }
    
    if([aView.layer animationForKey:animationKeyPath]) {
        [aView.layer removeAnimationForKey:animationKeyPath];
    }
    
    [aView.layer addAnimation:animationGroup forKey:animationKeyPath];

    return;
    [UIView animateWithDuration:time
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         aView.transform = CGAffineTransformMakeScale(0.8, 0.8);
                     }
                     completion:^(BOOL finished) {
                         [DESAnimation scaleView:aView
                                         toScale:1.2
                                           alpha:1.0
                                    withDuration:0.25
                                      completion:^(BOOL success) {
                                          [DESAnimation scaleView:aView
                                                          toScale:0.95
                                                            alpha:1.0
                                                     withDuration:0.15
                                                       completion:^(BOOL success) {
                                                           [DESAnimation scaleView:aView
                                                                           toScale:1.05
                                                                             alpha:1.0
                                                                      withDuration:0.12
                                                                        completion:^(BOOL success) {
                                                                            [DESAnimation scaleView:aView
                                                                                            toScale:1.0
                                                                                              alpha:1.0
                                                                                       withDuration:0.1
                                                                                         completion:^(BOOL success) {
                                                                                             
                                                                                         }];
                                                                        }];
                                                       }];
                                      }];
                     }];
}

- (void)bounceInAnimation:(UIView *)aView withDuration:(NSTimeInterval)time withKeyPath:(NSString *)animationKeypath
{
    CFTimeInterval startTime = 0;
    startTime += time;
    
    CABasicAnimation *scaleAnimation5 = [DESAnimation scaleFrom:1.0 to:1.05 duration:0.1 beginTime:startTime];
    startTime += 0.1;
    
    CABasicAnimation *scaleAnimation4 = [DESAnimation scaleFrom:1.05 to:0.95 duration:0.12 beginTime:startTime];
    startTime += 0.12;
    
    CABasicAnimation *scaleAniamtion3 = [DESAnimation scaleFrom:0.95 to:1.1 duration:0.15 beginTime:startTime];
    startTime += 0.15;
    
    CABasicAnimation *scaleAnimation2 = [DESAnimation scaleFrom:1.1 to:0.9 duration:0.25 beginTime:startTime];
    
    CABasicAnimation *fadeAnimation = [DESAnimation fadeFrom:1.0 to:0.0 duration:startTime+0.25 beginTime:time];//[CABasicAnimation animationWithKeyPath:@"opacity"];
    [self performSelector:@selector(hideAlphaOfView:) withObject:aView afterDelay:startTime+0.25];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = startTime + 0.1;
    animationGroup.delegate = self;
    animationGroup.animations = [NSArray arrayWithObjects:fadeAnimation, scaleAnimation5, scaleAnimation4, scaleAniamtion3, scaleAnimation2, nil];
    
    if([aView.layer animationForKey:animationKeypath]) {
        [aView.layer removeAnimationForKey:animationKeypath];
    }
    
    [aView.layer addAnimation:animationGroup forKey:animationKeypath];
}

- (void)hideAlphaOfView:(UIView *)aView
{
    aView.alpha = 0.0;
}

- (void)setUpThePosttionOfbuttonsFrame
{
    CGRect windowFrame  = [[UIScreen mainScreen] bounds];
    self.signUpBtn.frame = CGRectMake(110, CGRectGetHeight(windowFrame)*SingUpButtonClosePersentage, 100, 36);
    self.signInBtn.frame = CGRectMake(110, CGRectGetHeight(windowFrame)*SignInButtonClosePersentage, 100, 36);

    
}
#pragma mark FacebookIntegration
- (IBAction)loginWithFacebookAction:(id)sender
{
    [self showLoadView];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"faceBookButtonClicked" object:nil];
    [[DESocialConnectios sharedInstance] facebookSignIn];
    [DESocialConnectios sharedInstance].delegate =self;
}

#pragma mark socialConnection Delegate methods
- (void)googlePlusResponce:(NSMutableDictionary *)responseDict andFriendsList:(NSMutableArray*)inFriendsList
{
    if(responseDict == nil) {
        [HUD hide:YES];
        return;
    }
    
    WSModelClasses * dataClass = [WSModelClasses sharedHandler];
    dataClass.delegate = self;
    self.socialUserDataDic = responseDict;
    DESAppDelegate * delegate = (DESAppDelegate*)[UIApplication sharedApplication ].delegate;
    if (delegate.isFacebook) {
        [dataClass checkTheSocialIDwithDescriveServerCheckType:@"fb" andCheckValue:[responseDict valueForKey:@"id"]];
    }
    else if (delegate.isGooglePlus){
        [dataClass checkTheSocialIDwithDescriveServerCheckType:@"gplus" andCheckValue:[responseDict valueForKey:@"id"]];
    }
}

- (void)saveTheUserDetailsOfFacebook:(NSDictionary*)inDic
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    [dic setValue: [inDic valueForKey:@"email"] forKey:USER_MODAL_KEY_EMAIL];
    [dic setValue: [inDic valueForKey:@"first_name"] forKey:USER_MODAL_KEY_USERNAME];
    [dic setValue: [inDic valueForKey:@"last_name"] forKey:USER_MODAL_KEY_FULLNAME];
    
    if ([[inDic valueForKey:@"gender"]isEqualToString:@"male"]) {
        [dic setValue:[NSNumber numberWithInteger:1] forKey:USER_MODAL_KEY_GENDER];
    }
    else{
        [dic setValue:[NSNumber numberWithInteger:0] forKey:USER_MODAL_KEY_GENDER];
    }
    
    [dic setValue: [inDic valueForKey:@"location.name"] forKey:USER_MODAL_KEY_CITY];
    [dic setValue: [NSString convertThesocialNetworkDateToepochtime:[dic valueForKey:@"birthday"]] forKey:USER_MODAL_KEY_DOB];
    [dic setValue: [inDic valueForKeyPath:@"picture.data.url"] forKey:USER_MODAL_KEY_PROFILEPIC];
    
    UsersModel * data = [[UsersModel alloc]initWithDictionary:dic];
    [WSModelClasses sharedHandler].loggedInUserModel = data;
}

- (void)saveTheUserDetailsOfGooglePlus:(NSDictionary *)inDic
{

    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    [dic setValue: [inDic valueForKey:@"email"] forKey:USER_MODAL_KEY_EMAIL];
    [dic setValue: [inDic valueForKey:@"displayName"] forKey:USER_MODAL_KEY_USERNAME];
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
        }
        else if (delegate.isGooglePlus){
            signUpView.userDataDic =  self.socialUserDataDic;
            [self saveTheUserDetailsOfGooglePlus:self.socialUserDataDic];
            [self.navigationController pushViewController:signUpView animated:NO];
        }
    }
    else{
        if (delegate.isFacebook) {
            NSString * messageStr = [NSString stringWithFormat:@"This Facebook account is already associated with another Describe Identity. Do you want to sign in as \"%@\" instead.",[[responseDict valueForKeyPath:@"DataTable.UserData.Username"]objectAtIndex:0]];
            [self showAlert:@"Describe" message:messageStr  tag:100];
        }
        else if (delegate.isGooglePlus){
            NSString * messageStr = [NSString stringWithFormat:@"This Google+ account is already associated with another Describe Identity. Do you want to sign in as \"%@\" instead.",[[responseDict valueForKeyPath:@"DataTable.UserData.Username"]objectAtIndex:0]];
            [self showAlert:@"Describe" message:messageStr tag:100];
        }
    }
}


#pragma mark Alerview And delegate methods
- (void)showAlert:(NSString*)title message:(NSString*)inMessage tag:(int)InAlertTag
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:title message:inMessage delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag =  InAlertTag;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            DESAppDelegate * delegate = (DESAppDelegate*)[UIApplication sharedApplication ].delegate;
            if (delegate.isFacebook){
                [WSModelClasses sharedHandler].delegate = self;
                [[WSModelClasses sharedHandler]signInWithSocialNetwork:@"fb" andGateWauTokern:[[NSUserDefaults standardUserDefaults]valueForKey:FACEBOK_ID]];
            }
            else if (delegate.isGooglePlus) {
                [WSModelClasses sharedHandler].delegate = self;
                [[WSModelClasses sharedHandler]signInWithSocialNetwork:@"gplus" andGateWauTokern:[[NSUserDefaults standardUserDefaults]valueForKey:Google_plus_ID]];
            }
        }
            break;
        case 1:
        {
            [[DESocialConnectios sharedInstance] logoutGooglePlus];
            [[DESocialConnectios sharedInstance] logoutFacebook];
            break;
        }
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
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"googlePlusButtonClicked" object:nil];
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
