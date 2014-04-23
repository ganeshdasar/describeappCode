//
//  DesSearchPeopleViewContrlooerViewController.m
//  Describe
//
//  Created by NuncSys on 08/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DesSearchPeopleViewContrlooerViewController.h"
#import "DHeaderView.h"
#import "DSearchBarComponent.h"
#import "WSModelClasses.h"
#import "DUserData.h"
#import "DProfileDetailsViewController.h"


#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

@interface DesSearchPeopleViewContrlooerViewController ()<DSearchBarComponentDelegate, WSModelClassDelegate, DPeopleListDelegate>
{
    IBOutlet DHeaderView *_headerView;
    UIButton * backButton;
    IBOutlet DSearchBarComponent * _searchBarComponent;

    BOOL shouldLoadMoreForSearch;
    NSInteger pageLoadNumberForSearch;
}

@end

@implementation DesSearchPeopleViewContrlooerViewController
@synthesize _peoplelistView;
@synthesize searchListArray;
@synthesize backGroundImg;

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
    
    shouldLoadMoreForSearch = NO;
    pageLoadNumberForSearch = 0;
    searchListArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self designSerchList];
    [self designHeadderView];
    [self addSearchBar];
    self.view.backgroundColor =[UIColor clearColor];
    if (isiPhone5)
    {
        self.backGroundImg.image = [UIImage imageNamed:@"bg_std_4in.png"];
    }
    else
    {
        self.backGroundImg.image = [UIImage imageNamed:@"bg_std_3.5in.png"];
        
        //Iphone  3.5 inch
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)designSerchList
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self._peoplelistView = [[DPeopleListComponent alloc]initWithFrame:CGRectMake(0, _peoplelistView.frame.origin.y, 320, screenRect.size.height-108) andPeopleList:nil];
    [self._peoplelistView setDelegate:self];
    [_peoplelistView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self._peoplelistView];
}

- (void)designHeadderView
{
    backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(removeTheSearchViewFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [_headerView designHeaderViewWithTitle:@"Search" andWithButtons:@[backButton]];
}

- (void)addSearchBar
{
    [_searchBarComponent designSerachBar];
    _searchBarComponent.searchDelegate =self;
    [_searchBarComponent setBackgroundColor:[UIColor whiteColor]];
}

- (void)searchBarSearchButtonClicked:(DSearchBarComponent *)searchBar
{
    if ([searchBar.searchTxt.text length]!=0) {
        shouldLoadMoreForSearch = NO;
        pageLoadNumberForSearch = 0;
        [self fetchPeopleWithSearchWord:searchBar.searchTxt.text];
    }
}

- (void)fetchPeopleWithSearchWord:(NSString *)searchWord
{
    backButton.userInteractionEnabled = NO;
    
    WSModelClasses * modelClass = [WSModelClasses sharedHandler];
    modelClass.delegate = self;
    
    [modelClass showLoadView];
    [modelClass getSearchDetailsUserID:[[modelClass loggedInUserModel].userID stringValue] searchWord:searchWord range:pageLoadNumberForSearch];
}

- (void)loadNextPageOfPeopleList:(DPeopleListComponent *)peopleListComp
{
    if(shouldLoadMoreForSearch == YES) {
        shouldLoadMoreForSearch = NO;
        pageLoadNumberForSearch += 1;
        [self fetchPeopleWithSearchWord:_searchBarComponent.searchTxt.text];
    }
}

#pragma mark serachResult
- (void)getSearchDetails:(NSDictionary *)responseDict error:(NSError *)error
{
    [[WSModelClasses sharedHandler] removeLoadingView];
    if(responseDict == nil) {
        return;
    }
    
    if(pageLoadNumberForSearch == 0) {
        [searchListArray removeAllObjects];
    }
    
    NSArray * peopleArray = [responseDict valueForKey:@"DataTable"];
    
    NSMutableArray *pepoleListArray = [[NSMutableArray alloc] init];
    
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
    
    if(pepoleListArray.count > 50) {
        shouldLoadMoreForSearch = YES;
        [pepoleListArray removeLastObject];
    }
    
    [self.searchListArray addObjectsFromArray:pepoleListArray];
    
    backButton.userInteractionEnabled = YES;
    
    if(pageLoadNumberForSearch == 0) {
        [_peoplelistView reloadTableView:self.searchListArray];
    }
    else {
        [_peoplelistView loadMorePeople:pepoleListArray];
    }
}

- (void)removeTheSearchViewFromSuperview
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"refreshTheView"
     object:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)peopleListView:(DPeopleListComponent *)listView didSelectedItemIndex:(NSUInteger)index
{
    SearchPeopleData *people = self.searchListArray[index];    
    DProfileDetailsViewController *profileDetailViewController = [[DProfileDetailsViewController alloc] initWithNibName:@"DProfileDetailsViewController" bundle:nil];
    profileDetailViewController.profileId = people.profileUserUID;
    [self.navigationController pushViewController:profileDetailViewController animated:YES];
}

@end
