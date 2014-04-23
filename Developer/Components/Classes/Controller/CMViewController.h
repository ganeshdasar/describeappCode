//
//  CMViewController.h
//  Composition
//
//  Created by Describe Administrator on 18/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXReorderableCollectionViewFlowLayout.h"
#import "CMAVCameraHandler.h"

@interface CMViewController : UIViewController <LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, CMAVCameraHandlerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet UIView *cameraContainerView;
@property (weak, nonatomic) IBOutlet UIView *cameraOverlayView;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraDeviceButton;
@property (weak, nonatomic) IBOutlet UIButton *galleryButton;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)flashButtonClicked:(id)sender;
- (IBAction)cameraOptionClicked:(id)sender;
- (IBAction)galleryOptionClicked:(id)sender;
- (IBAction)captureImageClicked:(id)sender;
- (IBAction)deleteSelectedImage:(id)sender;
- (IBAction)listOptionClicked:(id)sender;
- (IBAction)nextOptionClicked:(id)sender;
- (IBAction)backOptionClicked:(id)sender;
- (void)refreshSelectedImageViewContainer;
- (void)showCameraOverlayView;

@end
