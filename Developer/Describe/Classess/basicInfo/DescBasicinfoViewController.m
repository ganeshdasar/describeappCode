//
//  DescBasicinfoViewController.m
//  Describe
//
//  Created by NuncSys on 30/12/13.
//  Copyright (c) 2013 App. All rights reserved.
//

#import "DescBasicinfoViewController.h"
#import <QuartzCore/CAAnimation.h>
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "DHeaderView.h"
#import "DESAppDelegate.h"
#import "WSModelClasses.h"
#import "DBAspectFillViewController.h"
#import "Constant.h"
#import "NotificationsViewController.h"
//#import "NSString+DateConverter.h"
#import "CMViewController.h"

#define CITYTEXTFRAME CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-44)
#define MALEBTNFRAME
#define FEMALEBTNFRAME
#define BIRTHDAYFRAME
#define BIOTEXTFRAME

@interface DescBasicinfoViewController ()<WSModelClassDelegate,UITextViewDelegate,NSLayoutManagerDelegate>{
    IBOutlet DHeaderView *_headerView;
    UIButton    *backButton,*nextButton;
    NSString * _searchString;
    DBAspectFillViewController *profilePicAspectController;
    
    float lastScale;
    CGPoint lastPanPoint;
    BOOL isEditingPic;
    
    UsersModel *profileUserDetail;
    
}

@property (nonatomic, strong) UIImage *previousPicRef;

@end

@implementation DescBasicinfoViewController
@synthesize bioTxt,birthdayTxt,cityTxt;
@synthesize cityTableView;
@synthesize userBasicInfoDic;
@synthesize isGenderMale;

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] init];
        searchQuery.radius = 100.0;
        shouldBeginEditing = NO;
    }
    return self;
}

- (void)viewDidLoad
{
        [super viewDidLoad];
        [self designHeaderView];
        [self setBackGroundimageView];
        [self.datePicker  setDate:[NSDate date] animated:NO];
        self.datePicker.maximumDate=[NSDate date];
        isEditingPic = NO;  // by default profile pic editing is NO
        [self designTheView];
        [self createProfilePicAspectView];
}

-  (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-  (void)designTheView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(35, 131, 250, 200) style:UITableViewStylePlain];
    self.cityTableView = tableView;
    tableView.scrollEnabled = NO;
    [self.view addSubview:self.cityTableView];
    self.cityTableView.dataSource = self;
    self.cityTableView.delegate = self;
    self.cityTableView.hidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    [self fillTheBasicInfoDataInFields];
    self.bioTxt.delegate =self;
    self.bioTxt.layoutManager.delegate = self;
    self.bioTxt.textContainer.lineFragmentPadding = 0;
    self.bioTxt.contentInset=UIEdgeInsetsZero;
    self.bioTxt.scrollEnabled = NO;
    
    self.bioTxt.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
}

- (void)createProfilePicAspectView
{
    _profilePicContainerView.layer.cornerRadius = CGRectGetHeight(_profilePicContainerView.frame)/2.0f;
    _profilePicContainerView.layer.masksToBounds = YES;
    _profilePicContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
    _profilePicContainerView.layer.borderWidth = 0.5f;
    profilePicAspectController = [[DBAspectFillViewController alloc] initWithNibName:@"DBAspectFillViewController" bundle:nil];
    [profilePicAspectController.view setFrame:_profilePicContainerView.bounds];
    [profilePicAspectController setScreenSize:_profilePicContainerView.frame.size];
    [_profilePicContainerView addSubview:profilePicAspectController.view];
    [_profilePicContainerView sendSubviewToBack:profilePicAspectController.view];
    [profilePicAspectController.imageView addGestureRecognizer:_profileTapGestureRef];
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
- (void)fillTheBasicInfoDataInFields
{
    profileUserDetail = [WSModelClasses sharedHandler].loggedInUserModel;
    if (profileUserDetail.city) {
        self.cityTxt.text = profileUserDetail.city;
    }
    
    if (profileUserDetail.profileImageName){
        [self downloadUserImageview:profileUserDetail.profileImageName];
    }
    
    if ([profileUserDetail.gender isEqualToNumber:[NSNumber numberWithInt:1]]){
        [self maleClicked:nil];
    }
    
    if ([profileUserDetail.gender isEqualToNumber:[NSNumber numberWithInt:0]]){
        [self femaleClicked:nil];
    }
    
    if (profileUserDetail.dobDate){
//       self.birthdayTxt.text =[NSString convertTheepochTimeToDate:[profileUserDetail.dobDate doubleValue]];
    }
    
    if (profileUserDetail.biodata) {
        self.bioTxt.text = profileUserDetail.biodata;
    }
}

- (void)downloadUserImageview:(NSString*)inUrlString
{
    dispatch_queue_t backgroundQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
        NSData *avatarData = nil;
        NSString *imageURLString = inUrlString;
        if (imageURLString) {
            NSURL *imageURL = [NSURL URLWithString:imageURLString];
            avatarData = [NSData dataWithContentsOfURL:imageURL];
        }
        if (avatarData) {
            // Update UI from the main thread when available
            dispatch_async(dispatch_get_main_queue(), ^{
                profilePicAspectController.imageView.image =  [UIImage imageWithData:avatarData];
            });
        }
    });
}

- (void)designHeaderView
{
    backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goToPeviousScreen:) forControlEvents:UIControlEventTouchUpInside];
    nextButton = [[UIButton alloc] init];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_next.png"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(goToAddPeopleScreen:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView designHeaderViewWithTitle:@"Basic Info" andWithButtons:@[nextButton]];
}

#pragma mark ButtonActions
- (void)goToPeviousScreen:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goToAddPeopleScreen:(id)sender
{
    [self saveBasicInfoDetails];
}

-  (IBAction)maleClicked:(id)sender
{
    self.isGenderMale = YES;
    [self.btnmale setImage:[UIImage imageNamed:@"male_active.png"] forState:UIControlStateNormal];
    [self.btnfemale setImage:[UIImage imageNamed:@"female_inactive.png"] forState:UIControlStateNormal];
}

- (IBAction)femaleClicked:(id)sender
{
    self.isGenderMale = NO;
    [self.btnmale setImage:[UIImage imageNamed:@"male_inactive.png"] forState:UIControlStateNormal];
    [self.btnfemale setImage:[UIImage imageNamed:@"female_active.png"] forState:UIControlStateNormal];
}

- (IBAction)profilePicTapped:(id)sender
{
    if(isEditingPic) {
        return;
    }
    [self hideAndShowView:YES];
    _previousPicRef = profilePicAspectController.imageView.image;
    UIActionSheet *chooseOption = [[UIActionSheet alloc] initWithTitle:@"ChooseSource" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"PhotoLibrary", nil];
    [chooseOption showInView:self.view];
}

- (IBAction)selectTheDate:(id)sender
{
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    CGRect rect;
	rect = [self.datePickerView frame];
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if (result.height < 500){
        rect.origin.y = 160;
    }
    else{
        rect.origin.y = 340;
    }
 	rect.size.height = 280;
    self.datePickerView.frame = rect;
	[self.view addSubview:self.datePickerView];
}

- (IBAction)dateDoneClicked:(id)sender
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    self.birthdayTxt.text=[dateFormatter stringFromDate:[self.datePicker date]];
    [self.birthdayTxt setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0]];
    [self.datePickerView removeFromSuperview];
}

- (IBAction)cancelProfilePicChanges:(id)sender
{
    isEditingPic = NO;
    _profileEditCancelBtn.hidden = YES;
    _profileEditDoneBtn.hidden = YES;
    //    _completeProfileView.hidden = YES;
    _profilePicOverlayView.backgroundColor = [UIColor clearColor];
    [profilePicAspectController enableTouches:NO];
    [_profilePicOverlayView setDontPassTouch:NO];
    [self hideAndShowView:NO];
    [profilePicAspectController placeSelectedImage:_previousPicRef withCropRect:CGRectNull];
}

- (IBAction)doneProfilePicChange:(id)sender
{
    isEditingPic = NO;
    UIImage *croppedImage = [profilePicAspectController getImageCroppedAtVisibleRect:profilePicAspectController.cropRect];
    [profilePicAspectController placeSelectedImage:croppedImage withCropRect:CGRectNull];
    _profileEditCancelBtn.hidden = YES;
    _profileEditDoneBtn.hidden = YES;
    //    _completeProfileView.hidden = YES;
    _profilePicOverlayView.backgroundColor = [UIColor clearColor];
    [profilePicAspectController enableTouches:NO];
    [_profilePicOverlayView setDontPassTouch:NO];
    [self hideAndShowView:NO];
}

- (IBAction)selectprofileimg:(id)sender
{
    UIActionSheet *chooseOption = [[UIActionSheet alloc] initWithTitle:@"ChooseSource" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"PhotoLibrary", nil];
    [chooseOption showInView:self.view];
}

#pragma mark - UIActionsheet delegate method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0) {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *openLibrary = [[UIImagePickerController alloc] init];
            openLibrary.sourceType = UIImagePickerControllerSourceTypeCamera;
            openLibrary.delegate = self;
            [self presentViewController:openLibrary animated:YES completion:nil];
        }
    }
    else if(buttonIndex==1) {
        UIImagePickerController *openLibrary = [[UIImagePickerController alloc] init];
        openLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        openLibrary.delegate = self;
        [self presentViewController:openLibrary animated:YES completion:nil];
    }
    else if(buttonIndex == 2) {
        //cancel
        [self hideAndShowView:NO];
    }
}

#pragma mark - UIImagePickerController Delegate Methods
-  (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [profilePicAspectController placeSelectedImage:info[UIImagePickerControllerOriginalImage] withCropRect:CGRectNull];
    isEditingPic = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
    _profileEditCancelBtn.hidden = NO;
    _profileEditDoneBtn.hidden = NO;
    _profilePicOverlayView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [profilePicAspectController enableTouches:YES];
    [_profilePicOverlayView setDontPassTouch:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    isEditingPic = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
    _profileEditCancelBtn.hidden = YES;
    _profileEditDoneBtn.hidden = YES;
    _profilePicOverlayView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [profilePicAspectController enableTouches:YES];
    [_profilePicOverlayView setDontPassTouch:YES];
    [self hideAndShowView:NO];
}

#pragma mark - Gesture recognizer methods
- (IBAction)profilePicPinchGesture:(id)sender
{
    if(!isEditingPic) {
        return;
    }
    UIPinchGestureRecognizer *pinchGesture = (UIPinchGestureRecognizer *)sender;
    if(pinchGesture.numberOfTouches != 2) {
        return;
    }
    if(pinchGesture.state == UIGestureRecognizerStateBegan) {
        lastScale = 1.0f;
    }
    CGFloat scale = 1.0 - (lastScale - pinchGesture.scale);
    [profilePicAspectController.imageContentScrollView setZoomScale:scale animated:YES];
}

- (IBAction)profilePicPanGesture:(id)sender
{
    if(!isEditingPic) {
        return;
    }
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)sender;
    if(panGesture.state == UIGestureRecognizerStateEnded) {
        return;
    }
    if(panGesture.state == UIGestureRecognizerStateBegan) {
        lastPanPoint = [panGesture locationInView:_profilePicOverlayView];
    }
    CGPoint point = [panGesture locationInView:_profilePicOverlayView];
    point.x -= lastPanPoint.x;
    point.y -= lastPanPoint.y;
    lastPanPoint = [panGesture locationInView:_profilePicOverlayView];
    point.x = -point.x;
    point.y = -point.y;
    CGPoint scrollPoint = profilePicAspectController.imageContentScrollView.contentOffset;
    point.x += scrollPoint.x;
    point.y += scrollPoint.y;
    if(point.x < 0) {
        point.x = 0;
    }
    
    if(point.x > profilePicAspectController.imageContentScrollView.contentSize.width - profilePicAspectController.imageContentScrollView.frame.size.width) {
        point.x = profilePicAspectController.imageContentScrollView.contentSize.width - profilePicAspectController.imageContentScrollView.frame.size.width;
    }
    
    if(point.y < 0) {
        point.y = 0;
    }
    
    if(point.y > profilePicAspectController.imageContentScrollView.contentSize.height - profilePicAspectController.imageContentScrollView.frame.size.height) {
        point.y = profilePicAspectController.imageContentScrollView.contentSize.height - profilePicAspectController.imageContentScrollView.frame.size.height;
    }
    
    [profilePicAspectController.imageContentScrollView setContentOffset:point animated:NO];
    [profilePicAspectController calculateCropRectForSelectImage];
}

- (void)dueDateChanged:(UIDatePicker *)sender
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
}

#pragma mark textField Delegate Method
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    searchQuery.input = searchStr;
    if (!shouldBeginEditing) {
        [self textFieldAnimation:YES];
    }
    self.cityTableView.hidden= NO;
    [self.cityTableView reloadData];
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
        } else {
            NSMutableArray * array =(NSMutableArray*)places;
            if (places.count ==5) {
                [array removeLastObject];
            }
            searchResultPlaces = array;
            if (searchResultPlaces.count) {
            }
        }
    }];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField.tag==11) {
        [self textFieldAnimation:NO];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag==11) {
        [self textFieldAnimation:YES];
    }
    return YES;
}

- (void)textFieldAnimation:(BOOL)inAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.5];
    if (inAnimation) {
        self.userprofileImg.hidden = YES;
        self.profileimgbtn.hidden = YES;
        CGRect frame  =  self.cityTxt.frame;
        frame.origin.y = 89;
        self.cityTxt.frame =frame;
        self.cityTxtImageView.frame = CGRectMake(25, 89, 270, 42);
    }else{
        CGRect frame  =  self.cityTxt.frame;
        frame.origin.y = 189;
        self.cityTxt.frame =frame;
        self.cityTxtImageView.frame = CGRectMake(25, 189, 270, 42);
        self.userprofileImg.hidden = NO;
        self.profileimgbtn.hidden = NO;
    }
    [UIView commitAnimations];
    self.cityTableView.hidden = YES;
}

#pragma mark - UITextviewDelegate Method
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

#pragma mark - Webservices Methods
- (void)saveBasicInfoDetails
{
    WSModelClasses * modelClass = [WSModelClasses sharedHandler];
    modelClass.delegate = self;
    NSString * gender = nil;
    if (isGenderMale) {
        gender = @"1";
    }
    else{
        gender = @"0";
    }
    [modelClass postBasicInfoWithUserUID: [NSString stringWithFormat:@"%@",profileUserDetail.userID] userBioData:self.bioTxt.text userCity:self.cityTxt.text   userDob: [NSString convertTheDateToepochtime:(NSString*)self.birthdayTxt.text ]  userGender:gender profilePic:profilePicAspectController.imageView.image];

}

#pragma mark WebService Delegate method
- (void)didFinishWSConnectionWithResponse:(NSDictionary *)responseDict
{
    WebservicesType serviceType = (WebservicesType)[responseDict[WS_RESPONSEDICT_KEY_SERVICETYPE] integerValue];
    if(responseDict[WS_RESPONSEDICT_KEY_ERROR]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Describe", @"") message:NSLocalizedString(@"Error while communicating to server. Please try again later.", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    switch (serviceType) {
        case kWebservicesType_SaveBasicInfo:
        {
//            DescAddpeopleViewController * addPeople = [[DescAddpeopleViewController alloc]initWithNibName:@"DescAddpeopleViewController" bundle:nil];
//            [self.navigationController pushViewController:addPeople animated:NO];
            
//            NotificationsViewController *notificationController = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:nil];
//            [self.navigationController pushViewController:notificationController animated:YES];
            
            CMViewController *compositionViewController = [[CMViewController alloc] initWithNibName:@"CMViewController" bundle:nil];
            [self.navigationController pushViewController:compositionViewController animated:YES];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - GooglePlaces Delegate Method
- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath
{
    if (searchResultPlaces.count)
        return [searchResultPlaces objectAtIndex:indexPath.row];
    return Nil;
}

#pragma mark tableview delegate method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchResultPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 9.0;
    }
    // Configure the cell...
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0];
    cell.textLabel.text = [self placeAtIndexPath:indexPath].name;
    return cell;
}

-  (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.cityTxt.text = [self placeAtIndexPath:indexPath].name;
    tableView.hidden = YES;
    [self textFieldAnimation:NO];
}

-  (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
{
    UIView* footer = [[UIView alloc] initWithFrame:CGRectMake(self.cityTableView.frame.origin.x
                                                              , self.cityTableView.frame.origin.y, 250, 30)];
    footer.backgroundColor = [UIColor whiteColor];
    
    UITextField* field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    [field setBorderStyle:UITextBorderStyleNone];
    field.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0];
    field.text = [NSString stringWithFormat:@" '%@' ",cityTxt.text];//self.cityTxt.text;
    [footer addSubview:field];
    [field addTarget:self action:@selector(footerSelected) forControlEvents:UIControlEventAllTouchEvents];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 30;
}

- (void)footerSelected
{
    self.cityTableView.hidden=YES;
    [self textFieldAnimation:NO];
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 16;
}

- (void)hideAndShowView:(BOOL)inBool
{
    self.txtBioImgView.hidden = inBool;
    self.cityTxtImgView.hidden = inBool;
    self.dateofBirthImgView.hidden = inBool;
    self.cityTxt.hidden = inBool;
    self.birthdayTxt.hidden = inBool;
    self.btnfemale.hidden = inBool;
    self.btnmale.hidden = inBool;
}


@end
