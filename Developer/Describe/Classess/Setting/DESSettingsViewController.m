//
//  DESSettingsViewController.m
//  Describe
//
//  Created by NuncSys on 21/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DESSettingsViewController.h"
#import "DHeaderView.h"
#import "DESEditAccountDetailsViewController.h"
#import "DESPushNotificationControl.h"
#import "DESEmailNotificationControll.h"
#import "UIColor+DesColors.h"
#import "Constant.h"
#import "DESocialConnectios.h"
#import "WSModelClasses.h"
#import "DESAppDelegate.h"

#define LABLERECT  CGRectMake(0, 0, 320, 40);
#define ELEMENT_FONT_COLOR  [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1];
#define ElEMENT_FONT_NAME [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];

#define HEADER_FONT_COLOR  [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];

@interface DESSettingsViewController ()<UITableViewDataSource,UITableViewDelegate,DESocialConnectiosDelegate, WSModelClassDelegate>
{
    IBOutlet DHeaderView * _headerView;
    UIButton    *backButton;
    
    NSMutableArray * sectionsArray;
    
    NSArray * socialAccountSectionsArray;
    NSArray * socialAccessayviewArray;
    NSArray * autoPlaySectionArray;
    NSArray * notificationsArray;

}
@end

@implementation DESSettingsViewController
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)hideoBottom
{
    self.settingTableView.alpha = 0.1;

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
    [super viewDidLoad];
    
//    _headerView.alpha = 0.1;
//    self.settingTableView.alpha = 0.1;

    [self setNeedsStatusBarAppearanceUpdate];
    if (isiPhone5)
    {
        self.backGroundImg.image = [UIImage imageNamed:@"bg_std_4in.png"];
    }
    else
    {
        self.backGroundImg.image = [UIImage imageNamed:@"bg_std_3.5in.png"];
    }
    [self createHeadder];
    [self initializeArrays];
    [self designSettingView];
    self.settingTableView.backgroundColor = [UIColor clearColor];
    self.settingTableView.showsVerticalScrollIndicator = NO;
    
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //self.settingTableView.frame = CGRectMake(0, self.settingTableView.frame.origin.x                                             , 320,  screenRect.size.height-65);
}

-(void)viewDidAppear:(BOOL)animated
{
 [UIView animateWithDuration:0.5 animations:^{
     
    _headerView.alpha = 1.0;
 } completion:^(BOOL finished) {
     
 }];
    
}


-(void)createHeadder
{
    backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView designHeaderViewWithTitle:@"Settings" andWithButtons:@[backButton]];
}


- (void)designSettingView
{
}
- (void)initializeArrays
{
    socialAccountSectionsArray = [[NSArray alloc]initWithObjects:@"Facebook",@"Google+", nil];
    autoPlaySectionArray = [[NSArray alloc]initWithObjects:@"Wi-Fi",@"Cellular network", nil];
    notificationsArray = [[NSArray alloc]initWithObjects:@"Push notifications",@"Email notifications", nil];
    socialAccessayviewArray = [[NSArray alloc]initWithObjects:@"Connected",@"Connect", nil];
}

-(void)back:(UIButton*)inButton
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark tablewview delegate and datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return socialAccountSectionsArray.count;
        case 2:
            return autoPlaySectionArray.count;
        case 3:
            return notificationsArray.count;
        default:
            return 2;
            break;
    }
    
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
    switch (indexPath.section) {
        case DSettingTypeAccount:
            cell.textLabel.text = @"Edit account details";
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
            cell.textLabel.textColor = ELEMENT_FONT_COLOR;
            cell.accessoryView = [self createBackGroundImageView:[UIImage imageNamed:@"chevron.png"]];
            break;
        case DSettingSocialServices:{
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
            cell.textLabel.textColor = ELEMENT_FONT_COLOR;
            cell.textLabel.text = socialAccountSectionsArray[indexPath.row];
            switch (indexPath.row) {
                case facebook_tag:{
                    if ([[DESocialConnectios sharedInstance] isFacebookLoggedIn]) {
                        cell.accessoryView = [self createLable:@"connected"];
                    }else{
                        cell.accessoryView = [self createLable:@"connect"];
                    }
                    break;
                }
                case google_plus_Tag:{
                    if ([[DESocialConnectios sharedInstance] isGooglePlusLoggeIn]) {
                        cell.accessoryView = [self createLable:@"connected"];
                    }else{
                        cell.accessoryView = [self createLable:@"connect"];
                    }
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case DSettingNetwork:
        {
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
            cell.textLabel.textColor = ELEMENT_FONT_COLOR;
            cell.textLabel.text = autoPlaySectionArray[indexPath.row];
            switch (indexPath.row) {
                case wifi_setting:
                    cell.accessoryView = [self createSwitch:wifi_setting];
                    break;
                    case cellular_netWork:
                    cell.accessoryView = [self createSwitch:cellular_netWork];
                    break;
                default:
                    break;
            }
            break;
        }
        case DSettingNotification:
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.f];
            cell.textLabel.textColor = ELEMENT_FONT_COLOR;
            cell.textLabel.text = notificationsArray[indexPath.row];
            CGRect accessoryViewFrame =cell.accessoryView.frame;
            accessoryViewFrame.origin.x = cell.contentView.frame.size.width - 100;
            cell.accessoryView.frame = accessoryViewFrame;
            cell.accessoryView = [self createBackGroundImageView:[UIImage imageNamed:@"chevron.png"]];
            break;
        default:
            break;
    }
    return cell;
}


-(UISwitch*)createSwitch:(settingType)tag
{
    UISwitch *swtch = [[UISwitch alloc] initWithFrame: CGRectZero];
    [swtch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    swtch.tag = tag;
    return swtch;
}

- (void)changeSwitch:(UISwitch*)sender{
    switch (sender.tag) {
        case wifi_setting:{
        NSString* status =  [sender isOn] ? @"1":@"0";
            [[NSUserDefaults standardUserDefaults]setObject:status forKey:WIFI_STATU];
            break;
        }
        case cellular_netWork:{
            NSString* status =  [sender isOn] ? @"1":@"0";
            [[NSUserDefaults standardUserDefaults]setObject:status forKey:CELLULAR_STATUS];
            break;
        }
        default:
            break;
    }
    
}


-(UILabel*)createLable:(NSString*)title{
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 80, 44)];
    lable.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size:16.f];
    lable.textColor = ELEMENT_FONT_COLOR;
    [lable setText:title];
    return lable;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case DSettingTypeAccount:{
            DESEditAccountDetailsViewController * editView = [[DESEditAccountDetailsViewController alloc]initWithNibName:@"DESEditAccountDetailsViewController" bundle:Nil];
            [self.navigationController pushViewController:editView animated:YES];
            break;
        }
        case DSettingNotification:{
            if (indexPath.row==0) {
                DESPushNotificationControl * pustNotificationView = [[DESPushNotificationControl alloc]initWithNibName:@"DESPushNotificationControl" bundle:Nil];
                [self.navigationController pushViewController:pustNotificationView animated:YES];
            }else if (indexPath.row==1){
                DESEmailNotificationControll * emailNotificationView = [[DESEmailNotificationControll alloc]initWithNibName:@"DESEmailNotificationControll" bundle:Nil];
                [self.navigationController pushViewController:emailNotificationView animated:YES];
            }
        }
            break;
        case DSettingSocialServices:{
            switch (indexPath.row) {
                case facebook_tag:
                    if ([[DESocialConnectios sharedInstance] isFacebookLoggedIn]) {
                        [self showLoadingView];
                        [[DESocialConnectios sharedInstance] setDelegate:self];
                        [[DESocialConnectios sharedInstance] logoutFacebook ];
                    }else{
                        [self showLoadingView];
                        [[DESocialConnectios sharedInstance] setDelegate:self];
                        [[DESocialConnectios sharedInstance] facebookSignIn ];

                    }
                    break;
                    case google_plus_Tag:
                    if ([[DESocialConnectios sharedInstance] isGooglePlusLoggeIn]) {
                        [self showLoadingView];
                        [[DESocialConnectios sharedInstance] setDelegate:self];
                        [[DESocialConnectios sharedInstance] logoutGooglePlus ];
                    }else{
                        [self showLoadingView];
                        [[DESocialConnectios sharedInstance] setDelegate:self];
                        [[DESocialConnectios sharedInstance] googlePlusSignIn ];
                    }
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 40;
}


- (UILabel*)createLableTitle:(NSString*)inTitle fontName:(NSString*)inFontName textSize:(CGFloat)inFloat tag:(int)inTag
{
    UILabel *tempLabel=[[UILabel alloc]init];
    tempLabel.frame =  CGRectMake(15, 0, 320, 40);
    tempLabel.numberOfLines = 0;
    tempLabel.backgroundColor=[UIColor clearColor];
    if (inTag==1) {
        tempLabel.textColor = ELEMENT_FONT_COLOR;
    }else if (inTag==2){
        tempLabel.textColor = HEADER_FONT_COLOR;
    }
    tempLabel.font =[UIFont fontWithName:inFontName size:inFloat];
    tempLabel.text = inTitle;
    return tempLabel;
}


#pragma mark FooterSection
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,0,320,40)];
    tempView.backgroundColor = [UIColor clearColor];
    switch (section) {
        case DSettingTypeAccount:{
            UILabel * label = [self createLableTitle:@"Edit your name, city, password, email address and other information associated with your Describe account." fontName:@"HelveticaNeue-Light" textSize:10.0 tag:1];
            label.frame = CGRectMake(15, 0, 320, 30);
            [tempView addSubview:label];
            break;
        }
        case DSettingSocialServices:{
            UILabel * label =[self createLableTitle:@"Manage access to your Facebook and Google+ accounts." fontName:@"HelveticaNeue-Light" textSize:10.0 tag:1];
            label.frame = CGRectMake(15, 0, 320, 20);
            [tempView addSubview:label];
            break;
        }
        case DSettingNetwork:{
            UILabel * label = [self createLableTitle:@"Manage autoplay of posts on Wi-Fi and Cellular networks." fontName:@"HelveticaNeue-Light" textSize:10.0 tag:1];
            label.frame = CGRectMake(15, 0, 320, 20);
            [tempView addSubview:label];
            break;
        }
        case DSettingNotification:
        {
            UILabel * lable = [self createLableTitle:@"Choose when you receive push notifications and email alerts." fontName:@"HelveticaNeue-Light" textSize:10.0 tag:1];
            lable.frame = CGRectMake(15, 0, 320, 20);
            [tempView addSubview:lable];
            break;
        }
        default:
            break;
    }
    return tempView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section) {
        case DSettingTypeAccount:
            return 40;
            break;
        default:
            break;
    }
    return  30;
}


#pragma mark HeaderSection
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView * imageView =[self createBackGroundImageView:[UIImage imageNamed:@"set_header.png"]];
    switch (section) {
        case 0:
            imageView.image = nil;
            imageView.backgroundColor = [UIColor clearColor];
            break;
        case 1:
            [imageView addSubview:[self createLableTitle:@"Connected services" fontName:@"HelveticaNeue-Thin" textSize:20.0 tag:2]];
            break;
        case 2:
            [imageView addSubview:[self createLableTitle:@"Autoplay" fontName:@"HelveticaNeue-Thin" textSize:20.0 tag:2]];
            break;
        case 3:
            [imageView addSubview:[self createLableTitle:@"Notifications" fontName:@"HelveticaNeue-Thin" textSize:20.0 tag:2]];
            break;
        default:
            break;
    }
    return imageView;
}


-  (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 15;
    }
    return 40;
}


- (UIImageView*)createBackGroundImageView:(UIImage*)inImage
{
    UIImageView * image = [[UIImageView alloc]initWithImage:inImage];
    return image;
}


- (void)changeTheNetwork:(UISwitch*)inSender
{
    
}

- (void)googlePlusResponce:(NSMutableDictionary *)responseDict andFriendsList:(NSMutableArray*)inFriendsList
{
    if(responseDict == nil) {
        [self.settingTableView reloadSections:[NSIndexSet indexSetWithIndex:DSettingNetwork] withRowAnimation:UITableViewRowAnimationNone];
        [self removeLoadingView];
        return;
    }
    
    WSModelClasses * dataClass = [WSModelClasses sharedHandler];
    dataClass.delegate = self;
    
    DESAppDelegate * delegate = (DESAppDelegate*)[UIApplication sharedApplication ].delegate;
    if (delegate.isFacebook) {
        [dataClass checkTheSocialIDwithDescriveServerCheckType:@"fb" andCheckValue:[responseDict valueForKey:@"id"]];
    }
    else if (delegate.isGooglePlus){
        [dataClass checkTheSocialIDwithDescriveServerCheckType:@"gplus" andCheckValue:[responseDict valueForKey:@"id"]];
    }
}

- (void)chekTheExistingUser:(NSDictionary *)responseDict error:(NSError *)error
{
    DESAppDelegate * delegate = (DESAppDelegate*)[UIApplication sharedApplication ].delegate;
    [self removeLoadingView];
    
    if ([[[responseDict valueForKeyPath:@"DataTable.UserData.Msg"]objectAtIndex:0] isEqualToString:@"TRUE"]) {
        // make either facebook / Gplus button as ON
        [self.settingTableView reloadSections:[NSIndexSet indexSetWithIndex:DSettingNetwork] withRowAnimation:UITableViewRowAnimationNone];
    }
    else {
        [self.settingTableView reloadSections:[NSIndexSet indexSetWithIndex:DSettingNetwork] withRowAnimation:UITableViewRowAnimationNone];
        NSString * messageStr = @"";
        if (delegate.isFacebook) {
            messageStr = NSLocalizedString(@"This Facebook account is already associated with another Describe account.", @"");
            [[DESocialConnectios sharedInstance] logoutFacebook];
        }
        else if (delegate.isGooglePlus){
            messageStr = NSLocalizedString(@"This Google+ account is already associated with another Describe account.", @"");
            [[DESocialConnectios sharedInstance] logoutGooglePlus];
        }
        
        [self showAlertWithTitle:NSLocalizedString(@"Describe", @"") message:messageStr tag:0 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
}

- (void)showAlertWithTitle:(NSString *)titleString message:(NSString *)message tag:(NSUInteger)tagValue delegate:(id /*<UIAlertViewDelegate>*/)target cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString message:message delegate:target cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    // get the variable arguments into argumentList(va_list) using va_start and then iterate through list to get all the button titles
    // add the button titles to the alert
    va_list args;
    va_start(args, otherButtonTitles);
    for(NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*)) {
        [alert addButtonWithTitle:arg];
    }
    va_end(args);
    
    alert.tag = tagValue;
    [alert show];
}

- (void)showLoadingView
{
    [[WSModelClasses sharedHandler] showLoadView];
}

- (void)removeLoadingView
{
    [[WSModelClasses sharedHandler] removeLoadingView];
}

@end
