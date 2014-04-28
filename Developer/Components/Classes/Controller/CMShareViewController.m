//
//  CMShareViewController.m
//  Composition
//
//  Created by Describe Administrator on 26/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "CMShareViewController.h"
#import "CMShareCategoryCell.h"
#import "CMShareTagCell.h"
#import "CMShareCompositionCell.h"
#import "CMPhotoModel.h"
#import "DPost.h"
#import "CMAVCameraHandler.h"
#import "CMShareSocialCell.h"
#import "DESLocationManager.h"
#import "DHeaderView.h"
#import "DPostBodyView.h"
#import "UIView+FindFirstResponder.h"
#import "DESocialConnectios.h"
#import "AFNetworking.h"

#define LOCATION_CELLIDENTIFIER             @"LocationCell"
#define COMPOSITION_CELLIDENTIFIER          @"CompositionCell"
#define CATEGORY_CELLIDENTIFIER             @"CategoryCell"
#define TAG_CELLIDENTIFIER                  @"TagCell"
#define SHARE_CELLIDENTIFIER                @"ShareCell"

typedef enum {
    ShareSectionCategory = 0,
    ShareSectionTag,
    ShareSectionShare,
}ShareSection;

#define NO_CATEGORY_SELECTED_COLOR          [UIColor colorWithR:212.0f G:212.0f B:212.0f A:255.0f]
#define ALERT_TAG_DISMISS                   10
#define ALERT_TAG_MOVEBACK                  15


@interface CMShareViewController () <DESLocationManagerDelegate, DPostBodyViewDelegate, DESocialConnectiosDelegate, DHeaderViewDelegate>
{
    BOOL showCompositionCell;
    BOOL showCategoryOption;    // identifies whether to show category options or not
    NSArray *sectionCellIdentiferList;      // holds the cell idenitifer of all sections
    NSArray *categoryList;          // holds all the category names
    NSArray *categoryColorList;     // holds color object for the category
    
    NSInteger selectedCategoryIndex;
    SPGooglePlacesAutocompleteViewController *googleSearchController;
    
    CMCategoryVC *categoryController;
    DPostImage *_imagePost;
    IBOutlet DHeaderView *_headerView;
    
    DPostBodyView *_postBodyView;
    
    BOOL fbSelected;
    BOOL gplusSelected;
    
    BOOL shareBtnSelected;
}

@property (nonatomic, strong) NSString *totalVideoDuration;

@end

@implementation CMShareViewController

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
	// Do any additional setup after loading the view.
    [self designHeaderView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoRecordingDone:) name:NOTIFICATION_VIDEO_RECORDING_COMPLETED object:nil];
    
    _imagePost = [[DPostImage alloc] init];
    
    gplusSelected = NO;
    fbSelected = NO;
    shareBtnSelected = NO;
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for(CMPhotoModel *modelObj in _capturedPhotoList) {
        if(modelObj.originalImagePath) {
            [images addObject:modelObj];
        }
    }
    
    [_imagePost setImages:images];
    [self videoRecordingDone:nil];
    
    UINib *nib = [UINib nibWithNibName:@"CMShareTagCell" bundle:nil];
    [self.shareTableView registerNib:nib forCellReuseIdentifier:TAG_CELLIDENTIFIER];
    
    nib = [UINib nibWithNibName:@"CMShareSocialCell" bundle:nil];
    [self.shareTableView registerNib:nib forCellReuseIdentifier:SHARE_CELLIDENTIFIER];
    
    selectedCategoryIndex = -1;  // default should be -1
    showCategoryOption = NO;  // default do not show category option
    sectionCellIdentiferList = [[NSArray alloc] initWithObjects:CATEGORY_CELLIDENTIFIER, TAG_CELLIDENTIFIER, SHARE_CELLIDENTIFIER, nil];
    
    googleSearchController = [[SPGooglePlacesAutocompleteViewController alloc] initWithNibName:@"SPGooglePlacesAutocompleteViewController" bundle:nil];
    googleSearchController.delegate = self;
    [self.locationContainerView addSubview:googleSearchController.view];
    
    categoryController = [[CMCategoryVC alloc] initWithNibName:@"CMCategoryVC" bundle:nil];
    [categoryController.view setFrame:CGRectMake(0, 0, 320, 41.0)];
    categoryController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    [[DESLocationManager sharedLocationManager] setDelegate:self];
    [[DESLocationManager sharedLocationManager] initializeFetchingCurrentLocationAndStartUpdating:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createPostBodyView
{
    if(_postBodyView == nil)
    {
        _postBodyView =  [[DPostBodyView alloc] initWithFrame:CGRectMake(0, 0, 320, 320) withPostImage:_imagePost];
        [_postBodyView setBackgroundColor:[UIColor clearColor]];
        [self.compositionContainerView addSubview:_postBodyView];
    }
    [_postBodyView setDelegate:self];
    [_postBodyView setPostImage:_imagePost];
}

- (void)postBodyViewDidTapOnImage:(DPostBodyView *)bodyView
{
    [self compositionCellIsTapped];
}

-(void)designHeaderView
{
    
    UIButton *closeButton = [[UIButton alloc] init];
    [closeButton setTag:HeaderButtonTypeClose];
    [closeButton setImage:[UIImage imageNamed:@"btn_nav_std_cancel.png"] forState:UIControlStateNormal];
    
    
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setTag:HeaderButtonTypePrev];
    [backButton setImage:[UIImage imageNamed:@"btn_nav_comp_back.png"] forState:UIControlStateNormal];
    

    
    [_headerView designHeaderViewWithTitle:@"Record" andWithButtons:@[backButton,  closeButton]];
    [_headerView setDelegate:self];
    [_headerView setbackgroundImage:[UIImage imageNamed:@"bg_nav_comp.png"]];
    
    
}

-(void)headerView:(DHeaderView *)headerView didSelectedHeaderViewButton:(UIButton *)headerButton
{
    HeaderButtonType buttonType = headerButton.tag;
    switch (buttonType) {
        case HeaderButtonTypeClose:
            [self dismissOptionCLicked:headerButton];
            break;
        case HeaderButtonTypePrev:
            [self prevOptionClicked:headerButton];
            break;
        default:
            break;
    }
}

- (void)videoRecordingDone:(NSNotification *)notification
{
#if !(TARGET_IPHONE_SIMULATOR)
    if([[CMAVCameraHandler sharedHandler] isRecordingDone]) {
        DPostVideo *video = [[DPostVideo alloc] init];
        NSArray *imgArray = _imagePost.images;
        if(imgArray) {
            CMPhotoModel *lastPhoto = (CMPhotoModel *)[imgArray lastObject];
            CGFloat totalDuration = lastPhoto.startAppearanceTime + lastPhoto.duration;
            [video setDuration:[NSString stringWithFormat:@"%0.2f", totalDuration]];
            
            _totalVideoDuration = [NSString stringWithFormat:@"%0.2f", totalDuration];
        }
        
        [video setUrl:[[CMAVCameraHandler sharedHandler] videoFilenamePath]];
        [_imagePost setVideo:video];
        [self performSelectorOnMainThread:@selector(createPostBodyView) withObject:nil waitUntilDone:YES];

    }
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Header button action methods

- (IBAction)listOptionClicked:(id)sender
{
    
}

- (IBAction)dismissOptionCLicked:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Describe", @"") message:NSLocalizedString(@"You will lose your current composition, if you navigate back. Do you still want to continue.", @"") delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.tag = ALERT_TAG_DISMISS;
    [alert show];
}

- (IBAction)prevOptionClicked:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Describe", @"") message:NSLocalizedString(@"You will lose your recorded video, if you navigate back. Do you still want to navigate back.", @"") delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.tag = ALERT_TAG_MOVEBACK;
    [alert show];
}

#pragma mark - UIAlertViewDelegate Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    NSLog(@"buttonIndex = %d", buttonIndex);
    if(buttonIndex == 1) {
        if(alertView.tag == ALERT_TAG_MOVEBACK) {
#if !(TARGET_IPHONE_SIMULATOR)
            NSString *path = [[CMAVCameraHandler sharedHandler] videoFilenamePath];
            if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                NSError *err;
                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&err];
                if(!success) {
                    NSLog(@"%d, error = %@ \n%@", success, err.description, err.debugDescription);
                }
            }
            
            [[CMAVCameraHandler sharedHandler] setVideoFilenamePath:nil];
#endif
            
            for(CMPhotoModel *modelObj in self.capturedPhotoList) {
                if(modelObj.originalImagePath) {
                    [modelObj resetRecordingValues];
                }
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self popToFeedScreen];
        }
    }
}

- (void)popToFeedScreen
{
    // remove the composition from document
    [[WSModelClasses sharedHandler] removeCompositionPath];

    // from here we should pop back to feed controller, which will be in stack at fourthLast index so we will get that controller from controllerStack and pop to that controller
    NSInteger count = self.navigationController.viewControllers.count;
    
    // since we need to go back twice, we will decrement count by 4 to get index
    NSInteger index = count - 4;
    if(index >= 0) {
        id viewController = self.navigationController.viewControllers[index];
        [self.navigationController popToViewController:(UIViewController *)viewController animated:YES];
    }
}

#pragma mark - Share cell action methods

- (IBAction)socailButtonClicked:(id)sender
{
    NSLog(@"%s, tag = %ld", __func__, (long)[sender tag]);
    if([sender tag] == 20) { // facebook
        UIButton *fbBtn = (UIButton *)sender;
        if(fbBtn.isSelected) {
            [fbBtn setSelected:!fbBtn.isSelected];
            fbSelected = NO;
            return;
        }
        
        fbSelected = YES;
        gplusSelected = NO;
        
        [[DESocialConnectios sharedInstance] setDelegate:self];
        if([[DESocialConnectios sharedInstance] isFacebookLoggedIn]) {
            fbSelected = NO;
            UIButton *fbBtn = (UIButton *)sender;
            [fbBtn setSelected:!fbBtn.isSelected];
        }
        else {
            [[WSModelClasses sharedHandler] showLoadView];
            [[DESocialConnectios sharedInstance] facebookSignIn];
        }
    }
    else if([sender tag] == 21) { // GPlus
        UIButton *gpBtn = (UIButton *)sender;
        if(gpBtn.isSelected) {
            [gpBtn setSelected:!gpBtn.isSelected];
            gplusSelected = NO;
            return;
        }
        
        gplusSelected = YES;
        fbSelected = NO;
        
        [[DESocialConnectios sharedInstance] setDelegate:self];
        if([[DESocialConnectios sharedInstance]isGooglePlusLoggeIn]) {
            gplusSelected = NO;
            UIButton *gpBtn = (UIButton *)sender;
            [gpBtn setSelected:!gpBtn.isSelected];
        }
        else {
            [[WSModelClasses sharedHandler] showLoadView];
            [[DESocialConnectios sharedInstance] googlePlusSignIn];
        }
    }
    
}

- (IBAction)shareButtonClicked:(id)sender
{
    NSLog(@"%s", __func__);
    shareBtnSelected = YES;
    [[DESLocationManager sharedLocationManager] setDelegate:self];
    [[DESLocationManager sharedLocationManager] initializeFetchingCurrentLocationAndStartUpdating:YES];
}

#pragma mark DESLocationManagerDelegate Method

- (void)didUpdatedToNewLocation:(DESLocationManager *)locationManager
{
    if(shareBtnSelected == YES) {
        shareBtnSelected = NO;
        [self postComposition];
    }
    else {
        //        http://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&sensor=true_or_false
        NSString *urlStr = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%lf,%lf&sensor=false", [[DESLocationManager sharedLocationManager] currentLocation].coordinate.latitude, [[DESLocationManager sharedLocationManager] currentLocation].coordinate.longitude];
        [[DESLocationManager sharedLocationManager] stopFetchingCurrentLocation];
        
        if (![[WSModelClasses sharedHandler] networkReachable]) {
            return;
        }
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:urlStr
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                 NSLog(@"%s %@", __func__, responseObject);
                 NSArray *addressList = [responseObject objectForKey:@"results"];
                 if(addressList != nil && addressList.count > 0) {
                     NSString *addressStr = addressList[0][@"formatted_address"];
                     if(addressStr != nil && addressStr.length > 0) {
                         googleSearchController.searchDisplayController.searchBar.text = addressStr;
                     }
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"%s Error = %@", __func__, [error localizedDescription]);
             }
         ];
    }
}

#pragma mark - DESocialConnectiosDelegate Method
- (void)googlePlusResponce:(NSMutableDictionary *)responseDict andFriendsList:(NSMutableArray *)inFriendsList
{
    if(responseDict == nil) {
        [[WSModelClasses sharedHandler] removeLoadingView];
        return;
    }
    
    WSModelClasses * dataClass = [WSModelClasses sharedHandler];
    dataClass.delegate = self;
    
    if (fbSelected == YES) {
        [dataClass checkTheSocialIDwithDescriveServerCheckType:@"fb" andCheckValue:[responseDict valueForKey:@"id"]];
    }
    else if (gplusSelected == YES){
        [dataClass checkTheSocialIDwithDescriveServerCheckType:@"gplus" andCheckValue:[responseDict valueForKey:@"id"]];
    }

}

- (void)chekTheExistingUser:(NSDictionary *)responseDict error:(NSError *)error
{
    [[WSModelClasses sharedHandler] removeLoadingView];
    
    if ([[[responseDict valueForKeyPath:@"DataTable.UserData.Msg"]objectAtIndex:0] isEqualToString:@"TRUE"]) {
        // make either facebook / Gplus button as ON
        CMShareSocialCell *socialCell = (CMShareSocialCell *)[self.shareTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ShareSectionShare]];
        if(socialCell == nil) {
            return;
        }
        
        if(fbSelected == YES) {
            fbSelected = NO;
            [socialCell.fbButton setSelected:YES];
            [socialCell.fbButton setImage:[UIImage imageNamed:@"btn_shareScreen_fb_off.png"] forState:UIControlStateNormal];
        }
        else if(gplusSelected == YES) {
            gplusSelected = NO;
            [socialCell.gpButton setSelected:YES];
            [socialCell.gpButton setImage:[UIImage imageNamed:@"btn_shareScreen_goog_off.png"] forState:UIControlStateNormal];
        }
        
    }
    else {
        NSString * messageStr = @"";
        if (fbSelected == YES) {
            messageStr = NSLocalizedString(@"This Facebook account is already associated with another Describe account.", @"");
            [[DESocialConnectios sharedInstance] logoutFacebook];
        }
        else if (gplusSelected == YES){
            messageStr = NSLocalizedString(@"This Google+ account is already associated with another Describe account.", @"");
            [[DESocialConnectios sharedInstance] logoutGooglePlus];
        }
        
        [self showAlertWithTitle:NSLocalizedString(@"Describe", @"") message:messageStr tag:0 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
}

- (void)showAlertWithTitle:(NSString *)titleString message:(NSString *)message tag:(NSUInteger)tagValue delegate:(id /*<UIAlertViewDelegate>*/)target cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString message:message delegate:target cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    // get the variable arguments into argumentList(va_list) using va_start and then iterate through list to get all the button titles
    // add the button titles to the alert
    va_list args;
    va_start(args, otherButtonTitles);
    for(NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*)) {
        [alert addButtonWithTitle:arg];
    }
    va_end(args);
    
    alert.tag = tagValue;
    [alert show];
}

#pragma mark - UITableDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 1;
    ShareSection sectionVal = (ShareSection)section;
    switch (sectionVal) {
        case ShareSectionShare:
        {
            rowCount = 1;
            break;
        }
            
        case ShareSectionCategory:
        {
            rowCount = 1;
            break;
        }
            
        case ShareSectionTag:
        {
            rowCount = 2;
            break;
        }
            
        default:
            rowCount = 1;
            break;
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = (NSString *)sectionCellIdentiferList[indexPath.section];
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    ShareSection sectionVal = (ShareSection)indexPath.section;
    switch (sectionVal) {
        case ShareSectionCategory:
        {
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            [categoryController.view removeFromSuperview];
            [cell.contentView addSubview:categoryController.view];
            
            CGRect categoryControllerRect = categoryController.view.frame;
            categoryControllerRect.size.height = cell.bounds.size.height;
            [categoryController.view setFrame:categoryControllerRect];
            
//            CMShareCategoryCell *categoryCell = (CMShareCategoryCell *)cell;
//            if(indexPath.row == 0 && !showCategoryOption) {
//                categoryCell.categoryNameLabel.text = selectedCategoryIndex != -1 ? categoryList[selectedCategoryIndex]:NSLocalizedString(@"tap to choose a category", @"");
//                categoryCell.contentView.backgroundColor = selectedCategoryIndex != -1 ? categoryColorList[selectedCategoryIndex]:NO_CATEGORY_SELECTED_COLOR;
//            }
//            else {
//                categoryCell.categoryNameLabel.text = (NSString *)categoryList[indexPath.row];
//                categoryCell.contentView.backgroundColor = (UIColor *)categoryColorList[indexPath.row];
//            }
            break;
        }
            
        case ShareSectionTag:
        {
            CMShareTagCell *tagCell = (CMShareTagCell *)cell;
            tagCell.tagTxtfld.delegate = self;
            if(indexPath.row == 0) {
                tagCell.tagTxtfld.placeholder = @"#FirstTag";
                tagCell.seperatorLine.hidden = NO;
            }
            else {
                tagCell.tagTxtfld.placeholder = @"#SecondTag";
                tagCell.seperatorLine.hidden = YES;
            }
            
            break;
        }
            
        case ShareSectionShare:
        {
            CMShareSocialCell *socialCell = (CMShareSocialCell *)cell;
            [socialCell.fbButton addTarget:self action:@selector(socailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [socialCell.gpButton addTarget:self action:@selector(socailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [socialCell.shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowheight = 41.0f;
    ShareSection sectionVal = (ShareSection)indexPath.section;
    switch (sectionVal) {
        case ShareSectionTag:
        {
            rowheight = 41.0f;
            break;
        }
        
        case ShareSectionCategory:
        {
            if(showCategoryOption) {
                rowheight = CGRectGetHeight(tableView.frame);// - 100.0f;
                categoryController.categoryTableView.scrollEnabled = YES;
            }
            else {
                rowheight = 41.0f;
                categoryController.categoryTableView.scrollEnabled = NO;
            }
            break;
        }
        
        case ShareSectionShare:
        {
            if([UIScreen mainScreen].bounds.size.height > 480) {
                rowheight = 238.0f;
            }
            else {
                rowheight = 182.0f;
            }
            break;
        }
            
        default:
            rowheight = 41.0f;
            break;
    }
    
    return rowheight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if(indexPath.section == ShareSectionCategory) {
        if(showCategoryOption) {
//            if(selectedCategoryIndex != indexPath.row) {
                selectedCategoryIndex = indexPath.row;
//            }
//            else {
//                selectedCategoryIndex = -1;
//            }
        }
        showCategoryOption = !showCategoryOption;

        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:showCategoryOption?UITableViewRowAnimationBottom:UITableViewRowAnimationTop];
    }*/
}

#pragma mark - UITextfield delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([self.view findFirstResponder]) {
        id txtfiled = [self.view findFirstResponder];
        if([txtfiled isKindOfClass:[UITextField class]]) {
            UITextField *tagField = (UITextField *)txtfiled;
            UITableViewCell *cell = (UITableViewCell *)[[[txtfiled superview] superview] superview];
            NSIndexPath *txtfldIndexPath = [self.shareTableView indexPathForCell:cell];
            if (txtfldIndexPath.section == ShareSectionTag && tagField.text.length == 1) {
                tagField.text = @"";
            }
        }
    }
    
    if(showCompositionCell) {
        showCompositionCell = NO;
        [self expandOrCollapseComposition];
    }
    
    UITableViewCell *cell = (UITableViewCell *)[[[textField superview] superview] superview];
    NSIndexPath *txtfldIndexPath = [self.shareTableView indexPathForCell:cell];
    if (txtfldIndexPath.section == ShareSectionTag && !textField.text.length) {
        textField.text = @"#";
    }
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         CGRect shareBodyFrame = self.shareBodyContainerView.frame;
                         shareBodyFrame.origin.y = 0.0f;
                         [self.shareBodyContainerView setFrame:shareBodyFrame];
                     }
                     completion:nil];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITableViewCell *cell = (UITableViewCell *)[[[textField superview] superview] superview];
    NSIndexPath *txtfldIndexPath = [self.shareTableView indexPathForCell:cell];
    if (txtfldIndexPath.section == ShareSectionTag) {
        if(textField.text.length == 1 && string.length == 0) {
            return NO;
        }
    }
    
    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification
{
    UITextField *txtfld = (UITextField *)[notification object];
    NSMutableAttributedString *coloredText = [[NSMutableAttributedString alloc] initWithString:txtfld.text];
    [coloredText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:255/255.0] range:NSMakeRange(0, 1)];
    
    txtfld.attributedText = coloredText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    UITableViewCell *cell = (UITableViewCell *)[[[textField superview] superview] superview];
    NSIndexPath *txtfldIndexPath = [self.shareTableView indexPathForCell:cell];
    if (txtfldIndexPath.section == ShareSectionTag && textField.text.length == 1) {
        textField.text = @"";
    }
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         CGRect shareBodyFrame = self.shareBodyContainerView.frame;
                         shareBodyFrame.origin.y = 64.0f;
                         [self.shareBodyContainerView setFrame:shareBodyFrame];
                     }
                     completion:nil];
    
    return YES;
}

#pragma mark - SPGooglePlacesAutoCompleteViewControllerDelegate Methods

- (void)searchbarEditingWillBegin:(SPGooglePlacesAutocompleteViewController *)placeViewController
{
    CGRect rect = self.locationContainerView.frame;
    rect.size.height = CGRectGetHeight([UIScreen mainScreen].bounds);
    self.locationContainerView.frame = rect;
//    self.shareTableView.hidden = YES;
}

- (void)searchbarEditingWillEnd:(SPGooglePlacesAutocompleteViewController *)placeViewController
{
    CGRect rect = self.locationContainerView.frame;
    rect.size.height = 40;
    self.locationContainerView.frame = rect;
//    self.shareTableView.hidden = NO;
}

#pragma mark - CMCategoryVCDelegate Methods

- (void)categoryTableViewConroller:(CMCategoryVC *)viewController didSelectObjectAtIndex:(NSIndexPath *)indexpath
{
    showCategoryOption = !showCategoryOption;
    
    // resign keyboard if on screen.
    if([self.view findFirstResponder]) {
        id txtfiled = [self.view findFirstResponder];
        if([txtfiled isKindOfClass:[UITextField class]]) {
            [self textFieldShouldReturn:(UITextField *)txtfiled];
        }
    }
    
    if(showCompositionCell) {
        showCompositionCell = NO;
        [self expandOrCollapseComposition];

        [self.shareTableView beginUpdates];
        [self.shareTableView reloadSections:[NSIndexSet indexSetWithIndex:ShareSectionCategory] withRowAnimation:UITableViewRowAnimationFade]; //
        [self.shareTableView endUpdates];
    }
    else {
        [self.shareTableView beginUpdates];
        [self.shareTableView reloadSections:[NSIndexSet indexSetWithIndex:ShareSectionCategory] withRowAnimation:UITableViewRowAnimationFade]; //
        [self.shareTableView endUpdates];
    }
    
}

#pragma mark - CMShareCompositionCellDelegate Methods

- (void)compositionCellIsTapped
{
    showCompositionCell = !showCompositionCell;
    
    // resign keyboard if on screen.
    if([self.view findFirstResponder]) {
        id txtfiled = [self.view findFirstResponder];
        if([txtfiled isKindOfClass:[UITextField class]]) {
            [self textFieldShouldReturn:(UITextField *)txtfiled];
        }
    }
    
    if(showCategoryOption) {
        showCategoryOption = NO;
        categoryController.showCategoryOptions = NO;
        [categoryController.categoryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        
        [self.shareTableView beginUpdates];
        [self.shareTableView reloadSections:[NSIndexSet indexSetWithIndex:ShareSectionCategory] withRowAnimation:UITableViewRowAnimationFade]; //
        [self.shareTableView endUpdates];
    }
    
    [self expandOrCollapseComposition];

}

- (void)expandOrCollapseComposition
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         CGRect shareTableRect = self.shareTableView.frame;
                         
                         if(YES == showCompositionCell) {
                             shareTableRect.origin.y = CGRectGetMaxY(self.compositionContainerView.frame);
                         }
                         else {
                             shareTableRect.origin.y = CGRectGetMinY(self.compositionContainerView.frame) + 100.0f;
                         }
                         self.shareTableView.frame = shareTableRect;
                     }
                     completion:nil];
}

#pragma mark - Webservices Method
- (void)postComposition
{
    NSMutableDictionary *argDict = [[NSMutableDictionary alloc] init];
    
    NSInteger imgCount = 1;
    NSMutableArray *imgTimeArray = [NSMutableArray array];
    for(CMPhotoModel *modelObj in _imagePost.images) {
        NSData *imageData = UIImagePNGRepresentation(modelObj.editedImage);
        NSString *encodedImgString = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        [argDict setObject:encodedImgString forKey:[NSString stringWithFormat:@"imgFile%ld",(long)imgCount]];
        
        [imgTimeArray addObject:[NSString stringWithFormat:@"%0.2f", modelObj.duration]];
        
        imgCount++;
    }
    
    if(imgCount < 10) {
        for (; imgCount <= 10; imgCount++) {
            [argDict setObject:@"" forKey:[NSString stringWithFormat:@"imgFile%ld",(long)imgCount]];
        }
    }
    
    NSData *videoData = [NSData dataWithContentsOfFile:_imagePost.video.url];
    NSString *videoEncodedString = [videoData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSString *latLongStr = @"";
    if([DESLocationManager sharedLocationManager].currentLocation) {
        latLongStr = [NSString stringWithFormat:@"%lf", [DESLocationManager sharedLocationManager].currentLocation.coordinate.latitude];
        latLongStr = [NSString stringWithFormat:@"%@, %lf", latLongStr, [DESLocationManager sharedLocationManager].currentLocation.coordinate.longitude];
        [DESLocationManager sharedLocationManager].delegate = nil;
    }
    [[DESLocationManager sharedLocationManager] stopFetchingCurrentLocation];

    
    // get tag1 text from tableview cell (section:ShareSectionTag, index:0)
    CMShareTagCell *tag1Cell = (CMShareTagCell *)[self.shareTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ShareSectionTag]];
    CMShareTagCell *tag2Cell = (CMShareTagCell *)[self.shareTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:ShareSectionTag]];
    
    NSString *tag1Text = @"";
    NSString *tag2Text = @"";
    if(nil != tag1Cell) {
        tag1Text = tag1Cell.tagTxtfld.text;
    }
    
    if(nil != tag2Cell) {
        tag2Text = tag2Cell.tagTxtfld.text;
    }
    
    CMShareSocialCell *socialCell = (CMShareSocialCell *)[self.shareTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ShareSectionShare]];
    
    [argDict setObject:[WSModelClasses sharedHandler].loggedInUserModel.userID forKey:@"UserUID"];
    [argDict setObject:[imgTimeArray componentsJoinedByString:@","] forKey:@"imageTimesArr"];
    [argDict setObject:[categoryController getSelectedCategory] forKey:@"txtCategory"];
    [argDict setObject:[googleSearchController.searchDisplayController.searchBar text] forKey:@"txtLocation"];
    [argDict setObject:latLongStr forKey:@"txtLatLongitude"];
    [argDict setObject:socialCell.fbButton.isSelected ? @"YES" : @"NO" forKey:@"shareFB"];
    [argDict setObject:socialCell.gpButton.isSelected ? @"YES" : @"NO" forKey:@"shareGoogle"];
//    [argDict setObject:@"NO" forKey:@"shareTwitter"];
    [argDict setObject:tag1Text forKey:@"txtTag1"];
    [argDict setObject:tag2Text forKey:@"txtTag2"];
    [argDict setObject:videoEncodedString forKey:@"movFile"];
    [argDict setObject:_totalVideoDuration forKey:@"clip_duration"];
    
    NSLog(@"%s sending to url", __func__);
    [[WSModelClasses sharedHandler] showLoadView];
    [[WSModelClasses sharedHandler] setDelegate:self];
    [[WSModelClasses sharedHandler] postComposition:(NSDictionary *)argDict];
}

#pragma mark - Webservice Delegate Method
- (void)didFinishWSConnectionWithResponse:(NSDictionary *)responseDict
{
    [[WSModelClasses sharedHandler] removeLoadingView];
    WebservicesType serviceType = (WebservicesType)[responseDict[WS_RESPONSEDICT_KEY_SERVICETYPE] integerValue];
    if(responseDict[WS_RESPONSEDICT_KEY_ERROR]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Describe", @"") message:NSLocalizedString(@"Error while communicating to server. Please try again.", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    switch (serviceType) {
        case kWebservicesType_PostComposition:
        {
            // get the weburl from responseDict
            NSString *postUrl = responseDict[@"ResponseData"][@"DataTable"][0][@"NewData"][@"WebURL"]; //[responseDict valueForKeyPath:@"DataTable.NewData.WebURL"];// 
            
            CMShareSocialCell *socialCell = (CMShareSocialCell *)[self.shareTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ShareSectionShare]];
            if(socialCell.fbButton.isSelected) {
                [[DESocialConnectios sharedInstance] facebookSharing:@"DescribeApp" picture:nil caption:nil andLink:[NSURL URLWithString:postUrl] decription:@"Hey check my post of Goa trip."];
            }
            
            if(socialCell.gpButton.isSelected) {
                [[DESocialConnectios sharedInstance] setDelegate:self];
                [[DESocialConnectios sharedInstance] shareLinkOnGooglePlus:postUrl];
                return;
            }
            
            [self popToFeedScreen];
            break;
        }
            
        default:
            break;
    }
}

- (void)finishedSharingGooglePlusWithError:(NSError *)error
{
    if (!error) {
        [self popToFeedScreen];
    }
    else if (error.code == kGPPErrorShareboxCanceled) {
        [self popToFeedScreen];
    }
    else {
        NSLog(@"%s Error (%@)", __func__, [error localizedDescription]);
    }
}

@end
