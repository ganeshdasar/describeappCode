//
//  DescSignupViewController.h
//  Describe
//
//  Created by kushal mandala on 05/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSModelClasses.h"
#import "MBProgressHUD.h"
typedef   enum  {
    USERNAME_TEXT_FIELD_TAG = 1,
    PASSWORD_TEXT_FIELD_TAG = 2,
    EMAIL_TEXT_FIELD_TAG = 3,
    NAME_TEXT_FIELD_TAG = 4,

    
}signUpTextFieldTag;
typedef  enum{
    SUCEES = 1,
    FAIL_USER ,
    FAIL_PASS,
    FAIL_EMAIL,
    FAIL_NAME
    
}validationFaildField;
@interface DescSignupViewController : UIViewController<UITextFieldDelegate,WSModelClassDelegate>
{
    BOOL isUserNameFilled;
    BOOL isPwsFilled;
    BOOL isEmailFilled;
    BOOL isNameFilled;
    IBOutlet UIView *_contentView;
    UITextField *_currentTextField;
    BOOL _isModifiedHeaderView;
}
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *userNameTxt;
@property (weak, nonatomic) IBOutlet UITextField *pwdTxt;
@property (weak, nonatomic) IBOutlet UITextField *emailTxt;
@property (weak, nonatomic) IBOutlet UITextField *nameTxt;
@property (retain, nonatomic)NSMutableData *signupResponseData;
@property (retain, nonatomic)NSMutableArray *signupjsonArray;
@property (nonatomic,strong) NSMutableDictionary * userDataDic;
@property (nonatomic,assign ) signUpTextFieldTag textFiledType;
@property (nonatomic,strong) NSString * messageTextField;

@property(nonatomic,retain) NSMutableArray * socialUserFriendsList;
-(void)setTheUserDataInTextFields;
@end
