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
}

@property (nonatomic, strong) UIImage *previousPicRef;

@end

@implementation DescBasicinfoViewController
@synthesize bioTxt,birthdayTxt,cityTxt;
@synthesize cityTableView;
@synthesize userBasicInfoDic;
@synthesize isGenderMale;

-(UIStatusBarStyle)preferredStatusBarStyle{
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
-(void)designTheView
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

-(void)createProfilePicAspectView{
    _profilePicContainerView.layer.cornerRadius = CGRectGetHeight(_profilePicContainerView.frame)/2.0f;
    _profilePicContainerView.layer.masksToBounds = YES;
    _profilePicContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
    _profilePicContainerView.layer.borderWidth = 0.5f;
    
    // adding aspectFillController here
    profilePicAspectController = [[DBAspectFillViewController alloc] initWithNibName:@"DBAspectFillViewController" bundle:nil];
    [profilePicAspectController.view setFrame:_profilePicContainerView.bounds];
    [profilePicAspectController setScreenSize:_profilePicContainerView.frame.size];
    [_profilePicContainerView addSubview:profilePicAspectController.view];
    [_profilePicContainerView sendSubviewToBack:profilePicAspectController.view];
    
    [profilePicAspectController.imageView addGestureRecognizer:_profileTapGestureRef];
    
}
-(void)setBackGroundimageView
{
    if (isiPhone5)
    {
        self.backGroundImageView.image = [UIImage imageNamed:@"bg_std_4in.png"];
    }else{
        self.backGroundImageView.image = [UIImage imageNamed:@"bg_std_3.5in.png"];
        
    }
}

#pragma mark Design HeadeView
-(void)fillTheBasicInfoDataInFields
{
    DESAppDelegate * appDelegate = (DESAppDelegate*)[UIApplication sharedApplication].delegate;
    if (appDelegate.isFacebook) {
        [self downloadUserImageview:[self.userBasicInfoDic valueForKeyPath:@"picture.data.url"]];
        self.cityTxt.text =[self.userBasicInfoDic valueForKeyPath:@"location.name"];
        self.birthdayTxt.text   = [self.userBasicInfoDic valueForKeyPath:@"birthday"];
        if ([[self.userBasicInfoDic valueForKey:@"gender"] isEqualToString:@"female"]) {
            [self femaleClicked:Nil];
        }else{
            [self maleClicked:Nil];
        }
    }else if (appDelegate.isGooglePlus){
        [self downloadUserImageview:[self.userBasicInfoDic valueForKeyPath:@"url"]];
    }
}
-(void)downloadUserImageview:(NSString*)inUrlString
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
                self.userprofileImg.image = [UIImage imageWithData:avatarData];
                
            });
        }
    });
}

-(void)designHeaderView
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
   
    WSModelClasses * modelClass = [WSModelClasses sharedHandler];
    modelClass.delegate  =self;
    NSString * gender =Nil;
    if (isGenderMale) {
        gender = @"1";
    }else{
        gender = @"0";

    }
    [modelClass postBasicInfoWithUserUID:[[NSUserDefaults standardUserDefaults]valueForKey:@"USERID" ] userBioData:self.bioTxt.text userCity:self.cityTxt.text   userDob:@"1980-02-21" userGender:gender profilePic:self.userprofileImg.image];
    return;

    DescAddpeopleViewController * addPeople = [[DescAddpeopleViewController alloc]initWithNibName:@"DescAddpeopleViewController" bundle:nil];
    [self.navigationController pushViewController:addPeople animated:NO];
}

-  (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)maleClicked:(id)sender
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

- (IBAction)selectprofileimg:(id)sender {
    
    UIActionSheet *chooseOption = [[UIActionSheet alloc] initWithTitle:@"ChooseSource" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"PhotoLibrary", nil];
    [chooseOption showInView:self.view];
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
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

-  (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [profilePicAspectController placeSelectedImage:info[UIImagePickerControllerOriginalImage] withCropRect:CGRectNull];
    
    isEditingPic = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    _profileEditCancelBtn.hidden = NO;
    _profileEditDoneBtn.hidden = NO;
    //    _completeProfileView.hidden = YES;
    _profilePicOverlayView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    
    [profilePicAspectController enableTouches:YES];
    [_profilePicOverlayView setDontPassTouch:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    isEditingPic = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    _profileEditCancelBtn.hidden = NO;
    _profileEditDoneBtn.hidden = NO;
    _profilePicOverlayView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    
    [profilePicAspectController enableTouches:YES];
    [_profilePicOverlayView setDontPassTouch:YES];
    [self hideAndShowView:NO];
    
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

- (IBAction)selectTheDate:(id)sender {
    
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    //[self.datePicker addTarget:self action:@selector(dueDateChanged:) forControlEvents:UIControlEventValueChanged];
//    CGSize pickerSize = [picker sizeThatFits:CGSizeZero];
//    picker.frame = CGRectMake(0.0, 340, pickerSize.width, 460);
    
    CGRect rect;
	rect = [self.datePickerView frame];
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if (result.height < 500)
    {
        //4s
        rect.origin.y = 160;
    }
    else
    {
        //5
        rect.origin.y = 340;
    }
    
    
	
	rect.size.height = 280;
    self.datePickerView.frame = rect;
	
	[self.view addSubview:self.datePickerView];
}


- (IBAction)dateDoneClicked:(id)sender {
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    
    self.birthdayTxt.text=[dateFormatter stringFromDate:[self.datePicker date]];
      [self.birthdayTxt setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0]];
    [self.datePickerView removeFromSuperview];

}

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

-(void) dueDateChanged:(UIDatePicker *)sender {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
}

#pragma mark textField Delegate Method
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
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
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag==11) {
        [self textFieldAnimation:YES];
    }
    return YES;
}
-(void)textFieldAnimation:(BOOL)inAnimation{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.5];
    if (inAnimation) {
        self.userprofileImg.hidden = YES;
        self.profileimgbtn.hidden = YES;
        self.cityTxt.frame = CGRectMake(25, 89, 270, 42);
        self.cityTxtImageView.frame = CGRectMake(25, 89, 270, 42);
        
    }else{
        self.cityTxt.frame = CGRectMake(25, 189, 270, 42);
        self.cityTxtImageView.frame = CGRectMake(25, 189, 270, 42);
        self.userprofileImg.hidden = NO;
        self.profileimgbtn.hidden = NO;

           }
  
    [UIView commitAnimations];
    self.cityTableView.hidden = YES;
    
}
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
#pragma mark service delegate method
- (void)basicinfoStatus:(NSDictionary *)responseDict error:(NSError *)error{
    
    
}
#pragma mark -
#pragma mark connection


- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    if (searchResultPlaces.count)
return [searchResultPlaces objectAtIndex:indexPath.row];
    return Nil;
}
#pragma mark tableview delegate method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [searchResultPlaces count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.cityTxt.text = [self placeAtIndexPath:indexPath].name;
    tableView.hidden = YES;
    [self textFieldAnimation:NO];
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
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
-(void)footerSelected{
    
    self.cityTableView.hidden=YES;
    [self textFieldAnimation:NO];
    
}


- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 16;
    
}
-(void)hideAndShowView:(BOOL)inBool{
    self.txtBioImgView.hidden = inBool;
    self.cityTxtImgView.hidden = inBool;
    self.dateofBirthImgView.hidden = inBool;
    self.cityTxt.hidden = inBool;
    self.birthdayTxt.hidden = inBool;
    self.btnfemale.hidden = inBool;
    self.btnmale.hidden = inBool;
    
}
@end
