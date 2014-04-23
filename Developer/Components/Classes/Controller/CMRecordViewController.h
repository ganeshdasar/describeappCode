//
//  CMRecordViewController.h
//  Composition
//
//  Created by Describe Administrator on 22/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXReorderableCollectionViewFlowLayout.h"
#import "CMAVCameraHandler.h"
#import "CMViewController.h"

@interface CMRecordViewController : UIViewController <CMAVCameraHandlerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet UIView *cameraContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
//@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) UIButton *nextButton;
@property (weak, nonatomic) UIButton *cancelButton;
@property (weak, nonatomic) UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIProgressView *videoProgressIndicator;
@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;

@property (nonatomic, assign) CMViewController *parentController;

@property (nonatomic, strong) NSMutableArray *capturedPhotoList;

//- (IBAction)listOptionClicked:(id)sender;
- (IBAction)nextOptionClicked:(id)sender;
- (IBAction)dissmissOptionClicked:(id)sender;
- (IBAction)prevButtonSelected:(id)sender;
- (IBAction)startOrPauseVideoRecording:(id)sender;

@end
