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
@interface DescAddpeopleViewController ()<DSearchBarComponentDelegate,WSModelClassDelegate,MBProgressHUDDelegate, DSocialMediaListViewDelegate,DESocialConnectiosDelegate, DHeaderViewDelegate>
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
    __weak IBOutlet UIView *followAndInviteView;
    __weak IBOutlet UIButton *followAndInviteImgView;
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
    //[backButton addTarget:self action:@selector(goToBack:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTag:HeaderButtonTypePrev];
    if([[self.navigationController viewControllers] count] == 2)
        [backButton setHidden:YES];
    else
        [backButton setHidden:NO];
    
    
    nextButton = [[UIButton alloc] init];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_next.png"] forState:UIControlStateNormal];
    //[nextButton addTarget:self action:@selector(goToFeedScreen:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setTag:HeaderButtonTypeNext];
    
    
    if(self.isCommmingFromFeed)
        [_headerView designHeaderViewWithTitle:@"Add People" andWithButtons:@[backButton]];
    else
        [_headerView designHeaderViewWithTitle:@"Add People" andWithButtons:@[backButton,nextButton]];
    [_headerView setDelegate:self];
}

-(void)headerView:(DHeaderView *)headerView didSelectedHeaderViewButton:(UIButton *)headerButton
{
    HeaderButtonType buttonType = headerButton.tag;
    switch (buttonType) {
        case HeaderButtonTypeNext:
            [self goToFeedScreen:headerButton];
            break;
        case HeaderButtonTypePrev:
            
            NSLog(@"Controllers:%@",self.navigationController.viewControllers);
            
            [self.navigationController popViewControllerAnimated:YES];
        default:
            break;
    }
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
    _searchBarComponent.tag = 2;
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
        case 0:
            [self requestToFaceboookForFriendsList:nil];
            
            break;
        case 1:
            [self requestToGooglePlusForFriendsList:nil];
            break;
            
        default:
            break;
    }
}


- (void)goToFeedScreen:(UIButton*)inButton
{
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
        SearchPeopleData * data =  [[SearchPeopleData alloc]initWithDictionary:dic[@"DescribeSearchResultsByPeople"]];
        [peopleArray addObject:data];
    }
    if (_peoplelistView!=nil) {
        [_peoplelistView removeFromSuperview];
        _peoplelistView=nil;
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _peoplelistView = [[DPeopleListComponent alloc]initWithFrame:CGRectMake(0, 200, 320, screenRect.size.height-240) andPeopleList:(NSArray*)peopleArray];
    _peoplelistView.tag = 1;
    if ([WSModelClasses sharedHandler].loggedInUserModel.isInvitation == YES) {
        [followAndInviteImgView setImage:[UIImage imageNamed:@"btn_invite_all.png"] forState:UIControlStateNormal];
    }else{
        [followAndInviteImgView setImage:[UIImage imageNamed:@"btn_follow_all.png"] forState:UIControlStateNormal];
    }
    [followAndInviteImgView bringSubviewToFront:_peoplelistView];
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
    WSModelClasses * modelClass = [WSModelClasses sharedHandler];
    modelClass.delegate = self;
    if (isSearching) {
        isSearching = NO;
        [_headerView removeSubviewFromHedderView];
        //back button
        backButton = [[UIButton alloc] init];
        [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(removeTheSearchViewFromSuperview:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView designHeaderViewWithTitle:@"Search" andWithButtons:@[backButton]];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        _peoplelistView = [[DPeopleListComponent alloc]initWithFrame:CGRectMake(0, 105, 320, screenRect.size.height-108) andPeopleList:nil];
        [self.view addSubview:_peoplelistView];
    }else{
        if ([searchBar.searchTxt.text length]!=0) {
            [modelClass getSearchDetailsUserID:@"1" searchType:nil  searchWord:searchBar.searchTxt.text];
            
        }
    }
}

- (void)getSearchDetails:(NSDictionary *)responseDict error:(NSError *)error{
    NSArray * peopleArray = [responseDict valueForKey:@"DataTable"];
    self.searchListArray = [[NSMutableArray alloc]init];
    for (NSMutableDictionary* dataDic in peopleArray) {
        SearchPeopleData * searchData = [[SearchPeopleData alloc]initWithDictionary:dataDic[@"DescribeSearchResultsByPeople"]];
        [self.searchListArray addObject:searchData];
    }
    backButton.userInteractionEnabled = YES;
    [_peoplelistView reloadTableView:self.searchListArray];
    
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

- (IBAction)followAndInviteActions:(id)sender {
    if ([WSModelClasses sharedHandler].loggedInUserModel.isInvitation == YES) {
        [self inviteAllAction];
    }else{
        [self followAllAction];
    }
}

-(void)followAllAction
{
    [[WSModelClasses sharedHandler]followAllActionUserID:@"" followAllString:@"" rageValue:@"0" responce:^(BOOL success, id responce){
        if (success) {
            
            
        }else{
            
        }
    }];
    
}

-(void)inviteAllAction
{
    [[WSModelClasses sharedHandler]inviteAllActionUserID:@"" inviteAllString:@"" rageValue:@"" responce:^(BOOL success, id responce){
        if (success) {
            
            
        }else{
            
            
        }
    }];
}
@end
