//
//  DescBasicinfoViewController.h
//  Describe
//
//  Created by NuncSys on 30/12/13.
//  Copyright (c) 2013 App. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CMPassTouchesView.h"

@class SPGooglePlacesAutocompleteQuery;
@interface DescBasicinfoViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSArray *searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    BOOL shouldBeginEditing;
}

@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *cityTxtImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userprofileImg;
@property (weak, nonatomic) IBOutlet UITextField *cityTxt;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTxt;
@property (weak, nonatomic) IBOutlet UITextView *bioTxt;
@property (weak, nonatomic) IBOutlet UIButton *btnmale;
@property (weak, nonatomic) IBOutlet UIButton *btnfemale;
@property (strong, nonatomic) IBOutlet UIView *datePickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *profileimgbtn;
@property (nonatomic,retain) UITableView * cityTableView;
@property (nonatomic,strong) NSMutableDictionary * userBasicInfoDic;
@property (nonatomic,assign) BOOL isGenderMale;
@property (weak, nonatomic) IBOutlet CMPassTouchesView *profilePicOverlayView;
@property (weak, nonatomic) IBOutlet UIView *profilePicContainerView;
@property (weak, nonatomic) IBOutlet UIButton *profileEditCancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *profileEditDoneBtn;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *profileTapGestureRef;

@property (weak, nonatomic) IBOutlet UIImageView *cityTxtImgView;
@property (weak, nonatomic) IBOutlet UIImageView *dateofBirthImgView;
@property (weak, nonatomic) IBOutlet UIImageView *txtBioImgView;


- (IBAction)profilePicTapped:(id)sender;

- (IBAction)selectTheDate:(id)sender;
- (IBAction)maleClicked:(id)sender;
- (IBAction)femaleClicked:(id)sender;
- (IBAction)selectprofileimg:(id)sender;
- (IBAction)dateDoneClicked:(id)sender;
- (IBAction)profilePicPinchGesture:(id)sender;
- (IBAction)profilePicPanGesture:(id)sender;
- (IBAction)cancelProfilePicChanges:(id)sender;
- (IBAction)doneProfilePicChange:(id)sender;

@end
