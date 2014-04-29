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
#import "DESSettingsViewController.h"
#import "DProfileDetailsViewController.h"
#import "DESAppDelegate.h"

@interface DescAddpeopleViewController ()<DSearchBarComponentDelegate,WSModelClassDelegate,MBProgressHUDDelegate, DSocialMediaListViewDelegate,DESocialConnectiosDelegate, DHeaderViewDelegate, DPeopleListDelegate>
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
    __weak IBOutlet UIView *followAndInviteView;
    __weak IBOutlet UIButton *followAndInviteImgView;
    
    BOOL shouldLoadMoreRecommend;
    NSInteger pageLoadNumberRecommend;
    NSMutableArray *werecommendedList;
    
    BOOL shouldLoadMoreInvite;
    NSInteger pageLoadNumberInvite;
    NSMutableArray *invitationList;
    
    BOOL shouldLoadMoreSearch;
    NSInteger pageLoadNumberSearch;
    
    UIButton *selecedSocialBtnRef;
}

@end

@implementation DescAddpeopleViewController
@synthesize selectedType;
@synthesize searchListArray;

- (UIStatusBarStyle)preferredStatusBarStyle
{
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
    // Do any additional setup after loading the view from its nib.

    if (isiPhone5) {
        self.backGroundImg.image = [UIImage imageNamed:@"bg_std_4in.png"];
    }
    else {
        self.backGroundImg.image = [UIImage imageNamed:@"bg_std_3.5in.png"];
    }
    
    self.selectedType.selected = NO;
    selecedSocialBtnRef = nil;
    
    shouldLoadMoreInvite = NO;
    shouldLoadMoreRecommend = NO;
    pageLoadNumberInvite = 0;
    pageLoadNumberRecommend = 0;
    
    shouldLoadMoreSearch = NO;
    pageLoadNumberSearch = 0;
    
    werecommendedList = [[NSMutableArray alloc] initWithCapacity:0];
    invitationList = [[NSMutableArray alloc] initWithCapacity:0];
    self.searchListArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self designHeaderView];
    [self createSegmenComponent];
    [self performSelector:@selector(fetchWerecommendList) withObject:nil afterDelay:0.5];
    [self addSearchBarView];
    [self designSocialComponent];
    [self designPeopleListView:nil];
    
    [self setNeedsStatusBarAppearanceUpdate];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTheView)
                                                 name:@"refreshTheView"
                                               object:nil];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//HeadderView
- (void)refreshTheView
{
    [self fetchWerecommendList];
}

- (void)designHeaderView
{
    //back button
    backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton setTag:HeaderButtonTypePrev];
    if([[self.navigationController viewControllers] count] == 2) {
        [backButton setHidden:YES];
    }
    else {
        [backButton setHidden:NO];
    }
    
    nextButton = [[UIButton alloc] init];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_next.png"] forState:UIControlStateNormal];
    [nextButton setTag:HeaderButtonTypeNext];
    
    if(self.isCommmingFromFeed) {
        [_headerView designHeaderViewWithTitle:@"Add People" andWithButtons:@[backButton]];
    }
    else {
        [_headerView designHeaderViewWithTitle:@"Add People" andWithButtons:@[nextButton]];
    }
    [_headerView setDelegate:self];
}

- (void)headerView:(DHeaderView *)headerView didSelectedHeaderViewButton:(UIButton *)headerButton
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
- (void)createSegmenComponent
{
    weRecommendBtn = [[UIButton alloc] init];
    [weRecommendBtn setTitle: @"We recommend" forState: UIControlStateNormal];
    weRecommendBtn.titleLabel.font  = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16];
    [weRecommendBtn setTitleColor:[UIColor textPlaceholderColor] forState:UIControlStateNormal];
    [weRecommendBtn setTitleColor:[UIColor segmentButtonSelectedColor] forState:UIControlStateSelected];
    weRecommendBtn.selected = YES;
    [weRecommendBtn addTarget:self action:@selector(getTheWeRecommendDataFromServer:) forControlEvents:UIControlEventTouchUpInside];
    
    invitationsBtn = [[UIButton alloc] init];
    [invitationsBtn setTitle: @"Invitations" forState: UIControlStateNormal];
    invitationsBtn.titleLabel.font  = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16];
    [invitationsBtn addTarget:self action:@selector(getTheInvitationsDataFromServer:) forControlEvents:UIControlEventTouchUpInside];
    [invitationsBtn setTitleColor:[UIColor textPlaceholderColor] forState:UIControlStateNormal];
    [invitationsBtn setTitleColor:[UIColor segmentButtonSelectedColor] forState:UIControlStateSelected];
    invitationsBtn.selected = NO;

    _searchBarComponent.tag = 2;
    [_segmentComponent designSegmentControllerWithButtons:@[weRecommendBtn,invitationsBtn]];
}

//Social Component
- (void)designSocialComponent
{
//    NSString *gpSelected =  ([[NSUserDefaults standardUserDefaults]valueForKey:GOOGLEPLUESACCESSTOKEN])?@"1":@"0";
    NSString *fbSelected =  ([[NSUserDefaults standardUserDefaults]valueForKey:FACEBOOKACCESSTOKENKEY])?@"1":@"0";
    
    NSDictionary *mediaItem0 = @{@"ImageNormal": @"btn_3rd_fb_nc.png", @"ImageSelected": @"btn_3rd_fb_on.png", @"Selected":fbSelected};
//    NSDictionary *mediaItem1 = @{@"ImageNormal": @"btn_3rd_goog_nc.png", @"ImageSelected": @"btn_3rd_goog_on.png", @"Selected":gpSelected};
    
    [_mediaListView setDelegate:self];
    [_mediaListView setMedaiList:@[mediaItem0]];
//    [_mediaListView setMedaiList:@[mediaItem0, mediaItem1]];
}

- (void)socailMediaDidSelectedItemAtIndex:(UIButton *)socialBtn
{
    [_peoplelistView setBackgroundColor:[UIColor clearColor]];
    NSInteger index = [socialBtn tag];
    switch (index)
    {
        case 0:
            [self requestToFaceboookForFriendsList:socialBtn];
            break;
            
        case 1:
            [self requestToGooglePlusForFriendsList:socialBtn];
            break;
            
        default:
            break;
    }
}

- (void)goToFeedScreen:(UIButton*)inButton
{
    [[WSModelClasses  sharedHandler] getTheGenaralFeedServices:@"" andPageValue:@""];
    DPostsViewController *postViewController = [[DPostsViewController alloc] initWithNibName:@"DPostsViewController" bundle:nil];
    [self.navigationController pushViewController:postViewController animated:YES];
}

#pragma mark SegmentView Actions
- (void)getTheWeRecommendDataFromServer:(UIButton*)inSender
{
    [WSModelClasses sharedHandler].loggedInUserModel.isInvitation = NO;
    inSender.selected = YES;
    invitationsBtn.selected = NO;
    [WSModelClasses sharedHandler].loggedInUserModel.isInvitation = NO;
    
    if(werecommendedList.count == 0) {
        shouldLoadMoreRecommend = NO;
        pageLoadNumberRecommend = 0;
        [self fetchWerecommendList];
    }
    
    [followAndInviteImgView setImage:[UIImage imageNamed:@"btn_follow_all.png"] forState:UIControlStateNormal];

    if(_peoplelistView != nil) {
        [_peoplelistView reloadTableView:werecommendedList];
    }
    
    [self showStatusView:YES];
}

- (void)getTheInvitationsDataFromServer:(UIButton*)inSender
{
    inSender.selected = YES;
    weRecommendBtn.selected = NO;
    [WSModelClasses sharedHandler].loggedInUserModel.isInvitation = YES;
    
    if(invitationList.count == 0) {
        shouldLoadMoreInvite = NO;
        pageLoadNumberInvite = 0;
        [self fetchInvitationList];
    }
    
    [followAndInviteImgView setImage:[UIImage imageNamed:@"btn_invite_all.png"] forState:UIControlStateNormal];
    
    if(_peoplelistView != nil) {
        [_peoplelistView reloadTableView:invitationList];
    }
    
    [self showStatusView:YES];
}

#pragma mark Socialnetwork actions
- (void)requestToFaceboookForFriendsList:(UIButton*)inSender
{
    if([[DESocialConnectios sharedInstance] isFacebookLoggedIn]) {
        inSender.selected = YES;
    }
    else {
        selecedSocialBtnRef = inSender;
        [[WSModelClasses sharedHandler] showLoadView];
        [DESocialConnectios sharedInstance].delegate = self;
        [[DESocialConnectios sharedInstance] facebookSignIn];
    }
}

- (void)requestToGooglePlusForFriendsList:(UIButton*)inSender
{
    if([[DESocialConnectios sharedInstance] isGooglePlusLoggeIn]) {
        inSender.selected = YES;
    }
    else {
        selecedSocialBtnRef = inSender;
        [[WSModelClasses sharedHandler] showLoadView];
        [[DESocialConnectios sharedInstance] googlePlusSignIn];
        [DESocialConnectios sharedInstance].delegate = self;
    }
}

- (void)googlePlusResponce:(NSMutableDictionary *)responseDict andFriendsList:(NSMutableArray*)inFriendsList
{
    if(responseDict == nil) {
        [[WSModelClasses sharedHandler] removeLoadingView];
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
    [[WSModelClasses sharedHandler] removeLoadingView];
    
    if ([[[responseDict valueForKeyPath:@"DataTable.UserData.Msg"]objectAtIndex:0] isEqualToString:@"TRUE"]) {
        // make either facebook / Gplus button as ON
        [selecedSocialBtnRef setSelected:YES];
//        [_mediaListView makeSocialBtnSelected:YES withTag:selecedSocialBtnTag];
    }
    else {
        [selecedSocialBtnRef setSelected:NO];
//        [_mediaListView makeSocialBtnSelected:YES withTag:selecedSocialBtnTag];
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

- (void)goToBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButton:(id)inSender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Design PeopleListView
- (void)designPeopleListView:(NSArray *)list
{
    if(_peoplelistView == nil) {
        CGRect socialFrame = _mediaListView.frame;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        CGRect peopleListFrame = CGRectZero;
        peopleListFrame.origin.y = CGRectGetMinY(socialFrame);
        peopleListFrame.size.width = CGRectGetWidth(screenRect);
        peopleListFrame.size.height = CGRectGetHeight(screenRect) - CGRectGetMinY(socialFrame) - CGRectGetHeight(followAndInviteView.frame);
        
        [_mediaListView removeFromSuperview];
        socialFrame.origin = CGPointZero;
        _mediaListView.frame = socialFrame;
        
        _peoplelistView = [[DPeopleListComponent alloc] initWithFrame:peopleListFrame andPeopleList:list];
        _peoplelistView.delegate = self;
        _peoplelistView.tag = 1;
        [_peoplelistView addHeaderViewForTable:_mediaListView];
        [self.view addSubview:_peoplelistView];
    }
}

- (void)fetchWerecommendList
{
    if(pageLoadNumberRecommend == 0) {
        [[WSModelClasses sharedHandler] showLoadView];
    }
    
    NSString * gateWay;
    NSString * accessToken;
    if ([[NSUserDefaults standardUserDefaults]valueForKey:FACEBOOKACCESSTOKENKEY]) {
        gateWay = @"fb";
        accessToken  = [[NSUserDefaults standardUserDefaults]valueForKey:FACEBOOKACCESSTOKENKEY];
    }
    else if ([[NSUserDefaults standardUserDefaults]valueForKey:GOOGLEPLUESACCESSTOKEN]){
        gateWay = @"gplus";
        accessToken = [[NSUserDefaults standardUserDefaults]valueForKey:GOOGLEPLUESACCESSTOKEN];
    }
    else {
        gateWay =@"";
        accessToken = @"";
    }
    
    [WSModelClasses sharedHandler].loggedInUserModel.isInvitation = NO;
    [WSModelClasses sharedHandler].delegate = self;
    [[WSModelClasses sharedHandler] getWeRecommendedpeople:(NSString*)[WSModelClasses sharedHandler].loggedInUserModel.userID GateWay:gateWay Accesstoken:accessToken AndRange:pageLoadNumberRecommend];
}

- (void)fetchInvitationList
{
    if(pageLoadNumberInvite == 0) {
        [[WSModelClasses sharedHandler] showLoadView];
    }
    
    NSString *fbAccessToken = @"";
    NSString *gpAccessToken = @"";
    [WSModelClasses sharedHandler].delegate = self;
    if ([[NSUserDefaults standardUserDefaults]valueForKey:FACEBOOKACCESSTOKENKEY]) {
        fbAccessToken = [[NSUserDefaults standardUserDefaults]valueForKey:FACEBOOKACCESSTOKENKEY];
    }
    
    if ([[NSUserDefaults standardUserDefaults]valueForKey:GOOGLEPLUESACCESSTOKEN]){
        gpAccessToken = [[NSUserDefaults standardUserDefaults]valueForKey:GOOGLEPLUESACCESSTOKEN];
    }
    
    if(fbAccessToken.length == 0 && gpAccessToken.length == 0) {
        [[WSModelClasses sharedHandler] removeLoadingView];
        return;
    }
    
    [WSModelClasses sharedHandler].loggedInUserModel.isInvitation = YES;
    [WSModelClasses sharedHandler].delegate = self;
    [[WSModelClasses sharedHandler] getInvitationListpeople:[[[WSModelClasses sharedHandler] loggedInUserModel].userID stringValue] FBAccesstoken:fbAccessToken GPAccessToken:gpAccessToken AndRange:pageLoadNumberInvite];
}

- (void)didFinishWSConnectionWithResponse:(NSDictionary *)responseDict
{
    [[WSModelClasses sharedHandler] removeLoadingView];
    WebservicesType serviceType = (WebservicesType)[responseDict[WS_RESPONSEDICT_KEY_SERVICETYPE] integerValue];
    if(responseDict[WS_RESPONSEDICT_KEY_ERROR]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Describe", @"") message:NSLocalizedString(@"Error while communicating to server. Please try again later.", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        if(_peoplelistView != nil) {
            if ([WSModelClasses sharedHandler].loggedInUserModel.isInvitation == YES) {
                [_peoplelistView reloadTableView:invitationList];
            }
            else {
                [_peoplelistView reloadTableView:werecommendedList];
            }
        }
        
        [self showStatusView:YES];
        return;
    }
    
    switch (serviceType) {
        case kWebserviesType_addPeople_wRecommended:
        {
            [self parsingTheData:responseDict forInvitation:NO];
            break;
        }
            
        case kWebserviesType_addPeople_wInvitations:
        {
            [self parsingTheData:responseDict forInvitation:YES];
            break;
        }
            
        default:
            break;
    }
}

- (void)parsingTheData:(NSDictionary*)responceDict forInvitation:(BOOL)isInvitation
{
    NSMutableArray  * peopleArray = [[NSMutableArray alloc]init];
    
    NSArray *responseArr = [responceDict valueForKeyPath:@"ResponseData.DataTable"];
    if(responseArr != nil && responseArr.count) {
        BOOL peopleListAvailable = YES;
        if (responseArr.count == 1) {
            NSDictionary *dict = responseArr[0];
            if([dict valueForKeyPath:@"DescribeSuggestedUsers.Msg"] && [[dict valueForKeyPath:@"DescribeSuggestedUsers.Msg"] isEqualToString:@"FALSE"]) {
                peopleListAvailable = NO;
            }
        }
        
        if(peopleListAvailable == YES) {
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
        }
    }
    
    BOOL reloadList = NO;
    
    if (isInvitation == YES) {
        if(pageLoadNumberInvite == 0) {
            [invitationList removeAllObjects];
        }
        
        [invitationList addObjectsFromArray:peopleArray];
        
        if(peopleArray.count == 10) {
            shouldLoadMoreInvite = YES;
            pageLoadNumberInvite += 1;
        }
        
        if(isSearching && [[WSModelClasses sharedHandler] loggedInUserModel].isInvitation == YES) {
            reloadList = YES;
            peopleArray = invitationList;
            [followAndInviteImgView setImage:[UIImage imageNamed:@"btn_invite_all.png"] forState:UIControlStateNormal];
        }
    }
    else {
        if(pageLoadNumberRecommend == 0) {
            [werecommendedList removeAllObjects];
        }
        
        [werecommendedList addObjectsFromArray:peopleArray];
        
        if(peopleArray.count == 10) {
            shouldLoadMoreRecommend = YES;
            pageLoadNumberRecommend += 1;
        }
        
        if(isSearching && [[WSModelClasses sharedHandler] loggedInUserModel].isInvitation == NO) {
            reloadList = YES;
            peopleArray = werecommendedList;
            [followAndInviteImgView setImage:[UIImage imageNamed:@"btn_follow_all.png"] forState:UIControlStateNormal];
        }
    }
    
    if(reloadList == YES) {
        if (_peoplelistView != nil) {
            [_peoplelistView reloadTableView:peopleArray];
        }
        else {
            [self designPeopleListView:peopleArray];
            [self.view bringSubviewToFront:followAndInviteView];
        }
        
        [self showStatusView:YES];
    }
}

- (void)addSearchBarView
{
    isSearching = YES;
    [_searchBarComponent designSerachBar];
    _searchBarComponent.searchDelegate =self;
    [_searchBarComponent setBackgroundColor:[UIColor whiteColor]];
}

#pragma serchThe People
- (void)searchBarSearchButtonClicked:(DSearchBarComponent *)searchBar
{
    if (isSearching) {
        isSearching = NO;
        [_headerView removeSubviewFromHedderView];
        //back button
        backButton = [[UIButton alloc] init];
        [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(removeTheSearchViewFromSuperview:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView designHeaderViewWithTitle:@"Search" andWithButtons:@[backButton]];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGRect peopleListFrame = _peoplelistView.frame;
        peopleListFrame.origin.y = 105.0f;
        peopleListFrame.size.height = CGRectGetHeight(screenRect) - 105.0f;
        [_peoplelistView setFrame:peopleListFrame];
        
        [_peoplelistView addHeaderViewForTable:nil];
        [_peoplelistView reloadTableView:self.searchListArray];

        [self showStatusView:NO];
    }
    else {
        if ([searchBar.searchTxt.text length]!=0) {
            shouldLoadMoreSearch = NO;
            pageLoadNumberSearch = 0;
            
            [self fetchSearchPeopleForWord:searchBar.searchTxt.text];
        }
    }
}

- (void)fetchSearchPeopleForWord:(NSString *)searchWord
{
    [[WSModelClasses sharedHandler] showLoadView];
    
    backButton.userInteractionEnabled = NO;
    WSModelClasses * modelClass = [WSModelClasses sharedHandler];
    modelClass.delegate = self;
    [modelClass getSearchDetailsUserID:[[modelClass loggedInUserModel].userID stringValue] searchWord:searchWord range:pageLoadNumberSearch];
}

- (void)getSearchDetails:(NSDictionary *)responseDict error:(NSError *)error
{
    if(isSearching) {
        [[WSModelClasses sharedHandler] removeLoadingView];
        backButton.userInteractionEnabled = YES;
        return;
    }
    
    [[WSModelClasses sharedHandler] removeLoadingView];
    
    if(pageLoadNumberSearch == 0) {
        [self.searchListArray removeAllObjects];
    }
    
    NSArray * peopleArray = [responseDict valueForKey:@"DataTable"];
    
    NSMutableArray *pepoleListArray = [[NSMutableArray alloc] init];
    
    if(peopleArray != nil && peopleArray.count) {
        BOOL peopleListAvailable = YES;
        if (peopleArray.count == 1) {
            NSDictionary *dict = peopleArray[0];
            if([dict valueForKeyPath:@"DescribeSearchResultsByPeople.Msg"] && [[dict valueForKeyPath:@"DescribeSearchResultsByPeople.Msg"] isEqualToString:@"There are no results on this Search Criteria."]) {
                peopleListAvailable = NO;
            }
        }
        
        if(peopleListAvailable == YES) {
            for (NSMutableDictionary* dataDic in peopleArray) {
                SearchPeopleData * searchData = [[SearchPeopleData alloc]init];
                searchData.followingStatus = [dataDic valueForKeyPath:@"DescribeSearchResultsByPeople.FollowingStatus"];
                searchData.profileUserCity = [dataDic valueForKeyPath:@"DescribeSearchResultsByPeople.ProfileUserCity"];
                searchData.profileUserEmail = [dataDic valueForKeyPath:@"DescribeSearchResultsByPeople.ProfileUserEmail"];
                searchData.profileUserFullName = [dataDic valueForKeyPath:@"DescribeSearchResultsByPeople.ProfileUserFullName"];
                searchData.profileUserProfilePicture = [dataDic valueForKeyPath:@"DescribeSearchResultsByPeople.ProfileUserProfilePicture"];
                searchData.profileUserUID = [dataDic valueForKeyPath:@"DescribeSearchResultsByPeople.ProfileUserUID"];
                searchData.profileUserName = [dataDic valueForKeyPath:@"DescribeSearchResultsByPeople.ProfileUsername"];
                searchData.userActCout = [dataDic valueForKeyPath:@"DescribeSearchResultsByPeople.UserActCount"];
                searchData.proximity = [dataDic valueForKeyPath:@"DescribeSearchResultsByPeople.proximity"];
                [pepoleListArray addObject:searchData];
            }
        }
    }
    
    if(pepoleListArray.count > 50) {
        shouldLoadMoreSearch = YES;
        [pepoleListArray removeLastObject];
    }
    
    [self.searchListArray addObjectsFromArray:pepoleListArray];
    
    backButton.userInteractionEnabled = YES;
    [WSModelClasses sharedHandler].loggedInUserModel.isInvitation = NO;
    
    if(pageLoadNumberSearch == 0) {
        [_peoplelistView reloadTableView:self.searchListArray];
    }
    else {
        [_peoplelistView loadMorePeople:pepoleListArray];
    }
}

- (void)removeTheSearchViewFromSuperview:(id)inSender
{
    [_headerView removeSubviewFromHedderView];
    _searchBarComponent.searchTxt.text = @"";
    
    [self.searchListArray removeAllObjects];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect peopleListFrame = _peoplelistView.frame;
    peopleListFrame.origin.y = 136.0f;
    peopleListFrame.size.height = CGRectGetHeight(screenRect) - CGRectGetMinY(peopleListFrame) - CGRectGetHeight(followAndInviteView.frame);
    [_peoplelistView setFrame:peopleListFrame];
    [_peoplelistView addHeaderViewForTable:_mediaListView];
    
    if(weRecommendBtn.isSelected == YES) {
        [WSModelClasses sharedHandler].loggedInUserModel.isInvitation = NO;
        [_peoplelistView reloadTableView:werecommendedList];
    }
    else {
        [WSModelClasses sharedHandler].loggedInUserModel.isInvitation = YES;
        [_peoplelistView reloadTableView:invitationList];
    }
    
    isSearching = YES;
    [_searchBarComponent.searchTxt resignFirstResponder];
    [self designHeaderView];

    [self showStatusView:YES];
}

- (void)showLoadView
{
    _loadingView = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:_loadingView];
    _loadingView.delegate = self;
    _loadingView.labelText = @"Loading";
    [_loadingView show:YES];
}

- (IBAction)followAndInviteActions:(id)sender
{
    if ([WSModelClasses sharedHandler].loggedInUserModel.isInvitation == YES) {
        [self inviteAllAction];
    }
    else {
        [self followAllAction];
    }
}

- (void)followAllAction
{
    [[WSModelClasses sharedHandler] followAllActionUserID:[[[WSModelClasses sharedHandler] loggedInUserModel].userID stringValue]
                                                followAll:YES
                                                rageValue:[NSString stringWithFormat:@"%ld", (long)pageLoadNumberRecommend]
                                                 responce:^(BOOL success, id responce) {
                                                     if (success) {
                                                         for(SearchPeopleData *peopleData in werecommendedList) {
                                                             peopleData.followingStatus = @"1";
                                                         }
                                                         
//                                                         [_peoplelistView reloadTableView:werecommendedList];
                                                         [_peoplelistView animateVisibleCellsStatusButton];
                                                         
                                                         [self showStatusView:NO];
                                                     }
                                                     else {
                                                         
                                                     }
                                                 }];
    
}

- (void)inviteAllAction
{
    [[WSModelClasses sharedHandler] inviteAllActionUserID:[[[WSModelClasses sharedHandler] loggedInUserModel].userID stringValue]
                                          inviteAllString:YES
                                                rageValue:[NSString stringWithFormat:@"%ld", (long)pageLoadNumberRecommend]
                                                 responce:^(BOOL success, id responce){
                                                     if (success) {
                                                         for(SearchPeopleData *peopleData in invitationList) {
                                                             peopleData.followingStatus = @"1";
                                                         }
                                                         
//                                                         [_peoplelistView reloadTableView:invitationList];
                                                         [_peoplelistView animateVisibleCellsStatusButton];
                                                         
                                                         [self showStatusView:NO];
                                                     }
                                                     else {
                                                         
                                                     }
                                                 }];
}

#pragma mark - DPeopleListComponentDelegate Method
- (void)loadNextPageOfPeopleList:(DPeopleListComponent *)peopleListComp
{
    if(isSearching == NO) {
        if(shouldLoadMoreSearch) {
            shouldLoadMoreSearch = NO;
            pageLoadNumberSearch += 1;
            [self fetchSearchPeopleForWord:_searchBarComponent.searchTxt.text];
        }
        return;
    }
    
    if ([WSModelClasses sharedHandler].loggedInUserModel.isInvitation == YES) {
        if(shouldLoadMoreInvite) {
            shouldLoadMoreInvite = NO;
            [self fetchInvitationList];
        }
    }
    else {
        if(shouldLoadMoreRecommend) {
            shouldLoadMoreRecommend = NO;
            [self fetchWerecommendList];
        }
    }
}

- (void)statusChange
{
    if(isSearching) {
        [self showStatusView:YES];
    }
}

- (void)peopleListView:(DPeopleListComponent *)listView didSelectedItemIndex:(NSUInteger)index
{
    if(self.isCommmingFromFeed == YES && ([WSModelClasses sharedHandler].loggedInUserModel.isInvitation == NO)) {
        SearchPeopleData *peopleDetail = nil;
        if(isSearching) {
            if(weRecommendBtn.isSelected) {
                peopleDetail = (SearchPeopleData *)werecommendedList[index];
            }
            else {
                peopleDetail = (SearchPeopleData *)invitationList[index];
            }
        }
        else {
            peopleDetail = (SearchPeopleData *)self.searchListArray[index];
        }
        
        DProfileDetailsViewController *profileController = [[DProfileDetailsViewController alloc] initWithNibName:@"DProfileDetailsViewController" bundle:nil];
        profileController.profileId = peopleDetail.profileUserUID;
        [self.navigationController pushViewController:profileController animated:YES];
    }
}

#pragma mark - Handle showing/hide of the bottom view (followUnfollowView)
- (void)showStatusView:(BOOL)showStatus
{
    if(isSearching) {  // do below steps when we are not in search view
        if([WSModelClasses sharedHandler].loggedInUserModel.isInvitation == NO) {
            int count = 0;
            for(SearchPeopleData *peopleDetail in werecommendedList) {
                if([peopleDetail.followingStatus isEqualToString:@"0"]) {
                    break;
                }
                
                count++;
            }
            
            if(count == werecommendedList.count) {
                showStatus = NO;
            }
        }
        else {
            int count = 0;
            for(SearchPeopleData *peopleDetail in invitationList) {
                if([peopleDetail.followingStatus isEqualToString:@"0"]) {
                    break;
                }
                
                count++;
            }
            
            if(count == invitationList.count) {
                showStatus = NO;
            }
        }
    }
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         CGRect frame = followAndInviteView.frame;
                         CGRect screenRect = [[UIScreen mainScreen] bounds];
                         frame.origin.y = showStatus ? (CGRectGetHeight(screenRect) - CGRectGetHeight(frame)) : CGRectGetHeight(screenRect);
                         
                         if(isSearching) {
                             CGRect peopleListFrame = _peoplelistView.frame;
                             if(showStatus == NO) {
                                 peopleListFrame.size.height = CGRectGetHeight(screenRect) - CGRectGetMinY(peopleListFrame);
                             }
                             else {
                                 peopleListFrame.size.height = CGRectGetHeight(screenRect) - CGRectGetMinY(peopleListFrame) - CGRectGetHeight(followAndInviteView.frame);
                             }
                             _peoplelistView.frame = peopleListFrame;
                         }
                         
                         followAndInviteView.frame = frame;
                     }
                     completion:nil];
}

@end
