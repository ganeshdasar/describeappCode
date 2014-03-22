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


@interface DescAddpeopleViewController ()<DSearchBarComponentDelegate,WSModelClassDelegate>
{
    IBOutlet DHeaderView *_headerView;
    UIButton    *backButton,*nextButton;
    UIButton    *weRecommendBtn,*invitationsBtn;
    UIButton     *facebookBtn,*googlePlusBtn;
    WSModelClasses * serviceClass;

    IBOutlet DPeopleListComponent *_peoplelistView;
    IBOutlet DSegmentComponent * _segmentComponent;
    IBOutlet DSearchBarComponent * _searchBarComponent;
    IBOutlet DSocialComponent * socialComponent;
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
    // Do any additional setup after loading the view from its nib.
}
//HeadderView
-(void)designHeaderView
{
    //back button
    backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goToBack:) forControlEvents:UIControlEventTouchUpInside];
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
    [_segmentComponent designSegmentControllerWithButtons:@[weRecommendBtn,invitationsBtn]];
}
//Social Component
-(void)designSocialComponent{
    facebookBtn = [[UIButton alloc]init];
    [facebookBtn setBackgroundImage:[UIImage imageNamed:@"btn_3rd_fb_nc.png"] forState:UIControlStateNormal];
    [facebookBtn setBackgroundImage:[UIImage imageNamed:@"btn_3rd_fb_on.png"] forState:UIControlStateSelected];
    facebookBtn.selected = NO;
    [facebookBtn addTarget:self action:@selector(requestToFaceboookForFriendsList:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    googlePlusBtn = [[UIButton alloc]init];
    [googlePlusBtn setBackgroundImage:[UIImage imageNamed:@"btn_3rd_goog_nc.png"] forState:UIControlStateNormal];
    [googlePlusBtn addTarget:self action:@selector(requestToGooglePlusForFriendsList:) forControlEvents:UIControlEventTouchUpInside];
    [googlePlusBtn setBackgroundImage:[UIImage imageNamed:@"btn_3rd_goog_on.png"] forState:UIControlStateSelected];
    googlePlusBtn.selected =NO;
    [socialComponent  designSocialNetworkConnectionsWithButtons:@[facebookBtn,googlePlusBtn]];
    
}

- (void)goToFeedScreen:(UIButton*)inButton
{
//    ProfileViewController *profileController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
//    profileController.profileUserID = [NSNumber numberWithInteger:45];
//    [self.navigationController pushViewController:profileController animated:YES];
//    
//    return;
    [[WSModelClasses  sharedHandler] getTheGenaralFeedServices:@"" andPageValue:@""];
    
    
    DPostsViewController *postViewController = [[DPostsViewController alloc] initWithNibName:@"DPostsViewController" bundle:nil];
    [self.navigationController pushViewController:postViewController animated:YES];
    
    
}

#pragma mark SegmentView Actions
-(void)getTheWeRecommendDataFromServer:(UIButton*)inSender{
    inSender.selected =YES;
    invitationsBtn.selected =NO;
    
  //  NSLog(@"werecommeded selected ");
}
-(void)getTheInvitationsDataFromServer:(UIButton*)inSender{
    inSender.selected =YES;
    weRecommendBtn.selected = NO;
  //  NSLog(@"invitations selected ");

    
    
    
}
#pragma mark Socialnetwork actions

-(void)requestToFaceboookForFriendsList:(UIButton*)inSender{
    inSender.selected = YES;
    
    
}
-(void)requestToGooglePlusForFriendsList:(UIButton*)inSender{
    
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
    
    [[WSModelClasses sharedHandler]getWeRecommendedpeople:(NSString*)[WSModelClasses sharedHandler].loggedInUserModel.userID AndRange:@"0"];
    [WSModelClasses sharedHandler].delegate = self;
}


- (void)didFinishWSConnectionWithResponse:(NSDictionary *)responseDict
{
    WebservicesType serviceType = (WebservicesType)[responseDict[WS_RESPONSEDICT_KEY_SERVICETYPE] integerValue];
    if(responseDict[WS_RESPONSEDICT_KEY_ERROR]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Describe", @"") message:NSLocalizedString(@"Error while communicating to server. Please try again later.", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    switch (serviceType) {
        case kWebserviesType_addPeople:
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
        data.profileUserEmail = [dic valueForKeyPath:@"DescribeSuggestedUsers.UserEmail"];
        data.profileUserFullName = [dic valueForKeyPath:@"DescribeSuggestedUsers.UserFullName"];
        data.profileUserProfilePicture = [dic valueForKeyPath:@"DescribeSuggestedUsers.UserProfilePicture"];
        data.profileUserUID = [dic valueForKeyPath:@"DescribeSuggestedUsers.UserUID"];
        data.profileUserName = [dic valueForKeyPath:@"DescribeSuggestedUsers.Username"];
        [peopleArray addObject:data];
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    _peoplelistView = [[DPeopleListComponent alloc]initWithFrame:CGRectMake(0, 200, 320, screenRect.size.height-108) andPeopleList:(NSArray*)peopleArray];
    [self.view addSubview:_peoplelistView];

    
}

-(void)addSearchBarView{
    isSearching = YES;
    [_searchBarComponent designSerachBar];
    _searchBarComponent.searchDelegate =self;
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

        _peoplelistView = [[DPeopleListComponent alloc]initWithFrame:CGRectMake(0, 110, 320, screenRect.size.height-108) andPeopleList:nil];
        [self.view addSubview:_peoplelistView];
    }else{
        if ([searchBar.searchTxt.text length]!=0) {
            [modelClass getSearchDetailsUserID:@"1" searchType:nil  searchWord:searchBar.searchTxt.text];
            
        }
    }
   
  
}

#pragma mark serachResult
- (void)getSearchDetails:(NSDictionary *)responseDict error:(NSError *)error{
    NSArray * peopleArray = [responseDict valueForKey:@"DataTable"];
    self.searchListArray = [[NSMutableArray alloc]init];
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
        [self.searchListArray addObject:searchData];
    }
    [_peoplelistView reloadTableView:self.searchListArray];
    
}

-(void)removeTheSearchViewFromSuperview:(id)inSender{
    [_headerView removeSubviewFromHedderView];
    [_peoplelistView removeFromSuperview];
    _searchBarComponent.searchTxt.text =@"";
    [_peoplelistView._peopleList removeAllObjects];
    [_searchBarComponent.searchTxt resignFirstResponder];
    [self designHeaderView];
}


@end
