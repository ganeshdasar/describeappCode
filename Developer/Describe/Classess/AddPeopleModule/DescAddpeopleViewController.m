//
//  DescAddpeopleViewController.m
//  Describe
//
//  Created by NuncSys on 07/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DescAddpeopleViewController.h"
#import "DHeaderView.h"
#import "DPeopleListComponent.h"
#import "DSegmentComponent.h"
#import "DSearchBarComponent.h"
#import "WSModelClasses.h"
#import "DSocialComponent.h"
#import "UIColor+DesColors.h"
#import "DPostsViewController.h"
#import "Constant.h"
#import "ProfileViewController.h"
#import "MBProgressHUD.h"
#import "DSocialMediaListView.h"
#import "DESocialConnectios.h"
#import "DesSearchPeopleViewContrlooerViewController.h"
#import "DESSettingsViewController.h"
@interface DescAddpeopleViewController ()<DSearchBarComponentDelegate,WSModelClassDelegate,MBProgressHUDDelegate, DSocialMediaListViewDelegate,DESocialConnectiosDelegate>
{
    IBOutlet DHeaderView *_headerView;
    UIButton    *backButton,*nextButton;
    UIButton    *weRecommendBtn,*invitationsBtn;
    UIButton     *facebookBtn,*googlePlusBtn;
    WSModelClasses * serviceClass;
    MBProgressHUD*_loadingView;
    
    IBOutlet DSocialMediaListView *_mediaListView;
    
    
    IBOutlet DPeopleListComponent *_peoplelistView;
    IBOutlet DSegmentComponent * _segmentComponent;
    IBOutlet DSearchBarComponent * _searchBarComponent;
    IBOutlet DSocialComponent * socialComponent;
    DesSearchPeopleViewContrlooerViewController *searchViewCntrl;
}
@end

@implementation DescAddpeopleViewController
@synthesize selectedType;
@synthesize peopleListArray;
@synthesize searchListArray;
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
    [super viewDidLoad];
    if (isiPhone5)
    {
        self.backGroundImg.image = [UIImage imageNamed:@"bg_std_4in.png"];
    }
    else
    {
        self.backGroundImg.image = [UIImage imageNamed:@"bg_std_3.5in.png"];
        
        //Iphone  3.5 inch
    }
    self.selectedType.selected = NO;
    [self designHeaderView];
    [self createSegmenComponent];
    [self designPeopleListView];
    [self addSearchBarView];
    [self designSocialComponent];
    [self setNeedsStatusBarAppearanceUpdate];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTheView)
                                                 name:@"refreshTheView"
                                               object:nil];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
//HeadderView
-(void)refreshTheView
{
    [self designPeopleListView];
}

-(void)designHeaderView
{
    //back button
    backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goToBack:) forControlEvents:UIControlEventTouchUpInside];
    
    if([[self.navigationController viewControllers] count] == 2)
        [backButton setHidden:YES];
    else
        [backButton setHidden:NO];
    
    
    nextButton = [[UIButton alloc] init];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_next.png"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(goToFeedScreen:) forControlEvents:UIControlEventTouchUpInside];
    
    [_headerView designHeaderViewWithTitle:@"Add People" andWithButtons:@[backButton,nextButton]];
    
}
//Segment

-(void)createSegmenComponent{
    weRecommendBtn = [[UIButton alloc] init];
    [weRecommendBtn setTitle: @"We recommend" forState: UIControlStateNormal];
    [weRecommendBtn setTitleColor:[UIColor textPlaceholderColor] forState:UIControlStateNormal];
    weRecommendBtn.titleLabel.font  = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16];
    [weRecommendBtn setTitleColor:[UIColor segmentButtonSelectedColor] forState:UIControlStateSelected];
    [weRecommendBtn setBackgroundImage:[UIImage imageNamed:@"seg_2_1.png"] forState:UIControlStateNormal];
    weRecommendBtn.selected = YES;
    [weRecommendBtn addTarget:self action:@selector(getTheWeRecommendDataFromServer:) forControlEvents:UIControlEventTouchUpInside];
    
    invitationsBtn = [[UIButton alloc] init];
    [invitationsBtn setBackgroundImage:[UIImage imageNamed:@"seg_2_2.png"] forState:UIControlStateNormal];
    [invitationsBtn setTitle: @"Invitations" forState: UIControlStateNormal];
    invitationsBtn.titleLabel.font  = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16];
    [invitationsBtn addTarget:self action:@selector(getTheInvitationsDataFromServer:) forControlEvents:UIControlEventTouchUpInside];
    [invitationsBtn setTitleColor:[UIColor textPlaceholderColor] forState:UIControlStateNormal];
    [invitationsBtn setTitleColor:[UIColor segmentButtonSelectedColor] forState:UIControlStateSelected];
    invitationsBtn.selected = NO;
    BOOL iskeyAvilable;
    if ([[NSUserDefaults standardUserDefaults]valueForKey:FACEBOOKACCESSTOKENKEY]) {
        iskeyAvilable = YES;
    }else if ([[NSUserDefaults standardUserDefaults]valueForKey:GOOGLEPLUESACCESSTOKEN]){
        iskeyAvilable = YES;
    }else {
        iskeyAvilable = NO;
    }
    if (!iskeyAvilable) {
        invitationsBtn.userInteractionEnabled = NO;
    }
    [_segmentComponent designSegmentControllerWithButtons:@[weRecommendBtn,invitationsBtn]];
}
//Social Component
-(void)designSocialComponent
{
    
    NSString *gpSelected =  ([[NSUserDefaults standardUserDefaults]valueForKey:GOOGLEPLUESACCESSTOKEN])?@"1":@"0";
        NSString *fbSelected =  ([[NSUserDefaults standardUserDefaults]valueForKey:FACEBOOKACCESSTOKENKEY])?@"1":@"0";
    
    NSDictionary *mediaItem0 = @{@"ImageNormal": @"btn_3rd_fb_nc.png", @"ImageSelected": @"btn_3rd_fb_on.png", @"Selected":fbSelected};
    NSDictionary *mediaItem1 = @{@"ImageNormal": @"btn_3rd_goog_nc.png", @"ImageSelected": @"btn_3rd_goog_on.png", @"Selected":gpSelected};
    
    [_mediaListView setDelegate:self];
    [_mediaListView setMedaiList:@[mediaItem0, mediaItem1]];
    
}


-(void)socailMediaDidSelectedItemAtIndex:(NSInteger)index
{
    [_peoplelistView setBackgroundColor:[UIColor clearColor]];
    switch (index)
    {
        case 1:
            [self requestToFaceboookForFriendsList:nil];
            
            break;
        case 2:
            [self requestToGooglePlusForFriendsList:nil];
            break;
            
        default:
            break;
    }
}


- (void)goToFeedScreen:(UIButton*)inButton
{
    DESSettingsViewController * setting = [[DESSettingsViewController alloc]initWithNibName:@"DESSettingsViewController" bundle:nil];
    [self.navigationController pushViewController:setting animated:NO];
    return;
    [[WSModelClasses  sharedHandler] getTheGenaralFeedServices:@"" andPageValue:@""];
    DPostsViewController *postViewController = [DPostsViewController sharedFeedController];////[[DPostsViewController alloc] initWithNibName:@"DPostsViewController" bundle:nil];
    [self.navigationController pushViewController:postViewController animated:YES];
}

#pragma mark SegmentView Actions
-(void)getTheWeRecommendDataFromServer:(UIButton*)inSender{
    inSender.selected =YES;
    [self showLoadView];
    invitationsBtn.selected =NO;
    NSString * gateWay;
    NSString * accessToken;
    [WSModelClasses sharedHandler].delegate = self;
    if ([[NSUserDefaults standardUserDefaults]valueForKey:FACEBOOKACCESSTOKENKEY]) {
        gateWay = @"fb";
        accessToken  = [[NSUserDefaults standardUserDefaults]valueForKey:FACEBOOKACCESSTOKENKEY];
    }else if ([[NSUserDefaults standardUserDefaults]valueForKey:GOOGLEPLUESACCESSTOKEN]){
        gateWay = @"gplus";
        accessToken = [[NSUserDefaults standardUserDefaults]valueForKey:GOOGLEPLUESACCESSTOKEN];
    }else {
        gateWay =@"";
        accessToken = @"";
    }
    [WSModelClasses sharedHandler].loggedInUserModel.isInvitation = NO;
    [[WSModelClasses sharedHandler]getWeRecommendedpeople:(NSString*)[WSModelClasses sharedHandler].loggedInUserModel.userID GateWay:gateWay Accesstoken:accessToken AndRange:@"0"];
}


-(void)getTheInvitationsDataFromServer:(UIButton*)inSender{
    inSender.selected =YES;
    [self showLoadView];
    NSString * gateWay;
    NSString * accessToken;
    [WSModelClasses sharedHandler].delegate = self;
    if ([[NSUserDefaults standardUserDefaults]valueForKey:FACEBOOKACCESSTOKENKEY]) {
        gateWay = @"fb";
        accessToken  = [[NSUserDefaults standardUserDefaults]valueForKey:FACEBOOKACCESSTOKENKEY];
    }else if ([[NSUserDefaults standardUserDefaults]valueForKey:GOOGLEPLUESACCESSTOKEN]){
        gateWay = @"gplus";
        accessToken = [[NSUserDefaults standardUserDefaults]valueForKey:GOOGLEPLUESACCESSTOKEN];
    }else {
        gateWay =@"";
        accessToken = @"";
    }
    [WSModelClasses sharedHandler].loggedInUserModel.isInvitation = YES;
    weRecommendBtn.selected = NO;
    [WSModelClasses sharedHandler].delegate = self;
    [[WSModelClasses sharedHandler]getInvitationListpeople:(NSString*)[WSModelClasses sharedHandler].loggedInUserModel.userID GateWay:gateWay Accesstoken:accessToken AndRange:@"0"];
}


#pragma mark Socialnetwork actions
-(void)requestToFaceboookForFriendsList:(UIButton*)inSender{
    inSender.selected = YES;
    inSender.selected = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"faceBookButtonClicked" object:nil];
    [[DESocialConnectios sharedInstance] facebookSignIn];
    [DESocialConnectios sharedInstance].delegate =self;
    
}
-(void)requestToGooglePlusForFriendsList:(UIButton*)inSender{
    inSender.selected = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"googlePlusButtonClicked" object:nil];
    [[DESocialConnectios sharedInstance] googlePlusSignIn];
    [DESocialConnectios sharedInstance].delegate = self;
    inSender.selected = YES;
}


-(void)goToBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)nextButton:(id)inSender{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Design PeopleListView
-(void)designPeopleListView{
    [self showLoadView];
    NSString * gateWay;
    NSString * accessToken;
    [WSModelClasses sharedHandler].delegate = self;
    if ([[NSUserDefaults standardUserDefaults]valueForKey:FACEBOOKACCESSTOKENKEY]) {
        gateWay = @"fb";
        accessToken  = [[NSUserDefaults standardUserDefaults]valueForKey:FACEBOOKACCESSTOKENKEY];
    }else if ([[NSUserDefaults standardUserDefaults]valueForKey:GOOGLEPLUESACCESSTOKEN]){
        gateWay = @"gplus";
        accessToken = [[NSUserDefaults standardUserDefaults]valueForKey:GOOGLEPLUESACCESSTOKEN];
    }else {
        gateWay =@"";
        accessToken = @"";
    }
    [[WSModelClasses sharedHandler]getWeRecommendedpeople:(NSString*)[WSModelClasses sharedHandler].loggedInUserModel.userID GateWay:gateWay Accesstoken:accessToken AndRange:@"0"];
}


- (void)didFinishWSConnectionWithResponse:(NSDictionary *)responseDict
{
    _loadingView.hidden=YES;
    [_loadingView removeFromSuperview];
    WebservicesType serviceType = (WebservicesType)[responseDict[WS_RESPONSEDICT_KEY_SERVICETYPE] integerValue];
    if(responseDict[WS_RESPONSEDICT_KEY_ERROR]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Describe", @"") message:NSLocalizedString(@"Error while communicating to server. Please try again later.", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    switch (serviceType) {
        case kWebserviesType_addPeople_wRecommended:
        {
            [self parsingTheData:responseDict];
            break;
        }
        case kWebserviesType_addPeople_wInvitations:
        {
            [self parsingTheData:responseDict];
            break;
        }
        default:
            break;
    }
    
    
}

-(void)parsingTheData:(NSDictionary*)responceDict
{
    NSMutableArray  * peopleArray = [[NSMutableArray alloc]init];
    
    for (NSMutableDictionary * dic in [responceDict valueForKeyPath:@"ResponseData.DataTable"]) {
        SearchPeopleData * data =  [[SearchPeopleData alloc]init];
        data.followingStatus = [dic valueForKeyPath:@"DescribeSuggestedUsers.FollowingStatus"];
        data.gateWayToken = [dic valueForKeyPath:@"DescribeSuggestedUsers.GateWayToken"];
        data.gateWayType = [dic valueForKeyPath:@"DescribeSuggestedUsers.GateWayType"];
        data.profileUserEmail = [dic valueForKeyPath:@"DescribeSuggestedUsers.UserEmail"];
        data.profileUserFullName = [dic valueForKeyPath:@"DescribeSuggestedUsers.UserFullName"];
        data.profileUserProfilePicture = [dic valueForKeyPath:@"DescribeSuggestedUsers.UserProfilePicture"];
        data.profileUserUID = [dic valueForKeyPath:@"DescribeSuggestedUsers.UserUID"];
        data.profileUserName = [dic valueForKeyPath:@"DescribeSuggestedUsers.Username"];
        [peopleArray addObject:data];
    }
    if (_peoplelistView!=nil) {
        [_peoplelistView removeFromSuperview];
        _peoplelistView=nil;
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _peoplelistView = [[DPeopleListComponent alloc]initWithFrame:CGRectMake(0, 200, 320, screenRect.size.height-200) andPeopleList:(NSArray*)peopleArray];
    _peoplelistView.tag = 1;
    [self.view addSubview:_peoplelistView];
    
}

-(void)addSearchBarView{
    isSearching = YES;
    [_searchBarComponent designSerachBar];
    _searchBarComponent.searchDelegate =self;
    [_searchBarComponent setBackgroundColor:[UIColor whiteColor]];
}
#pragma serchThe People
- (void)searchBarSearchButtonClicked:(DSearchBarComponent *)searchBar;{
    for (UIView*view in self.view.subviews) {
        if (view.tag==1) [view removeFromSuperview];
        }
    DesSearchPeopleViewContrlooerViewController*search = [[DesSearchPeopleViewContrlooerViewController alloc]initWithNibName:@"DesSearchPeopleViewContrlooerViewController" bundle:nil];
    searchViewCntrl = search;
    [self.navigationController pushViewController:search animated:YES];
    
}


-(void)removeTheSearchViewFromSuperview:(id)inSender{
    [_headerView removeSubviewFromHedderView];
    [_peoplelistView removeFromSuperview];
    _searchBarComponent.searchTxt.text =@"";
    [_peoplelistView._peopleList removeAllObjects];
    isSearching = YES;
    [_searchBarComponent.searchTxt resignFirstResponder];
    [self designHeaderView];
}


- (void)showLoadView
{
    _loadingView = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:_loadingView];
    _loadingView.delegate = self;
    _loadingView.labelText = @"Loading";
    [_loadingView show:YES];
}

@end
