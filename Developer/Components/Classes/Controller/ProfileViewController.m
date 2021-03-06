//
//  ProfileViewController.m
//  Composition
//
//  Created by Describe Administrator on 15/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "ProfileViewController.h"
#import "DBAspectFillViewController.h"
#import "WSModelClasses.h"
#import "UsersModel.h"
#import "UIImage+ImageEffects.h"

typedef enum {
    kProfileModeNormal = 1,
    kProfileModeEditing,
    kProfileModeCanvasEditing,
    kProfileModeProfilePicEditing
} ProfileMode;

#define PHOTO_SELECTION_ACTIONSHEET_TAG         10
#define FOLLOW_SELECTION_ACTIONSHEET_TAG        15

@interface ProfileViewController () <DBAspectFillViewControllerDelegate, WSModelClassDelegate>
{
    CGFloat lastScale;
    CGPoint lastPanPoint;
    UIImageView *abcImgView;
}

@property (nonatomic, assign) ProfileMode currentProfileMode;
@property (nonatomic, assign) ProfileMode changeProfileModeRequest;
@property (nonatomic, strong) DBAspectFillViewController *canvasImageViewController;
@property (nonatomic, strong) DBAspectFillViewController *profilePicImageViewController;
@property (nonatomic, strong) UsersModel *profileUserModel;
@property (nonatomic, strong) UIImage *profilePicImg;
@property (nonatomic, strong) UIImage *canvasImg;

@end

@implementation ProfileViewController

#pragma mark- View Life Cycle

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
    // Do any additional setup after loading the view from its nib.
    
//    if(_profileUserID) {
//        [self fetchUserModelForUserId:_profileUserID];
//        _currentProfileType = kProfileTypeOthers;
//    }
//    else {
//        [self fetchUserModelForUserId:[[WSModelClasses sharedHandler] loggedInUserModel].userID];
//        _currentProfileType = kProfileTypeOwn;
//    }
    
    _followUnfollowBtn.hidden = YES;
    _editBtn.hidden = YES;
    
    // hide the navigation bar
    self.navigationController.navigationBarHidden = YES;
    _profileImageHolderView.layer.cornerRadius = CGRectGetHeight(_profileImageHolderView.frame)/2.0f;
    _profileImageHolderView.layer.masksToBounds = YES;
    _profileImageHolderView.layer.borderColor = [UIColor whiteColor].CGColor;
    _profileImageHolderView.layer.borderWidth = 0.5f;
    
    _canvasImageViewController = [[DBAspectFillViewController alloc] initWithNibName:@"DBAspectFillViewController" bundle:nil];
    [_canvasImageViewController.view setFrame:_canvasChangeOverlayView.frame];
    [_canvasImageViewController setScreenSize:_canvasChangeOverlayView.frame.size];
    [_canvasContainerView addSubview:_canvasImageViewController.view];
    [_canvasContainerView sendSubviewToBack:_canvasImageViewController.view];
    
    _profilePicImageViewController = [[DBAspectFillViewController alloc] initWithNibName:@"DBAspectFillViewController" bundle:nil];
    [_profilePicImageViewController.view setFrame:_profileImageHolderView.bounds];
    [_profilePicImageViewController setScreenSize:_profileImageHolderView.frame.size];
    [_profileImageHolderView addSubview:_profilePicImageViewController.view];
    [_profileImageHolderView sendSubviewToBack:_profilePicImageViewController.view];
    
    [_profilePicImageViewController.imageView addGestureRecognizer:_profilePicTapGesture];
    
//    [_canvasImageViewController placeSelectedImage:[UIImage imageNamed:@"profileSampleImage.png"] withCropRect:CGRectNull];
//    [self profileModeChangedTo:kProfileModeNormal];
    
    [self addSwipeViewController];

}

- (void)handlePan:(UIPanGestureRecognizer*)recognizer
{
    if(_currentProfileMode != kProfileModeNormal) {
        return;
    }
    
    CGPoint translation = [recognizer translationInView:recognizer.view];
    CGFloat xVal = recognizer.view.center.x+translation.x;
    CGFloat yVal = recognizer.view.center.y;
    
    if(xVal > recognizer.view.bounds.size.width/2.0) {
        xVal = recognizer.view.bounds.size.width/2.0;
    }
    
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        if(xVal > (screenWidth/2.0 - (screenWidth*0.3))) {
            // push the view back to its place
            [UIView animateWithDuration:0.3 animations:^{
                CGRect profileFrame = self.view.frame;
                profileFrame.origin.x = 0;
                [self.view setFrame:profileFrame];
//                self.view.alpha = 1.0;
                [self changeAplhaOfSubviewsForTransition:1.0];
            } completion:^(BOOL finished) {
                //Show profile details here...
            }];
        }
        else {
            // call showNextScreen
            if(_delegate != nil && [_delegate respondsToSelector:@selector(showNextScreen:)]) {
                [_delegate showNextScreen:self];
            }
        }
    }
    else {
        recognizer.view.center = CGPointMake(xVal, yVal);
        [recognizer setTranslation:CGPointMake(0, 0) inView:recognizer.view];
        
        // calculateAlpha value
        CGFloat xPos = xVal - [[UIScreen mainScreen] bounds].size.width/2.0;
        if(xPos < 0) {
            xPos = xPos * -1;
        }
        
        CGFloat alphaVal = 1 - (1/([[UIScreen mainScreen] bounds].size.width/2.5) * xPos);
        
        [self changeAplhaOfSubviewsForTransition:alphaVal];
    }
}

- (void)changeAplhaOfSubviewsForTransition:(CGFloat)alphaVal
{
    if(alphaVal > 1.0) {
        alphaVal = 1.0;
    }
    
    if(alphaVal < 0) {
        alphaVal = 0.0;
    }
    
    _completeProfileView.alpha = alphaVal;
    _profilePicContainerView.alpha = alphaVal;
    _headerView.alpha = alphaVal;
}

- (void)addSwipeViewController
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [panGesture setDelegate:self];
    [panGesture setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:panGesture];
    
//    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeGesture:)];
//    [rightSwipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
//    [self.view addGestureRecognizer:rightSwipeGesture];
//
//    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeGesture:)];
//    [leftSwipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
//    [self.view addGestureRecognizer:leftSwipeGesture];
}

- (void)rightSwipeGesture:(UISwipeGestureRecognizer *)gesture
{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(showNextScreen:)])
    {
        [_delegate showNextScreen:self];
    }
}

- (void)leftSwipeGesture:(UISwipeGestureRecognizer *)gesture
{
    [self menuOptionSelected:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetch UserModel from server

- (void)fetchUserModelForUserId:(NSNumber *)userID
{
    //Getting the details from profile details screen so simply returning from here...
    return;
    
    [[WSModelClasses sharedHandler] setDelegate:self];
    [[WSModelClasses sharedHandler] getProfileDetailsForUserID:[userID stringValue]];
}

- (void)getTheUserProfileDataFromServer:(NSDictionary *)responceDict error:(NSError *)error
{
    if(error) {
        NSLog(@"%s error = %@", __func__, error.localizedDescription);
    }
    else {
        NSLog(@"%s responseDict = %@", __func__, responceDict);
        NSMutableDictionary *profileDict = [[NSMutableDictionary alloc] initWithDictionary:responceDict[@"UserProfile"] copyItems:YES];
        if(profileDict[@"ProfileCanvas"]) {
            [profileDict setObject:profileDict[@"ProfileCanvas"] forKey:USER_MODAL_KEY_PROFILECANVAS];
        }
        
        UsersModel *modelObj = [[UsersModel alloc] initWithDictionary:profileDict];
        _profileUserModel = modelObj;
        [self showProfileDetailOnView];
    }
}


- (void)loadProfileDetails:(NSDictionary *)dictionary
{
    NSMutableDictionary *profileDict = [[NSMutableDictionary alloc] initWithDictionary:dictionary[@"UserProfile"] copyItems:YES];
    if(profileDict[@"ProfileCanvas"]) {
        [profileDict setObject:profileDict[@"ProfileCanvas"] forKey:USER_MODAL_KEY_PROFILECANVAS];
    }
    
    UsersModel *modelObj = [[UsersModel alloc] initWithDictionary:profileDict];
    _profileUserModel = modelObj;
    
    if([modelObj.userID integerValue] == [[[WSModelClasses sharedHandler] loggedInUserModel].userID integerValue]) {
        _currentProfileType = kProfileTypeOwn;
    }
    else {
        _currentProfileType = kProfileTypeOthers;
    }
    
    [self showProfileDetailOnView];
    [self profileModeChangedTo:kProfileModeNormal];
}


- (void)showProfileDetailOnView
{
    _fullNameLabel.text = _profileUserModel.fullName ? _profileUserModel.fullName : @"";
    _usernameLabel.text = _profileUserModel.userName ? _profileUserModel.userName : @"";
    _cityLabel.text = _profileUserModel.city ? _profileUserModel.city : @"";
    _bioLabel.text = _profileUserModel.biodata ? _profileUserModel.biodata : @"";
    _postsCountLabel.text = _profileUserModel.postCount ? [_profileUserModel.postCount stringValue] : @"0";
    _followingCountLabel.text = _profileUserModel.followingCount ? [_profileUserModel.followingCount stringValue] : @"";
    _followersCountLabel.text = _profileUserModel.followerCount ? [_profileUserModel.followerCount stringValue] : @"";
    
    _profileStatusTxtView.text = _profileUserModel.statusMessage ? _profileUserModel.statusMessage : @"";
    
    if(_profileUserModel.snippetPosition != nil) {
        CGRect snippetFrame = _snippetRegionImgView.frame;
        snippetFrame.origin.y = [_profileUserModel.snippetPosition doubleValue];
        _snippetRegionImgView.frame = snippetFrame;
    }
    
    NSString *profilePicStr = _profileUserModel.profileImageName;
    if(profilePicStr != nil) {
        profilePicStr = [profilePicStr lastPathComponent];
        profilePicStr = [NSString stringWithFormat:@"http://mirusstudent.com/service/postimages/%@",profilePicStr];
        [_profilePicImageViewController loadImageFromURLString:profilePicStr];
    }
//    [_profilePicImageViewController loadImageFromURLString:_profileUserModel.profileImageName];
    [_canvasImageViewController loadImageFromURLString:_profileUserModel.canvasImageName];
}

#pragma mark - Edit mode Button methods

- (IBAction)changeOptionSelected:(id)sender
{
//    [self showAcionSheetForPhotoSelection];
    if(_currentProfileMode == kProfileModeCanvasEditing) {
        [_canvasImageViewController resetImageContentToEmpty];
        [_canvasImageViewController.imageView setImage:_canvasImg];
    }
    else if(_currentProfileMode == kProfileModeProfilePicEditing) {
        [_profilePicImageViewController resetImageContentToEmpty];
        [_profilePicImageViewController.imageView setImage:_profilePicImg];
    }
    
    [self profileModeChangedTo:kProfileModeEditing];
}

- (IBAction)doneOptionSelected:(id)sender
{
    [self profileModeChangedTo:kProfileModeEditing];
}

- (IBAction)editCanvasOptionSelected:(id)sender
{
    _changeProfileModeRequest = kProfileModeCanvasEditing;
    [self showAcionSheetForPhotoSelection];
}

- (IBAction)profilePicTapped:(id)sender
{
    if(_currentProfileMode != kProfileModeEditing) {
        return;
    }
    
    _changeProfileModeRequest = kProfileModeProfilePicEditing;
    [self showAcionSheetForPhotoSelection];
}

- (IBAction)pinchGestureDetected:(id)sender
{
    if(_currentProfileMode != kProfileModeProfilePicEditing) {
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
    [_profilePicImageViewController.imageContentScrollView setZoomScale:scale animated:YES];
}

- (IBAction)panGestureDetected:(id)sender
{
    if(_currentProfileMode != kProfileModeProfilePicEditing) {
        return;
    }
    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)sender;
    if(panGesture.state == UIGestureRecognizerStateEnded) {
        return;
    }
    
    if(panGesture.state == UIGestureRecognizerStateBegan) {
        lastPanPoint = [panGesture locationInView:_profilePicContainerView];
    }
    
    CGPoint point = [panGesture locationInView:_profilePicContainerView];
    point.x -= lastPanPoint.x;
    point.y -= lastPanPoint.y;
    
    lastPanPoint = [panGesture locationInView:_profilePicContainerView];
    
    point.x = -point.x;
    point.y = -point.y;
    
    CGPoint scrollPoint = _profilePicImageViewController.imageContentScrollView.contentOffset;
    point.x += scrollPoint.x;
    point.y += scrollPoint.y;
    
    if(point.x < 0) {
        point.x = 0;
    }
    
    if(point.x > _profilePicImageViewController.imageContentScrollView.contentSize.width - _profilePicImageViewController.imageContentScrollView.frame.size.width) {
        point.x = _profilePicImageViewController.imageContentScrollView.contentSize.width - _profilePicImageViewController.imageContentScrollView.frame.size.width;
    }
    
    if(point.y < 0) {
        point.y = 0;
    }
    
    if(point.y > _profilePicImageViewController.imageContentScrollView.contentSize.height - _profilePicImageViewController.imageContentScrollView.frame.size.height) {
        point.y = _profilePicImageViewController.imageContentScrollView.contentSize.height - _profilePicImageViewController.imageContentScrollView.frame.size.height;
    }
        
    [_profilePicImageViewController.imageContentScrollView setContentOffset:point animated:NO];
    [_profilePicImageViewController calculateCropRectForSelectImage];
}

- (IBAction)snippetPanGestureDetected:(id)sender
{
    if(_currentProfileMode != kProfileModeCanvasEditing) {
        return;
    }
    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)sender;
    CGPoint centerPoint = [panGesture locationInView:_snippetRegionImgView.superview];
    centerPoint.x = CGRectGetWidth(_snippetRegionImgView.frame)/2.0;
    
    if(centerPoint.y - CGRectGetHeight(_snippetRegionImgView.frame)/2 < 0) {
        centerPoint.y = CGRectGetHeight(_snippetRegionImgView.frame)/2;
    }
    
    if(centerPoint.y + CGRectGetHeight(_snippetRegionImgView.frame)/2 > CGRectGetHeight(_canvasChangeOverlayView.frame)) {
        centerPoint.y = CGRectGetHeight(_canvasChangeOverlayView.frame) - CGRectGetHeight(_snippetRegionImgView.frame)/2.0;
    }
    
    _snippetRegionImgView.center = centerPoint;
}

- (void)showAcionSheetForPhotoSelection
{
    // here we need to show actionsheet with options as:
    // 1. Camera
    // 2. Photo Library
    // 3. Cancel
    
       NSString *profilePicStr = _profileUserModel.profileImageName;
    UIActionSheet *actionSheet ;
      if(profilePicStr != nil && [profilePicStr length]) {
     actionSheet = [[UIActionSheet alloc]  initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", nil), NSLocalizedString(@"Photo Library", nil),@"Remove Picture", nil];
      }else{
   actionSheet = [[UIActionSheet alloc]  initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", nil), NSLocalizedString(@"Photo Library", nil), nil];
      }
    actionSheet.tag = PHOTO_SELECTION_ACTIONSHEET_TAG;
    [actionSheet showInView:self.view];
}

- (void)profileModeChangedTo:(ProfileMode)newMode
{
    _currentProfileMode = newMode;
    
    _canvasChangeOverlayView.hidden = YES;
    _changeBtn.hidden = YES;
    _doneBtn.hidden = YES;
    _completeProfileView.hidden = NO;
    _editCanvasBtn.hidden = YES;
    _profilePicContainerView.hidden = NO;
    _profilePicContainerView.backgroundColor = [UIColor clearColor];
    _profileStatusTxtView.userInteractionEnabled = NO;
    _statsContainerView.hidden = YES;
    
    [_canvasImageViewController enableTouches:NO];
    [_profilePicImageViewController enableTouches:NO];
    [_profilePicContainerView setDontPassTouch:NO];
    // here we will manage the visibility of views
    switch (newMode) {
        case kProfileModeNormal:
        {
            _followUnfollowBtn.hidden = (_currentProfileType == kProfileTypeOwn);
            _editBtn.hidden = (_currentProfileType == kProfileTypeOthers);
            _editingDoneBtn.hidden = YES;
            _statsContainerView.hidden = NO;
            break;
        }
            
        case kProfileModeEditing:
        {
            _editCanvasBtn.hidden = NO;
            _profileStatusTxtView.userInteractionEnabled = YES;
            _editingDoneBtn.hidden = NO;
            _editBtn.hidden = YES;
            break;
        }
            
        case kProfileModeCanvasEditing:
        {
            _canvasChangeOverlayView.hidden = NO;
            _profilePicContainerView.hidden = YES;
            _completeProfileView.hidden = YES;
            
            [_canvasImageViewController enableTouches:YES];
            break;
        }
            
        case kProfileModeProfilePicEditing:
        {
            _changeBtn.hidden = NO;
            _doneBtn.hidden = NO;
            _completeProfileView.hidden = YES;
            _profilePicContainerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
            
            [_profilePicImageViewController enableTouches:YES];
            [_profilePicContainerView setDontPassTouch:YES];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - HeaderView Button methods

- (IBAction)menuOptionSelected:(id)sender
{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(showPreviousScreen:)])
    {
        [_delegate showPreviousScreen:self];
    }
}

- (IBAction)editOptionSelected:(id)sender
{
    // here we need to enable editing for canvas, status msg and profile pic (change editBtn to editingDoneBtn)
    self.profilePicImg = _profilePicImageViewController.imageView.image;
    self.canvasImg = _canvasImageViewController.imageView.image;
    
    [self profileModeChangedTo:kProfileModeEditing];
}

- (IBAction)followUnfollowSelected:(id)sender
{
    // here we need to show actionsheet with options as:
    // 1. Follow/Unfollow
    // 2. Block/Unblock
    // 3. Cancel
    UIActionSheet *actionSheet = [[UIActionSheet alloc]  initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Follow", nil), NSLocalizedString(@"Block", nil), nil];
    actionSheet.tag = FOLLOW_SELECTION_ACTIONSHEET_TAG;
    [actionSheet showInView:self.view];
}

- (IBAction)editingDoneSelected:(id)sender
{
    // here we need to send the edited details to server and disable editing mode (change editingDoneBtn to editBtn)
    _profileUserModel.snippetPosition = [NSString stringWithFormat:@"%0.2f", CGRectGetMinY(_snippetRegionImgView.frame)];
    CGFloat screenScaleValue = [[UIScreen mainScreen] scale];
    
    CGRect snippetCropRect = _snippetRegionImgView.frame;
    snippetCropRect.origin.x = CGRectGetMinX(_canvasImageViewController.cropRect);
    snippetCropRect.origin.y = (CGRectGetMinY(snippetCropRect) * screenScaleValue) + CGRectGetMinY(_canvasImageViewController.cropRect);
    snippetCropRect.size.width *= screenScaleValue;
    snippetCropRect.size.height *= screenScaleValue;
    UIImage *snippetImg = [_canvasImageViewController getImageCroppedAtVisibleRect:snippetCropRect];
//    if(abcImgView == nil)
//        abcImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 200, 320.0, 50.0)];
//    [abcImgView setImage:snippetImg];
//    [self.view addSubview:abcImgView];
//    [self.view bringSubviewToFront:abcImgView];
//    return;
    
    // applying blur effect on the snippet image
    UIImage *blurSnippetImg = [snippetImg applyBlurWithRadius:20.0f tintColor:[UIColor clearColor] saturationDeltaFactor:1.8f maskImage:nil];
    
    [[WSModelClasses sharedHandler] saveUserProfile:_profileUserModel
                                         profilePic:[_profilePicImageViewController getImageCroppedAtVisibleRect:_profilePicImageViewController.cropRect]
                                          canvasPic:[_canvasImageViewController getImageCroppedAtVisibleRect:_canvasImageViewController.cropRect]
                                         snippetPic:blurSnippetImg];
    
    [self profileModeChangedTo:kProfileModeNormal];
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(textView.text.length == 200 && text.length > 0) {
        return NO;
    }
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - UIActionsheetDelegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == PHOTO_SELECTION_ACTIONSHEET_TAG && buttonIndex < 3) {
        
        if(buttonIndex == 0 && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Device does not have camera.", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            return;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        
        switch (buttonIndex) {
            case 0:
            {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            }
                
            case 1:
            {
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            }
            case 2:
            {
                _profileUserModel.profileImageName =@"";
                _profilePicImageViewController.imageView.image = nil;
                return;
            }
                
            default:
                break;
        }
        
        [self presentViewController:picker animated:YES completion:nil];

    }
    
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    UIImage *image = info[UIImagePickerControllerOriginalImage];
//    UIImage *correctOrientationImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationUp];
    
//    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
//        
//    }
    
    if(_changeProfileModeRequest == kProfileModeCanvasEditing) {
        [_canvasImageViewController placeSelectedImage:info[UIImagePickerControllerOriginalImage] withCropRect:CGRectNull];
    }
    else {
        [_profilePicImageViewController placeSelectedImage:info[UIImagePickerControllerOriginalImage] withCropRect:CGRectNull];
    }
    
    [self profileModeChangedTo:_changeProfileModeRequest];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self profileModeChangedTo:_changeProfileModeRequest];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
//    if(gestureRecognizer == _profilePinGesture && otherGestureRecognizer == _profilePicPanGesture) {
//        return YES;
//    }
//    
//    if(gestureRecognizer == _profilePicPanGesture && otherGestureRecognizer == _profilePinGesture) {
//        return YES;
//    }
    
    return NO;
}

@end
