//
//  DConversationViewController.m
//  Describe
//
//  Created by LaxmiGopal on 25/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DConversationViewController.h"
#import "DHeaderView.h"
#import "DConversationListView.h"

@interface DConversationViewController ()
{
    IBOutlet DHeaderView *_headerView;
    IBOutlet DConversationListView *_conversationListView;
}
@end

@implementation DConversationViewController
@synthesize conversationListArray;

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
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeGesture:)];
    [leftSwipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:leftSwipeGesture];
 
    
    [self designHeaderView];
    [self designConversationView];
}

-(void)leftSwipeGesture:(UISwipeGestureRecognizer *)rightSwipeGesture
{
    //NSLog(@"left Swipe Gesture Activated");
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)designHeaderView
{
    
    UIButton *addButton, *reloadButton, *moreButton;
    
    addButton = [[UIButton alloc] init];
    [addButton setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    //[addButton addTarget:self action:@selector(addPost:) forControlEvents:UIControlEventTouchUpInside];
    
    reloadButton = [[UIButton alloc] init];
    [reloadButton setBackgroundImage:[UIImage imageNamed:@"reload.png"] forState:UIControlStateNormal];
    //[reloadButton addTarget:self action:@selector(reloadPostList:) forControlEvents:UIControlEventTouchUpInside];
    
    moreButton = [[UIButton alloc] init];
    [moreButton setBackgroundImage:[UIImage imageNamed:@"more1.png"] forState:UIControlStateNormal];
    //[moreButton addTarget:self action:@selector(morePost:) forControlEvents:UIControlEventTouchUpInside];
    
    [_headerView designHeaderViewWithTitle:@"Conversation" andWithButtons:@[moreButton,  addButton]];    
}

-(void)designConversationView
{
    _conversationListView._conversationList =  self.conversationListArray;
    [_conversationListView designConversationListView];
    
}



@end
