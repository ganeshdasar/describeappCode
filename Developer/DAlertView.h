//
//  DAlertView.h
//  Describe
//
//  Created by Aashish Raj on 3/30/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DAlertViewResponse)(NSUInteger buttonIndex);//(void (^)(NSUInteger index))

@interface DAlertView : UIAlertView



- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;


//If response status is required....
@property(nonatomic, assign)DAlertViewResponse response;

@end
