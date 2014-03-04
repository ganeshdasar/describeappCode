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


@interface DESPushNotificationControl ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray * pushNotificationList;
    UIButton    *backButton;

}

@end

@implementation DESPushNotificationControl
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
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.pustNotificationTbl.frame = CGRectMake(0, self.pustNotificationTbl.frame.origin.x
                                             , 320,  screenRect.size.height-65);
    self.pustNotificationTbl.backgroundColor = [UIColor clearColor];
    [self initilizeTheArray];
    [self createHeadderView];
    [self setBackGroundImage];
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
    [self.navigationController popViewControllerAnimated:YES];
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
    UISwitch *stch = [[UISwitch alloc] initWithFrame: CGRectZero];
    cell.accessoryView = stch;
    return cell;
}


- (UIImageView*)createBackGroundImageView:(UIImage*)inImage
{
    UIImageView * image = [[UIImageView alloc]initWithImage:inImage];
    return image;
}
@end
