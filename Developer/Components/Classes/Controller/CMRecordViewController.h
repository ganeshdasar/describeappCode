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

@interface CMRecordViewController : UIViewController <CMAVCameraHandlerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet UIView *cameraContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIProgressView *videoProgressIndicator;
@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;

@property (nonatomic, strong) NSMutableArray *capturedPhotoList;

- (IBAction)listOptionClicked:(id)sender;
- (IBAction)nextOptionClicked:(id)sender;
- (IBAction)dissmissOptionClicked:(id)sender;
- (IBAction)prevButtonSelected:(id)sender;
- (IBAction)startOrPauseVideoRecording:(id)sender;

@end
