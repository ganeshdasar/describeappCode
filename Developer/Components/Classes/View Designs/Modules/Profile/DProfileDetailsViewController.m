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
    
    NSArray *_posts, *_followers, *_followings;
    BOOL _holdingFingerOnPostListView;
    BOOL _isSegmentControllerIsVisible;
    CGPoint _currentContentOffset;
    
    DPeopleListComponent *_followingList;
    DPeopleListComponent *_followersList;
    
    
    ProfileViewController *_profileController;
    
    
    
    NSArray *_postDetails;
    
    ProfileViewController *_profileController2;
    DPostListView *_listView2;
    IBOutlet UIView *_contentView;
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
    [self designHeaderView];
    [self designPostListView];
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


-(void)showPreviousScreen:(ProfileViewController *)profileViewController
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
            
        } completion:^(BOOL finished) {
            //Show profile details here...
        }];
    }
}

-(void)showNextScreen:(ProfileViewController *)profileViewController
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect profileFrame = _profileController.view.frame;
        profileFrame.origin.x = -320;
        [_profileController.view setFrame:profileFrame];
        
    } completion:^(BOOL finished) {
        //Show profile details here...
    }];
}

-(void)designSegmentListView
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

-(void)setProfileId:(NSString *)profileId
{
    _profileId = profileId;
    
    //Download the content of a profile id...
    
    
}

-(void)segmentViewDidSelected:(DSegmentView *)segmentView
{
   
  // [self designListView:_posts];
}

-(void)getPostDetailsResponse:(NSDictionary *)response withError:(NSError *)error
{
    NSArray *postList = response[@"DataTable"];
    NSLog(@"Post Details Reponse: %@",response);
    
    NSMutableArray *postModelList = [[NSMutableArray alloc] init];
    int count = [postList count] ;
    for (int  i=0; i<count; i ++ )
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
                    int postImagesCount = [postDetails[@"PostImageCount"] integerValue];
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
    _posts= postModelList;
    _listView = [[DPostListView alloc] initWithFrame:_postView.frame andPostsList:postModelList withHeaderView:[[UIView alloc] init]];
    [_listView setDelegate:self];
    [_contentView addSubview:_listView];
    [_contentView bringSubviewToFront:_segmentListView];
    [_contentView bringSubviewToFront:_headerView];
    //[_contentView sendSubviewToBack:_listView];
    
    //[[self segmentViewDidSelected:nil atIndex:[NSNumber numberWithInt:1]];
    //[self addNewObserverForDelegateProfileDetails];
    
}

-(void)segmentViewDidSelected:(DSegmentView *)segmentView atIndex:(NSNumber *)index
{
    int indexx = [index integerValue];
    switch (indexx) {
        case 0:
            [self removeViewFromSuperView:_followersList];
            [self removeViewFromSuperView:_followingList];
            [self designListView:_posts];
            break;
        case 1:
            [self removePostsListView];
            [self removeViewFromSuperView:_followersList];
            [self getFollowingList];
            break;
        case 2:
            [self removePostsListView];
            [self removeViewFromSuperView:_followingList];
            [self getFollowersList];

            break;
            
        default:
            break;
    }
    
    [_contentView bringSubviewToFront:_segmentListView];
    [_contentView bringSubviewToFront:_headerView];
}
-(void)removePostsListView
{
    
    
    
    if(_listView != nil)
    {
        [_listView removeFromSuperview];
        _listView = nil;
    }
}


-(void)removeViewFromSuperView:(UIView *)view
{
    if(view != nil)
    {
        [view removeFromSuperview];
        view = nil;
    }
}

-(void)designHeaderView
{
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_back.png"] forState:UIControlStateNormal];
    [backButton setTag:HeaderButtonTypePrev];
    [_headerView setDelegate:self];
    [_headerView designHeaderViewWithTitle:@"Profile" andWithButtons:@[backButton]];
}

-(void)headerView:(DHeaderView *)headerView didSelectedHeaderViewButton:(UIButton *)headerButton
{
    HeaderButtonType buttonType = headerButton.tag;
    switch (buttonType) {
        case HeaderButtonTypePrev:
        {
            [UIView animateWithDuration:0.5 animations:^{
                CGRect profileFrame = _profileController.view.frame;
                profileFrame.origin.x = 0;
                [_profileController.view setFrame:profileFrame];
                
            } completion:^(BOOL finished) {
                //Show profile details here...
            }];
        }
            break;
            
        default:
            break;
    }
}

-(NSArray *)parseFollowingsList:(NSDictionary *)response
{
    if(response == nil) return nil;
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    NSArray *peopleList = response[@"DataTable"];
    NSInteger count = peopleList.count;
    for (int i=0; i<count; i++)
    {
        NSDictionary *dict = peopleList[i];
        NSDictionary *people = dict[@"DescribeUserProfileFollowings"];
        SearchPeopleData *peopleInfo = [[SearchPeopleData alloc] initWithDictionary:people];
        [list addObject:peopleInfo];
    }
    
    
    return list;
}


-(NSArray *)parseFollowersList:(NSDictionary *)response
{
    if(response == nil) return nil;
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    NSArray *peopleList = response[@"DataTable"];
    NSInteger count = peopleList.count;
    for (int i=0; i<count; i++)
    {
        NSDictionary *dict = peopleList[i];
        NSDictionary *people = dict[@"DescribeUserProfileFollowers"];
        SearchPeopleData *peopleInfo = [[SearchPeopleData alloc] initWithDictionary:people];
        [list addObject:peopleInfo];
    }
    
    return list;
}



-(void)designFollowingList
{
    if(_followingList != nil)
    {
        [_followingList removeFromSuperview];
        _followingList = nil;
    }
    
    if(_followingList == nil)
    {
        _followingList = [[DPeopleListComponent alloc] initWithFrame:_postView.frame andPeopleList:_followings];
        [_followingList addHeaderViewForTable:[[UIView alloc] init]];
        [_followingList setDelegate:self];
        [_followingList setTag:111];
        [_contentView addSubview:_followingList];
    }
    
    [_contentView bringSubviewToFront:_segmentListView];
    [_contentView bringSubviewToFront:_headerView];
}



-(void)createAlerternateProfileControllers
{
    if(_profileController2 == nil)
    {
        _profileController2 = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        [self.view addSubview:_profileController2.view];
        
        
        CGRect profileCont2Rect = _profileController2.view.frame;
        profileCont2Rect.origin.x = 320;
        [_profileController2.view setFrame:profileCont2Rect];
    }
}


-(void)peopleListView:(DPeopleListComponent *)listView didSelectedItemIndex:(NSUInteger)index
{
    if(listView.tag ==  111)//Following list...
    {
        //Navigate the contentview and _profileviewController2 to unvisible and visible...
        SearchPeopleData *userDetail = _followings[index];
        NSString *profileId = userDetail.profileUserUID;
        
        DProfileDetailsViewController *profileC = [[DProfileDetailsViewController alloc] initWithNibName:@"DProfileDetailsViewController" bundle:nil];
        [profileC setProfileId:profileId];
        [self.navigationController pushViewController:profileC animated:YES];
        
//        [self createAlerternateProfileControllers];
//        
//        CGRect contentViewRect  = _contentView.frame;
//        CGRect profile2Rect     = _profileController2.view.frame;
//        
//        contentViewRect.origin.x    = -320;
//        profile2Rect.origin.x       = 0;
//        
//        [UIView animateWithDuration:0.5 animations:^{
//            //Animate the views....
//            [_contentView setFrame:contentViewRect];
//            [_profileController2.view setFrame:profile2Rect];
//        } completion:^(BOOL finished) {
//           //Finished the content...
//        }];
    }
    else//Followers list...
    {
        SearchPeopleData *userDetail = _followers[index];
        NSString *profileId = userDetail.profileUserUID;
        
        DProfileDetailsViewController *profileC = [[DProfileDetailsViewController alloc] initWithNibName:@"DProfileDetailsViewController" bundle:nil];
        profileC.profileId = profileId;
        [self.navigationController pushViewController:profileC animated:YES];
    }
}



-(void)getFollowingList
{
    NSString *currentUserId = [[[[WSModelClasses sharedHandler] loggedInUserModel] userID] stringValue];
    NSString *profileId = self.profileId;
    NSInteger pageNumber = 0;
    
    [[WSModelClasses sharedHandler] getFollowingListForUserId:currentUserId ofPersons:profileId pageNumber:pageNumber response:^(BOOL success, id response) {
        if(success)
        {
            //Need to parse the data...
            NSLog(@"Follwing List:%@",response);
            _followings = [self parseFollowingsList:response];
            [self designFollowingList];
        }
        else
        {
            //Failed to get the details of the following list...
            NSLog(@"Failed to get the followings list:%@",response);
        }
    }];
}



-(void)getFollowersList
{
    NSString *currentUserId = [[[[WSModelClasses sharedHandler] loggedInUserModel] userID] stringValue];
    NSString *profileId = self.profileId;
    NSInteger pageNumber = 0;
    
    [[WSModelClasses sharedHandler] getFollowersListForUserId:currentUserId ofPersons:profileId pageNumber:pageNumber response:^(BOOL success, id response) {
        if(success)
        {
            //Need to parse the data...
            NSLog(@"Followers List:%@",response);
            _followers = [self parseFollowersList:response];
            [self desingFollwerList];
        }
        else
        {
            //Failed to get the details of the following list...
            NSLog(@"Failed to get the follwers list:%@",response);
        }
    }];
}


- (void)desingFollwerList
{
    if(_followersList != nil)
    {
        [_followersList removeFromSuperview];
        _followersList = nil;
    }
    
    if(_followersList == nil)
    {
        _followersList = [[DPeopleListComponent alloc] initWithFrame:_postView.frame andPeopleList:_followers];
        [_followersList addHeaderViewForTable:[[UIView alloc] init]];
        [_followersList setDelegate:self];
        [_contentView addSubview:_followersList];
    }
    
    [_contentView bringSubviewToFront:_segmentListView];
    [_contentView bringSubviewToFront:_headerView];
}

-(void)designPostListView
{
 

    
    WSModelClasses *sharedInstance = [WSModelClasses sharedHandler];
    [sharedInstance setDelegate:self];
    [sharedInstance getPostDetailsOfUserId:[[[WSModelClasses sharedHandler] loggedInUserModel].userID stringValue] anotherUserId:self.profileId response:^(BOOL success, id response) {
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
    
    
    
//    [self designListView:nil];
}

-(void)designListView:(NSArray *)array
{
    if(_listView != nil)
    {
        [_listView removeFromSuperview];
        _listView = nil;
    }
    
    _listView = [[DPostListView alloc] initWithFrame:_postView.frame andPostsList:array withHeaderView:[[UIView alloc] init]];
    [_listView setDelegate:self];
    [_contentView addSubview:_listView];
}

-(void)scrollView:(UIScrollView *)scrollView didHoldingFinger:(NSString *)finger
{
    if([finger isEqualToString:@"HOLDING"])
    {
        _holdingFingerOnPostListView = YES;
    }
    else
    {
        _holdingFingerOnPostListView = NO;
    }
    _currentContentOffset = scrollView.contentOffset;

}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _currentContentOffset = scrollView.contentOffset;
}

-(void)scrollView:(UIScrollView *)scrollView scrollingDirection:(NSString *)direction
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

-(void)userProfileSelectedForPost:(DPost *)post
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
