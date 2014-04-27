//
//  DESEditAccountDetailsViewController.m
//  Describe
//
//  Created by NuncSys on 16/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DESEditAccountDetailsViewController.h"
#import "DHeaderView.h"
#import "UIColor+DesColors.h"
#import "Constant.h"
#import "WSModelClasses.h"
#import "NSString+DateConverter.h"
#import "DESAppDelegate.h"
#import "DESecurityViewCnt.h"
#import "DescWelcomeViewController.h"
#import "DESocialConnectios.h"
#import "DESAboutTextView.h"

#define LABLERECT  CGRectMake(0, 0, 320, 40);
#define ELEMENT_FONT_COLOR  [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1];
#define ElEMENT_FONT_NAME [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];

#define HEADER_FONT_COLOR  [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
@interface DESEditAccountDetailsViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,NSLayoutManagerDelegate,UIActionSheetDelegate,UIPickerViewDelegate,UIPickerViewDataSource>{
    IBOutlet DHeaderView * _headerView;
    UIButton    *backButton;
    NSArray * _userInfoArray;
    NSArray * _userinfoDetailsArray;
    NSString * selectedTxt;
    NSString *userNameString;
    NSString *userMaleString;
    NSString *userbirtdayString;
    int gender;
    BOOL isChangedUserData;
    NSIndexPath *_indexPath;
    
    float _cityTableViewHeight;
}

@end

@implementation DESEditAccountDetailsViewController
@synthesize optionsArr;
@synthesize optionsPickerView;
@synthesize pickerActionSheet;
@synthesize genderSting;
@synthesize dateString;
@synthesize datePicker;
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
    [self intializeArray];
    [self setBackGroundImage];
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    self.acountDetailsTableView.frame = CGRectMake(0, self.acountDetailsTableView.frame.origin.x
//                                                   , 320,  screenRect.size.height-65);
    self.acountDetailsTableView.backgroundColor = [UIColor clearColor];
    self.acountDetailsTableView.showsVerticalScrollIndicator = NO;
    userbirtdayString =  [NSString convertTheepochTimeToDate:[[WSModelClasses sharedHandler].loggedInUserModel.dobDate doubleValue]];
    _cityTableViewHeight = 40.;
    isChangedUserData = NO;
    [self registerKeyboardNotifications];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void)createHeadderView
{
    backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView designHeaderViewWithTitle:@"Settings" andWithButtons:@[backButton]];
}


- (void)intializeArray
{
    _userInfoArray = [NSArray arrayWithObjects:@"Name",@"Gender",@"Birthday", nil];
     self.optionsArr = [[NSMutableArray alloc] initWithObjects:@"Male",@"Female", nil];
}


- (void)setBackGroundImage
{
    if (isiPhone5)
    {
        self.backGroundImg.image = [UIImage imageNamed:@"bg_std_4in.png"];
    }
    else
    {
        self.backGroundImg.image = [UIImage imageNamed:@"bg_std_3.5in.png"];
    }
}


- (void)back:(UIButton*)inSender
{
    if (isChangedUserData ==YES) {
        [self updateTheUserInformation];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case DUserInformation:
            return _userInfoArray.count;
            break;
        case DUserCity:
            return 1;
            break;
        case DUserBio:
            return 1;
            break;
        case DUserSecurity:
            return 1;
            break;
        case DUserSignOut:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"identifier_%d_%ld",indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    UILabel * genderLbl;
    UILabel * datelabl;
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.selectedBackgroundView = nil;
        
        switch (indexPath.section) {
            case DUserInformation:
            {
                if (indexPath.row == DUerNameTxt) {
                    UITextField *name = [self createDetailTextField:cell AndTag:DUerNameTxt];
                    name.textColor = [UIColor textFieldTextColor];
                    name.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
                    name.tag = DUsernameTag;
                    name.text = [WSModelClasses sharedHandler].loggedInUserModel.userName;
                    userNameString = [WSModelClasses sharedHandler].loggedInUserModel.userName;
                    [cell.contentView addSubview:name];
                }
                else if(indexPath.row == DUserGenderTxt){
                    genderLbl  = [self createLabel:cell];
                    genderLbl.tag = DGenderLblTag;
                    genderLbl.textColor = [UIColor textFieldTextColor];
                    genderLbl.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
                    [cell.contentView addSubview:genderLbl];
                }
                else if(indexPath.row ==DUserBirhDayTxt ){
                    datelabl = [self createLabel:cell];
                    datelabl.tag = DdateLblTag;
                    datelabl.textColor = [UIColor textFieldTextColor];
                    datelabl.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
                    [cell.contentView addSubview:datelabl];
                }
                
                break;
            }
            case DUserCity:
            {
                UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 36)];
                [contentView setBackgroundColor:[[UIColor orangeColor] colorWithAlphaComponent:0.2]];
                [contentView setTag:2222];
                if(contentView != nil)
                {
                    UILabel *cityLabel = [self createLableTitle:@"City" fontName:@"HelveticaNeue-Thin"  textSize:20.f tag:111];
                    [contentView addSubview:cityLabel];
                    
                    UITextField * city = [self createDetailTextField:cell AndTag:DUserCity];
                    city.textColor = [UIColor textFieldTextColor];
                    city.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
                    [contentView addSubview:city];
                }
                break;
            }
                
            case DUserBio:
            {
                UIImageView * image = [self createBackGroundImageView:[UIImage imageNamed:@"set_about.png"]];
                cell.backgroundView = image;
                
                DESAboutTextView * textview = [[DESAboutTextView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
                textview.backgroundColor = [UIColor clearColor];
                textview.delegate = self;
                textview.layoutManager.delegate = self;
                textview.contentInset = UIEdgeInsetsZero;
                textview.scrollEnabled = NO;
                textview.tag = DUserBio;
                textview.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
                [cell.contentView addSubview:textview];
                
                [self lineSpacingFroTextView:textview];
                
                break;
            }
                
            case DUserSecurity:{
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
                cell.textLabel.textColor = ELEMENT_FONT_COLOR;
                cell.textLabel.text= @"Security";
                cell.accessoryView = [self createBackGroundImageView:[UIImage imageNamed:@"chevron.png"]];
                break;
            }
            case DUserSignOut:{
                cell.textLabel.text = @"Sign out";
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.backgroundColor=  [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
                break;
                
            }
            
            default:
                break;
        }
        
    }
    
    switch (indexPath.section)
    {
        case DUserInformation:
        {
            cell.textLabel.text = _userInfoArray[indexPath.row];
            cell.textLabel.textColor = [UIColor textPlaceholderColor];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
            
            if (indexPath.row==DUerNameTxt) {
                UITextField *name = (UITextField*)[cell.contentView viewWithTag:DUsernameTag];
                name.text = [WSModelClasses sharedHandler].loggedInUserModel.userName;
            }
            else if (indexPath.row == DUserGenderTxt){
                genderLbl  = (UILabel*) [cell viewWithTag:DGenderLblTag];
                if ([[WSModelClasses sharedHandler].loggedInUserModel.gender isEqualToNumber:[NSNumber numberWithInt:1]]) {
                   genderLbl.text = @"Male";
                    selectedTxt =[NSString stringWithFormat:@"%@",@"Male"];
                }else if ([[WSModelClasses sharedHandler].loggedInUserModel.gender   isEqualToNumber:[NSNumber numberWithInt:0]]){
                   genderLbl.text = @"Female";
                    selectedTxt =[NSString stringWithFormat:@"%@",@"Female"];
                }else{
                    genderLbl.text = @"Not specified";
                    selectedTxt =[NSString stringWithFormat:@"%@",@"Not specified"];
                }
            }
            else if (indexPath.row ==DUserBirhDayTxt ){
                datelabl  = (UILabel*) [cell viewWithTag:DdateLblTag];
                datelabl.text =userbirtdayString;
            }
            break;
        }
        case DUserCity:{
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
            cell.textLabel.text = @"City";
            cell.textLabel.textColor = [UIColor textFieldTextColor];
            
            UITextField *city = (UITextField*)[cell.contentView viewWithTag:DUserCity];
            city.text = [WSModelClasses sharedHandler].loggedInUserModel.city;
            break;
        }
        case DUserBio:{
            
            UITextView * textview = [[UITextView alloc]initWithFrame:CGRectMake(10, 0, 310, 123)];
            textview.backgroundColor = [UIColor clearColor];
            UIImageView * image = [self createBackGroundImageView:[UIImage imageNamed:@"set_about.png"]];
            cell.backgroundView = image;
            textview.delegate =self;
            textview.scrollEnabled = NO;
            //textview.text = [WSModelClasses sharedHandler].loggedInUserModel.biodata;
            textview.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
            self.bioTxt = (DESAboutTextView*)textview;
            self.bioTxt.returnKeyType = UIReturnKeyDone;
            [self lineSpacingFroTextView:self.bioTxt];
            [cell.contentView addSubview:textview];
            break;
        }
        case DUserSecurity:{
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
            cell.textLabel.textColor = ELEMENT_FONT_COLOR;
            cell.textLabel.text= @"Security";
            cell.accessoryView = [self createBackGroundImageView:[UIImage imageNamed:@"chevron.png"]];
            UITextView * textview = (UITextView*)[cell.contentView viewWithTag:DUserBio];
            textview.text = [WSModelClasses sharedHandler].loggedInUserModel.biodata;
            break;
        }
        
        default:
            break;
    }
    
    return cell;
}

- (void)lineSpacingFroTextView:(UITextView*)text
{
    DESAboutTextView *lab = self.bioTxt;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 15.0f;
    
    NSString *string = @" ";
    NSDictionary *ats = @{
                          NSParagraphStyleAttributeName : paragraphStyle,
                          NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0],
                          NSForegroundColorAttributeName : [UIColor lightGrayColor],
                          };
    
    lab.attributedText = [[NSAttributedString alloc] initWithString:string attributes:ats];
    lab.text = [WSModelClasses sharedHandler].loggedInUserModel.biodata;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case DUserSecurity:
        {
            [self showAlertView];
            break;
        }
        case DUserInformation:
        {
            if (indexPath.row == 1) {
                if ([[WSModelClasses sharedHandler].loggedInUserModel.gender isEqualToNumber:[NSNumber numberWithInt:1]]) {
                    [WSModelClasses sharedHandler].loggedInUserModel.gender =[NSNumber numberWithInt:0];
                }else if ([[WSModelClasses sharedHandler].loggedInUserModel.gender   isEqualToNumber:[NSNumber numberWithInt:0]]){
                    [WSModelClasses sharedHandler].loggedInUserModel.gender =[NSNumber numberWithInt:1];
                }
             [self.acountDetailsTableView reloadSections:[NSIndexSet indexSetWithIndex:DUserInformation] withRowAnimation:UITableViewRowAnimationNone];
                
            }else if (indexPath.row==2){
                [self inputAccessaryViewandTag:DdateTag];
            }
            break;
        }
        case DUserSignOut:{
            [self removeTheKeysInUserDefaults];
            [self addTheWelcomesViewControllerToWindow];
            break;
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)addTheWelcomesViewControllerToWindow
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
//    DESAppDelegate *_appDelegate = (DESAppDelegate*)[UIApplication sharedApplication].delegate;
//    DescWelcomeViewController *welcomScreen = [[DescWelcomeViewController alloc]initWithNibName:@"DescWelcomeViewController.h" bundle:nil];
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:welcomScreen];
//    _appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    for (UIView*view in _appDelegate.window.subviews ) {
//        [view removeFromSuperview];
//    }
//    [_appDelegate.window setRootViewController:nav];
//    _appDelegate.window.backgroundColor = [UIColor whiteColor];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case DUserBio:
            return 123;
            break;
        case DUserCity:
            return _cityTableViewHeight;
        default:
            return 40;
            break;
    }
}

//- (void)lineSpacingFroTextView:(DESAboutTextView *)textView
//{
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.lineSpacing = 15.0f;
//    
//    NSString *string = @" ";
//    NSDictionary *ats = @{
//                          NSParagraphStyleAttributeName : paragraphStyle,
//                          NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0],
//                          NSForegroundColorAttributeName : [UIColor lightGrayColor],
//                          };
//    
//    textView.attributedText = [[NSAttributedString alloc] initWithString:string attributes:ats];
//    textView.text = @"";
//}

- (UILabel*)createLableTitle:(NSString*)inTitle fontName:(NSString*)inFontName textSize:(CGFloat)inFloat tag:(int)inTag
{
    UILabel *tempLabel=[[UILabel alloc]init];
    tempLabel.frame =  CGRectMake(15, 0, 320, 40);
    tempLabel.numberOfLines = 0;
    tempLabel.backgroundColor=[UIColor clearColor];
    if (inTag==1) {
        tempLabel.textColor = ELEMENT_FONT_COLOR;
    }else if (inTag==2){
        tempLabel.textColor = HEADER_FONT_COLOR;
    }
    tempLabel.font =[UIFont fontWithName:inFontName size:inFloat];
    tempLabel.text = inTitle;
    return tempLabel;
}


#pragma mark FooterSection
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,0,320,40)];
    tempView.backgroundColor=[UIColor clearColor];
    switch (section) {
        case DUserSecurity:
            [tempView addSubview:[self createLableTitle:@"Edit the email address and password assoicated with your Describe identity." fontName:@"HelveticaNeue-Light" textSize:10.0 tag:1]];
            return tempView;
            break;
        default:
            break;
    }
    return Nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section) {
        case DUserInformation:
            return 10;
            break;
        case DUserSecurity:
            return 30;
        case DUserCity:
            return 20;
        default:
            break;
    }
    return 10;
}


#pragma mark HeaderSection
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView * imageView =[self createBackGroundImageView:[UIImage imageNamed:@"set_header.png"]];
    switch (section) {
        case DUserBio:
            [imageView addSubview:[self createLableTitle:@"Write about yourself." fontName:@"HelveticaNeue-Thin" textSize:20.0 tag:2]];
            return imageView;
            break;
        default:
            break;
    }
    return Nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case DUserBio:
            return 40;
            break;
        case DUserInformation:
            return 15;
            break;
        default:
            break;
    }
    return 10;
}


-(UIImageView*)createBackGroundImageView:(UIImage*)inImage
{
    UIImageView * image = [[UIImageView alloc]initWithImage:inImage];
    return image;
}

- (UITextField*)createDetailTextField:(UITableViewCell*)inTableViewCell AndTag:(editAccountTyopes)tag
{
    UITextField * textField = [[UITextField alloc]initWithFrame:CGRectMake(100, 0, 220, 36)];
    textField.delegate = self;
    textField.tag = tag;
    return textField;
}


- (UILabel *)createLabel:(UITableViewCell*)inTableviewCell
{
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, CGRectGetWidth(inTableviewCell.bounds)-45, 36)];
    return label;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)willPresentActionSheet:(UIActionSheet *)actionSheet;
{
    switch (actionSheet.tag) {
        case DMaleTag:{
            [self showPickerView:actionSheet];
        }
            break;
        case DdateTag:{
            [self showDatePickerView:actionSheet];
        }
            break;
        default:
            break;
    }
}


#pragma mark picker
- (void)showPickerView:(UIActionSheet*)inActionSheet
{
    UIToolbar *_myToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self setToolBarColor:_myToolBar];
    NSMutableArray *_toolBarItems = [[NSMutableArray alloc]init];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelClicked)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];  space.enabled =NO;
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked)];
    [_toolBarItems addObject:cancel];
    [_toolBarItems addObject:space];
    [_toolBarItems addObject:done];
    [_myToolBar setItems:_toolBarItems animated:NO];
    [inActionSheet addSubview:_myToolBar];
    
    UIPickerView *_pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 320, 170)];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.showsSelectionIndicator=YES;
    [inActionSheet addSubview:_pickerView];
    [_pickerView setBackgroundColor:[UIColor whiteColor]];
    for (int i = 0; i<self.optionsArr.count; i++) {
        if ([[self.optionsArr objectAtIndex:i] isEqualToString:selectedTxt]) {
            [_pickerView selectRow:i inComponent:0 animated:YES];
        }
    }
    
 }


- (void)setToolBarColor:(UIToolbar*)inToolBar
{
    inToolBar.tintColor =[UIColor whiteColor];//
    inToolBar.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:168.0/255.0 blue:157.0/255.0 alpha:1.0];
    inToolBar.barStyle = UIBarStyleBlackTranslucent;
    [inToolBar setBackgroundImage:[UIImage new]
               forToolbarPosition:UIBarPositionAny
                       barMetrics:UIBarMetricsDefault];
}

#pragma mark datepicker
-(void)showDatePickerView:(UIActionSheet*)inActionSheet
{
    UIDatePicker* _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.hidden = NO;
    _datePicker.date = [NSDate date];
    [_datePicker setBackgroundColor:[UIColor whiteColor]];
    [inActionSheet addSubview:_datePicker];
    self.datePicker = _datePicker;
    UIToolbar *_myToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _myToolBar.backgroundColor =[UIColor colorWithRed:53.0/255.0 green:168.0/255.0 blue:157.0/255.0 alpha:1.0];
    _myToolBar.tintColor =[UIColor whiteColor];
    _myToolBar.barStyle = UIBarStyleBlackTranslucent;
    [self setToolBarColor:_myToolBar];
    NSMutableArray *_toolBarItems = [[NSMutableArray alloc]init];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelDatePicker)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];  space.enabled =NO;
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(selectDateFromDatePickerView)];
    
    [_toolBarItems addObject:cancel];
    [_toolBarItems addObject:space];
    [_toolBarItems addObject:done];
    
    [_myToolBar setItems:_toolBarItems animated:NO];
    [inActionSheet addSubview:_myToolBar];
}


- (void)cancelDatePicker
{
    [self.pickerActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}


- (void)selectDateFromDatePickerView
{
    [self.pickerActionSheet dismissWithClickedButtonIndex:1 animated:YES];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    userbirtdayString=[dateFormatter stringFromDate:[self.datePicker date]];
    isChangedUserData = YES;
    [self.acountDetailsTableView reloadData];
}

- (void)showAlertView
{
    UIAlertView* dialog = [[UIAlertView alloc]initWithTitle:@"Describe" message:@"Enter password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    dialog.tag = 1;
    dialog.alertViewStyle = UIAlertViewStylePlainTextInput;
    [dialog textFieldAtIndex:0].keyboardType = UIKeyboardTypeASCIICapable;
    [dialog textFieldAtIndex:0].keyboardAppearance=UIKeyboardAppearanceDefault;
    [dialog textFieldAtIndex:0].secureTextEntry=YES;
    CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 10.0);
    [dialog setTransform: moveUp];
    [dialog show];
}

-(void)alertView:(UIAlertView *)inalertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (inalertView.tag==10) return;
    UITextField *textField = [inalertView textFieldAtIndex:0];
    switch (buttonIndex) {
        case 0:
            break;
        case 1:{
            [[WSModelClasses sharedHandler]checkingTheUserPassword:textField.text UserUID:[NSString stringWithFormat:@"%@",[WSModelClasses sharedHandler].loggedInUserModel.userID]  response:^(BOOL success, id response){
                if (success) {
                    NSString * message = [[(NSDictionary*)response valueForKeyPath:@"DataTable.UserData.Msg"]objectAtIndex:0];
                    if ([message isEqualToString:@"FALSE"]) {
                        UIAlertView* dialog = [[UIAlertView alloc]initWithTitle:@"Describe" message:@"The password you have entered is incorrect." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        dialog.tag = 10;
                        [dialog show];
                    }else{
                        [self gotoUserSecurityView:textField.text];
                    }
                }else{
                }
            }];
            break;
    }
        default:
            break;
    }
}


- (void)gotoUserSecurityView:(NSString*)password;
{
    DESecurityViewCnt * security = [[DESecurityViewCnt alloc]initWithNibName:@"DESecurityViewCnt" bundle:Nil];
    [self.navigationController pushViewController:security animated:YES];
    security.userPassword = password;
    security.userEmailId = [WSModelClasses sharedHandler].loggedInUserModel.userEmail;
}


#pragma mark - Action sheet will present
- (void)inputAccessaryViewandTag:(int)inTag
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    aSheet.tag = inTag;
    aSheet.backgroundColor = [UIColor whiteColor];
    [aSheet showInView:self.view];
    [aSheet setFrame:CGRectMake(0, screenRect.size.height-170, 320, 170)];
    self.pickerActionSheet = aSheet;
//    return aSheet;
}


-(void)cancelClicked
{
    [self.pickerActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}


- (void)doneClicked
{
    [self.pickerActionSheet dismissWithClickedButtonIndex:1 animated:YES];
    
    [self.acountDetailsTableView reloadData];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [self.optionsArr count];
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    self.genderSting = [self.optionsArr objectAtIndex:row];
    if ([[self.optionsArr objectAtIndex:row] isEqualToString:@"Male"]) {
        gender = 1;
        [WSModelClasses sharedHandler].loggedInUserModel.gender =[NSNumber numberWithInt:1];
    }else if ([[self.optionsArr objectAtIndex:row] isEqualToString:@"Female"]){
        [WSModelClasses sharedHandler].loggedInUserModel.gender =[NSNumber numberWithInt:0];
        gender = 0;
    }else{
        
    }
    isChangedUserData = NO;
    return [self.optionsArr objectAtIndex:row];
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{

    
    if(textField.tag == DUserCity)
    {
        
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //[self showTableviewHalf];
    if(textField.tag == DUserCity)
    {
        _indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        _cityTableViewHeight = 200;
        [self.acountDetailsTableView reloadData];
    }
    else if(textField.tag == DUsernameTag)
        _indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if ([string isEqualToString:@""]) {
        return  YES;
    }
    if ([textField.text length] == 30) {
        return NO;
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.tag == DUerNameTxt) {
        isChangedUserData = YES;
        [WSModelClasses sharedHandler].loggedInUserModel.userName = textField.text;
    }else if (textField.tag  == DUserGenderTxt ){
        }
    else if(textField.tag == DUserCity)
    {
        _cityTableViewHeight = 40.;
        [self.acountDetailsTableView reloadData];
    }
    
    //[self showTableViewFull];
}


-(void)showTableviewHalf
{
    CGRect tableFrame = self.acountDetailsTableView.frame;
    tableFrame.size.height = ScreenHeight - (tableFrame.origin.y + 218.);
    [self.acountDetailsTableView setFrame:tableFrame];
   
    [self.acountDetailsTableView scrollToRowAtIndexPath:_indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)showTableViewFull
{
    CGRect tableFrame = self.acountDetailsTableView.frame;
    tableFrame.size.height = ScreenHeight - (tableFrame.origin.y);
    [self.acountDetailsTableView setFrame:tableFrame];
    
    [self.acountDetailsTableView scrollToRowAtIndexPath:_indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [WSModelClasses sharedHandler].loggedInUserModel.biodata = textView.text;
    isChangedUserData = YES;
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        //[self tableViewAnimatedWhileTypingTheDataWithFrame:CGRectMake(0, 65, self.acountDetailsTableView.frame.size.width, self.acountDetailsTableView.frame.size.height)];
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    
    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
    UIFont *font = textView.font;
    
    CGSize maximumSize = textView.frame.size;
    maximumSize.width -= 10.0f;
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:textView.font forKey: NSFontAttributeName];
    CGSize expectedLabelSize2 = [string boundingRectWithSize:maximumSize
                                                     options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:stringAttributes context:nil].size;
    
    float numberOfLines = expectedLabelSize2.height / font.lineHeight;
    //    NSLog(@"numberOfLines = %f", numberOfLines);
    if(numberOfLines > 3.0) {
        return NO;
    }
    
    return YES;
}

-(void)updateTheUserInformation
{
   [[WSModelClasses sharedHandler]updateTheUserInformationDataUSerID:[NSString stringWithFormat:@"%@",[WSModelClasses sharedHandler].loggedInUserModel.userID] userName:[WSModelClasses sharedHandler].loggedInUserModel.userName userCity:[WSModelClasses sharedHandler].loggedInUserModel.city userDob:[NSString convertTheDateToepochtime:userbirtdayString ] userGender:[NSString stringWithFormat:@"%d",gender] userBioData:[WSModelClasses sharedHandler].loggedInUserModel.biodata responce:^(BOOL success, id responce){
       if (success) {
           isChangedUserData = YES;
           [self.navigationController popViewControllerAnimated:YES];
       }
    }];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    _indexPath = [NSIndexPath indexPathForRow:0 inSection:DUserBio];
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    //[self showTableviewHalf];
}
- (void)textViewDidEndEditing:(UITextView *)textView;
{
    [WSModelClasses sharedHandler].loggedInUserModel.biodata = textView.text;
    //[self showTableViewFull];
    
    //_indexPath = nil;
}


-(void)registerKeyboardNotifications
{
    // Add two notifications for the keyboard. One when the keyboard is shown and one when it's about to hide.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillShown:(NSNotification *)notification
{
    id object = [notification object];
    NSLog(@"Notification:%@",object);
    
    [self showTableviewHalf];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    id object = [notification object];
    NSLog(@"Notification 222:%@",object);
    
    [self showTableViewFull];
}


//- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
//    //[self tableViewAnimatedWhileTypingTheDataWithFrame:CGRectMake(0, -50, self.acountDetailsTableView.frame.size.width, self.acountDetailsTableView.frame.size.height)];
//    return YES;
//}

//
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    [WSModelClasses sharedHandler].loggedInUserModel.biodata = textView.text;
//    if ([text isEqualToString:@"\n"]) {
//         [self tableViewAnimatedWhileTypingTheDataWithFrame:CGRectMake(0, 65, self.acountDetailsTableView.frame.size.width, self.acountDetailsTableView.frame.size.height)];
//        [textView resignFirstResponder];
//
//        return NO; // or true, whetever you's like
//    }
//    
//    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
//    UIFont *font = textView.font;
//    
//    CGSize maximumSize = textView.frame.size;
//    maximumSize.width -= 10.0f;
//    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:textView.font forKey: NSFontAttributeName];
//    CGSize expectedLabelSize2 = [string boundingRectWithSize:maximumSize
//                                                     options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
//                                                  attributes:stringAttributes context:nil].size;
//    
//    float numberOfLines = expectedLabelSize2.height / font.lineHeight;
////    NSLog(@"numberOfLines = %f", numberOfLines);
//    if(numberOfLines > 3.0) {
//        return NO;
//    }
//    
//    return YES;
//}


-(void)tableViewAnimatedWhileTypingTheDataWithFrame:(CGRect)rect
{
    [UIView animateWithDuration:.25f animations:^{
        self.acountDetailsTableView.frame = rect;
    } completion:^(BOOL finished) {
    }];
}

-(void)removeTheKeysInUserDefaults
{
   [[NSUserDefaults standardUserDefaults]removeObjectForKey:USERSAVING_DATA_KEY];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:USER_PUSHNOTIFICATIONS];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:USER_EMAILNOTIFICAIONS];
    [[DESocialConnectios sharedInstance]logoutGooglePlus];
    [[DESocialConnectios sharedInstance]logoutFacebook];
    [[NSUserDefaults standardUserDefaults]synchronize ];
}
@end
