//
//  DESecurityViewCnt.m
//  Describe
//
//  Created by NuncSys on 16/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DESecurityViewCnt.h"
#import "UIColor+DesColors.h"
#import "Constant.h"
#import "WSModelClasses.h"
@interface DESecurityViewCnt ()<UITextFieldDelegate>{
 IBOutlet   DHeaderView * _headerView;
    UIButton    *backButton;
    NSArray * securityNamesArray;

}
@end

@implementation DESecurityViewCnt
@synthesize userEmailId = _userEmailId;
@synthesize userPassword = _userPassword;
@synthesize isTextFieldEditing;


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
    [self createHeadderView];
    [self intilizeArray];
    if (isiPhone5)
    {
        self.backGroundImg.image = [UIImage imageNamed:@"bg_std_4in.png"];
    }
    else
    {
        self.backGroundImg.image = [UIImage imageNamed:@"bg_std_3.5in.png"];
        
        //Iphone  3.5 inch
    }
    self.isTextFieldEditing = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


-(void)createHeadderView
{
    backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView designHeaderViewWithTitle:@"Settings" andWithButtons:@[backButton]];
}

-(void)back:(UIButton*)inButton
{
    if (self.isTextFieldEditing) {
        [self updateTheUserEmailAndPassword];
    }else{
        [self.navigationController popViewControllerAnimated:YES];

    }
}


-(void)updateTheUserEmailAndPassword
{
    [[WSModelClasses sharedHandler]updateTheUserEmaiIdAndPassword:self.userEmailId AndPassword:self.userPassword responce:^(BOOL success, id response){
        if (success) {
            NSString *status = [[(NSDictionary*)response valueForKeyPath:@"DataTable.UserData.Status"]objectAtIndex:0];
            if ([status isEqualToString:@"FALSE"]) {
                [self showAlert:@"Alert" message:[[(NSDictionary*)response valueForKeyPath:@"DataTable.UserData.Msg"]objectAtIndex:0]];
            }else{
                self.isTextFieldEditing = NO;
                [WSModelClasses sharedHandler].loggedInUserModel.userEmail = self.userEmailId;
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }else{
            
            
        }
    }];
}

-(void)intilizeArray
{
    securityNamesArray = [[NSArray alloc]initWithObjects:@"Email",@"Password", nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark tablewview delegate and datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return securityNamesArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"identifier_%d_%ld",indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.selectedBackgroundView = nil;
        }
    if (indexPath.row ==Email_TAG) {
        UITextField * name = [self createDetailTextField:cell];
        name.tag = indexPath.row;
        name.textColor = [UIColor textFieldTextColor];
        name.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
        name.text =self.userEmailId;
        [cell.contentView addSubview:name];
        
    }else if (indexPath.row == PASSWORD_TAG){
        UITextField * name = [self createDetailTextField:cell];
        name.tag = indexPath.row;
        name.textColor = [UIColor textFieldTextColor];
        name.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
        name.text =self.userPassword;
        [cell.contentView addSubview:name];
    }
    
    
    cell.textLabel.text =  securityNamesArray[indexPath.row];
    cell.textLabel.textColor = [UIColor textPlaceholderColor];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
    
    return cell;
}


-(UITextField*)createDetailTextField:(UITableViewCell*)inTableViewCell
{
    
    UITextField * textField = [[UITextField alloc]initWithFrame:CGRectMake(100, 0, 220, 40)];
    textField.delegate = self;
    return textField;

}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}


#pragma textFieldDelegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;{
    if ([string isEqualToString:@""])
    {
        return  YES;
    }
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == Email_TAG) {
        if (![self validateEmailWithString:textField.text]) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Validation" message:@" Please enter a valid email address." delegate:self cancelButtonTitle:@"oK" otherButtonTitles:Nil, nil];
            [alert show];
            [textField becomeFirstResponder];
            return YES;
        }
     
    }else if (textField.tag == PASSWORD_TAG){
        [self passwordTextFiledValidataion:textField.text];
        
    }
    [textField resignFirstResponder];
    return YES;
}


- (BOOL) validateEmailWithString:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{0,5}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}


-(BOOL)passwordTextFiledValidataion:(NSString*)inString
{
    if([inString length]==0)
	{
    [self showAlert:@"Validation" message:@"Your password must have at least 8 characters. "];
        return NO;
	}else if ([inString length]<8){
       [self showAlert:@"Validation" message:@"Your password must have at least 8 characters."];
        return NO;
    }
    return YES;
    
}


-(void)showAlert:(NSString *)inTitle message:(NSString*)inMessage
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:inTitle message:inMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.isTextFieldEditing = YES;
    if (textField.tag == Email_TAG ) {
        self.userEmailId = textField.text;
    }else if (textField.tag == PASSWORD_TAG){
        self.userPassword = textField.text;
    }
  
    
}

@end
