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
//#import "NotificationsViewController.h"
#import "NSString+DateConverter.h"
//#import "CMViewController.h"
#import "ProfileViewController.h"
#import "DESSettingsViewController.h"
#import "NSDate+DDate.h"

#define CITYTEXTFRAME CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-44)
#define MALEBTNFRAME
#define FEMALEBTNFRAME
#define BIRTHDAYFRAME
#define BIOTEXTFRAME

@interface DescBasicinfoViewController ()<WSModelClassDelegate,UITextViewDelegate,NSLayoutManagerDelegate>
{
    IBOutlet DHeaderView *_headerView;
    UIButton    *backButton,*nextButton;
    NSString * _searchString;
    DBAspectFillViewController *profilePicAspectController;
    
    float lastScale;
    CGPoint lastPanPoint;
    BOOL isEditingPic;
    
    UsersModel *profileUserDetail;
    IBOutlet UIView *_contentView;
    IBOutlet UIView *_subContentView;
    NSString *_selectedDob;
    id _currentTextField;
    
    BOOL shouldHideStatusBar;
    BOOL _isDatePickerVisble;
}

@property (nonatomic, strong) UIImage *previousPicRef;

-(IBAction)dateSelected:(id)sender;
-(IBAction)dateCancelButtonClicked:(id)sender;
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

- (BOOL)prefersStatusBarHidden
{
    return shouldHideStatusBar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self designHeaderView];
    [self setBackGroundimageView];
    [self.datePicker  setDate:[NSDate dateFromString:DefaultDate] animated:NO];
    self.datePicker.maximumDate=[NSDate date];
    isEditingPic = NO;  // by default profile pic editing is NO
    
    
    
    [self designTheView];
    [self createProfilePicAspectView];
    
    shouldHideStatusBar = NO;
    
    
    self.btnmale.selected = YES;
    self.cityTxt.returnKeyType = UIReturnKeyDone;
    self.bioTxt.returnKeyType = UIReturnKeyDone;

    [self lineSpacingFroTextView];
    
    
    
    return;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 50.0f;
    paragraphStyle.maximumLineHeight = 50.0f;
    paragraphStyle.minimumLineHeight = 50.0f;
    NSString *string = @"if you want reduce or increase space between lines in uitextview ,you can do this with this,but donot set font on this paragraph , set this on uitextveiw.";
    
    NSDictionary *ats = @{
                          NSParagraphStyleAttributeName : paragraphStyle,
                          };
    
    [self.bioTxt setFont:[UIFont fontWithName:@"Arial" size:20.0f]];
    self.bioTxt.attributedText = [[NSAttributedString alloc] initWithString:string attributes:ats];
    
    
}


- (void)lineSpacingFroTextView
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
    lab.text = @"";
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
    //tableView.scrollEnabled = NO;
    [self.view addSubview:self.cityTableView];
    self.cityTableView.dataSource = self;
    self.cityTableView.delegate = self;
    self.cityTableView.hidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    [self fillTheBasicInfoDataInFields];
    self.bioTxt.delegate =self;
//    self.bioTxt.layoutManager.delegate = self;
//    self.bioTxt.textContainer.lineFragmentPadding = 0;
//    self.bioTxt.contentInset=UIEdgeInsetsZero;
    self.bioTxt.scrollEnabled = NO;
    //self.cityTableView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.2];
    //self.bioTxt.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
}

- (void)createProfilePicAspectView
{
    
    _profileimgbtn.layer.cornerRadius = CGRectGetHeight(_profilePicContainerView.frame)/2.0f;
    _profileimgbtn.layer.masksToBounds = YES;
    _profileimgbtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _profileimgbtn.layer.borderWidth = 0.5f;
    [_profileimgbtn setSelected:NO];
    
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
        self.birthdayTxt.text =[NSString convertTheepochTimeToDate:[profileUserDetail.dobDate doubleValue]];
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
    
    
    if([[self.navigationController viewControllers] count] == 2)
        [backButton setHidden:YES];
    else
        [backButton setHidden:NO];
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
    [self.btnmale setSelected:YES];
    [self.btnfemale setSelected:NO];

}

- (IBAction)femaleClicked:(id)sender
{
    self.isGenderMale = NO;
    [self.btnmale setSelected:NO];
    [self.btnfemale setSelected:YES];
}

- (IBAction)profilePicTapped:(id)sender
{
    if(isEditingPic) {
        return;
    }
    [self hideAndShowView:YES];
    _previousPicRef = profilePicAspectController.imageView.image;
    UIActionSheet *chooseOption = [[UIActionSheet alloc] initWithTitle:@"ChooseSource" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remove Pic",@"Camera",@"PhotoLibrary", nil];
    [chooseOption showInView:self.view];
    [chooseOption setTag:222];
}

- (IBAction)selectTheDate:(id)sender
{
    if(_currentTextField != nil)
        [_currentTextField resignFirstResponder];
    
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.datePicker.datePickerMode = UIDatePickerModeDate;

    //Placing the date picker on view...
    CGRect rect = [self.datePickerView frame];
    rect.origin.y = self.view.bounds.size.height;
    self.datePickerView.frame = rect;
    [self.view addSubview:self.datePickerView];

    //Animatin the date picer to visible rect on view...
    
   
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect rect = [self.datePickerView frame];
        rect.origin.y = self.view.bounds.size.height - rect.size.height;
        [UIView animateWithDuration:.25f animations:^{
            [self.datePickerView setFrame:rect];
        } completion:^(BOOL finished) {
            _isDatePickerVisble = YES;
        }];
        
    });
    
    
}

-(void)dateSelected:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.birthdayTxt.text = [[datePicker date] dateString];

}

-(IBAction)dateCancelButtonClicked:(id)sender
{
    self.birthdayTxt.text = _selectedDob;
    

    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGRect datePickerFrame = self.datePickerView.frame;
        datePickerFrame.origin.y = self.view.bounds.size.height;
        
        [UIView animateWithDuration:.25f animations:^{
            [self.datePickerView setFrame:datePickerFrame];
        } completion:^(BOOL finished) {
            [self.datePickerView removeFromSuperview];
            _isDatePickerVisble = NO;
        }];
        
    });
    
    

}



- (IBAction)dateDoneClicked:(id)sender
{
    self.birthdayTxt.text = [[self.datePicker date] dateString];
    
    _selectedDob = self.birthdayTxt.text;
    
    
   
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect datePickerFrame = self.datePickerView.frame;
        datePickerFrame.origin.y = self.view.bounds.size.height;
        
        
        [UIView animateWithDuration:.25f animations:^{
            [self.datePickerView setFrame:datePickerFrame];
        } completion:^(BOOL finished) {
            [self.datePickerView removeFromSuperview];
            _isDatePickerVisble = NO;
        }];
    });
   
}

- (IBAction)cancelProfilePicChanges:(id)sender
{
    shouldHideStatusBar = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [_profileimgbtn setTag:111];
    isEditingPic = NO;
    _profileEditCancelBtn.hidden = YES;
    _profileEditDoneBtn.hidden = YES;
    //    _completeProfileView.hidden = YES;
    _profilePicOverlayView.backgroundColor = [UIColor clearColor];
    [profilePicAspectController enableTouches:NO];
    [_profilePicOverlayView setDontPassTouch:NO];
    [_profilePicOverlayView setHidden:YES];
    [self hideAndShowView:NO];
    [profilePicAspectController placeSelectedImage:_previousPicRef withCropRect:CGRectNull];
}

- (IBAction)doneProfilePicChange:(id)sender
{
    shouldHideStatusBar = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    
    isEditingPic = NO;
    UIImage *croppedImage = [profilePicAspectController getImageCroppedAtVisibleRect:profilePicAspectController.cropRect];

    [_profileimgbtn setTag:222];
    [_profileimgbtn setBackgroundImage:croppedImage forState:UIControlStateNormal];
    [profilePicAspectController placeSelectedImage:nil withCropRect:CGRectNull];
    _profileEditCancelBtn.hidden = YES;
    _profileEditDoneBtn.hidden = YES;
    //    _completeProfileView.hidden = YES;
    _profilePicOverlayView.backgroundColor = [UIColor clearColor];
    [profilePicAspectController enableTouches:NO];
    [_profilePicOverlayView setDontPassTouch:NO];
    [_profilePicOverlayView setHidden:YES];
    [self hideAndShowView:NO];
}

- (IBAction)selectprofileimg:(id)sender
{
    NSLog(@"profile image tag:%d",[_profileimgbtn tag]);
    if(_profileimgbtn.tag == 111)
    {
        UIActionSheet *chooseOption = [[UIActionSheet alloc] initWithTitle:@"ChooseSource" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"PhotoLibrary", nil];
        [chooseOption setTag:111];
        [chooseOption showInView:self.view];
    }
    else if(_profileimgbtn.tag == 222)
    {
        UIActionSheet *chooseOption = [[UIActionSheet alloc] initWithTitle:@"ChooseSource" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete Profile Pic",@"Camera",@"PhotoLibrary", nil];
        [chooseOption setTag:222];
        [chooseOption showInView:self.view];
    }
    
}

#pragma mark - UIActionsheet delegate method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 111)
    {
        if(buttonIndex == 0)
        {
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
    else
    {
        if(buttonIndex == 0)
        {
            //Remove the pic...
            profilePicAspectController.imageView.image = nil;
            _profileimgbtn.tag = 111;
            _profilePicOverlayView.hidden = YES;
            [_profileimgbtn setBackgroundImage:[UIImage imageNamed:@"thumb_user_basic_info.png"] forState:UIControlStateNormal];

        }
        else if(buttonIndex==1) {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *openLibrary = [[UIImagePickerController alloc] init];
                openLibrary.sourceType = UIImagePickerControllerSourceTypeCamera;
                openLibrary.videoQuality = UIImagePickerControllerQualityTypeMedium;
                openLibrary.delegate = self;
                [self presentViewController:openLibrary animated:YES completion:nil];
            }
        }
        else if(buttonIndex==2) {
            UIImagePickerController *openLibrary = [[UIImagePickerController alloc] init];
            openLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            openLibrary.delegate = self;
            [self presentViewController:openLibrary animated:YES completion:nil];
        }
        else if(buttonIndex == 3) {
            //cancel
            [self hideAndShowView:NO];
        }
    }

}

#pragma mark - UIImagePickerController Delegate Methods
-  (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    
    shouldHideStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    _profileimgbtn.tag = 222;
    _profilePicOverlayView.hidden = NO;
    [profilePicAspectController placeSelectedImage:info[UIImagePickerControllerOriginalImage] withCropRect:CGRectNull];
    isEditingPic = YES;
    _profileEditCancelBtn.hidden = NO;
    _profileEditDoneBtn.hidden = NO;
    _profilePicOverlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [profilePicAspectController enableTouches:YES];
    [_profilePicOverlayView setDontPassTouch:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [profilePicAspectController enableTouches:NO];
    [_profilePicOverlayView setDontPassTouch:NO];
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

    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
        } else {
            NSMutableArray * array =(NSMutableArray*)places;
            if (places.count ==5) {
                [array removeLastObject];
            }
            searchResultPlaces = array;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showSearchTableView:searchResultPlaces];
            });
            if (searchResultPlaces.count) {
            }
        }
    }];
    return YES;
}


-(void)showSearchTableView:(NSArray *)searchResults
{

    self.cityTableView.hidden= NO;
    [self.cityTableView reloadData];
    

    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        int count = searchResults.count;
        CGRect tableViewFrame = self.cityTableView.frame;
        CGRect subContentFrame = _subContentView.frame;
        
        if(count < 5)
            tableViewFrame.size.height  = count*30 + 30;
        else
            tableViewFrame.size.height = 200.f;
        
        subContentFrame.origin.y    = 174.f + tableViewFrame.size.height + 2;
        [UIView animateWithDuration:0.5f animations:^{
            [self.cityTableView setFrame:tableViewFrame];
            [_subContentView setFrame:subContentFrame];
            
        } completion:^(BOOL finished) {
            //Animatin finished...
        }];
    });
    
   
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
      _currentTextField = (UITextField *)textField;
    
    if(_isDatePickerVisble)
        [self dateCancelButtonClicked:self.datePicker];
    
    if (textField.tag==11)
    {
        [self textFieldAnimation:YES];
    }
    _profilePicOverlayView.hidden = YES;
    
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    _currentTextField = nil;
    
    if([_profileimgbtn imageForState:UIControlStateNormal])
        _profilePicOverlayView.hidden = NO;
    
    cityTableView.hidden = YES;
}

- (void)textFieldAnimation:(BOOL)inAnimation
{
    //[self showSearchTableView:nil];
    
    if(inAnimation)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGRect contentViewFrame = _contentView.frame;
            contentViewFrame.origin.y = -100.f;
            
            [UIView animateWithDuration:0.5f animations:^{
                [_contentView setFrame:contentViewFrame];

            } completion:^(BOOL finished) {
                //Animatin finished...
            }];
            
        });
        
    }
    else
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGRect contentViewFrame = _contentView.frame;
            contentViewFrame.origin.y = 2.f;
            CGRect subContentFrame = _subContentView.frame;
            subContentFrame.origin.y    =  174.f;
            
            
            CGRect tableViewFrame = self.cityTableView.frame;
            tableViewFrame.size.height = 0;
            tableViewFrame.origin.y = 200.;
            [UIView animateWithDuration:0.5f animations:^{
                [_contentView setFrame:contentViewFrame];
                [_subContentView setFrame:subContentFrame];
                //[self.cityTableView setFrame:tableViewFrame];
                
            } completion:^(BOOL finished) {
                //Animatin finished...
            }];
            
        });
    }
    
    return;
    
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

-(void)showTextFieldInVisibleRect:(UITextView *)textField inView:(UIView *)view
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            [view setBounds:viewRect];
        }];
    });
    
    
    
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([textView.text length]) {
        [self.textviewPlaceholderLabel setHidden:YES];
    }
    else {
        [self.textviewPlaceholderLabel setHidden:NO];
    }
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _currentTextField = textView;
    _profilePicOverlayView.hidden = YES;
    
    CGFloat keyboardHeight = 218.f;//In portraint mode...
    CGPoint textViewPositionOnMainScreen = [[textView superview] convertPoint:textView.frame.origin toView:self.view];
    CGFloat textViewBoundary =textViewPositionOnMainScreen.y  + textView.bounds.size.height;
    
    NSInteger visibleHeight = (self.view.bounds.size.height - keyboardHeight);
    if(textViewBoundary > visibleHeight)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGRect contentViewFrame = _contentView.bounds;
            contentViewFrame.origin.y =  textViewBoundary - visibleHeight + 10 ;
            
            [UIView animateWithDuration:0.5f animations:^{
                [_contentView setBounds:contentViewFrame];
            } ];
            
        });
       
        
      
    }
    else
    {
        
    }
 
// /   _currentTextField = textView;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    _currentTextField = nil;
    
    if([_profileimgbtn imageForState:UIControlStateNormal])
        _profilePicOverlayView.hidden = NO;
    
    CGFloat keyboardHeight = 218.f;//In portraint mode...
    CGFloat textViewBoundary = textView.frame.origin.y + textView.bounds.size.height;
    
    if(textViewBoundary < (self.view.bounds.size.height - keyboardHeight))
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGRect contentViewFrame = _contentView.bounds;
            contentViewFrame.origin.y =  0.f;
            [UIView animateWithDuration:0.5f animations:^{
                [_contentView setBounds:contentViewFrame];
            } ];
            
        });
    }
    else
    {
        
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if([textView.text length]) {
        [self.textviewPlaceholderLabel setHidden:YES];
    }
    else {
        [self.textviewPlaceholderLabel setHidden:NO];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
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
            DescAddpeopleViewController * addPeople = [[DescAddpeopleViewController alloc]initWithNibName:@"DescAddpeopleViewController" bundle:nil];
            [self.navigationController pushViewController:addPeople animated:NO];
            return;
            DESSettingsViewController * setting = [[DESSettingsViewController alloc]initWithNibName:@"DESSettingsViewController" bundle:nil];
            [self.navigationController pushViewController:setting animated:NO];

            return;
            
            //    NotificationsViewController *notificationController = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:nil];
            //            [self.navigationController pushViewController:notificationController animated:YES];
            
            //            CMViewController *compositionViewController = [[CMViewController alloc] initWithNibName:@"CMViewController" bundle:nil];
            //            [self.navigationController pushViewController:compositionViewController animated:YES];
            return;
            ProfileViewController *profileVC = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
            [self.navigationController pushViewController:profileVC animated:YES];
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
        //cell.contentView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
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
    
    if(self.cityTxt.text.length)
    {
        UITextField* field = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 250, 30)];
        [field setBorderStyle:UITextBorderStyleNone];
        [field setEnabled:NO];
        field.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0];
        field.text = [NSString stringWithFormat:@"Add - '%@' ",self.cityTxt.text];//self.cityTxt.text;
        [footer addSubview:field];
        [field addTarget:self action:@selector(footerSelected) forControlEvents:UIControlEventAllTouchEvents];
    }
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 30;
}

- (void)footerSelected
{
    //self.cityTableView.hidden=YES;
    [self.cityTxt resignFirstResponder];
   // [self textFieldAnimation:NO];
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
    self.bioTxt.hidden  = inBool;
    self.cityTxt.hidden = inBool;
    self.birthdayTxt.hidden = inBool;
    self.btnfemale.hidden = inBool;
    self.btnmale.hidden = inBool;
}


@end
