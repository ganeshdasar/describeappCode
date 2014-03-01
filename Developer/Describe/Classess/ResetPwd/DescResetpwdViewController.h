//
//  DescResetpwdViewController.h
//  Describe
//
//  Created by kushal mandala on 05/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DescResetpwdViewController : UIViewController<UIAlertViewDelegate>
{

}
@property (weak, nonatomic) IBOutlet UITextField *txtemail;
@property (retain, nonatomic)NSMutableData *RPresponseData;
@property (retain, nonatomic)NSMutableArray *RPjsonArray;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;

@end
