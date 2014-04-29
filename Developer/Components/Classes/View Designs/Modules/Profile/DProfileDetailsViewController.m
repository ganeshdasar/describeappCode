//
//  DProfileDetailsViewController.m
//  Describe
//
//  Created by Aashish Raj on 2/15/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DProfileDetailsViewController.h"
#import "DPostListView.h"
#import "DPostView.h"
#import "DPost.h"
#import "DHeaderView.h"
#import "DSegmentViewList.h"
#import "DSegment.h"
#import "DUserData.h"
#import "DUserComponent.h"
#import "DPeopleListComponent.h"
#import "ProfileViewController.h"
#import "CMPhotoModel.h"

#define SEGMENTLIST_FRAME CGRectMake(0, 64, 320, 50)
#define SEGMENTLIST_FRAME_HIDDEN CGRectMake(0, 14, 320, 50)

@interface DProfileDetailsViewController ()<DSegementListViewDelegate, DPostListViewDelegate, DPeopleListDelegate, ProfileViewDelegate, DHeaderViewDelegate, WSModelClassDelegate>
{
    IBOutlet DHeaderView *_headerView;
    IBOutlet DPostListView *_listView;
    IBOutlet DPostView *_postView;
    IBOutlet DSegmentViewList *_segmentListView;
    
    NSMutableArray *_posts, *_followers, *_followings;
    BOOL _holdingFingerOnPostListView;
    BOOL _isSegmentControllerIsVisible;
    CGPoint _currentContentOffset;
    
    DPeopleListComponent *_followingList;
    DPeopleListComponent *_followersList;
    
    
    ProfileViewController *_profileController;
    
    
    
    NSArray *_postDetails;
    
    DPostListView *_listView2;
    IBOutlet UIView *_contentView;
    
    BOOL shouldLoadMorePosts;
    NSInteger pageNumberOfPosts;
    
    BOOL shouldLoadMoreFollowers;
    NSInteger pageNumberOfFollowers;
    
    BOOL shouldLoadMoreFollowings;
    NSInteger pageNumberOfFollowings;
}
@end

@implementation DProfileDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _profileController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        _profileController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib...
    shouldLoadMorePosts = NO;
    pageNumberOfPosts = 0;
    
    _posts = [[NSMutableArray alloc] initWithCapacity:0];
    _followers = [[NSMutableArray alloc] initWithCapacity:0];
    _followings = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self designHeaderView];
    [self fetchPostListView];
    [self designSegmentListView];
    
    _profileController.profileUserID = [NSNumber numberWithInteger:[self.profileId integerValue]];
    [self .view addSubview:_profileController.view];
    
    [self fetchUserModelForUserId:self.profileId];
}




- (void)fetchUserModelForUserId:(NSString *)userID
{
    [[WSModelClasses sharedHandler] setDelegate:self];
    [[WSModelClasses sharedHandler] getProfileDetailsForUserID:userID];
}

- (void)getTheUserProfileDataFromServer:(NSDictionary *)responceDict error:(NSError *)error
{
    if(error) {
        NSLog(@"%s error = %@", __func__, error.localizedDescription);
    }
    else {
        NSLog(@"%s responseDict = %@", __func__, responceDict);
        NSMutableDictionary *profileDict = [[NSMutableDictionary alloc] initWithDictionary:responceDict[@"UserProfile"] copyItems:YES];
        if(profileDict[@"ProfileCanvas"]) {
            [profileDict setObject:profileDict[@"ProfileCanvas"] forKey:USER_MODAL_KEY_PROFILECANVAS];
        }
        
        UsersModel *modelObj = [[UsersModel alloc] initWithDictionary:profileDict];
        [_profileController loadProfileDetails:responceDict];
        
        
        [_segmentListView setText:[[modelObj postCount] stringValue] forIndex:0];
        [_segmentListView setText:[[modelObj followingCount] stringValue] forIndex:1];
        [_segmentListView setText:[[modelObj followerCount] stringValue] forIndex:2];
   }
}


- (void)showPreviousScreen:(ProfileViewController *)profileViewController
{
    //move this screen to unvisible area to appear profile details...
   if(1)//Check the number of moves available here...
   {
       [self.navigationController popViewControllerAnimated:YES];
   }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect profileFrame = _profileController.view.frame;
            profileFrame.origin.x = +320;
            [_profileController.view setFrame:profileFrame];
//            _profileController.view.alpha = 1.0;
            [_profileController changeAplhaOfSubviewsForTransition:1.0];
            
        } completion:^(BOOL finished) {
            //Show profile details here...
        }];
    }
}

- (void)showNextScreen:(ProfileViewController *)profileViewController
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect profileFrame = _profileController.view.frame;
        profileFrame.origin.x = -320;
        [_profileController.view setFrame:profileFrame];
        
    } completion:^(BOOL finished) {
        //Show profile details here...
    }];
}

- (void)designSegmentListView
{
    NSMutableArray *segmentList = [[NSMutableArray alloc] init];
    {
        DSegment *segment = [[DSegment alloc] init];
        [segment setTitle:@"Posts"];
        [segment setSubTitle:@""];
        [segmentList addObject:segment];
    }
    {
        DSegment *segment = [[DSegment alloc] init];
        [segment setTitle:@"Following"];
        [segment setSubTitle:@""];
        [segmentList addObject:segment];
    }
    {
        DSegment *segment = [[DSegment alloc] init];
        [segment setTitle:@"Followers"];
        [segment setSubTitle:@""];
        [segmentList addObject:segment];
    }
    
    [_contentView bringSubviewToFront:_segmentListView];
    [_contentView bringSubviewToFront:_headerView];
    [_segmentListView setDelegate:self];
    [_segmentListView setSegments:segmentList];
    [_segmentListView designSegmentView];
    [_segmentListView selectSegmentAtIndex:0];
}

- (void)setProfileId:(NSString *)profileId
{
    _profileId = profileId;
    
    //Download the content of a profile id...
    
    
}

- (void)segmentViewDidSelected:(DSegmentView *)segmentView
{
   
  // [self designListView:_posts];
}

- (void)getPostDetailsResponse:(NSDictionary *)response withError:(NSError *)error
{
    [[WSModelClasses sharedHandler] removeLoadingView];
    
    NSArray *postList = response[@"DataTable"];
    NSLog(@"Post Details Reponse: %@",response);
    
    NSMutableArray *postModelList = [[NSMutableArray alloc] init];
    NSInteger count = [postList count];
    
    // here check if count is 11, then decrease count by1, since last object indicates that there are more posts which would be coming form server
    if(count == 11) {
        count -= 1;
        shouldLoadMorePosts = YES;
    }
    
    for (int i = 0; i < count; i++)
    {
        //Post lists...
        NSDictionary  *post = postList[i];
        NSDictionary *postData = post[@"PostData"];
        {
            NSDictionary *authUserDetails = postData[@"AuthUserDetails"];
            NSDictionary *postDetails = postData[@"PostDetails"];
            
            //Will bind the details with post view...
            DPost *postModel = [[DPost alloc] init];
            postModel.postId = postDetails[@"PostUID"];
            {
                DPostImage *imagePost = [[DPostImage alloc] init];
                {
                    //Binding photo models...
                    NSMutableArray *images = [[NSMutableArray alloc] init];
                    NSString *durations = postDetails[@"ImagesDuration"];
                    NSArray *durationList = nil;
                    if(durations != nil)
                    {
                        durationList = [durations componentsSeparatedByString:@","];
                    }
                    
                    //Will create and add each photo as model and adding them to the list.
                    NSInteger postImagesCount = [postDetails[@"PostImageCount"] integerValue];
                    postImagesCount = postImagesCount + 1;
                    //postImagesCount = 10;
                    
                    
                    for (int j=1; j<postImagesCount; j++)
                    {
                        NSString *imageUrl = postDetails[[NSString stringWithFormat:@"Image%d",j]];
                        if(imageUrl== nil || !imageUrl.length)
                            break;
                        
                        
                        CMPhotoModel *photoModel = [[CMPhotoModel alloc] init];
                        [photoModel setImageUrl:imageUrl];
                        [photoModel setImageUrl:[NSString stringWithFormat:@"http://mirusstudent.com/service/postimages/%@",postDetails[[NSString stringWithFormat:@"Image%d",j]]]];
                        
                        [photoModel setDuration:[durationList[j-1]integerValue]];
                        [images addObject:photoModel];
                    }
                    [imagePost setImages:images];
                    
                    
                    //Binding video to the post...
                    DPostVideo *video = [[DPostVideo alloc] init];
                    [video setDuration:@"10"];
                    [video setUrl:postDetails[@"VideoFile"]];
                    [video setUrl:[NSString stringWithFormat:@"http://mirusstudent.com/service/postimages/%@",postDetails[@"VideoFile"]]];
                    
                    [imagePost setVideo:video];
                    
                    [postModel setElapsedTime:postDetails[@"ElapsedTime"]];
                }
                
                //Binding the user details...
                DUser *user = [[DUser alloc] init];
                {
                    [user setUserId:authUserDetails[@"AuthUserUID"]];
                    [user setName:authUserDetails[@"Username"]];
                    [user setAddress:postDetails[@"PostLocation"]];
                    [user setUserCanvasImage:[NSString stringWithFormat:@"http://mirusstudent.com/service/postimages/%@",authUserDetails[@"UserCanvasImage"]]];
                    [user setUserCanvasSnippet:[NSString stringWithFormat:@"http://mirusstudent.com/service/postimages/%@",authUserDetails[@"UserCanvasSnippet"]]];
                    [user setUserProfilePicture:[NSString stringWithFormat:@"http://mirusstudent.com/service/postimages/%@",authUserDetails[@"UserProfilePicture"]]];
                }
                
                //The post model here...
                [postModel setImagePost:imagePost];
                [postModel setUser:user];
            }
            
            
            //The footer content added here....
            {
                NSMutableArray *tags = [[NSMutableArray alloc] init];
                if(postDetails[@"Tag1"] != nil && [(NSString *)postDetails[@"Tag1"] length])
                {
                    DPostTag *postTag = [[DPostTag alloc] init];
                    [postTag setTagId:@""];
                    [postTag setTagName:postDetails[@"Tag1"]];
                    [tags addObject:postTag];
                }
                
                if(postDetails[@"Tag2"] != nil && [(NSString *)postDetails[@"Tag2"] length])
                {
                    DPostTag *postTag = [[DPostTag alloc] init];
                    [postTag setTagId:@""];
                    [postTag setTagName:postDetails[@"Tag2"]];
                    [tags addObject:postTag];
                }
                
                DPostAttachments *attachements = [[DPostAttachments alloc] init];
                [attachements setLikeRating:[postDetails[@"PostRating"] integerValue]];
                [attachements setNumberOfComments:[postDetails[@"PostImageCount"] integerValue]];
                [attachements setNumberOfLikes:[postDetails[@"PostLikeCount"] integerValue]];
                [attachements setTagsList:tags];
                [postModel setAttachements:attachements];
            }
            
            
            [postModelList addObject:postModel];
        }
    }
    
    _postDetails = postModelList;
    if(pageNumberOfPosts == 0) {
        [_posts removeAllObjects];
    }

    [_posts addObjectsFromArray:postModelList];

    if(_listView == nil) {
        _listView = [[DPostListView alloc] initWithFrame:_postView.frame andPostsList:postModelList withHeaderView:[[UIView alloc] init]];
        [_listView setDelegate:self];
        [_contentView addSubview:_listView];
    }
    
    if([_listView superview] != nil) {
        [_contentView bringSubviewToFront:_segmentListView];
        [_contentView bringSubviewToFront:_headerView];
        if(pageNumberOfPosts == 0) {
            [_listView reloadData:postModelList];
        }
        else {
            [_listView appendMorePosts:postModelList];
        }
    }
    
    //[_contentView sendSubviewToBack:_listView];
    
    //[[self segmentViewDidSelected:nil atIndex:[NSNumber numberWithInt:1]];
    //[self addNewObserverForDelegateProfileDetails];
    
}

- (void)segmentViewDidSelected:(DSegmentView *)segmentView atIndex:(NSNumber *)index
{
    NSInteger indexx = [index integerValue];
    switch (indexx) {
        case 0:
        {
            [self removeViewFromSuperView:_followersList];
            [self removeViewFromSuperView:_followingList];
            if(_posts.count == 0) {
                [self fetchPostListView];
            }
            else {
                [self designListView:_posts];
            }
            
            break;
        }
            
        case 1:
        {
            [self removePostsListView];
            [self removeViewFromSuperView:_followersList];
            if(_followings.count == 0) {
                [self getFollowingList];
            }
            else {
                [self designFollowingList];
            }
            break;
        }
            
        case 2:
        {
            [self removePostsListView];
            [self removeViewFromSuperView:_followingList];
            if(_followers.count == 0) {
                [self getFollowersList];
            }
            else {
                [self desingFollwerList];
            }

            break;
        }
            
        default:
            break;
    }
    
    [_contentView bringSubviewToFront:_segmentListView];
    [_contentView bringSubviewToFront:_headerView];
}

- (void)removePostsListView
{
    if(_listView != nil) {
        [_listView removeFromSuperview];
        _listView = nil;
    }
}

- (void)removeViewFromSuperView:(UIView *)view
{
    if(view != nil) {
        [view removeFromSuperview];
        view = nil;
    }
}

- (void)designHeaderView
{
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton setTag:HeaderButtonTypePrev];
    [_headerView setDelegate:self];
    [_headerView designHeaderViewWithTitle:@"Profile" andWithButtons:@[backButton]];
}

- (void)headerView:(DHeaderView *)headerView didSelectedHeaderViewButton:(UIButton *)headerButton
{
    HeaderButtonType buttonType = headerButton.tag;
    switch (buttonType) {
        case HeaderButtonTypePrev:
        {
            [UIView animateWithDuration:0.5 animations:^{
                CGRect profileFrame = _profileController.view.frame;
                profileFrame.origin.x = 0;
                [_profileController.view setFrame:profileFrame];
//                _profileController.view.alpha = 1.0;
                [_profileController changeAplhaOfSubviewsForTransition:1.0];

            } completion:^(BOOL finished) {
                //Show profile details here...
            }];
        }
            break;
            
        default:
            break;
    }
}

- (NSArray *)parseFollowingsList:(NSDictionary *)response
{
    if(response == nil) return nil;
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    NSArray *peopleList = response[@"DataTable"];
    NSInteger count = peopleList.count;
    
    if(count == 51) {
        count -= 1;
        shouldLoadMoreFollowings = YES;
    }
    
    BOOL peopleListAvailable = YES;
    if (peopleList.count == 1) {
        NSDictionary *dict = peopleList[0];
        if([dict valueForKeyPath:@"DescribeUserProfileFollowings.Msg"] && [[dict valueForKeyPath:@"DescribeUserProfileFollowings.Msg"] isEqualToString:@"0 Followings on this User."]) {
            peopleListAvailable = NO;
        }
    }
    
    if(peopleListAvailable) {
        for (int i=0; i<count; i++) {
            NSDictionary *dict = peopleList[i];
            NSDictionary *people = dict[@"DescribeUserProfileFollowings"];
            SearchPeopleData *peopleInfo = [[SearchPeopleData alloc] initWithDictionary:people];
            [list addObject:peopleInfo];
        }
    }
    
    return list;
}

- (NSArray *)parseFollowersList:(NSDictionary *)response
{
    if(response == nil) return nil;
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    NSArray *peopleList = response[@"DataTable"];
    NSInteger count = peopleList.count;
    
    if(count == 51) {
        count -= 1;
        shouldLoadMoreFollowers = YES;
    }
    
    BOOL peopleListAvailable = YES;
    if (peopleList.count == 1) {
        NSDictionary *dict = peopleList[0];
        if([dict valueForKeyPath:@"DescribeUserProfileFollowers.Msg"] && [[dict valueForKeyPath:@"DescribeUserProfileFollowers.Msg"] isEqualToString:@"0 Posts on this User."]) {
            peopleListAvailable = NO;
        }
    }
    
    if(peopleListAvailable) {
        for (int i=0; i<count; i++) {
            NSDictionary *dict = peopleList[i];
            NSDictionary *people = dict[@"DescribeUserProfileFollowers"];
            SearchPeopleData *peopleInfo = [[SearchPeopleData alloc] initWithDictionary:people];
            [list addObject:peopleInfo];
        }
    }
    
    return list;
}

- (void)peopleListView:(DPeopleListComponent *)listView didSelectedItemIndex:(NSUInteger)index
{
    if(listView.tag ==  111) { //Following list...
        //Navigate the contentview and _profileviewController2 to unvisible and visible...
        SearchPeopleData *userDetail = _followings[index];
        NSString *profileId = userDetail.profileUserUID;
        
        DProfileDetailsViewController *profileC = [[DProfileDetailsViewController alloc] initWithNibName:@"DProfileDetailsViewController" bundle:nil];
        [profileC setProfileId:profileId];
        [self.navigationController pushViewController:profileC animated:YES];
    }
    else { //Followers list...
        SearchPeopleData *userDetail = _followers[index];
        NSString *profileId = userDetail.profileUserUID;
        
        DProfileDetailsViewController *profileC = [[DProfileDetailsViewController alloc] initWithNibName:@"DProfileDetailsViewController" bundle:nil];
        profileC.profileId = profileId;
        [self.navigationController pushViewController:profileC animated:YES];
    }
}

- (void)getFollowingList
{
    NSString *currentUserId = [[[[WSModelClasses sharedHandler] loggedInUserModel] userID] stringValue];
    NSString *profileId = self.profileId;
//    NSInteger pageNumber = 0;
    
    [[WSModelClasses sharedHandler] showLoadView];
    [[WSModelClasses sharedHandler] getFollowingListForUserId:currentUserId ofPersons:profileId pageNumber:pageNumberOfFollowings response:^(BOOL success, id response) {
        [[WSModelClasses sharedHandler] removeLoadingView];
        if(success) {
            //Need to parse the data...
            NSLog(@"Follwing List:%@",response);
            NSArray *parsedList = [self parseFollowingsList:response];
            if(pageNumberOfFollowings == 0) {
                [_followings removeAllObjects];
            }
            [_followings addObjectsFromArray:parsedList];
            
            if(_followingList == nil)
            {
                _followingList = [[DPeopleListComponent alloc] initWithFrame:_postView.frame andPeopleList:_followings];
                [_followingList addHeaderViewForTable:[[UIView alloc] init]];
                [_followingList setDelegate:self];
                [_followingList setTag:111];
                [_contentView addSubview:_followingList];
            }
            
            if([_followingList superview] != nil) {
                if(pageNumberOfFollowings == 0) {
                    [_followingList reloadTableView:_followings];
                }
                else {
                    [_followingList loadMorePeople:parsedList];
                }
                
                [_contentView bringSubviewToFront:_segmentListView];
                [_contentView bringSubviewToFront:_headerView];
            }
//            [self designFollowingList];
        }
        else {
            //Failed to get the details of the following list...
            NSLog(@"Failed to get the followings list:%@",response);
        }
    }];
}

- (void)getFollowersList
{
    NSString *currentUserId = [[[[WSModelClasses sharedHandler] loggedInUserModel] userID] stringValue];
    NSString *profileId = self.profileId;
//    NSInteger pageNumber = 0;
    
    [[WSModelClasses sharedHandler] showLoadView];
    [[WSModelClasses sharedHandler] getFollowersListForUserId:currentUserId ofPersons:profileId pageNumber:pageNumberOfFollowers response:^(BOOL success, id response) {
        [[WSModelClasses sharedHandler] removeLoadingView];
        if(success) {
            //Need to parse the data...
            NSLog(@"Followers List:%@",response);
            NSArray *parsedList = [self parseFollowersList:response];
            if(pageNumberOfFollowers == 0) {
                [_followers removeAllObjects];
            }
            [_followers addObjectsFromArray:parsedList];
            
            if(_followersList == nil)
            {
                _followersList = [[DPeopleListComponent alloc] initWithFrame:_postView.frame andPeopleList:_followers];
                [_followersList addHeaderViewForTable:[[UIView alloc] init]];
                [_followersList setDelegate:self];
                [_contentView addSubview:_followersList];
            }
            
            if([_followersList superview] != nil) {
                if(pageNumberOfFollowers == 0) {
                    [_followersList reloadTableView:_followers];
                }
                else {
                    [_followersList loadMorePeople:parsedList];
                }
                
                [_contentView bringSubviewToFront:_segmentListView];
                [_contentView bringSubviewToFront:_headerView];
            }

//            [self desingFollwerList];
        }
        else {
            //Failed to get the details of the following list...
            NSLog(@"Failed to get the follwers list:%@",response);
        }
    }];
}

- (void)designFollowingList
{
//    if(_followingList != nil)
//    {
//        [_followingList removeFromSuperview];
//        _followingList = nil;
//    }
    
    if(_followingList == nil)
    {
        _followingList = [[DPeopleListComponent alloc] initWithFrame:_postView.frame andPeopleList:_followings];
        [_followingList addHeaderViewForTable:[[UIView alloc] init]];
        [_followingList setDelegate:self];
        [_followingList setTag:111];
    }
    
    if([_followingList superview] == nil) {
        [_contentView addSubview:_followingList];
    }
    
    [_followingList reloadTableView:_followings];
    
    [_contentView bringSubviewToFront:_segmentListView];
    [_contentView bringSubviewToFront:_headerView];
}

- (void)desingFollwerList
{
//    if(_followersList != nil)
//    {
//        [_followersList removeFromSuperview];
//        _followersList = nil;
//    }
//    
    if(_followersList == nil)
    {
        _followersList = [[DPeopleListComponent alloc] initWithFrame:_postView.frame andPeopleList:_followers];
        [_followersList addHeaderViewForTable:[[UIView alloc] init]];
        [_followersList setDelegate:self];
    }
    
    if([_followersList superview] == nil) {
        [_contentView addSubview:_followersList];
    }
    
    [_followersList reloadTableView:_followers];
    
    [_contentView bringSubviewToFront:_segmentListView];
    [_contentView bringSubviewToFront:_headerView];
}

- (void)fetchPostListView
{
    WSModelClasses *sharedInstance = [WSModelClasses sharedHandler];
    [sharedInstance setDelegate:self];
    [sharedInstance showLoadView];
    
    [sharedInstance getPostDetailsOfUserId:[[[WSModelClasses sharedHandler] loggedInUserModel].userID stringValue] anotherUserId:self.profileId pageNumber:pageNumberOfPosts response:^(BOOL success, id response) {
        if(success)
        {
            //Success the ...
            [self getPostDetailsResponse:response withError:nil];
        }
        else
        {
            [self getPostDetailsResponse:nil withError:response];
        }
    }];
}

- (void)designListView:(NSArray *)array
{
    if(_listView == nil)
    {
        _listView = [[DPostListView alloc] initWithFrame:_postView.frame andPostsList:array withHeaderView:[[UIView alloc] init]];
        [_listView setDelegate:self];
    }
    
    if([_listView superview] == nil) {
        [_contentView addSubview:_listView];
    }
    
    [_listView reloadData:array];
}

#pragma mark - DPostListViewDelegate Methods
- (void)loadNextPageOfPost:(DPostListView *)postListView
{
    if(shouldLoadMorePosts) {
        shouldLoadMorePosts = NO;
        pageNumberOfPosts += 1;
        
        [self fetchPostListView];
    }
}

#pragma mark - DPeopleListComponentDelegate Methods
- (void)loadNextPageOfPeopleList:(DPeopleListComponent *)peopleListComp
{
    if(peopleListComp == _followersList) {
        if(shouldLoadMoreFollowers) {
            shouldLoadMoreFollowers = NO;
            pageNumberOfFollowers += 1;
            
            [self getFollowersList];
        }
    }
    else {
        if(shouldLoadMoreFollowings) {
            shouldLoadMoreFollowings = NO;
            pageNumberOfFollowings += 1;
            
            [self getFollowingList];
        }
    }
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollView:(UIScrollView *)scrollView didHoldingFinger:(NSString *)finger
{
    if([finger isEqualToString:@"HOLDING"]) {
        _holdingFingerOnPostListView = YES;
    }
    else {
        _holdingFingerOnPostListView = NO;
    }
    _currentContentOffset = scrollView.contentOffset;

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _currentContentOffset = scrollView.contentOffset;
}

- (void)scrollView:(UIScrollView *)scrollView scrollingDirection:(NSString *)direction
{
    if(!_holdingFingerOnPostListView)
        return;
    
    CGPoint contentOffset = scrollView.contentOffset;
    
    if([direction isEqualToString:@"UP"])
    {
        int yPosition = contentOffset.y;
        if(yPosition >= 0)
        {
            //unhide the segment...
            if(contentOffset.y > 50)
            {
                if((_segmentListView.frame.origin.y >= 14))
                {
                    float diff = contentOffset.y - _currentContentOffset.y;
                    NSLog(@"Diff:%f",diff);
                    if(diff > 0)
                    {
                        [UIView animateWithDuration:0.15 animations:^{[_segmentListView setFrame:SEGMENTLIST_FRAME_HIDDEN];} completion:^(BOOL finished)
                         {
                         }];
                        _isSegmentControllerIsVisible = NO;

                    }
                }
            }
            else
            {
                
                    CGRect segmentFrame = _segmentListView.frame;
                    segmentFrame.origin.y = SEGMENTLIST_FRAME.origin.y - contentOffset.y;
                    [_segmentListView setFrame:segmentFrame];
                
            }
        }
    }
    else        
    {
        
        CGSize contentSize = scrollView.contentSize;
        if(contentSize.height > (contentOffset.y + scrollView.bounds.size.height))
        {
            if(!(_segmentListView.frame.origin.y == 64.0))
            {
                [UIView animateWithDuration:0.15 animations:^{[_segmentListView setFrame:SEGMENTLIST_FRAME];} completion:^(BOOL finished)
                 {
                 }];
                
            }
        }
        
    }
}

- (void)userProfileSelectedForPost:(DPost *)post
{
    DUser *user = [post user];
    NSLog(@"user profile id:%@", user.userId);
    DProfileDetailsViewController *profileDetailsController = [[DProfileDetailsViewController alloc] initWithNibName:@"DProfileDetailsViewController" bundle:nil];
    profileDetailsController.profileId = user.userId;
    [self.navigationController pushViewController:profileDetailsController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
