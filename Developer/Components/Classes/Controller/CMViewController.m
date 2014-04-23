//
//  CMViewController.m
//  Composition
//
//  Created by Describe Administrator on 18/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "CMViewController.h"
#import "CMPhotoCell.h"
#import "CMRecordViewController.h"
#import "CMAVCameraHandler.h"
#import "DBAspectFillViewController.h"
#import "WSModelClasses.h"
#import "DHeaderView.h"

#define MAX_IMAGE_SELECT_COUNT              10
#define DEFAULT_IMAGE_RECT                  CGRectMake(0, 0, 320.0, 320.0)
#define LIST_BUTTON_DEFAULT_XVAL            177
#define RECORD_CONTROLLER_SEAGUE            @"RecordPush"

#define IMAGE_FLASH_AUTO                    @"btn_black_flash_auto.png"
#define IMAGE_FLASH_ON                      @"btn_black_trash.png"
#define IMAGE_FLASH_OFF                     @"btn_black_flash_off.png"

@interface CMViewController () <DBAspectFillViewControllerDelegate, DHeaderViewDelegate>
{
    CameraDevice currentCameraMode;
    AVCaptureFlashMode currentFlashMode;
    IBOutlet DHeaderView *_headerView;
}

@property (nonatomic, strong) NSMutableArray *capturedPhotoList;
@property (assign) NSUInteger selectedImageCount;
@property (assign) NSInteger selectedImageIndex;
@property (nonatomic, strong) DBAspectFillViewController *aspectFillImageController;

@end

@implementation CMViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self designHeaderView];

    UINib *nib = [UINib nibWithNibName:@"CMPhotoCell" bundle:nil];
    [self.photoCollectionView registerNib:nib forCellWithReuseIdentifier:@"PhotoCellIdentifier"];
    
    // hide the navigation bar
    self.navigationController.navigationBarHidden = YES;
    
    self.selectedImageCount = 0;
    self.selectedImageIndex = -1;  // -1 indicates no image is selected
    currentCameraMode = kCameraDeviceRear;
    currentFlashMode = AVCaptureFlashModeAuto;
    
    // place the DBAspectFillViewController.view on top of cameraContainerView and send view to back
    _aspectFillImageController = [[DBAspectFillViewController alloc] initWithNibName:@"DBAspectFillViewController" bundle:nil];
    _aspectFillImageController.delegate = self;
    [_aspectFillImageController.view setFrame:_cameraContainerView.bounds];
    [_aspectFillImageController setScreenSize:_cameraContainerView.frame.size];
    [_cameraContainerView addSubview:_aspectFillImageController.view];
    [_cameraContainerView sendSubviewToBack:_aspectFillImageController.view];
    
    self.capturedPhotoList = [self constructPhotoList];
    [self manageHeaderButtonVisibility];
    
    LXReorderableCollectionViewFlowLayout *flowLayout = [[LXReorderableCollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 5.0f;
    flowLayout.minimumInteritemSpacing = 5.0f;
    flowLayout.itemSize = CGSizeMake(58.0, 58.0);
//    NSLog(@"Frame = %@", NSStringFromCGRect([UIScreen mainScreen].bounds));
    if([UIScreen mainScreen].bounds.size.height > 480) {
        flowLayout.sectionInset = UIEdgeInsetsMake(20.0, 5.0, 20.0, 5.0);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    else {
        flowLayout.sectionInset = UIEdgeInsetsMake(-20.0, 5.0, 0.0, 5.0);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    
    [self.photoCollectionView setCollectionViewLayout:flowLayout animated:NO];
    [self.photoCollectionView setContentOffset:CGPointMake(0.0, 20.0) animated:NO];
    
    [self.photoCollectionView reloadData];
#if !(TARGET_IPHONE_SIMULATOR)

    [[CMAVCameraHandler sharedHandler] startCaptureSession];
    
#endif
    
}

-(void)designHeaderView
{
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setTag:HeaderButtonTypeClose];
    [backButton setImage:[UIImage imageNamed:@"btn_nav_std_cancel.png"] forState:UIControlStateNormal];
    
    UIButton *nextButton = [[UIButton alloc] init];
    [nextButton setTag:HeaderButtonTypeNext];
    [nextButton setImage:[UIImage imageNamed:@"btn_nav_comp_next.png"] forState:UIControlStateNormal];
    [nextButton setHidden:YES];
    
    [_headerView designHeaderViewWithTitle:@"Add Photos" andWithButtons:@[nextButton, backButton]];
    [_headerView setDelegate:self];
    [_headerView setbackgroundImage:[UIImage imageNamed:@"bg_nav_comp.png"]];
    
    self.nextButton = nextButton;
}

-(void)headerView:(DHeaderView *)headerView didSelectedHeaderViewButton:(UIButton *)headerButton
{
    HeaderButtonType buttonType = headerButton.tag;
    switch (buttonType) {
        case HeaderButtonTypeClose:
            [self backOptionClicked:headerButton];
            break;
        case HeaderButtonTypeNext:
            [self nextOptionClicked:headerButton];
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([self checkIfTrayisFull]) {
        if(self.selectedImageIndex == -1) {
            self.selectedImageIndex = 0;
        }
        
        [self showSelectedPhoto:self.selectedImageIndex];
    }
    else {
        self.selectedImageIndex = -1;
        [self showCameraView];
//        [self performSelector:@selector(showCameraView) withObject:nil afterDelay:0.1];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCameraView
{
#if !(TARGET_IPHONE_SIMULATOR)

    [[CMAVCameraHandler sharedHandler] changeCapturesSessionPreset:AVCaptureSessionPresetPhoto];
    [[CMAVCameraHandler sharedHandler] setDelegate:self];
    [[CMAVCameraHandler sharedHandler] addVideoInputFromFrontCamera:currentCameraMode];
    [[CMAVCameraHandler sharedHandler] showCameraPreviewInView:_cameraContainerView withRect:[[UIScreen mainScreen] bounds]];
    [_cameraContainerView bringSubviewToFront:_cameraOverlayView];

#endif
}

- (void)removeCameraView
{
#if !(TARGET_IPHONE_SIMULATOR)
    
    [[CMAVCameraHandler sharedHandler] setDelegate:nil];
    [[CMAVCameraHandler sharedHandler] removePreviewLayer];

#endif
}

- (BOOL)checkIfTrayisFull
{
    return _selectedImageCount==self.capturedPhotoList.count;
}

- (void)manageHeaderButtonVisibility
{
    // here we will arrange header buttons frame and their visibility depending upon selection of images
    
    if(_selectedImageCount > 0) {
        // shift list button to default xVal and show nextbutton
        CGRect rect = self.listButton.frame;
        rect.origin.x = LIST_BUTTON_DEFAULT_XVAL;
        self.listButton.frame = rect;
        
        self.nextButton.hidden = NO;
    }
    else {
        // shift listbutton to next button position and hide the nextbutton
        CGRect rect = self.nextButton.frame;
        [self.listButton setFrame:rect];
        
        self.nextButton.hidden = YES;
    }
}

#pragma mark - Create default photo model and store it into photoList

- (NSMutableArray *)constructPhotoList
{
    NSMutableArray *listArray = [[NSMutableArray alloc] init];
    
    NSString *compositionPath = [NSString stringWithFormat:@"%@/%@", COMPOSITION_TEMP_FOLDER_PATH, COMPOSITION_DICT];
    NSMutableArray *compositionArray = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:compositionPath]) {
        NSData *data = [NSData dataWithContentsOfFile:compositionPath];
        NSDictionary *compositionDict = [[NSDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data] copyItems:YES];
        compositionArray = [[NSMutableArray alloc] initWithArray:compositionDict[COMPOSITION_IMAGE_ARRAY_KEY] copyItems:YES];
    }
    
    // create photo list of ten items
    for (int num = 0; num < 10; num++) {
        CMPhotoModel *model = nil;
        if(compositionArray != nil && compositionArray.count > num) {
            model = [[CMPhotoModel alloc] initWithDictionary:compositionArray[num]];
            _selectedImageCount++;
        }
        else {
            model = [[CMPhotoModel alloc] init];
        }
        
        model.indexNumber = num+1;
        [listArray addObject:model];
    }
    
    return listArray;
}

#pragma mark - Hide/Unhide camera overlay buttons

- (void)showDeleteButton:(BOOL)isShow
{
    // here we will handle showing and hiding of delete button and other camera overlay buttons
    // if isShow flag is YES then show delete button and hide all other buttons
    // and if flag is NO then hide delete button and show all other buttons
    
    self.deleteButton.hidden = !isShow;
    
    self.flashButton.hidden = isShow;
    self.cameraDeviceButton.hidden = isShow;
    self.captureButton.hidden = isShow;
    self.galleryButton.hidden = isShow;
}

- (void)manageCameraGalleryButton
{
    if(_selectedImageCount >= MAX_IMAGE_SELECT_COUNT) {
        self.captureButton.enabled = NO;
        self.galleryButton.enabled = NO;
    }
    else {
        self.captureButton.enabled = YES;
        self.galleryButton.enabled = YES;
    }
}

- (void)refreshSelectedImageViewContainer
{
    [self showDeleteButton:NO];
    
    self.selectedImageIndex = -1;
    [_aspectFillImageController resetImageContentToEmpty];
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
//    NSLog(@"%s", __func__);
    [self showSelectedPhoto:indexPath.item];
}

- (void)showSelectedPhoto:(NSInteger)index
{
    CMPhotoModel *modelObj = (CMPhotoModel *)self.capturedPhotoList[index];
    if(modelObj.originalImage) {
        [self removeCameraView];
        
        // set default rect for selectedImageView
//        [_aspectFillImageController resetImageContentToEmpty];
        [_aspectFillImageController placeSelectedImage:modelObj.originalImage withCropRect:modelObj.cropRect];
        self.selectedImageIndex = index;
        
        // now hide all the camera related buttons and show delete button on cameraOverlayView
        [self showDeleteButton:YES];
    }
    else {
        [self refreshSelectedImageViewContainer];
#if !(TARGET_IPHONE_SIMULATOR)

        if([[CMAVCameraHandler sharedHandler] isPreviewLayerDisplaying] == NO) {
            [self showCameraView];
        }
        
#endif
    }
}

#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    CMPhotoModel *modelObject = (CMPhotoModel *)self.capturedPhotoList[fromIndexPath.item];
    
    [self.capturedPhotoList removeObjectAtIndex:fromIndexPath.item];
    [self.capturedPhotoList insertObject:modelObject atIndex:toIndexPath.item];
    
    // change the position of objects in saved plist too
    NSString *compositionPath = [NSString stringWithFormat:@"%@/%@", COMPOSITION_TEMP_FOLDER_PATH, COMPOSITION_DICT];
    NSMutableArray *compositionArray = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:compositionPath]) {
        NSData *data = [NSData dataWithContentsOfFile:compositionPath];
        NSMutableDictionary *compositionDict = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data] copyItems:YES];
        compositionArray = [[NSMutableArray alloc] initWithArray:compositionDict[COMPOSITION_IMAGE_ARRAY_KEY] copyItems:YES];
        
        NSDictionary *fromDict = [[NSDictionary alloc] initWithDictionary:compositionArray[fromIndexPath.item]];
        [compositionArray removeObjectAtIndex:fromIndexPath.item];
        [compositionArray insertObject:fromDict atIndex:toIndexPath.item];
        
        [compositionDict setObject:compositionArray forKey:COMPOSITION_IMAGE_ARRAY_KEY];
        BOOL arraySuccess = [NSKeyedArchiver archiveRootObject:compositionDict toFile:compositionPath];
        if(!arraySuccess) {
//            NSLog(@"arraySuccess = %d", arraySuccess);
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"%s", __func__);
    CMPhotoModel *model = self.capturedPhotoList[indexPath.item];
    if(model.originalImage && !model.isRecorded && !model.startAppearanceTime && !model.pauseTime) {
        return YES;
    }
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
//    NSLog(@"%s", __func__);
    CMPhotoModel *model = self.capturedPhotoList[toIndexPath.item];
    if(model.originalImage && !model.isRecorded && !model.startAppearanceTime && !model.pauseTime) {
        return YES;
    }
    return NO;
}

#pragma mark - Camera Overlay View Button Action methods

- (IBAction)flashButtonClicked:(id)sender
{
    // Switching the camera flash mode from Auto - On - OFF
    switch (currentFlashMode) {
        case AVCaptureFlashModeOff:
        {
            currentFlashMode = AVCaptureFlashModeAuto;
            [sender setBackgroundImage:[UIImage imageNamed:IMAGE_FLASH_AUTO] forState:UIControlStateNormal];
            break;
        }
            
        case AVCaptureFlashModeOn:
        {
            currentFlashMode = AVCaptureFlashModeOff;
            [sender setBackgroundImage:[UIImage imageNamed:IMAGE_FLASH_OFF] forState:UIControlStateNormal];
            break;
        }
            
        case AVCaptureFlashModeAuto:
        {
            currentFlashMode = AVCaptureFlashModeOn;
            [sender setBackgroundImage:[UIImage imageNamed:IMAGE_FLASH_ON] forState:UIControlStateNormal];
            break;
        }
            
        default:
            break;
    }
    
#if !(TARGET_IPHONE_SIMULATOR)

    [[CMAVCameraHandler sharedHandler] changeCameraFlashMode:currentFlashMode];
    
#endif
}

- (IBAction)cameraOptionClicked:(id)sender
{
    // switching the camera mode between front end and rear end
    switch (currentCameraMode) {
        case kCameraDeviceRear:
        {
            currentCameraMode = kCameraDeviceFront;
            self.flashButton.hidden = YES;
            break;
        }
            
        case kCameraDeviceFront:
        {
            currentCameraMode = kCameraDeviceRear;
            self.flashButton.hidden = NO;
            break;
        }
            
        default:
            break;
    }
#if !(TARGET_IPHONE_SIMULATOR)

    [[CMAVCameraHandler sharedHandler] addVideoInputFromFrontCamera:currentCameraMode];
    
#endif
}

- (IBAction)galleryOptionClicked:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)captureImageClicked:(id)sender
{
#if !(TARGET_IPHONE_SIMULATOR)

    [[CMAVCameraHandler sharedHandler] captureStillImage];
    
#endif
}

- (IBAction)deleteSelectedImage:(id)sender
{
    // check if some image selected by checking for selectedImageIndex, if it is -1 then no image is selected
    if(self.selectedImageIndex != -1) {
        CMPhotoModel *modelObj = (CMPhotoModel *)self.capturedPhotoList[_selectedImageIndex];
        modelObj.originalImage = nil;
        modelObj.editedImage = nil;
        [self.capturedPhotoList removeObjectAtIndex:_selectedImageIndex];
        [self.capturedPhotoList addObject:modelObj];
        _selectedImageCount--;
        
        [self manageCameraGalleryButton];
        
        [_aspectFillImageController resetImageContentToEmpty];
        
        [self.photoCollectionView reloadData];
        
        [self showDeleteButton:NO];
        [self manageHeaderButtonVisibility];
        
        if(_selectedImageCount == 0) {
            // show cameraview if no images are in tray
            _selectedImageIndex = -1;
            [self showCameraView];
        }
        else {
            // show previous image of currentSelectedImage, if no index for prev then select currentIndex
            _selectedImageIndex--;
            
            if(_selectedImageIndex == -1) {
                // here comes when index in invalid, so set _selectedImageIndex as 0
                _selectedImageIndex = 0;
            }
            
            [self showSelectedPhoto:_selectedImageIndex];
        }
    }
}

- (IBAction)listOptionClicked:(id)sender
{
//    NSLog(@"Show the list options in headder view");
//    NSURL *url = [NSURL URLWithString:@"http://mirusstudent.com/service/describe-service/getUserFeeds/format=json/UserUID=1"];
//    NSData *data = [NSData dataWithContentsOfURL:url];
//    
//    NSError *error = nil;
//    NSDictionary *aDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//    NSLog(@"data = %@", aDict);
}

- (IBAction)nextOptionClicked:(id)sender
{
//    NSLog(@"Navigate to the video composition screen for images");
    [self showSelectedPhoto:0];
    [self showDeleteButton:NO];
    
//    [[WSModelClasses sharedHandler] showLoadView];
    [UIView animateWithDuration:1.0 animations:^{
        CGRect frame = self.cameraOverlayView.frame;
        frame.origin.x = -320.0f;
        self.cameraOverlayView.frame = frame;
    } completion:^(BOOL finished) {
        [self goToVideoRecordingScreen];
    }];
//    [self performSelector:@selector(goToVideoRecordingScreen) withObject:nil afterDelay:0.3];
}

- (void)goToVideoRecordingScreen
{
    CMRecordViewController *recordController = [[CMRecordViewController alloc] initWithNibName:@"CMRecordViewController" bundle:nil];
    recordController.capturedPhotoList = self.capturedPhotoList;
    recordController.parentController = self;
    [self.navigationController pushViewController:recordController animated:NO];
    recordController = nil;
}

- (void)showCameraOverlayView
{
    [UIView animateWithDuration:1.0
                     animations:^{
                         CGRect frame = self.cameraOverlayView.frame;
                         frame.origin.x = 0.0f;
                         self.cameraOverlayView.frame = frame;
                     }
                     completion:^(BOOL finished) {
//                         [self showDeleteButton:YES];
                     }];
}

- (IBAction)backOptionClicked:(id)sender
{
//    NSLog(@"Dismiss the current view and navigate to previous screen.");
    [self removeCameraView];
    // remove the composition from document
    [[WSModelClasses sharedHandler] removeCompositionPath];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(_selectedImageCount >= MAX_IMAGE_SELECT_COUNT) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    _selectedImageIndex = -1;
    
    [_aspectFillImageController resetImageContentToEmpty];
    [_aspectFillImageController placeSelectedImage:info[UIImagePickerControllerOriginalImage] withCropRect:CGRectNull];
    
    CMPhotoModel *modelObj = self.capturedPhotoList[_selectedImageCount];
    modelObj.originalImage = _aspectFillImageController.imageView.image;
    modelObj.cropRect = _aspectFillImageController.cropRect;
    
//    NSLog(@"%@",NSStringFromCGSize(_selectedImageView.image.size));
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // update the collection tray with the image
    [self.photoCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_selectedImageCount inSection:0]]];
    _selectedImageCount++;
    
    [self manageHeaderButtonVisibility];
    [self manageCameraGalleryButton];
    
    if([self checkIfTrayisFull]) {
        [self showSelectedPhoto:0];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CMAVCameraHandlerDelegate Method

- (void)didFinishCapturingStillImage:(UIImage *)image error:(NSError *)error withContextInfo:(void *)contextInfo
{
#if !(TARGET_IPHONE_SIMULATOR)
    _selectedImageIndex = -1;

    //[self imageWithImage:image scaledToSize:CGSizeMake(CGRectGetWidth(DEFAULT_IMAGE_RECT), CGRectGetHeight(DEFAULT_IMAGE_RECT))];
//    image = [_aspectFillImageController imageWithImage:image scaledToSize:_cameraContainerView.frame.size];
    [_aspectFillImageController resetImageContentToEmpty];
    [_aspectFillImageController placeSelectedImage:image withCropRect:CGRectNull];
    [_aspectFillImageController calculateCropRectForSelectImage];
    
    CMPhotoModel *modelObj = self.capturedPhotoList[_selectedImageCount];
    modelObj.originalImage = _aspectFillImageController.imageView.image;
    modelObj.cropRect = _aspectFillImageController.cropRect;
    
    // update the collection tray with the image
    [self.photoCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_selectedImageCount inSection:0]]];
    _selectedImageCount++;
    
    [self manageHeaderButtonVisibility];
    [self manageCameraGalleryButton];
    
    if([self checkIfTrayisFull]) {
        [self showSelectedPhoto:0];
    }

#endif
}

#pragma mark DBAspectFillViewControllerDelegate Method

- (void)imageDidZoomToRect:(CGRect)cropRect
{
    if(_selectedImageIndex != -1) {
        CMPhotoModel *modelObj = self.capturedPhotoList[_selectedImageIndex];
        [modelObj setCropRect:cropRect];
        [self.photoCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_selectedImageIndex inSection:0]]];
    }
}

@end
