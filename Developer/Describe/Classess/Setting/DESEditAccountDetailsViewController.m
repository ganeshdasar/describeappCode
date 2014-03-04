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
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.acountDetailsTableView.frame = CGRectMake(0, self.acountDetailsTableView.frame.origin.x
                                                   , 320,  screenRect.size.height-65);
    self.acountDetailsTableView.backgroundColor = [UIColor clearColor];
    self.acountDetailsTableView.showsVerticalScrollIndicator = NO;
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
    _userinfoDetailsArray = [NSArray arrayWithObjects:@"mahesh ",@"Male",@"jun-25-1990", nil];
     self.optionsArr = [[NSMutableArray alloc] initWithObjects:@"Not specified",@"Male",@"Female", nil];
    self.dateString = @"March 22 2013";
    self.genderSting = @"Male";
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
    [self.navigationController popViewControllerAnimated:YES];
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
        genderLbl  = [self createLabel:cell];
        genderLbl.tag = DGenderLblTag;
        [cell.contentView addSubview:genderLbl];
        datelabl = [self createLabel:cell];
        datelabl.tag = DdateLblTag;
        [cell.contentView addSubview:datelabl];
    }
    switch (indexPath.section) {
        case DUserInformation:{
            cell.textLabel.text = _userInfoArray[indexPath.row];
            cell.textLabel.textColor = [UIColor textPlaceholderColor];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
            
            if (indexPath.row==DUerNameTxt) {
                UITextField * name = [self createDetailTextField:cell];
                name.textColor = [UIColor textFieldTextColor];
                name.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
                name.text =@"textview";
                [cell.contentView addSubview:name];
            }else if (indexPath.row == DUserGenderTxt){
                genderLbl  = (UILabel*) [cell viewWithTag:DGenderLblTag];
                genderLbl.textColor = [UIColor textFieldTextColor];
                genderLbl.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
                genderLbl.text = self.genderSting;
                selectedTxt =[NSString stringWithFormat:@"%@",@"Female"];
            }else if (indexPath.row ==DUserBirhDayTxt ){
                datelabl  = (UILabel*) [cell viewWithTag:DdateLblTag];
                datelabl.textColor = [UIColor textFieldTextColor];
                datelabl.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
                datelabl.text =self.dateString;
                //  gender.inputAccessoryView =
            }
            break;
        }
        case DUserCity:{
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
            cell.textLabel.text =@"City";
            cell.textLabel.textColor = [UIColor textFieldTextColor];
            UITextField * city = [self createDetailTextField:cell];
            city.textColor = [UIColor textFieldTextColor];
            city.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
            city.text =@"Hyderabad";
            //  gender.inputAccessoryView =
            [cell.contentView addSubview:city];
            break;
            
        }
        case DUserBio:{
            UITextView * textview = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
            textview.backgroundColor = [UIColor clearColor];
            UIImageView * image = [self createBackGroundImageView:[UIImage imageNamed:@"set_about.png"]];
            cell.backgroundView = image;
            textview.delegate =self;
            textview.layoutManager.delegate = self;
            textview.textContainer.lineFragmentPadding = 10;
            textview.contentInset=UIEdgeInsetsZero;
            textview.scrollEnabled = NO;
            textview.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
            [cell.contentView addSubview:textview];
            
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
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case DUserSecurity:{
            [self showAlertView];
            break;
        }
        case DUserInformation:{
            if (indexPath.row == 1) {
                [self inputAccessaryViewandTag:DMaleTag];
            }else if (indexPath.row==2){
                [self inputAccessaryViewandTag:DdateTag];
            }
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case DUserBio:
            return 118;
            break;
        default:
            return 40;
            break;
    }
}


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

- (UITextField*)createDetailTextField:(UITableViewCell*)inTableViewCell
{
    UITextField * textField = [[UITextField alloc]initWithFrame:CGRectMake(100, 0, 220, 36)];
    textField.delegate = self;
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
-(void)showPickerView:(UIActionSheet*)inActionSheet
{
    UIPickerView *_pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.showsSelectionIndicator=YES;
    [inActionSheet addSubview:_pickerView];
    [_pickerView setBackgroundColor:[UIColor whiteColor]];
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
    UIDatePicker* _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
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
    
   self.dateString=[dateFormatter stringFromDate:[self.datePicker date]];
    NSLog(@"date sting %@",self.dateString);
    [self.acountDetailsTableView reloadData];
}

- (void)showAlertView
{
    UIAlertView* dialog = [[UIAlertView alloc]initWithTitle:@"Describe" message:@"Enter password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    dialog.tag = 1;
    dialog.alertViewStyle = UIAlertViewStylePlainTextInput;
    [dialog textFieldAtIndex:0].keyboardType = UIKeyboardTypeASCIICapable;
    [dialog textFieldAtIndex:0].keyboardAppearance=UIKeyboardAppearanceDefault;
    CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 10.0);
    [dialog setTransform: moveUp];
    [dialog show];
}

-(void)alertView:(UIAlertView *)inalertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //UITextField *textField = [inalertView textFieldAtIndex:0];
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [self gotoUserSecurityView];
            break;
        default:
            break;
    }
}


- (void)gotoUserSecurityView
{
    DESecurityViewCnt * security = [[DESecurityViewCnt alloc]initWithNibName:@"DESecurityViewCnt" bundle:Nil];
    [self.navigationController pushViewController:security animated:YES];
}


#pragma mark - Action sheet will present
- (UIActionSheet*)inputAccessaryViewandTag:(int)inTag
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    aSheet.tag = inTag;
    aSheet.backgroundColor = [UIColor whiteColor];
    [aSheet showInView:[self.view superview]];
    [aSheet setFrame:CGRectMake(0, screenRect.size.height-180, 320, 180)];
    self.pickerActionSheet = aSheet;
    return aSheet;
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
    return [self.optionsArr objectAtIndex:row];
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

@end
