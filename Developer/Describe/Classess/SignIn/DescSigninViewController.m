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


@interface DescSigninViewController ()<WSModelClassDelegate>{
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
    [self setNeedsStatusBarAppearanceUpdate];
    [self.txtusername becomeFirstResponder];
    self.navigationController.navigationBarHidden = YES;
    [self designHeaderView];
    [self setBackGroundimageView];
    [self intilizTextFieldColors];
}

-(void)setBackGroundimageView{
    if (isiPhone5)
    {
        self.backGroundImage.image = [UIImage imageNamed:@"bg_std_4in.png"];
    }else{
        self.backGroundImage.image = [UIImage imageNamed:@"bg_std_3.5in.png"];
        
    }
}
#pragma mark Design HeadeView
-(void)designHeaderView
{
    //back button
    backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goToBack:) forControlEvents:UIControlEventTouchUpInside];
    
    //next button
    nextButton = [[UIButton alloc] init];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_next.png"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(signIntoDescribeAction:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView designHeaderViewWithTitle:@"Sign in" andWithButtons:@[backButton]];
    
    
}
-(void)intilizTextFieldColors{
    
    self.txtusername.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"username" attributes:@{NSForegroundColorAttributeName: [UIColor textPlaceholderColor]}];
    [self.txtusername setTextColor:[UIColor textFieldTextColor]];
    self.txtpassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"password" attributes:@{NSForegroundColorAttributeName: [UIColor textPlaceholderColor]}];
    [self.txtpassword setTextColor:[UIColor textFieldTextColor]];

    
}
-(void)addTheButtonAboveNavBarWithImage:(UIImage*)inImage andSize:(CGRect*) inFrame andActionName:(NSString*)inActionName{
    

    
}
-(void)goToBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)signIntoDescribeAction:(id)sender{
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
#pragma mark signResponce delegate method
- (void)loginStatus:(NSDictionary *)responseDict error:(NSError *)error{
   
    NSString * message = [[responseDict valueForKeyPath:@"DataTable.UserData.Msg"]objectAtIndex:0];

    
    [HUD hide:YES];
    
    if ([message isEqualToString:@"TRUE"]) {
        [[NSUserDefaults standardUserDefaults]setValue:[[responseDict valueForKeyPath:@"DataTable.UserData.UserUID"]objectAtIndex:0] forKey:@"USERID"];
        DescBasicinfoViewController * basicInfo = [[DescBasicinfoViewController alloc]initWithNibName:@"DescBasicinfoViewController" bundle:nil];
        [self.navigationController pushViewController:basicInfo animated:YES];

    }else{
        
        [self showalertMessage:@"The username or password you have entered is incorrect."];
    }
}
-(void)showalertMessage:(NSString*)inMeassage{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Validation" message:inMeassage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [self.txtusername becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)forgetpwdClicked:(id)sender {
    DescResetpwdViewController * reset = [[DescResetpwdViewController alloc]initWithNibName:@"DescResetpwdViewController" bundle:Nil];
    [self.navigationController pushViewController:reset animated:NO];
}
-(void)showAlert:(NSString *)inTitle message:(NSString*)inMessage{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:inTitle message:inMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}
-(BOOL)userNameTextFieldValidation{
    
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
-(BOOL)passwordTextFiledValidataion{
    
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField
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
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string; {
    NSLog(@"textfield length %d",[textField.text length]);

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

-(void)goToNext:(id)sender{
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
