//
//  DescResetpwdViewController.m
//  Describe
//
//  Created by kushal mandala on 05/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DescResetpwdViewController.h"
#import "DHeaderView.h"
#import "UIColor+DesColors.h"
#import "WSModelClasses.h"
#import "MBProgressHUD.h"
#import "Constant.h"
#import "UIView+FindFirstResponder.h"

@interface DescResetpwdViewController ()<WSModelClassDelegate>
{
    IBOutlet DHeaderView *_headerView;
    UIButton    *backButton,*nextButton;
    MBProgressHUD * HUD;
}
@end

@implementation DescResetpwdViewController
@synthesize RPjsonArray,RPresponseData;

-(UIStatusBarStyle)preferredStatusBarStyle
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
    [self setNeedsStatusBarAppearanceUpdate];
    [super viewDidLoad];
    
    // registering the self.view to resign keyboard upon singleTap anywhere on the view
    [self.view registerToResignKeyboard];
    
    [self.txtemail becomeFirstResponder];
    [self setBackGroundimageView];
    [self designHeaderView];
    [self intilizTextFieldColors];
    // Do any additional setup after loading the view from its nib.
    
    self.txtemail.returnKeyType = UIReturnKeyGo;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if ([self validateEmailWithString:self.txtemail.text]) {
        [_headerView designHeaderViewWithTitle:@"Reset Password" andWithButtons:@[backButton,nextButton]];
    }
}

- (void)setBackGroundimageView
{
    if (isiPhone5)
    {
        self.backGroundImageView.image = [UIImage imageNamed:@"bg_std_4in.png"];
    }else{
        self.backGroundImageView.image = [UIImage imageNamed:@"bg_std_3.5in.png"];
    }
}


#pragma  Design Header view
-  (void)designHeaderView
{
    backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    nextButton = [[UIButton alloc] init];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_next.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goToBack:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton addTarget:self action:@selector(getThePaasword:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView designHeaderViewWithTitle:@"Reset Password" andWithButtons:@[backButton]];
}


- (void)intilizTextFieldColors
{
   self.txtemail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"email" attributes:@{NSForegroundColorAttributeName: [UIColor textPlaceholderColor]}];
    [self.txtemail setTextColor:[UIColor textFieldTextColor]];
}


- (void)goToBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)backClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)getThePaasword:(id)inSender
{
   WSModelClasses * data = [WSModelClasses sharedHandler];
    data.delegate  =self;
    [data resetPassword:self.txtemail.text];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Loading";
    [HUD show:YES];
}


#pragma mark receive passwod delegate method
-  (void)resetPasswordStatus:(NSDictionary *)responseDict error:(NSError *)error{
    [HUD hide:YES];
    NSString * message = [[responseDict valueForKeyPath:@"DataTable.ReplyData.Msg"]objectAtIndex:0];
    if ([message isEqualToString:@"Your Email ID is not registered with us."]) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"There is no Describe account associated with this email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        alert.tag = 120;
        [alert show];
    }else{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"An email with instructions to reset the password has been sent to this email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        alert.tag = 121;
        [alert show];
    }
  
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 120:
            [self.txtemail becomeFirstResponder];
            break;
        case 121:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self validateEmailWithString:self.txtemail.text]) {
        [_headerView designHeaderViewWithTitle:@"Reset Password" andWithButtons:@[backButton,nextButton]];
        [textField resignFirstResponder];
        [self getThePaasword:nil];
    }else{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@" Please enter a valid email address." delegate:self cancelButtonTitle:@"oK" otherButtonTitles:Nil, nil];
        [alert show];
        [self.txtemail becomeFirstResponder];
    }
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.txtemail.text length]>0 ) {
    }
    else
    {
        [_headerView designHeaderViewWithTitle:@"Reset Password" andWithButtons:@[backButton]];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if ([string isEqualToString:@""]) {
        [_headerView designHeaderViewWithTitle:@"Reset Password" andWithButtons:@[backButton]];
    }
    return YES;
}


- (BOOL) validateEmailWithString:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{0,5}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

@end
