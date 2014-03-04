//
//  DESEmailNotificationControll.m
//  Describe
//
//  Created by NuncSys on 16/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DESEmailNotificationControll.h"
#import "UIColor+DesColors.h"
#import "Constant.h"


@interface DESEmailNotificationControll ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray * emailNotificationList;
    UIButton    *backButton;

}

@end

@implementation DESEmailNotificationControll
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
    self.emailNotificationTbl.frame = CGRectMake(0, self.emailNotificationTbl.frame.origin.x
                                                , 320,  screenRect.size.height-65);
    self.emailNotificationTbl.backgroundColor = [UIColor clearColor];
    [self setBackGroundImage];
    [super viewDidLoad];
    [self initializeTheArray];
    [self createHeadderView];
    // Do any additional setup after loading the view from its nib.
}


- (void)initializeTheArray
{
    emailNotificationList = [[NSArray alloc]initWithObjects:@"likes on my posts",@"comments on my posts",@"my mentions in comments",@"not followers", nil];
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

-(void)setBackGroundImage
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


-(void)back:(UIButton*)inSender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return emailNotificationList.count;
            break;
        case 1:
            return 1;
            break;
        default:
            return 1;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"identifier_%d_%ld",indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.selectedBackgroundView = nil;
    }
    UISwitch *stch = [[UISwitch alloc] initWithFrame: CGRectZero];
    cell.accessoryView = stch;
    switch (indexPath.section) {
        case 0:{
            cell.textLabel.text = emailNotificationList[indexPath.row];
            cell.textLabel.textColor = [UIColor textPlaceholderColor];
            break;
        }
        case 1:{
            cell.textLabel.text = @"Activity updates";
            cell.textLabel.textColor = [UIColor textPlaceholderColor];
            break;
        }
        case 2:{
            cell.textLabel.text = @"Important announcements";
            cell.textLabel.textColor = [UIColor textPlaceholderColor];
            break;
        }
        default:
            break;
    }
    return cell;
}


- (UIImageView*)createBackGroundImageView:(UIImage*)inImage
{
    UIImageView * image = [[UIImageView alloc]initWithImage:inImage];
    return image;
}


#pragma mark FooterSection
-  (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,0,320,40)];
    tempView.backgroundColor=[UIColor clearColor];
    switch (section) {
        case 1:{
            UILabel * label = [self createLableTitle:@"Activity updates are curated collections of the newest and the most interesting post shared by users." fontName:@"HelveticaNeue-Light" textSize:10.0 tag:1];
            [tempView addSubview:label];
            break;
        }
        case 2:{
            UILabel * label = [self createLableTitle:@"Information about  security alerts, products updates and useful tips." fontName:@"HelveticaNeue-Light" textSize:10.0 tag:1];
            label.frame = CGRectMake(15, 0, 320, 20);
            [tempView addSubview:label];
        }
            break;
        default:
            break;
    }
    return tempView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return 30;
            break;
        default:
            break;
    }
    return  10;
}


-  (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 15;
    }
    return 0;
}


#pragma mark HeaderSection
- (UILabel*)createLableTitle:(NSString*)inTitle fontName:(NSString*)inFontName textSize:(CGFloat)inFloat tag:(int)inTag
{
    UILabel *tempLabel=[[UILabel alloc]init];
    tempLabel.frame =  CGRectMake(15, 0, 320, 40);
    tempLabel.numberOfLines = 0;
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.font =[UIFont fontWithName:inFontName size:inFloat];
    tempLabel.text = inTitle;
    tempLabel.textColor =   [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1];
    return tempLabel;
}

@end
