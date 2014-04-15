//
//  DESPushNotificationControl.m
//  Describe
//
//  Created by NuncSys on 16/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DESPushNotificationControl.h"
#import "UIColor+DesColors.h"
#import "Constant.h"
#import "WSModelClasses.h"

@interface DESPushNotificationControl ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray * pushNotificationList;
    UIButton    *backButton;
  
}

@end

@implementation DESPushNotificationControl
@synthesize isLikesOnMyPost;
@synthesize isCommentsOnMypost;
@synthesize ismymentionInComment;
@synthesize isNotfollower;
@synthesize isChangeTheSwitch;
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
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
    self.pustNotificationTbl.backgroundColor = [UIColor clearColor];
    [self initilizeTheArray];
    [self createHeadderView];
    [self setBackGroundImage];
    [self getTheUserPushNotification];
    isChangeTheSwitch = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void)initilizeTheArray
{
    pushNotificationList = [[NSArray alloc]initWithObjects:@"likes on my posts",@"comments on my posts",@"my mentions in comments",@"not followers", nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createHeadderView
{
    backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self._HeaderView designHeaderViewWithTitle:@"Settings" andWithButtons:@[backButton]];
}
- (void)setBackGroundImage
{
    if (isiPhone5)
    {
        self.backGroundImg.image = [UIImage imageNamed:@"bg_std_4in.png"];
    }
    else
    {
        self.backGroundImg.image = [UIImage imageNamed:@"bg_std_3.5in.png"];
    }
}


- (void)back:(UIButton*)inSender
{
    if (isChangeTheSwitch) {
        [self updateThePushNotifications];
        isChangeTheSwitch = NO;
    }else{
        [self.navigationController popViewControllerAnimated:YES];

    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return pushNotificationList.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"identifier_%d_%ld",indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.selectedBackgroundView = nil;
    }
    cell.textLabel.text = pushNotificationList[indexPath.row];
    cell.textLabel.textColor = [UIColor textPlaceholderColor];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
    switch (indexPath.row) {
        case likes_onMyPost:
            cell.accessoryView = [self createSwitch:likes_onMyPost];
            break;
        case comments_onMypost:
            cell.accessoryView = [self createSwitch:comments_onMypost];
            break;
        case mymentions_incomment:
            cell.accessoryView = [self createSwitch:mymentions_incomment];
            break;
        case not_follower:
            cell.accessoryView = [self createSwitch:not_follower];
            break;
        default:
            break;
    }
    return cell;
}


-(UISwitch*)createSwitch:(notificationsType)tag
{
    UISwitch *swtch = [[UISwitch alloc] initWithFrame: CGRectZero];
    [swtch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    swtch.tag = tag;
    switch (tag) {
        case likes_onMyPost:
            swtch.on = isLikesOnMyPost;
            break;
        case comments_onMypost:
            swtch.on = isCommentsOnMypost;
            break;
        case mymentions_incomment:
            swtch.on = ismymentionInComment;
            break;
        case not_follower:
            swtch.on = isNotfollower;
            break;
            
        default:
            break;
    }
    return swtch;
}


- (void)changeSwitch:(UISwitch*)sender{
    isChangeTheSwitch = YES;
    switch (sender.tag) {
        case likes_onMyPost:
            isLikesOnMyPost = [sender isOn] ? YES:NO;
            break;
        case comments_onMypost:
            isCommentsOnMypost = [sender isOn] ? YES:NO;
            break;
        case mymentions_incomment:
            ismymentionInComment = [sender isOn] ? YES:NO;
            break;
        case not_follower:
            isNotfollower = [sender isOn] ? YES:NO;
            break;
        default:
            break;
    }
}


- (UIImageView*)createBackGroundImageView:(UIImage*)inImage
{
    UIImageView * image = [[UIImageView alloc]initWithImage:inImage];
    return image;
}


-(void)getTheUserPushNotification
{
    [[WSModelClasses sharedHandler]getTheUserPushNotificationresponce:^(BOOL success, id responce){
        if (success) {
        [self updateTheStatus:[[(NSDictionary*)responce valueForKeyPath:@"DataTable.UserData"]objectAtIndex:0]];
        }else{
        }
    }];
}


-(void)updateTheStatus:(NSDictionary*)responceDic
{
    isLikesOnMyPost=  [[responceDic valueForKey:@"UserPushNotifyLikesStatus"] isEqualToString:@"1"]? YES:NO;
    isCommentsOnMypost=  [[responceDic valueForKey:@"UserPushNotifyCommentsStatus"] isEqualToString:@"1"]? YES:NO;
    ismymentionInComment=  [[responceDic valueForKey:@"UserPushNotifyMentsionsStatus"] isEqualToString:@"1"]? YES:NO;
    isNotfollower=  [[responceDic valueForKey:@"UserPushNotifyFollowersStatus"] isEqualToString:@"1"]? YES:NO;
    [self.pustNotificationTbl reloadData];
}

-(void)updateThePushNotifications{
    
    [[WSModelClasses sharedHandler]updatTheUserPushNotifications:[NSNumber numberWithBool:isLikesOnMyPost] CommentsStatus:[NSNumber numberWithBool:isCommentsOnMypost] mymentionsStatus:[NSNumber numberWithBool:ismymentionInComment] followsStatus:[NSNumber numberWithBool:isNotfollower] responce:^(BOOL success, id responce){
        if (success) {
             [self.navigationController popViewControllerAnimated:YES];
        }else{
        }
        
    }];
}

-  (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

@end
