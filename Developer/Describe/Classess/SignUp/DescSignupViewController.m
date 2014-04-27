//
//  DescSignupViewController.m
//  Describe
//
//  Created by kushal mandala on 05/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DescSignupViewController.h"
#import "DescBasicinfoViewController.h"
#import "ConstantValues.h"
#import "DHeaderView.h"
#import "UIColor+DesColors.h"
#import "DESAppDelegate.h"
#import "DesPeopleSortingComponent.h"
#import "Constant.h"
#import "DESocialConnectios.h"
#import "UIView+FindFirstResponder.h"

@interface DescSignupViewController ()<MBProgressHUDDelegate>{
    IBOutlet DHeaderView *_headerView;
    UIButton    *backButton,*nextButton;
    MBProgressHUD *HUD;

}

@end

@implementation DescSignupViewController
@synthesize userNameTxt;
@synthesize pwdTxt;
@synthesize emailTxt;
@synthesize nameTxt;
@synthesize signupjsonArray;
@synthesize signupResponseData;
@synthesize userDataDic;
@synthesize textFiledType;
@synthesize messageTextField;
@synthesize socialUserFriendsList;
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


-  (void)viewDidLoad
{
    [self setNeedsStatusBarAppearanceUpdate];
    [self.userNameTxt becomeFirstResponder];
    [super viewDidLoad];
    [self setBackGroundimageView];
    [self designHeaderView];
    [self intilizTextFieldColors];
    [self setTheUserDataInTextFields];
    [self registerKeyboardNotifications];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [self.view registerToResignKeyboard];
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


#pragma mark Design HeadeView
- (void)designHeaderView
{
    backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goToBack:) forControlEvents:UIControlEventTouchUpInside];
    nextButton = [[UIButton alloc] init];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_next.png"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(goToBasicInfoView:) forControlEvents:UIControlEventTouchUpInside];
    
    [_headerView designHeaderViewWithTitle:@"Sign up" andWithButtons:@[backButton]];
}


- (void)setTheUserDataInTextFields
{
    DESAppDelegate * appDelegate = (DESAppDelegate*)[UIApplication sharedApplication].delegate;
    if (appDelegate.isFacebook == YES) {
        self.emailTxt.text = [self.userDataDic valueForKey:@"email"];
        
        NSString *firstName = [self.userDataDic valueForKey:@"first_name"];
        NSString *lastName = [self.userDataDic valueForKey:@"last_name"];
        
        if(firstName != nil && lastName != nil)
            self.nameTxt.text = [NSString stringWithFormat:@"%@ %@",firstName, lastName];
        else if(firstName != nil)
            self.nameTxt.text = firstName;
        else if(lastName != nil)
            self.nameTxt.text = lastName;
            
    }else if (appDelegate.isGooglePlus == YES){
        self.emailTxt.text = [self.userDataDic valueForKey:@"email"];
        
        NSString *displayName = [self.userDataDic valueForKey:@"last_name"];
        if(displayName != nil)
            self.nameTxt.text = [NSString stringWithFormat:@"%@ ",displayName];
    }
    
}


- (void)intilizTextFieldColors
{
    self.userNameTxt.tag = USERNAME_TEXT_FIELD_TAG;
    self.userNameTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"username" attributes:@{NSForegroundColorAttributeName: [UIColor textPlaceholderColor]}];
    [self.userNameTxt setTextColor:[UIColor textFieldTextColor]];
    
    self.pwdTxt.tag = PASSWORD_TEXT_FIELD_TAG;
    self.pwdTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"password" attributes:@{NSForegroundColorAttributeName: [UIColor textPlaceholderColor]}];
    [self.pwdTxt setTextColor:[UIColor textFieldTextColor]];
    
    self.emailTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"email" attributes:@{NSForegroundColorAttributeName: [UIColor textPlaceholderColor]}];
    [self.emailTxt setTextColor:[UIColor textFieldTextColor]];
    self.emailTxt.tag= EMAIL_TEXT_FIELD_TAG;
    
    self.nameTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"name" attributes:@{NSForegroundColorAttributeName: [UIColor textPlaceholderColor]}];
    [self.nameTxt setTextColor:[UIColor textFieldTextColor]];
    self.nameTxt.tag= NAME_TEXT_FIELD_TAG;
}

- (void)goToBack:(id)sender
{
    [[DESocialConnectios sharedInstance] logoutFacebook];
    [[DESocialConnectios sharedInstance] logoutGooglePlus];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)backClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)goToBasicInfoView:(id)sender
{
    [userNameTxt resignFirstResponder];
    [pwdTxt resignFirstResponder];
    [emailTxt resignFirstResponder];
    [nameTxt resignFirstResponder];
    if (![self userNameTextFieldValidation])
        return;
    if (![self passwordTextFiledValidataion])
        return;
    if (![self emailTextFieldValidataion])
        return;
    if (![self fullNameTextFiledValidataion])
        return;
    [self sendTheparametersToServer];
}


- (void)sendTheparametersToServer
{
    WSModelClasses * modelClass = [WSModelClasses sharedHandler];
    modelClass.delegate  =self;
    DESAppDelegate * delegate = (DESAppDelegate*)[UIApplication sharedApplication ].delegate;
    NSString * outhType =@"";
    NSString * outhID = @"";
    if (delegate.isFacebook) {
        outhType     =@"fb";
        outhID =[self.userDataDic valueForKey:@"id"];
    }else if (delegate.isGooglePlus){
        outhType =@"gplus";
        outhID =[self.userDataDic valueForKey:@"id"];
    }
    [modelClass postSignUpWithUsername:userNameTxt.text password:pwdTxt.text email:emailTxt.text fullName:nameTxt.text OAuthType:outhType OAuthID:outhID];//FB,GP,
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Loading";
    [HUD show:YES];
}

#pragma  mark TextField Validation
- (BOOL)emailTextFieldValidataion
{
    if([emailTxt.text length]==0)
	{
        [self showAlert:@"Validation" message:@"Please enter email"];
        return NO;
	}else if (![self validateEmailWithString:self.emailTxt.text]) {
        [self showAlert:@"Validation" message:@"Please enter a valid email address"];
        return NO;
    }
    return YES;
}


- (BOOL)userNameTextFieldValidation
{
    if(([userNameTxt.text length]==0 ))
    {
        [self showAlert:@"Validation" message:@"Please enter your username."];
        return NO;
	}else if ([self.userNameTxt.text length]<6){
        [self showAlert:@"Validation" message:@"Username must have at least 6 characters. You may only use alphabets, numbers and _ in your username."];
        return NO;
    }
    return YES;
}


- (BOOL)passwordTextFiledValidataion
{
    if([pwdTxt.text length]==0)
	{
        [self showAlert:@"Validation" message:@"Your password must have at least 8 characters. "];
        return NO;
	}else if ([pwdTxt.text length]<8){
        [self showAlert:@"Validation" message:@"Your password must have at least 8 characters."];
        return NO;
    }
    return YES;
}


-  (BOOL)fullNameTextFiledValidataion
{
    if([nameTxt.text length]==0)
	{
        [self showAlert:@"Validation" message:@"Please enter your name"];
        return NO;
	}else if ([nameTxt.text length]>30){
        [self showAlert:@"Validation" message:@"Please enter your name max Thirty characters"];
        return NO;
    }
    return YES;
}


#pragma mark AlertView Method
- (void)showAlert:(NSString *)inTitle message:(NSString*)inMessage
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:inTitle message:inMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}


#pragma mark ServerResponce Delegate Method
- (void)signUpStatus:(NSDictionary *)responseDict error:(NSError *)error
{
    
    NSString * message = [[responseDict valueForKeyPath:@"DataTable.UserData.Msg"]objectAtIndex:0];
    if ([message isEqualToString:@"TRUE"]) {
        
        NSString *userId = [[responseDict valueForKeyPath:@"DataTable.UserData.UserUID"]objectAtIndex:0];        
        [[NSUserDefaults standardUserDefaults]setValue:userId forKey:@"USERID"];
        [[[WSModelClasses sharedHandler] loggedInUserModel] setUserID:[NSNumber numberWithInteger:[userId integerValue]]];
        [self saveUserDetails:responseDict];
        [self goToBasicInfoScreen];
        [HUD hide:YES];
    }else{
        [HUD hide:YES];
        [self showAlert:@"AuthenticationFail" message:message];
    }
}

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

- (void)getThePeopleListFromServer:(NSDictionary *) responceDict error:(NSError*)error;
{
    [self goToBasicInfoScreen];
    [DesPeopleSortingComponent facebookFriendsListFiltring:Nil andLocalfacebookFriendsList:self.socialUserFriendsList ];
    [HUD hide:YES];
}


- (void)goToBasicInfoScreen
{
    DescBasicinfoViewController * basicInfo = [[DescBasicinfoViewController alloc]initWithNibName:@"DescBasicinfoViewController" bundle:nil];
    [self.navigationController pushViewController:basicInfo animated:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)checkTheTextFileds
{
//    if (isUserNameFilled == YES && isPwsFilled == YES && isEmailFilled == YES && isNameFilled == YES) {
//        [_headerView designHeaderViewWithTitle:@"Sign up" andWithButtons:@[backButton,nextButton]];
//        return YES;
//    }else{
//        [_headerView designHeaderViewWithTitle:@"Sign up" andWithButtons:@[backButton]];
//    }
    return NO;
}


#pragma mark Textfield Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //[textField resignFirstResponder];
    if (textField.tag == USERNAME_TEXT_FIELD_TAG){
        if ([self userNameTextFieldValidation]) {
            isUserNameFilled = YES;
            [self checkTheTextFileds];
            [self.pwdTxt becomeFirstResponder];
            return YES;
        }else{
            [self.userNameTxt becomeFirstResponder];
            isUserNameFilled = NO;
            return NO;
        }
    }
    else if (textField.tag == PASSWORD_TEXT_FIELD_TAG){
        if ([self passwordTextFiledValidataion]) {
            isPwsFilled = YES;
            [self checkTheTextFileds];
            [self.emailTxt becomeFirstResponder];
            return YES;
        }else{
            self.pwdTxt.text = nil;
            isPwsFilled = NO;
            [self.pwdTxt becomeFirstResponder];
            return NO;
        }
    }
    else if (textField.tag == EMAIL_TEXT_FIELD_TAG){
        if ([self emailTextFieldValidataion]) {
            isEmailFilled  = YES;
            [self checkTheTextFileds];
            [self.nameTxt becomeFirstResponder];
            return YES;
        }else{
            isEmailFilled = NO;
            [self.emailTxt becomeFirstResponder];
            return NO;
        }
    }
    else if (textField.tag == NAME_TEXT_FIELD_TAG){
        
        if (textField.tag == NAME_TEXT_FIELD_TAG)
        {
            if([self checkMinimumFieldValidation])
                [self goToBasicInfoView:nil];
            else
                return NO;
        }
        
        
        
    }
    return YES;
}


-  (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _currentTextField = textField;
    
      return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
  
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self showTextFieldInVisibleRect:textField inView:_contentView];

    
    if ([self.userNameTxt.text length]!=0 &&! [self.userNameTxt.text length]<6) {
        isUserNameFilled =YES;
    }
    if(![pwdTxt.text length]==0 && ![pwdTxt.text length]<8)
	{
        isPwsFilled = YES;
	}
    if(![emailTxt.text length]==0 && [self validateEmailWithString:self.emailTxt.text])
	{
        isEmailFilled = YES;
	}
    if(![nameTxt.text length]==0)
	{
        isNameFilled = YES;
	}
    [self checkTheTextFileds];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    
    [self checkTheTextFileds];
    
    if ([string isEqualToString:@""]) {
        return  YES;
    }
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return FALSE;
    } else {
        if (textField.tag == USERNAME_TEXT_FIELD_TAG) {
            if ([self.userNameTxt.text length]==15) {
                return NO;
            }else{
                return YES;
            }
        }else if (textField.tag == PASSWORD_TEXT_FIELD_TAG){
            return YES;
        }else if (textField.tag == EMAIL_TEXT_FIELD_TAG){
            return YES;
        }else if (textField.tag == NAME_TEXT_FIELD_TAG){
            if ([self.nameTxt.text length]==30) {
                return NO;
            }else{
                return YES;
            }
        }
    }    
    return YES;
}

-(void)textFieldDidChange:(NSNotification *)notification
{
    [self checkMinimumFieldValidation];
}

-(BOOL )checkMinimumFieldValidation
{
    BOOL isValidDetailsEntering = YES;

    if([[self.userNameTxt text] length] < 6)
        isValidDetailsEntering = NO;
    else if(![self validateEmailWithString:self.emailTxt.text])
        isValidDetailsEntering = NO;
    else if([[self.pwdTxt text] length] < 8)
        isValidDetailsEntering = NO;
    else if(![[self.nameTxt text] length])
        isValidDetailsEntering = NO;
   
    NSLog(@"isValidFields:%d _isModified:%d ",isValidDetailsEntering, _isModifiedHeaderView);
    if(_isModifiedHeaderView != isValidDetailsEntering)
    {
        if(isValidDetailsEntering)
        {
            [_headerView designHeaderViewWithTitle:@"Sign up" andWithButtons:@[backButton,nextButton]];
            _isModifiedHeaderView = isValidDetailsEntering;
        }
        else
        {
            [_headerView designHeaderViewWithTitle:@"Sign up" andWithButtons:@[backButton]];
            _isModifiedHeaderView = isValidDetailsEntering;
        }
    }
    
    return isValidDetailsEntering;
}


-(void)registerKeyboardNotifications
{
    // Add two notifications for the keyboard. One when the keyboard is shown and one when it's about to hide.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}



-(void)keyboardWillShown:(id)notification
{
}

-(void)keyboardWillHide:(id)notification
{
    [self showTextFieldInVisibleRect:_currentTextField inView:_contentView];
}


-(void)showTextFieldInVisibleRect:(UITextField *)textField inView:(UIView *)view
{
    CGRect textFieldRect = textField.frame;
    CGRect mainViewRect = self.view.bounds;
    CGRect viewRect = view.bounds;
    mainViewRect.size.height = mainViewRect.size.height - 218;//Where 218 is the original keyboard height...
    
    CGRect originalRectOfTextField = [self.view convertRect:textFieldRect fromView:_contentView];
    if(!CGRectContainsRect(mainViewRect, originalRectOfTextField))
    {
        //Text field is not there in visible rect....
        float diff = originalRectOfTextField.origin.y + originalRectOfTextField.size.height - mainViewRect.size.height;
        diff = diff + 10;//Buffer to visible rect...
        
        viewRect.origin.y = diff;
    }
    else
    {
        viewRect.origin.y = 0;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [view setBounds:viewRect];
    }];
}

- (BOOL) validateEmailWithString:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,5}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}




@end
