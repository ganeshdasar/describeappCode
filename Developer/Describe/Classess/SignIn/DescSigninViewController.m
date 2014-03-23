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

@interface DescSigninViewController ()<WSModelClassDelegate,DESocialConnectiosDelegate,MBProgressHUDDelegate>{
IBOutlet DHeaderView *_headerView;
    UIButton    *backButton,*nextButton;
    WSModelClasses * modelClass;
    MBProgressHUD *HUD;
}
@end

@implementation DescSigninViewController
@synthesize loginjsonArray,loginresponseData;
@synthesize txtusername,txtpassword;
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


-  (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    [self setNeedsStatusBarAppearanceUpdate];
    [self.txtusername becomeFirstResponder];
    self.navigationController.navigationBarHidden = YES;
    [self designHeaderView];
    [self setBackGroundimageView];
    [self intilizTextFieldColors];
}


- (void)setBackGroundimageView
{
    if (isiPhone5)
    {
        self.backGroundImage.image = [UIImage imageNamed:@"bg_std_4in.png"];
    }else{
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
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)signIntoDescribeAction:(id)sender
{
    [self.txtusername resignFirstResponder];
    [self.txtpassword resignFirstResponder];
    if(([self.txtusername.text length]==0))
    {
        [self showalertMessage:@"Please enter your user name"];
	}
	else if([self.txtpassword.text length]==0)
	{
		[self showalertMessage:@"Please enter your password"];
	}
    else
    {
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
    connection =FAcebook_connected;
    [self showLoadView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"faceBookButtonClicked" object:nil];
    [[DESocialConnectios sharedInstance] facebookSignIn];
    [DESocialConnectios sharedInstance].delegate =self;
}


- (IBAction)signInWithGooglePlus:(id)sender
{
    connection =Googleplus_connected;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"googlePlusButtonClicked" object:nil];
    [[DESocialConnectios sharedInstance] googlePlusSignIn];
    [DESocialConnectios sharedInstance].delegate = self;
    [self showLoadView];
    
}

-  (void)googlePlusResponce:(NSMutableDictionary *)responseDict andFriendsList:(NSMutableArray*)inFriendsList
{
    HUD.hidden = YES;
    if (connection==FAcebook_connected) {
        [WSModelClasses sharedHandler].delegate = self;
        [[WSModelClasses sharedHandler]signInWithSocialNetwork:@"fb" andGateWauTokern:[[NSUserDefaults standardUserDefaults]valueForKey:FACEBOK_ID]];
    }else if (connection==Googleplus_connected){
        [WSModelClasses sharedHandler].delegate = self;
        [[WSModelClasses sharedHandler]signInWithSocialNetwork:@"gplus" andGateWauTokern:[[NSUserDefaults standardUserDefaults]valueForKey:Google_plus_ID]];
    }
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Describe", @"") message:NSLocalizedString(@"Error while communicating to server. Please try again later.", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    switch (serviceType) {
        case kWebserviesType_SignIn:
        {
            [HUD hide:YES];
            if ([[[responseDict valueForKeyPath:@"ResponseData.DataTable.UserData.Msg"]objectAtIndex:0] isEqualToString:@"TRUE"]) {
                [self gotoBasicinfoScreen];
            }else{
                [self showalertMessage:@"The username or password you have entered is incorrect."];
            }
            break;
        }
        default:
            break;
    }
}


-(void)gotoBasicinfoScreen
{
    
    DescBasicinfoViewController * basicInfo = [[DescBasicinfoViewController alloc]initWithNibName:@"DescBasicinfoViewController" bundle:nil];
    [self.navigationController pushViewController:basicInfo animated:YES];
    
}

- (void)showalertMessage:(NSString*)inMeassage
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Validation" message:inMeassage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.txtusername becomeFirstResponder];
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


- (void)showAlert:(NSString *)inTitle message:(NSString*)inMessage
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:inTitle message:inMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}


- (BOOL)userNameTextFieldValidation
{
    if(([self.txtusername.text length]==0 ))
    {
        [self showAlert:@"Validation" message:@"Please enter a valid username"];
        //        [self.userNameTxt becomeFirstResponder];
        return NO;
	}else if ([self.txtusername.text length]<6){
        [self showAlert:@"Validation" message:@"Please enter a valid username"];
        //        [self.userNameTxt becomeFirstResponder];
        return NO;
    }else if ([self.txtusername.text length]>15){
        [self showAlert:@"Validation" message:@"Please enter a valid username"];
        //        [self.userNameTxt becomeFirstResponder];
        return NO;
    }
    return YES;
}


- (BOOL)passwordTextFiledValidataion
{
    if([self.txtpassword.text length]==0)
	{
        [self showAlert:@"Validation" message:@"Please enter a valid password.. "];
        //        [self.pwdTxt becomeFirstResponder];
        return NO;
	}else if ([self.txtpassword.text length]<8){
        [self showAlert:@"Validation" message:@"Please enter a valid password.."];
        //        [self.pwdTxt becomeFirstResponder];
        return NO;
    }
    return YES;
}


-  (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField.tag ==1) {
        if ([self userNameTextFieldValidation]) {
            [self.txtpassword becomeFirstResponder];
            return YES;
        }else{
            return NO;
        }
    }else if (textField.tag==2){
      return  [self passwordTextFiledValidataion];
    }
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if ([string isEqualToString:@""]) {
        if ( [txtusername.text length]>6 &&[txtpassword.text length]>8) {
            [_headerView designHeaderViewWithTitle:@"Sign in" andWithButtons:@[backButton,nextButton]];
        }else{
            [_headerView designHeaderViewWithTitle:@"Sign in" andWithButtons:@[backButton]];
        }
    }else{
        if ( [txtusername.text length]>4 &&[txtpassword.text length]>6) {
            [_headerView designHeaderViewWithTitle:@"Sign in" andWithButtons:@[backButton,nextButton]];
        }else{
            [_headerView designHeaderViewWithTitle:@"Sign in" andWithButtons:@[backButton]];
        }
    }
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
}


-(void)goToNext:(id)sender
{
    [txtusername resignFirstResponder];
    [txtpassword resignFirstResponder];
	// Regular expression to checl the email format.
    if(([txtusername.text length]==0))
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Validation" message:@"Please enter UserName" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
	}
	else if([txtpassword.text length]==0)
	{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Validation" message:@"Please enter UserName" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
	}
	else
	{
        DescBasicinfoViewController * basicInfo = [[DescBasicinfoViewController alloc]initWithNibName:@"DescBasicinfoViewController" bundle:nil];
        [self.navigationController pushViewController:basicInfo animated:YES];
    }
}
@end
