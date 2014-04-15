//
//  NotificationsViewController.m
//  Composition
//
//  Created by Describe Administrator on 17/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "NotificationsViewController.h"
#import "WSModelClasses.h"
#import "DHeaderView.h"
#import "DPostsViewController.h"
#import "ProfileViewController.h"
#import "NotificationsViewController.h"
#import "DesSearchPeopleViewContrlooerViewController.h"
#import "DESSettingsViewController.h"
#import "DescAddpeopleViewController.h"

@interface NotificationsViewController () <WSModelClassDelegate, DHeaderViewDelegate>
{

}

@property (nonatomic, strong) NSMutableArray *notificationListArray;
@property (assign) BOOL isRefresh;
@property (assign) NSInteger selectedRow;
@property (assign) NSInteger similarCount;
@property (assign) NSInteger mainPageNumber;
@property (assign) NSInteger childPageNumber;

@end

@implementation NotificationsViewController

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
	// Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    
    _selectedRow = -1;   // default value, when no row is selected
    
//    NSLog(@"FontFamily = %@", [UIFont fontNamesForFamilyName:@"Helvetica Neue"]);
    
    _notificationListArray = [[NSMutableArray alloc] init];
    
    [self refreshNotificationData:nil];
    [self designHeaderView];
}

-(void)designHeaderView
{
    UIButton  *reloadButton, *moreButton;
    
    reloadButton = [[UIButton alloc] init];
    [reloadButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_refresh.png"] forState:UIControlStateNormal];
    [reloadButton setTag:HeaderButtonTypeReload];
    
    moreButton = [[UIButton alloc] init];
    [moreButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_menu.png"] forState:UIControlStateNormal];
    [moreButton setTag:HeaderButtonTypeMenu];
    
    [_headerView setDelegate:self];
    [_headerView designHeaderViewWithTitle:@"Following" andWithButtons:@[moreButton, reloadButton] andMenuButtons:[self menuButtonsList]];
}

-(NSArray *)menuButtonsList
{
    UIButton *homeButton, *profileButton,  *searchButton, *addPeople, *settingsButton, *closeButton;
    
    profileButton = [[UIButton alloc] init];
    [profileButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_profile.png"] forState:UIControlStateNormal];
    [profileButton setTag:HeaderButtonTypeProfile];
    
    homeButton = [[UIButton alloc] init];
    [homeButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_home.png"] forState:UIControlStateNormal];
    [homeButton setTag:HeaderButtonTypeHome];
    
    searchButton = [[UIButton alloc] init];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_search.png"] forState:UIControlStateNormal];
    [searchButton setTag:HeaderButtonTypeSearch];
    
    addPeople = [[UIButton alloc] init];
    [addPeople setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_add_people.png"] forState:UIControlStateNormal];
    [addPeople setTag:HeaderButtonTypeAddPeople];
    
    settingsButton = [[UIButton alloc] init];
    [settingsButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_settings.png"] forState:UIControlStateNormal];
    [settingsButton setTag:HeaderButtonTypeSettings];
    
    closeButton = [[UIButton alloc] init];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_cancel.png"] forState:UIControlStateNormal];
    [closeButton setTag:HeaderButtonTypeClose];
    
    
    return @[homeButton, profileButton,  searchButton, addPeople, settingsButton, closeButton];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshNotificationData:(id)sender
{
//TODO - REMOVE TEMP CODE
    //fetching data from temp file for notification
//    [_notificationListArray removeAllObjects];
//    NSArray *anArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NotificationsResponse" ofType:@"plist"]];
//    for(int i = 0; i < anArray.count; i++) {
//        NotificationModel *model = [[NotificationModel alloc] initWithDictionary:anArray[i]];
//        [_notificationListArray addObject:model];
//        model = nil;
//    }
//
//    [_notificationTableview reloadData];
    
    _selectedRow = -1;
    [self getNotificationListWithNotificationID:nil];
}

- (IBAction)showMenuOptions:(id)sender
{
    
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _notificationListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"NotifcationsCell";
    
    NotifcationsCell *aCell = (NotifcationsCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(aCell == nil) {
        NSString *nibName = @"NotifcationsCell";
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
        for(id currentObject in nibObjects)
        {
            if([currentObject isKindOfClass:[NotifcationsCell class]]) {
                aCell = (NotifcationsCell *)currentObject;
            }
            
            aCell.delegate = self;
            [aCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    }
    
    [aCell setData:(NotificationModel *)_notificationListArray[indexPath.row]];
    return aCell;
}

#pragma mark - NotificationCell delegate methods

- (void)notificationImageSelectedAtIndexpath:(NSIndexPath *)indexpath
{
    NSLog(@"%s", __func__);
    
}

- (void)notificationTitleSelectedAtIndexpath:(NSIndexPath *)indexpath
{
    NSLog(@"%s", __func__);
    NotificationModel *model = _notificationListArray[indexpath.row];
    if([model.similarCount integerValue] > 1 ) {
        _selectedRow = indexpath.row;
        _similarCount = model.similarCount.integerValue;
        [self getNotificationListWithNotificationID:model.notificationId];
//        NSInteger startInsertIndex = indexpath.row + 1;
//        NSMutableArray *fadeRowIndexpathArray = [[NSMutableArray alloc] initWithCapacity:0];
//        for(NotificationModel *modelObj in model.similarData) {
//            [_notificationListArray insertObject:modelObj atIndex:startInsertIndex];
//            [fadeRowIndexpathArray addObject:[NSIndexPath indexPathForRow:startInsertIndex inSection:0]];
//            startInsertIndex++;
//        }
//        
//        model.similarData = nil;
//        model.similarCount = [NSNumber numberWithInteger:1];
//        
//        [_notificationTableview beginUpdates];
//        
//        [_notificationTableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexpath.row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//        [_notificationTableview insertRowsAtIndexPaths:fadeRowIndexpathArray withRowAnimation:UITableViewRowAnimationFade];
//        
//        [_notificationTableview endUpdates];
    }
    
}

- (void)notificationFriendsJoinedSelectedAtIndexpath:(NSIndexPath *)indexpath
{
    NSLog(@"%s", __func__);

}

#pragma mark - Fetching Notification from API

- (void)getNotificationListWithNotificationID:(NSNumber *)notificationId
{
    WSModelClasses * modelClass = [WSModelClasses sharedHandler];
    modelClass.delegate = self;
    
    [modelClass getNotificationListForUser:[[WSModelClasses sharedHandler] loggedInUserModel].userID withSubId:notificationId andPageNumber:[NSNumber numberWithInteger:0]];
}

- (void)didFinishFetchingNotification:(NSArray *)responseList error:(NSError *)error
{
    if(_selectedRow != -1) {
        NSInteger startInsertIndex = _selectedRow + 1;
        NSMutableArray *fadeRowIndexpathArray = [[NSMutableArray alloc] initWithCapacity:0];
        for(NotificationModel *modelObj in responseList) {
            [_notificationListArray insertObject:modelObj atIndex:startInsertIndex];
            [fadeRowIndexpathArray addObject:[NSIndexPath indexPathForRow:startInsertIndex inSection:0]];
            startInsertIndex++;
        }
        
        NotificationModel *model = (NotificationModel *)_notificationListArray[_selectedRow];
        model.similarCount = [NSNumber numberWithInteger:1];
        
        _similarCount = _similarCount - fadeRowIndexpathArray.count;
        
        if(_similarCount < 2) {
            _selectedRow = -1;
            _similarCount = -1;
        }
        else {
            [self getNotificationListWithNotificationID:model.notificationId];
        }

        [_notificationTableview beginUpdates];

        [_notificationTableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [_notificationTableview insertRowsAtIndexPaths:fadeRowIndexpathArray withRowAnimation:UITableViewRowAnimationFade];

        [_notificationTableview endUpdates];
    }
    else {  // will come here if its firstTime or refreshButton is pressed
        [_notificationListArray removeAllObjects];
        for(NotificationModel *modelObj in responseList) {
            [_notificationListArray addObject:modelObj];
        }
        
        if(_notificationListArray.count == 0) {
            _notificationTableview.hidden = YES;
            _emptyMsgLabel.hidden = NO;
        }
        else {
            _notificationTableview.hidden = NO;
            _emptyMsgLabel.hidden = YES;
        }
        
        [_notificationTableview reloadData];
    }
}

#pragma mark Header View Delegate Methods -
-(void)headerView:(DHeaderView *)headerView didSelectedHeaderViewButton:(UIButton *)headerButton
{
    HeaderButtonType buttonType = [headerButton tag];
    switch (buttonType)
    {
       
        case HeaderButtonTypeReload:
            break;
        case HeaderButtonTypeHome:
        {
            DPostsViewController *feedViewController = [[DPostsViewController alloc] initWithNibName:@"DPostsViewController" bundle:nil];
            [self.navigationController pushViewController:feedViewController animated:YES];
        }
            break;
        case HeaderButtonTypeProfile:
        {
            ProfileViewController *profileController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
            [self.navigationController pushViewController:profileController animated:YES];
        }
            break;
        case HeaderButtonTypeNotification:
        {
            NotificationsViewController *notificationViewController = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:nil];
            [self.navigationController pushViewController:notificationViewController animated:YES];
        }
            break;
        case HeaderButtonTypeSearch:
        {
            DesSearchPeopleViewContrlooerViewController *searchViewController = [[DesSearchPeopleViewContrlooerViewController alloc] initWithNibName:@"DesSearchPeopleViewContrlooerViewController" bundle:nil];
            [self.navigationController pushViewController:searchViewController animated:YES];
        }
            break;
        case HeaderButtonTypeAddPeople:
        {
            DescAddpeopleViewController *addPeopleViewController = [[DescAddpeopleViewController alloc] initWithNibName:@"DescAddpeopleViewController" bundle:nil];
            [self.navigationController pushViewController:addPeopleViewController animated:YES];
        }
        case HeaderButtonTypeSettings:
        {
            DESSettingsViewController *settingViewController = [[DESSettingsViewController alloc] initWithNibName:@"DESSettingsViewController" bundle:nil];
            [self.navigationController pushViewController:settingViewController animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
