//
//  ProfileViewController.h
//  Composition
//
//  Created by Describe Administrator on 15/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPassTouchesView.h"

typedef enum {
    kProfileTypeOthers = 1,
    kProfileTypeOwn
} ProfileType;

@interface ProfileViewController : UIViewController <UITextViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) ProfileType currentProfileType;


@property (weak, nonatomic) IBOutlet CMPassTouchesView *completeProfileView;
@property (weak, nonatomic) IBOutlet UIButton *editCanvasBtn;
@property (weak, nonatomic) IBOutlet UITextView *profileStatusTxtView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *editingDoneBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *followUnfollowBtn;

@property (weak, nonatomic) IBOutlet UIView *profileDetailContainerView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;

@property (weak, nonatomic) IBOutlet UIView *statsContainerView;
@property (weak, nonatomic) IBOutlet UILabel *postsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;

@property (weak, nonatomic) IBOutlet CMPassTouchesView *canvasChangeOverlayView;
@property (weak, nonatomic) IBOutlet CMPassTouchesView *profilePicContainerView;
@property (weak, nonatomic) IBOutlet UIView *profileImageHolderView;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *profilePicTapGesture;
@property (weak, nonatomic) IBOutlet UIImageView *snippetRegionImgView;
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *profilePinGesture;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *profilePicPanGesture;

@property (nonatomic, strong) NSNumber *profileUserID;

- (IBAction)changeOptionSelected:(id)sender;
- (IBAction)doneOptionSelected:(id)sender;

- (IBAction)editCanvasOptionSelected:(id)sender;
- (IBAction)menuOptionSelected:(id)sender;
- (IBAction)editOptionSelected:(id)sender;
- (IBAction)followUnfollowSelected:(id)sender;
- (IBAction)editingDoneSelected:(id)sender;
- (IBAction)profilePicTapped:(id)sender;
- (IBAction)pinchGestureDetected:(id)sender;
- (IBAction)panGestureDetected:(id)sender;
- (IBAction)snippetPanGestureDetected:(id)sender;

@end
