//
//  DPostsViewController.m
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DPostsViewController.h"
#import "DPostListView.h"
#import "DPostView.h"

@interface DPostsViewController ()
{
    UIView *_headerView;
    IBOutlet DPostListView *_listView;
    IBOutlet DPostView *_postView;
}
@end

@implementation DPostsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self designPostView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [_postView startAnimation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark View Creations -

-(void)createNewPost
{
    
}

#pragma mark View Designs -

-(void)designPostView
{
    [_postView designPostView];
}

#pragma mark View Operations -
#pragma mark Model Operations -


@end
