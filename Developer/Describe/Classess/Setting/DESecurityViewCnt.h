//
//  DESecurityViewCnt.h
//  Describe
//
//  Created by NuncSys on 16/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHeaderView.h"

typedef   enum  {
    Email_TAG=0,
    PASSWORD_TAG=1
    
}textFieldTag;


@interface DESecurityViewCnt : UIViewController

@property (nonatomic,strong) NSString * userPassword;
@property (nonatomic,strong) NSString * userEmailId;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImg;
@property (weak, nonatomic) IBOutlet UITableView *securityTableView;

@property (nonatomic,assign) BOOL isTextFieldEditing;

@end
