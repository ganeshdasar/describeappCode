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

@interface DConversationViewController ()<DHeaderViewDelegate>
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
    UIButton *backButton;
    
    backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton setTag:HeaderButtonTypePrev];
    [_headerView setDelegate:self];
    
    [_headerView designHeaderViewWithTitle:@"Conversation" andWithButtons:@[backButton] andMenuButtons:nil];
}


-(void)designConversationView
{
    _conversationListView._conversationList =  self.conversationListArray;
    
    [_conversationListView designConversationListView];
}


-(void)headerView:(DHeaderView *)headerView didSelectedHeaderViewButton:(UIButton *)headerButton
{
    HeaderButtonType buttonType = headerButton.tag;
    switch (buttonType) {
        case HeaderButtonTypePrev:
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }
}


@end
