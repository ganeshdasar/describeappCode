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

#define LOCATION_CELLIDENTIFIER             @"LocationCell"
#define COMPOSITION_CELLIDENTIFIER          @"CompositionCell"
#define CATEGORY_CELLIDENTIFIER             @"CategoryCell"
#define TAG_CELLIDENTIFIER                  @"TagCell"
#define SHARE_CELLIDENTIFIER                @"ShareCell"

typedef enum {
    ShareSectionLocation = -1,
    ShareSectionComposition = 0,
    ShareSectionCategory,
    ShareSectionTag,
    ShareSectionShare,
}ShareSection;

#define NO_CATEGORY_SELECTED_COLOR          [UIColor colorWithR:212.0f G:212.0f B:212.0f A:255.0f]
#define ALERT_TAG_DISMISS                   10
#define ALERT_TAG_MOVEBACK                  15

@interface CMShareViewController ()
{
    BOOL showCompositionCell;
    BOOL showCategoryOption;    // identifies whether to show category options or not
    NSArray *sectionCellIdentiferList;      // holds the cell idenitifer of all sections
    NSArray *categoryList;          // holds all the category names
    NSArray *categoryColorList;     // holds color object for the category
    
    NSInteger selectedCategoryIndex;
    SPGooglePlacesAutocompleteViewController *vc;
    
    CMCategoryVC *categoryController;
    DPostImage *_imagePost;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoRecordingDone:) name:NOTIFICATION_VIDEO_RECORDING_COMPLETED object:nil];
    
    _imagePost = [[DPostImage alloc] init];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for(CMPhotoModel *modelObj in _capturedPhotoList) {
        if(modelObj.originalImagePath) {
            [images addObject:modelObj];
        }
    }
    
    [_imagePost setImages:images];
    [self videoRecordingDone:nil];
    
   // [_imagePost setImages:[[NSArray alloc] initWithObjects:@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg", nil]];
   // [_imagePost setDurationList:[[NSArray alloc] initWithObjects:@"10",@"2",@"1",@"4",@"3", nil]];
    
    
    UINib *nib = [UINib nibWithNibName:@"CMShareCompositionCell" bundle:nil];
    [self.shareTableView registerNib:nib forCellReuseIdentifier:COMPOSITION_CELLIDENTIFIER];
    
//    nib = [UINib nibWithNibName:@"CMShareCategoryCell" bundle:nil];
//    [self.shareTableView registerNib:nib forCellReuseIdentifier:CATEGORY_CELLIDENTIFIER];
    
    nib = [UINib nibWithNibName:@"CMShareTagCell" bundle:nil];
    [self.shareTableView registerNib:nib forCellReuseIdentifier:TAG_CELLIDENTIFIER];
    
    nib = [UINib nibWithNibName:@"CMShareSocialCell" bundle:nil];
    [self.shareTableView registerNib:nib forCellReuseIdentifier:SHARE_CELLIDENTIFIER];
    
    selectedCategoryIndex = -1;  // default should be -1
    showCategoryOption = NO;  // default do not show category option
    sectionCellIdentiferList = [[NSArray alloc] initWithObjects:COMPOSITION_CELLIDENTIFIER, CATEGORY_CELLIDENTIFIER, TAG_CELLIDENTIFIER, SHARE_CELLIDENTIFIER, nil];
    
//    categoryList = [[NSArray alloc] initWithObjects:NSLocalizedString(@"No category", @""), NSLocalizedString(@"Activities", @""), NSLocalizedString(@"Animals & Pets", @""), NSLocalizedString(@"Architecture & Spaces", @""), NSLocalizedString(@"Arts & Crafts", @""), NSLocalizedString(@"Books", @""), NSLocalizedString(@"Celebration", @""), NSLocalizedString(@"Care", @""), NSLocalizedString(@"Design", @""), NSLocalizedString(@"Events", @""), NSLocalizedString(@"Education", @""), NSLocalizedString(@"Family", @""), NSLocalizedString(@"Food", @""), NSLocalizedString(@"Lifestyle", @""), NSLocalizedString(@"Places", @""), NSLocalizedString(@"Humor", @""), NSLocalizedString(@"Inspiration", @""), NSLocalizedString(@"Movies & TV", @""), NSLocalizedString(@"Music", @""), NSLocalizedString(@"News", @""), NSLocalizedString(@"Opinions", @""), NSLocalizedString(@"People", @""), NSLocalizedString(@"Photography", @""), NSLocalizedString(@"Products", @""), NSLocalizedString(@"Stories", @""), NSLocalizedString(@"Science & Nature", @""), NSLocalizedString(@"Technology", @""), NSLocalizedString(@"Things I Love", @""), nil];
//    
//    categoryColorList = [[NSArray alloc] initWithObjects:NO_CATEGORY_COLOR, ACTIVITIES_COLOR, ANIMALS_PETS_COLOR, ARCHITECTURE_SPACES_COLOR, ARTS_CRAFTS_COLOR, BOOKS_COLOR, CELEBRATION_COLOR, CARE_COLOR, DESIGN_COLOR, EVENTS_COLOR, EDUCATION_COLOR, FAMILY_COLOR, FOOD_COLOR, LIFESTYLE_COLOR, PLACES_COLOR, HUMOR_COLOR, INSPIRATION_COLOR, MOVIES_TV_COLOR, MUSIC_COLOR, NEWS_COLOR, OPINIONS_COLOR, PEOPLE_COLOR, PHOTOGRAPHY_COLOR, PRODUCTS_COLOR, STORIES_COLOR, SCIENCE_NATURE_COLOR, TECHNOLOGY_COLOR, THINGS_I_LOVE_COLOR, nil];
    
    vc = [[SPGooglePlacesAutocompleteViewController alloc] initWithNibName:@"SPGooglePlacesAutocompleteViewController" bundle:nil];
    vc.delegate = self;
    [self.locationContainerView addSubview:vc.view];
    
    categoryController = [[CMCategoryVC alloc] initWithNibName:@"CMCategoryVC" bundle:nil];
    [categoryController.view setFrame:CGRectMake(0, 0, 320, 41.0)];
    categoryController.delegate = self;
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
            NSString *path = [[CMAVCameraHandler sharedHandler] videoFilenamePath];
            if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                NSError *err;
                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&err];
                if(!success) {
                    NSLog(@"%d, error = %@ \n%@", success, err.description, err.debugDescription);
                }
            }
            
            [[CMAVCameraHandler sharedHandler] setVideoFilenamePath:nil];
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
}

- (IBAction)shareButtonClicked:(id)sender
{
    NSLog(@"%s", __func__);
    [self postComposition];
}

#pragma mark - UITableDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 1;
    ShareSection sectionVal = (ShareSection)section;
    switch (sectionVal) {
        case ShareSectionLocation:
        case ShareSectionComposition:
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
        case ShareSectionLocation:
        {
            break;
        }
            
        case ShareSectionComposition:
        {
            CMShareCompositionCell *compositeCell = (CMShareCompositionCell *)cell;
            compositeCell.delegate = self;
            CMPhotoModel *model = (CMPhotoModel *)self.capturedPhotoList[0];
            compositeCell.compositionImageView.image = model.editedImage;
            [compositeCell setPostImage:_imagePost];
            
            break;
        }
            
        case ShareSectionCategory:
        {
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            [categoryController.view removeFromSuperview];
            [cell.contentView addSubview:categoryController.view];
            
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
                tagCell.seperatorLineView.hidden = NO;
            }
            else {
                tagCell.tagTxtfld.placeholder = @"#SecondTag";
                tagCell.seperatorLineView.hidden = YES;
            }
            
            break;
        }
            
        case ShareSectionShare:
        {
            CMShareSocialCell *socialCell = (CMShareSocialCell *)cell;
            [socialCell.fbButton addTarget:self action:@selector(socailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [socialCell.gpButton addTarget:self action:@selector(socailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [socialCell.twButton addTarget:self action:@selector(socailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
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
        case ShareSectionLocation:
        case ShareSectionTag:
        {
            rowheight = 41.0f;
            break;
        }
        
        case ShareSectionCategory:
        {
            if(showCategoryOption) {
                rowheight = CGRectGetHeight(tableView.frame) - 100.0f;
                categoryController.categoryTableView.scrollEnabled = YES;
            }
            else {
                rowheight = 41.0f;
                categoryController.categoryTableView.scrollEnabled = NO;
            }
            break;
        }
            
        case ShareSectionComposition:
        {
            if(!showCompositionCell) {
                rowheight = 100.0f;
            }
            else {
                rowheight = 320.0f;
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
    NSLog(@"%@", [[textField superview] superview]);
    NSLog(@"%@", [[[textField superview] superview] superview]);
    UITableViewCell *cell = (UITableViewCell *)[[[textField superview] superview] superview];
    NSIndexPath *txtfldIndexPath = [self.shareTableView indexPathForCell:cell];
    if (txtfldIndexPath.section == ShareSectionTag && !textField.text.length) {
        textField.text = @"#";
    }
    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    UITableViewCell *cell = (UITableViewCell *)[[[textField superview] superview] superview];
    NSIndexPath *txtfldIndexPath = [self.shareTableView indexPathForCell:cell];
    if (txtfldIndexPath.section == ShareSectionTag && textField.text.length == 1) {
        textField.text = @"";
    }
    
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
    
    if(showCompositionCell) {
        showCompositionCell = NO;

        [self.shareTableView beginUpdates];
        [self.shareTableView reloadSections:[NSIndexSet indexSetWithIndex:ShareSectionComposition] withRowAnimation:UITableViewRowAnimationFade];
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
    
    if(showCategoryOption) {
        showCategoryOption = NO;
        categoryController.showCategoryOptions = NO;
        [categoryController.categoryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        
        [self.shareTableView beginUpdates];
        [self.shareTableView reloadSections:[NSIndexSet indexSetWithIndex:ShareSectionCategory] withRowAnimation:UITableViewRowAnimationFade]; //
        [self.shareTableView reloadSections:[NSIndexSet indexSetWithIndex:ShareSectionComposition] withRowAnimation:UITableViewRowAnimationFade];
        [self.shareTableView endUpdates];
    }
    else {
        [self.shareTableView reloadSections:[NSIndexSet indexSetWithIndex:ShareSectionComposition] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Webservices Method
- (void)postComposition
{
    NSMutableDictionary *argDict = [[NSMutableDictionary alloc] init];
    
    NSInteger imgCount = 1;
    NSMutableArray *imgTimeArray = [NSMutableArray array];
    for(CMPhotoModel *modelObj in _imagePost.images) {
        NSData *imageData = UIImagePNGRepresentation(modelObj.editedImage);
        NSString *encodedImgString = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
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
    if(videoEncodedString == nil) {
        videoEncodedString = @"";
    }
    
    [argDict setObject:[[[[WSModelClasses sharedHandler] loggedInUserModel] userID] stringValue] forKey:@"UserUID"];
    [argDict setObject:[imgTimeArray componentsJoinedByString:@","] forKey:@"imageTimesArr"];
    [argDict setObject:@"No Category" forKey:@"txtCategory"];
    [argDict setObject:@"Hyderabad" forKey:@"txtLocation"];
    [argDict setObject:@"17.366, 78.476" forKey:@"txtLatLongitude"];
    [argDict setObject:@"NO" forKey:@"shareFB"];
    [argDict setObject:@"NO" forKey:@"shareGoogle"];
    [argDict setObject:@"NO" forKey:@"shareTwitter"];
    [argDict setObject:@"SampleComposition" forKey:@"txtTag1"];
    [argDict setObject:@"MakeComposition" forKey:@"txtTag2"];
    [argDict setObject:videoEncodedString forKey:@"movFile"];
    [argDict setObject:_totalVideoDuration forKey:@"clip_duration"];
    
    NSLog(@"%s sending to url", __func__);
    [[WSModelClasses sharedHandler] setDelegate:self];
    [[WSModelClasses sharedHandler] postComposition:(NSDictionary *)argDict];
}

#pragma mark - Webservice Delegate Method
- (void)didFinishWSConnectionWithResponse:(NSDictionary *)responseDict
{
    WebservicesType serviceType = (WebservicesType)[responseDict[WS_RESPONSEDICT_KEY_SERVICETYPE] integerValue];
    if(responseDict[WS_RESPONSEDICT_KEY_ERROR]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Describe", @"") message:NSLocalizedString(@"Error while communicating to server. Please try again.", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    switch (serviceType) {
        case kWebservicesType_PostComposition:
        {
            [self popToFeedScreen];
            break;
        }
            
        default:
            break;
    }
}

@end
