//
//  NotificationsViewController.m
//  Composition
//
//  Created by Describe Administrator on 17/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "NotificationsViewController.h"

@interface NotificationsViewController ()

@property (nonatomic, strong) NSMutableArray *notificationListArray;

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
    
//    NSLog(@"FontFamily = %@", [UIFont fontNamesForFamilyName:@"Helvetica Neue"]);
    
    _notificationListArray = [[NSMutableArray alloc] init];
    
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
    [_notificationListArray removeAllObjects];
    NSArray *anArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NotificationsResponse" ofType:@"plist"]];
    for(int i = 0; i < anArray.count; i++) {
        NotificationModel *model = [[NotificationModel alloc] initWithDictionary:anArray[i]];
        [_notificationListArray addObject:model];
        model = nil;
    }

    [_notificationTableview reloadData];
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
    if([model.similarCount integerValue] > 1 && model.similarData && model.similarData.count) {
        NSInteger startInsertIndex = indexpath.row + 1;
        NSMutableArray *fadeRowIndexpathArray = [[NSMutableArray alloc] initWithCapacity:0];
        for(NotificationModel *modelObj in model.similarData) {
            [_notificationListArray insertObject:modelObj atIndex:startInsertIndex];
            [fadeRowIndexpathArray addObject:[NSIndexPath indexPathForRow:startInsertIndex inSection:0]];
            startInsertIndex++;
        }
        
        model.similarData = nil;
        model.similarCount = [NSNumber numberWithInteger:1];
        
        [_notificationTableview beginUpdates];
        
        [_notificationTableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexpath.row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [_notificationTableview insertRowsAtIndexPaths:fadeRowIndexpathArray withRowAnimation:UITableViewRowAnimationFade];
        
        [_notificationTableview endUpdates];
    }
    
}

- (void)notificationFriendsJoinedSelectedAtIndexpath:(NSIndexPath *)indexpath
{
    NSLog(@"%s", __func__);

}

@end
