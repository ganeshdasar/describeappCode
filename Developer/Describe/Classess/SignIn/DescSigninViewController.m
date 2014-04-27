//
//  DescSigninViewController.m
//  Describe
//
//  Created by NuncSys on 30/12/13.
//  Copyright (c) 2013 App. All rights reserved.
//

#import "DescSigninViewController.h"
#import "DescResetpwdViewController.h"
#import "ConstantValues.h"
#import "DHeaderView.h"
#import "UIColor+DesColors.h"
#import "WSModelClasses.h"
#import "MBProgressHUD.h"
#import "Constant.h"
#import "DESocialConnectios.h"
#import "DPostsViewController.h"
#import "DAlertView.h"
#import "NSString+DateConverter.h"
#import "UIView+FindFirstResponder.h"
#import "DescSignupViewController.h"

#define ALERT_TAG_FACEBOOK      10
#define ALERT_TAG_GOOGLEPLUS    11

@interface DescSigninViewController ()<WSModelClassDelegate,DESocialConnectiosDelegate,MBProgressHUDDelegate>
{
    IBOutlet DHeaderView *_headerView;
    UIButton    *backButton,*nextButton;
    WSModelClasses * modelClass;
    MBProgressHUD *HUD;
}

@property (nonatomic, strong) NSMutableDictionary *socialDetailsDict;

@end

@implementation DescSigninViewController
@synthesize loginjsonArray,loginresponseData;
@synthesize txtusername,txtpassword;

- (UIStatusBarStyle)preferredStatusBarStyle
{
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
    [super viewDidLoad];

    // registering the self.view to resign keyboard upon singleTap anywhere on the view
    [self.view registerToResignKeyboard];
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self.txtusername becomeFirstResponder];
    self.navigationController.navigationBarHidden = YES;
    [self designHeaderView];
    [self setBackGroundimageView];
    [self intilizTextFieldColors];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textfieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)setBackGroundimageView
{
    if (isiPhone5) {
        self.backGroundImage.image = [UIImage imageNamed:@"bg_std_4in.png"];
    }
    else {
        self.backGroundImage.image = [UIImage imageNamed:@"bg_std_3.5in.png"];
    }
}

#pragma mark Design HeadeView
- (void)designHeaderView
{
    backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goToBack:) forControlEvents:UIControlEventTouchUpInside];
    nextButton = [[UIButton alloc] init];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_next.png"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(signIntoDescribeAction:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView designHeaderViewWithTitle:@"Sign in" andWithButtons:@[backButton]];
}

- (void)intilizTextFieldColors
{
    self.txtusername.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"username" attributes:@{NSForegroundColorAttributeName: [UIColor textPlaceholderColor]}];
    [self.txtusername setTextColor:[UIColor textFieldTextColor]];
    self.txtpassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"password" attributes:@{NSForegroundColorAttributeName: [UIColor textPlaceholderColor]}];
    [self.txtpassword setTextColor:[UIColor textFieldTextColor]];
}

- (void)goToBack:(id)sender
{
    [[DESocialConnectios sharedInstance] logoutFacebook];
    [[DESocialConnectios sharedInstance] logoutGooglePlus];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)signIntoDescribeAction:(id)sender
{
    signInType = SignInConnectionType_DescribeName;
    
    [self.txtusername resignFirstResponder];
    [self.txtpassword resignFirstResponder];
    
    if(([self.txtusername.text length]==0)) {
        [self showAlertWithTitle:NSLocalizedString(@"Validation", @"")
                         message:NSLocalizedString(@"Please enter your name.", @"")
                             tag:0
                        delegate:nil
               cancelButtonTitle:@"OK"
               otherButtonTitles:nil];
	}
	else if([self.txtpassword.text length]==0) {
        [self showAlertWithTitle:NSLocalizedString(@"Validation", @"")
                         message:NSLocalizedString(@"Please enter your password.", @"")
                             tag:0
                        delegate:nil
               cancelButtonTitle:@"OK"
               otherButtonTitles:nil];
	}
    else {
        modelClass = [WSModelClasses sharedHandler];
        modelClass.delegate  =self;
        [modelClass getSignInWithUsername:self.txtusername.text password:self.txtpassword.text];
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.labelText = @"Loading";
        [HUD show:YES];
    }
}

- (IBAction)signInWithFacebook:(id)sender
{
    signInType = SignInConnectionType_Facebook;
    [self showLoadView];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"faceBookButtonClicked" object:nil];
    [DESocialConnectios sharedInstance].delegate =self;
    [[DESocialConnectios sharedInstance] facebookSignIn];
}


- (IBAction)signInWithGooglePlus:(id)sender
{
    signInType = SignInConnectionType_GooglePlus;
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"googlePlusButtonClicked" object:nil];
    [DESocialConnectios sharedInstance].delegate = self;
    [[DESocialConnectios sharedInstance] googlePlusSignIn];
    [self showLoadView];
}

- (void)showLoadView
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Loading";
    [HUD show:YES];
}

#pragma mark signResponce delegate method
- (void)didFinishWSConnectionWithResponse:(NSDictionary *)responseDict
{
    WebservicesType serviceType = (WebservicesType)[responseDict[WS_RESPONSEDICT_KEY_SERVICETYPE] integerValue];
    if(responseDict[WS_RESPONSEDICT_KEY_ERROR]) {
        [self showAlertWithTitle:NSLocalizedString(@"Describe", @"")
                         message:NSLocalizedString(@"Error while communicating to server. Please try again later.", @"")
                             tag:0
                        delegate:nil
               cancelButtonTitle:@"OK"
               otherButtonTitles:nil];
        
        [HUD hide:YES];
        return;
    }
    switch (serviceType) {
        case kWebserviesType_SignIn:
        {
            [HUD hide:YES];
            if ([[[responseDict valueForKeyPath:@"ResponseData.DataTable.UserData.Msg"]objectAtIndex:0] isEqualToString:@"TRUE"]) {
                //Have to store these details in the shared holder to call/access them globally...
                [self saveUserDetails:responseDict];
                [self showNextScreen:responseDict];
            }
            else {
                if (signInType == SignInConnectionType_Facebook) {
                    [self showAlertWithTitle:NSLocalizedString(@"Validation", @"")
                                     message:NSLocalizedString(@"There is no Describe Identity associated with this Facebook account. Would you like to Signup ?", @"")
                                         tag:ALERT_TAG_FACEBOOK
                                    delegate:self
                           cancelButtonTitle:@"Cancel"
                           otherButtonTitles:@"Signup", nil];
                }
                else if (signInType == SignInConnectionType_GooglePlus) {
                    [self showAlertWithTitle:NSLocalizedString(@"Validation", @"")
                                     message:NSLocalizedString(@"There is no Describe Identity associated with this Google account. Would you like to Signup ?", @"")
                                         tag:ALERT_TAG_GOOGLEPLUS
                                    delegate:self
                           cancelButtonTitle:@"Cancel"
                           otherButtonTitles:@"Signup", nil];
                }
                else {
                    [self showAlertWithTitle:NSLocalizedString(@"Validation", @"")
                                     message:NSLocalizedString(@"The username or password you have entered is incorrect.", @"")
                                         tag:0
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil];
                }
            }
            
            break;
        }
        default:
            break;
    }
}

//Instead of saving them in the user defaults lets save them in global object wich can access from the any globally...
- (void)saveUserDetails:(NSDictionary *)dictionary
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *username = [dictionary valueForKeyPath:@"ResponseData.DataTable.UserData.Username"];
    NSArray *userid = [dictionary valueForKeyPath:@"ResponseData.DataTable.UserData.UserUID"];
    NSArray *userprofilepic = [dictionary valueForKeyPath:@"ResponseData.DataTable.UserData.UserProfilePicture"];
    
    [userDefaults setValue:(username.count)?username[0]:nil forKey:@"UserName"];
    [userDefaults setValue:(userid.count)?userid[0]:nil forKey:@"UserUID"];
    [userDefaults setValue:(userprofilepic.count)?userprofilepic[0]:nil forKey:@"UserProfilePicture"];
    [self saveUserDataInUserDefaults:dictionary];
    
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
    if ([followingCount isEqualToString:@"0"])
        return NO;
    return YES;
}

- (void)gotoBasicinfoScreen
{
    DescBasicinfoViewController * basicInfo = [[DescBasicinfoViewController alloc]initWithNibName:@"DescBasicinfoViewController" bundle:nil];
    [self.navigationController pushViewController:basicInfo animated:YES];
}

#pragma mark - Showing alert and managing its action
- (void)showAlertWithTitle:(NSString *)titleString message:(NSString *)message tag:(NSUInteger)tagValue delegate:(id /*<UIAlertViewDelegate>*/)target cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString message:message delegate:target cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];

    // get the variable arguments into argumentList(va_list) using va_start and then iterate through list to get all the button titles
    // add the button titles to the alert
    va_list args;
    va_start(args, otherButtonTitles);
    for(NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*)) {
        [alert addButtonWithTitle:arg];
    }
    va_end(args);
    
    alert.tag = tagValue;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERT_TAG_FACEBOOK || alertView.tag == ALERT_TAG_GOOGLEPLUS) {
        NSLog(@"buttonIndex = %ld", (long)buttonIndex);
        if(buttonIndex == 0) {  // cancel
            [[DESocialConnectios sharedInstance] logoutFacebook];
            [[DESocialConnectios sharedInstance] logoutGooglePlus];
        }
        else {
            DESAppDelegate * delegate = (DESAppDelegate*)[UIApplication sharedApplication ].delegate;
            if (delegate.isFacebook) {
                [self saveTheUserDetailsOfFacebook:self.socialDetailsDict];
            }
            else if (delegate.isGooglePlus){
                [self saveTheUserDetailsOfGooglePlus:self.socialDetailsDict];
            }
            
            DescSignupViewController * signUpView = [[DescSignupViewController alloc]initWithNibName:@"DescSignupViewController" bundle:Nil];
            signUpView.userDataDic =  self.socialDetailsDict;
            [self.navigationController pushViewController:signUpView animated:YES];
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)forgetpwdClicked:(id)sender
{
    DescResetpwdViewController * reset = [[DescResetpwdViewController alloc]initWithNibName:@"DescResetpwdViewController" bundle:Nil];
    [self.navigationController pushViewController:reset animated:NO];
}

- (BOOL)userNameTextFieldValidation
{
    if(([self.txtusername.text length] == 0) ||
       ([self.txtusername.text length] < 6) ||
       ([self.txtusername.text length] > 15) )
    {
        [self showAlertWithTitle:NSLocalizedString(@"Validation", @"")
                         message:NSLocalizedString(@"Please enter a valid username.", @"")
                             tag:0
                        delegate:nil
               cancelButtonTitle:@"OK"
               otherButtonTitles:nil];
        
        return NO;
	}
    
    return YES;
}

- (BOOL)passwordTextFiledValidataion
{
    if([self.txtpassword.text length] == 0 ||
       [self.txtpassword.text length] < 8 )
	{
        [self showAlertWithTitle:NSLocalizedString(@"Validation", @"")
                         message:NSLocalizedString(@"Please enter a valid password.", @"")
                             tag:0
                        delegate:nil
               cancelButtonTitle:@"OK"
               otherButtonTitles:nil];

        return NO;
	}
    
    return YES;
}

#pragma mark - Textfiled delegate methods
-  (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1) {
        if ([self userNameTextFieldValidation]) {
            [self.txtpassword becomeFirstResponder];
            return YES;
        }
        return NO;
    }
    else if (textField.tag == 2) {
        if([self passwordTextFiledValidataion]) {
            [textField resignFirstResponder];
            [self performSelector:@selector(signIntoDescribeAction:) withObject:nil afterDelay:0.0f];
            return YES;
        }
        return NO;
    }
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if (textField.tag == 1) {
        NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    return YES;
}

- (void)textfieldDidChange:(NSNotification *)notification
{
//    UITextField *textfield = (UITextField *)[notification object];
    if ([txtusername.text length] >= 6 && [txtpassword.text length] >= 8) {
        [_headerView designHeaderViewWithTitle:@"Sign in" andWithButtons:@[backButton, nextButton]];
    }
    else {
        [_headerView designHeaderViewWithTitle:@"Sign in" andWithButtons:@[backButton]];
    }
}

#pragma mark socialConnection Delegate methods
- (void)googlePlusResponce:(NSMutableDictionary *)responseDict andFriendsList:(NSMutableArray*)inFriendsList
{
    if(responseDict == nil) {
        HUD.hidden = YES;
        return;
    }
    
    _socialDetailsDict = responseDict;
    if (signInType == SignInConnectionType_Facebook) {
        [WSModelClasses sharedHandler].delegate = self;
        [[WSModelClasses sharedHandler] signInWithSocialNetwork:@"fb" andGateWauTokern:[[NSUserDefaults standardUserDefaults]valueForKey:FACEBOK_ID]];
    }
    else if (signInType == SignInConnectionType_GooglePlus) {
        [WSModelClasses sharedHandler].delegate = self;
        [[WSModelClasses sharedHandler] signInWithSocialNetwork:@"gplus" andGateWauTokern:[[NSUserDefaults standardUserDefaults]valueForKey:Google_plus_ID]];
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


@end
