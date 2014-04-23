//
//  CMRecordViewController.m
//  Composition
//
//  Created by Describe Administrator on 22/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "CMRecordViewController.h"
#import "CMPhotoCell.h"
#import "CMShareViewController.h"
#import "DHeaderView.h"


#define SHARE_CONTROLLER_SEAGUE             @"SharePush"
#define MAX_VIDEO_RECORD_TIME               10.0f

@interface CMRecordViewController ()<DHeaderViewDelegate>
{
    CGFloat progressVal;
    NSTimer *progressTimer;
    CGFloat currentVideoTime;
    
    BOOL isRecordingCompleted;
    IBOutlet DHeaderView *_headerView;
    CGRect prevBtnActualRect;
}

@property (assign) NSInteger selectedImageIndex;
@property (assign) NSInteger pauseStateIndex;

@end

@implementation CMRecordViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([self identifyNotRecordedImageAndDisplay] == NO) {
        self.selectedImageIndex = 0;
        self.selectedImageView.image = [(CMPhotoModel *)self.capturedPhotoList[0] editedImage];
        
        isRecordingCompleted = YES;
    }
    else {
        if(self.selectedImageIndex == 0) {
            progressVal = 0;
            currentVideoTime = 0.0;
            isRecordingCompleted = NO;
        }
        
        if([self isLastPhotoRecording]) {
            [UIView animateWithDuration:0.3 animations:^{
//                CGRect frame = self.listButton.frame;
//                self.prevButton.frame = frame;
//                
//                frame.origin.x = 139.0;
//                self.listButton.frame = frame;
//                
//                self.nextButton.hidden = NO;
            }];
        }
    }

    [self showCameraView];
//    [self performSelector:@selector(showCameraView) withObject:nil afterDelay:0.1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    if(self.parentController != nil) {
        [[WSModelClasses sharedHandler] removeLoadingView];
//        [self.parentController refreshSelectedImageViewContainer];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self designHeaderView];
    self.navigationController.navigationBarHidden = YES;
    
    _videoPreviewView.layer.cornerRadius = 10.0f;
    _videoPreviewView.layer.masksToBounds = YES;
    _videoPreviewView.layer.borderWidth = 1.0f;
    _videoPreviewView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    isRecordingCompleted = NO;
    
    UINib *nib = [UINib nibWithNibName:@"CMPhotoCell" bundle:nil];
    [self.photoCollectionView registerNib:nib forCellWithReuseIdentifier:@"PhotoCellIdentifier"];
    
    self.selectedImageIndex = -1;
    progressVal = 0;
    currentVideoTime = 0.0;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.photoCollectionView.collectionViewLayout;
    if([UIScreen mainScreen].bounds.size.height > 480) {
        flowLayout.sectionInset = UIEdgeInsetsMake(20.0, 5.0, 20.0, 5.0);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    else {
        flowLayout.sectionInset = UIEdgeInsetsMake(-20.0, 5.0, 0.0, 5.0);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    
    [self.photoCollectionView setContentOffset:CGPointMake(0.0, 20.0) animated:NO];
}

- (void)designHeaderView
{
    UIButton *closeButton = [[UIButton alloc] init];
    [closeButton setTag:HeaderButtonTypeClose];
    [closeButton setImage:[UIImage imageNamed:@"btn_nav_std_cancel.png"] forState:UIControlStateNormal];
    
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setTag:HeaderButtonTypePrev];
    [backButton setImage:[UIImage imageNamed:@"btn_nav_comp_back.png"] forState:UIControlStateNormal];
    
    UIButton *nextButton = [[UIButton alloc] init];
    [nextButton setTag:HeaderButtonTypeNext];
    [nextButton setImage:[UIImage imageNamed:@"btn_nav_comp_next.png"] forState:UIControlStateNormal];
    
    [_headerView designHeaderViewWithTitle:@"Record" andWithButtons:@[backButton, nextButton, closeButton]];
    [_headerView setDelegate:self];
    [_headerView setbackgroundImage:[UIImage imageNamed:@"bg_nav_comp.png"]];
    
//    [_headerView hideButton:nextButton];
    self.nextButton = nextButton;
    self.prevButton = backButton;
    self.cancelButton = closeButton;
    
    prevBtnActualRect = self.prevButton.frame;
    self.prevButton.frame = self.nextButton.frame;
}

- (void)headerView:(DHeaderView *)headerView didSelectedHeaderViewButton:(UIButton *)headerButton
{
    HeaderButtonType buttonType = headerButton.tag;
    switch (buttonType) {
        case HeaderButtonTypeClose:
        {
            [self dissmissOptionClicked:headerButton];
            break;
        }
            
        case HeaderButtonTypeNext:
        {
            [self nextOptionClicked:headerButton];
            break;
        }
            
        case HeaderButtonTypePrev:
        {
            [self prevButtonSelected:headerButton];
            break;
        }
            
        default:
            break;
    }
}

- (BOOL)identifyNotRecordedImageAndDisplay
{
    for(CMPhotoModel *modelObj in self.capturedPhotoList) {
        if(!modelObj.isRecorded) {
            self.selectedImageView.image = modelObj.editedImage;
            self.selectedImageIndex = [self.capturedPhotoList indexOfObject:modelObj];
            progressVal = (modelObj.pauseTime - modelObj.startAppearanceTime)/10;
            if(modelObj.pauseTime) {
                currentVideoTime = modelObj.pauseTime;
            }
            else {
                currentVideoTime = modelObj.startAppearanceTime;
            }
            
            [self.videoProgressIndicator setProgress:progressVal];
            
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isAllPhotosRecorded
{
    for(CMPhotoModel *modelObj in self.capturedPhotoList) {
        if(modelObj.originalImage && modelObj.isRecorded == NO) {
            return NO;
        }
        
    }
    
    return YES;
}

- (BOOL)isLastPhotoRecording
{
    if(self.selectedImageIndex < 0) {
        return NO;
    }
    
    CMPhotoModel *modelObj = self.capturedPhotoList[self.selectedImageIndex];
    if(modelObj.originalImage && modelObj.isRecorded == NO) {
        int nextIndex = self.selectedImageIndex+1;
        if(nextIndex == self.capturedPhotoList.count) {
            return YES;
        }
        
        CMPhotoModel *nextObj = self.capturedPhotoList[nextIndex];
        if(nextObj.originalImage == nil) {
            return YES;
        }
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCameraView
{
#if !(TARGET_IPHONE_SIMULATOR)

    [[CMAVCameraHandler sharedHandler] changeCapturesSessionPreset:AVCaptureSessionPresetLow];
    [[CMAVCameraHandler sharedHandler] setDelegate:self];
    [[CMAVCameraHandler sharedHandler] removeVideoAudioOutput];
    [[CMAVCameraHandler sharedHandler] addVideoInputFromFrontCamera:kCameraDeviceFront];
    [[CMAVCameraHandler sharedHandler] addvideoAudioOutputForUsingAssetLibrary];
    [[CMAVCameraHandler sharedHandler] showCameraPreviewInView:_videoPreviewView withRect:_videoPreviewView.bounds];
    
#endif
}

- (void)removeCameraView
{
#if !(TARGET_IPHONE_SIMULATOR)
    
    [[CMAVCameraHandler sharedHandler] setDelegate:nil];
    [[CMAVCameraHandler sharedHandler] removePreviewLayer];
    
#endif
}

#pragma mark - UICollectionView Datasource methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMPhotoModel *model = (CMPhotoModel *)self.capturedPhotoList[indexPath.item];
    model.indexNumber = indexPath.item + 1;
    CMPhotoCell *aCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCellIdentifier" forIndexPath:indexPath];
    [aCell setDataModel:model];
    return aCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s %d, pauseIndex = %d", __func__, indexPath.item, self.pauseStateIndex);
#if !(TARGET_IPHONE_SIMULATOR)

    if(![[CMAVCameraHandler sharedHandler] isVideoRecordingStarted]) {
        return;
    }
    
    if([[CMAVCameraHandler sharedHandler] isRecordingPaused]) {
        if((indexPath.item > self.pauseStateIndex && (indexPath.item-1) == self.pauseStateIndex) || self.pauseStateIndex == indexPath.item) {
            CMPhotoModel *modelObj = (CMPhotoModel *)self.capturedPhotoList[indexPath.item];
            if(modelObj.originalImage != nil) {
                self.selectedImageView.image = modelObj.editedImage;
                self.selectedImageIndex = indexPath.item;
            }
        }
    }
    else if(indexPath.item > self.selectedImageIndex && (indexPath.item-1) == self.selectedImageIndex) {
        [self changePreviewImageToNext];
    }
    
#endif
}

#pragma mark - Header button action methods

- (IBAction)listOptionClicked:(id)sender
{
    
}

- (IBAction)nextOptionClicked:(id)sender
{
    if([self isAllPhotosRecorded] == NO && [self isLastPhotoRecording] == NO) {
        
#if !(TARGET_IPHONE_SIMULATOR)
        if([[CMAVCameraHandler sharedHandler] isVideoRecordingStarted] && ![[CMAVCameraHandler sharedHandler] isRecordingPaused]) {
            [self startOrPauseVideoRecording:nil];
        }
#endif
        
        // show alert to record video for all photos
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Describe", @"") message:NSLocalizedString(@"Record video for all photos to continue.", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
#if !(TARGET_IPHONE_SIMULATOR)
    if([[CMAVCameraHandler sharedHandler] isVideoRecordingStarted]) {
        if(self.selectedImageIndex != -1 && self.selectedImageIndex < self.capturedPhotoList.count) {
            CMPhotoModel *modelObj = (CMPhotoModel *)self.capturedPhotoList[self.selectedImageIndex];
            if(modelObj != nil && modelObj.originalImage) {
                modelObj.isRecorded = YES;
                NSLog(@"duration = %f", currentVideoTime - modelObj.startAppearanceTime - 0.1);
                modelObj.duration = currentVideoTime - modelObj.startAppearanceTime - 0.1;  // we are removing 0.1 here because 0.1 is added to currentVideoTime before it came here; so getting actualValue
            }
        }
        
        [[CMAVCameraHandler sharedHandler] startOrStopRecordingVideo];
    }
#endif
    
    CMShareViewController *shareController = [[CMShareViewController alloc] initWithNibName:@"CMShareViewController" bundle:nil];
    shareController.capturedPhotoList = self.capturedPhotoList;
    [self.navigationController pushViewController:shareController animated:YES];
    shareController = nil;
    
//    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.prevButton.frame;
//        self.listButton.frame = frame;
    
        frame = self.nextButton.frame;
        self.prevButton.frame = frame;
        
        self.nextButton.hidden = YES;
//    }];
}

- (IBAction)dissmissOptionClicked:(id)sender
{
#if !(TARGET_IPHONE_SIMULATOR)
    if([[CMAVCameraHandler sharedHandler] isVideoRecordingStarted] && ![[CMAVCameraHandler sharedHandler] isRecordingPaused]) {
        [self startOrPauseVideoRecording:nil];
    }
#endif

    // show an alert whether user wants to really dismiss the current video composition.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Describe", @"") message:NSLocalizedString(@"You will lose your current composition, if you navigate back. Do you still want to continue.", @"") delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

- (IBAction)prevButtonSelected:(id)sender
{
#if !(TARGET_IPHONE_SIMULATOR)

    if([[CMAVCameraHandler sharedHandler] isVideoRecordingStarted] && ![[CMAVCameraHandler sharedHandler] isRecordingPaused]) {
        [self startOrPauseVideoRecording:nil];
    }
    [self removeCameraView];
    
#endif
    
    [self.navigationController popViewControllerAnimated:NO];
    [self.parentController showCameraOverlayView];
}

- (IBAction)startOrPauseVideoRecording:(id)sender
{
    if(isRecordingCompleted) {
        return;
    }
    
#if !(TARGET_IPHONE_SIMULATOR)

    if([[CMAVCameraHandler sharedHandler] isVideoRecordingStarted] == NO) {
        if(self.selectedImageView.image) {
            [[CMAVCameraHandler sharedHandler] startOrStopRecordingVideo];
        }
        else {
            return;
        }
    }
    else {
        [[CMAVCameraHandler sharedHandler] pauseOrResumeRecordingVideo];
    }
    
    if(![[CMAVCameraHandler sharedHandler] isRecordingPaused]) {
        // the recording is resumed
        if(self.pauseStateIndex != self.selectedImageIndex) {
            CMPhotoModel *modelObj = (CMPhotoModel *)self.capturedPhotoList[self.pauseStateIndex];
            modelObj.isRecorded = YES;
            
            progressVal = 0.0;
            [self.videoProgressIndicator setProgress:0.0];
        }
        
        [self startProgressTimer];
    }
    else {
        // the recording is paused
        self.pauseStateIndex = self.selectedImageIndex;
        CMPhotoModel *modelObj = (CMPhotoModel *)self.capturedPhotoList[self.pauseStateIndex];
        if(modelObj.originalImagePath) {
            modelObj.pauseTime = currentVideoTime;
        }
    }

#endif
}

#pragma mark - UIAlertViewDelegate Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //    NSLog(@"buttonIndex = %d", buttonIndex);
    if(buttonIndex == 1) {
        [self popToFeedScreen];
    }
    
}

- (void)popToFeedScreen
{
    // remove the composition from document
    [[WSModelClasses sharedHandler] removeCompositionPath];
    
    // from here we should pop back to feed controller, which will be in stack at thirdLast index so we will get that controller from controllerStack and pop to that controller
    NSInteger count = self.navigationController.viewControllers.count;
    
    // since we need to go back twice, we will decrement count by 3 to get index
    NSInteger index = count - 3;
    if(index >= 0) {
        id viewController = self.navigationController.viewControllers[index];
        [self.navigationController popToViewController:(UIViewController *)viewController animated:YES];
    }
}

#pragma mark - Updating progressbar

- (void)updateProgressBar
{
#if !(TARGET_IPHONE_SIMULATOR)

    if([[CMAVCameraHandler sharedHandler] isRecordingPaused] || ![[CMAVCameraHandler sharedHandler] isVideoRecordingStarted]) {
        [self invalidateProgressTimer];
        return;
    }
    
    if(progressVal == 0.0) {
        // set the start progress time in photomodel as currentVideoTime
        CMPhotoModel *modelObj = (CMPhotoModel *)self.capturedPhotoList[self.selectedImageIndex];
        modelObj.startAppearanceTime = currentVideoTime;
    }
    
    [self.videoProgressIndicator setProgress:progressVal];
    progressVal += 0.01;
    currentVideoTime += 0.1;
    
//    NSLog(@"progressVal = %f", progressVal);
    if(progressVal > 1) {
        progressVal = 0.0;
        [progressTimer invalidate];
        NSLog(@"Invalidate");
        [self changePreviewImageToNext];
    }
    
#endif
}

- (void)startProgressTimer
{
    if(progressTimer) {
        [self invalidateProgressTimer];
    }
    
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
}

- (void)invalidateProgressTimer
{
    if(progressTimer && [progressTimer isValid]) {
        [progressTimer invalidate];
        progressTimer = nil;
    }
}

- (void)changePreviewImageToNext
{
    BOOL isRecordingDone = NO;
    if(self.selectedImageIndex != -1) {
        CMPhotoModel *modelObj = (CMPhotoModel *)self.capturedPhotoList[self.selectedImageIndex];
        modelObj.isRecorded = YES;
        NSLog(@"duration = %f", currentVideoTime - modelObj.startAppearanceTime - 0.1);
        modelObj.duration = currentVideoTime - modelObj.startAppearanceTime - 0.1;  // we are removing 0.1 here because 0.1 is added to currentVideoTime before it came here; so getting actualValue
    }
    
    self.selectedImageIndex++;
    if(self.selectedImageIndex < self.capturedPhotoList.count) {
        CMPhotoModel *modelObj = (CMPhotoModel *)self.capturedPhotoList[self.selectedImageIndex];
        if(modelObj.originalImage != nil) {
            self.selectedImageView.image = modelObj.editedImage;
        }
        else {
            isRecordingDone = YES;
            isRecordingCompleted = YES;
        }
    }
    else {
        // here we come if all images are recorded
        isRecordingDone = YES;
        isRecordingCompleted = YES;
    }
    
    if([self isLastPhotoRecording]) {
        [UIView animateWithDuration:0.3 animations:^{
//            CGRect frame = self.listButton.frame;
//            self.prevButton.frame = frame;
//            
//            frame.origin.x = 139.0;
//            self.listButton.frame = frame;
//            
//            self.nextButton.hidden = NO;
        }];
    }
    
#if !(TARGET_IPHONE_SIMULATOR)

    if(isRecordingDone) {
        // Stop video recording
        if([[CMAVCameraHandler sharedHandler] isVideoRecordingStarted] && ![[CMAVCameraHandler sharedHandler] isRecordingPaused]) {
            if(self.selectedImageIndex >= self.capturedPhotoList.count) {
                [[CMAVCameraHandler sharedHandler] startOrStopRecordingVideo];
            }
            else {
                [self startOrPauseVideoRecording:nil];
            }
        }
        
    }
    else {
        progressVal = 0;
        [self.videoProgressIndicator setProgress:0.0];
        [self startProgressTimer];
    }
    
#endif
}

#pragma mark - Seague callback method for storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SHARE_CONTROLLER_SEAGUE]) {
#if !(TARGET_IPHONE_SIMULATOR)

        if([[CMAVCameraHandler sharedHandler] isVideoRecordingStarted]) {
            [[CMAVCameraHandler sharedHandler] startOrStopRecordingVideo];
        }
        
#endif

        CMShareViewController *recordController = segue.destinationViewController;
        [recordController setCapturedPhotoList:self.capturedPhotoList];
    }
    
}

#pragma mark - Application entering background handling
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    if([[CMAVCameraHandler sharedHandler] isVideoRecordingStarted] && ![[CMAVCameraHandler sharedHandler] isRecordingPaused]) {
        NSLog(@"Pausing the camera while going to background");
        [self startOrPauseVideoRecording:nil];
    }
    
#endif
    
}

#pragma mark - CMAVCameraHandlerDelegate Methods

- (void)didStartedVideoRecordingAtPath:(NSString *)recordingPath
{
    NSString *compositionPath = [NSString stringWithFormat:@"%@/%@", COMPOSITION_TEMP_FOLDER_PATH, COMPOSITION_DICT];
    if([[NSFileManager defaultManager] fileExistsAtPath:compositionPath]) {
        NSData *data = [NSData dataWithContentsOfFile:compositionPath];
        NSMutableDictionary *compositionDict = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data] copyItems:YES];
        [compositionDict setObject:recordingPath forKey:COMPOSITION_VIDEO_PATH_KEY];
        
        BOOL arraySuccess = [NSKeyedArchiver archiveRootObject:compositionDict toFile:compositionPath];
        if(!arraySuccess) {
            NSLog(@"%s arraySuccess = %d", __func__, arraySuccess);
        }
    }
}

@end
