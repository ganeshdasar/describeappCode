//
//  DPostsViewController.h
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPost;
@interface DPostsViewController : UIViewController <UIAlertViewDelegate>


+(id)sharedFeedController;


- (void)rightSwipeGesture:(UISwipeGestureRecognizer *)rightSwipeGesture withPost:(DPost *)post;

-(void)showMoreDetailsOfPost:(DPost *)post;
-(void)showConversationForThisPost:(DPost *)post;

@end
