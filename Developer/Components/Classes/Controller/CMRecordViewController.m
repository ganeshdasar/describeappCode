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

#define SHARE_CONTROLLER_SEAGUE             @"SharePush"
#define MAX_VIDEO_RECORD_TIME               10.0f

@interface CMRecordViewController ()
{
    float progressVal;
    NSTimer *progressTimer;
    float currentVideoTime;
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
    }
    
    [self performSelector:@selector(showCameraView) withObject:nil afterDelay:0.1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    
    UINib *nib = [UINib nibWithNibName:@"CMPhotoCell" bundle:nil];
    [self.photoCollectionView registerNib:nib forCellWithReuseIdentifier:@"PhotoCellIdentifier"];
    
    self.selectedImageIndex = -1;
    progressVal = 0;
    currentVideoTime = 0.0;
    
//    CMPhotoModel *modelObj = (CMPhotoModel *)self.capturedPhotoList[0];
//    self.selectedImageView.image = modelObj.editedImage;
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCameraView
{
#if !(TARGET_IPHONE_SIMULATOR)

    [[CMAVCameraHandler sharedHandler] addVideoInputFromFrontCamera:kCameraDeviceFront];
    [[CMAVCameraHandler sharedHandler] removeVideoAudioOutput];
    [[CMAVCameraHandler sharedHandler] addvideoAudioOutputForUsingAssetLibrary];
    [[CMAVCameraHandler sharedHandler] showCameraPreviewInView:_videoPreviewView];
    
#endif
}

- (void)removeCameraView
{
#if !(TARGET_IPHONE_SIMULATOR)

    [[CMAVCameraHandler sharedHandler] removePreviewLayer];
    [[CMAVCameraHandler sharedHandler] setDelegate:nil];
    
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
#if !(TARGET_IPHONE_SIMULATOR)
    
    if([[CMAVCameraHandler sharedHandler] isVideoRecordingStarted]) {
        [[CMAVCameraHandler sharedHandler] startOrStopRecordingVideo];
    }
    
#endif
    
    CMShareViewController *shareController = [[CMShareViewController alloc] initWithNibName:@"CMShareViewController" bundle:nil];
    shareController.capturedPhotoList = self.capturedPhotoList;
    [self.navigationController pushViewController:shareController animated:YES];
    shareController = nil;
}

- (IBAction)dissmissOptionClicked:(id)sender
{
    
}

- (IBAction)prevButtonSelected:(id)sender
{
#if !(TARGET_IPHONE_SIMULATOR)

    if([[CMAVCameraHandler sharedHandler] isVideoRecordingStarted] && ![[CMAVCameraHandler sharedHandler] isRecordingPaused]) {
        [self startOrPauseVideoRecording:nil];
    }
    [self removeCameraView];
    
#endif
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)startOrPauseVideoRecording:(id)sender
{
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
        modelObj.pauseTime = currentVideoTime;
    }

#endif
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
    }
    
    self.selectedImageIndex++;
    if(self.selectedImageIndex < self.capturedPhotoList.count) {
        CMPhotoModel *modelObj = (CMPhotoModel *)self.capturedPhotoList[self.selectedImageIndex];
        if(modelObj.originalImage != nil) {
            self.selectedImageView.image = modelObj.editedImage;
        }
        else {
            isRecordingDone = YES;
        }
    }
    else {
        // here we come if all images are recorded
        isRecordingDone = YES;
    }
    
#if !(TARGET_IPHONE_SIMULATOR)

    if(isRecordingDone) {
        // Stop video recording
        if([[CMAVCameraHandler sharedHandler] isVideoRecordingStarted] && ![[CMAVCameraHandler sharedHandler] isRecordingPaused]) {
            [self startOrPauseVideoRecording:nil];
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


@end
