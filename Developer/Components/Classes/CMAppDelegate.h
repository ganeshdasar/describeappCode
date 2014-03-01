//
//  CMAppDelegate.h
//  Composition
//
//  Created by Describe Administrator on 18/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMViewController.h"
#import "ProfileViewController.h"
#import "NotificationsViewController.h"

//FB App Id:356923667782947 of Mahesh


@interface CMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CMViewController *viewController;
//@property (strong, nonatomic) ProfileViewController *viewController;
//@property (strong, nonatomic) NotificationsViewController *viewController;

@end
