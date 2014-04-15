//
//  DPostsViewController.m
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DPostsViewController.h"
#import "DConversationViewController.h"
#import "DPostListView.h"
#import "DPostView.h"
#import "DPost.h"
#import "DHeaderView.h"
#import "DPostHeaderView.h"
#import "CMViewController.h"
#import "CMPhotoModel.h"
#import "CMAVCameraHandler.h"
#import "WSModelClasses.h"
#import "DConversation.h"
#import "WSModelClasses.h"
#import "ProfileViewController.h"
#import "NotificationsViewController.h"
#import "DesSearchPeopleViewContrlooerViewController.h"
#import "DESSettingsViewController.h"
#import "DescAddpeopleViewController.h"
#import "DProfileDetailsViewController.h"

@interface DPostsViewController ()<DPostHeaderViewDelegate,WSModelClassDelegate, UIActionSheetDelegate, DHeaderViewDelegate>
{
    IBOutlet DHeaderView *_headerView;
    IBOutlet DPostListView *_listView;
    IBOutlet DPostView *_postView;
    
    CMViewController *_compositionViewController;
    
    UIActionSheet *_moreActionSheet;
    DPost           *_currentPost;
    BOOL            _isSelfPost;
}
@end

@implementation DPostsViewController


static DPostsViewController *sharedFeedController;

+(id)sharedFeedController
{
    
    if(sharedFeedController == nil)
    {
        sharedFeedController = [[DPostsViewController alloc] initWithNibName:@"DPostsViewController" bundle:nil];
    }
    
    return sharedFeedController;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreButtonClicked:) name:POST_MORE_BUTTON_NOTIFICATION_KEY object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentButtonClicked:) name:POST_COMMENT_BUTTON_NOTIFICATION_KEY object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likesAndCommentButtonClicked:) name:POST_LIKES_BUTTON_NOTIFICATION_KEY object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.view.backgroundColor = [UIColor greenColor];
//    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeGesture:)];
//    [rightSwipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
//    [self.view addGestureRecognizer:rightSwipeGesture];
    
  
    
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeGesture:)];
    [leftSwipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:leftSwipeGesture];
    
    //[self designPostView];
    [self designHeaderView];
    [self designPostListView];
    
    
    WSModelClasses *sharedInstance = [WSModelClasses sharedHandler];
    [sharedInstance setDelegate:self];
    [sharedInstance getPostDetailsOfUserId:@"45" anotherUserId:@"45"];
    
}


-(void)viewDidAppear:(BOOL)animated
{
    
    return;
    
    DConversationViewController *conversationController = [[DConversationViewController alloc] initWithNibName:@"DConversationViewController" bundle:nil];
    [self.navigationController pushViewController:conversationController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidUnload
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:POST_MORE_BUTTON_NOTIFICATION_KEY];
//    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:POST_COMMENT_BUTTON_NOTIFICATION_KEY];
//    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:POST_LIKES_BUTTON_NOTIFICATION_KEY];
//    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kNOTIFY_PROFILE_DETAILS];
}

-(void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:POST_MORE_BUTTON_NOTIFICATION_KEY];
//    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:POST_COMMENT_BUTTON_NOTIFICATION_KEY];
//    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:POST_LIKES_BUTTON_NOTIFICATION_KEY];
//    
}


#pragma mark View Creations -

-(void)createNewPost
{
    
}


#pragma mark View Designs -

-(void)designHeaderView
{
    UIButton *addButton, *reloadButton, *moreButton;
    
    addButton = [[UIButton alloc] init];
    [addButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_compose.png"] forState:UIControlStateNormal];
    [addButton setTag:HeaderButtonTypeAdd];
    
    reloadButton = [[UIButton alloc] init];
    [reloadButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_refresh.png"] forState:UIControlStateNormal];
    [reloadButton setTag:HeaderButtonTypeReload];
    
    moreButton = [[UIButton alloc] init];
    [moreButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_menu.png"] forState:UIControlStateNormal];
    [moreButton setTag:HeaderButtonTypeMenu];

    
    [_headerView setDelegate:self];
    [_headerView designHeaderViewWithTitle:@"Following" andWithButtons:@[moreButton, reloadButton, addButton] andMenuButtons:[self menuButtonsList]];
}

-(NSArray *)menuButtonsList
{
    UIButton *profileButton, *notificationButton, *searchButton, *addPeople, *settingsButton, *closeButton;
    
    profileButton = [[UIButton alloc] init];
    [profileButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_profile.png"] forState:UIControlStateNormal];
    [profileButton setTag:HeaderButtonTypeProfile];
    
    notificationButton = [[UIButton alloc] init];
    [notificationButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_notifications.png"] forState:UIControlStateNormal];
    [notificationButton setTag:HeaderButtonTypeNotification];
    
    searchButton = [[UIButton alloc] init];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_search.png"] forState:UIControlStateNormal];
    [searchButton setTag:HeaderButtonTypeSearch];
    
    addPeople = [[UIButton alloc] init];
    [addPeople setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_add_people.png"] forState:UIControlStateNormal];
    [addPeople setTag:HeaderButtonTypeAddPeople];
    
    settingsButton = [[UIButton alloc] init];
    [settingsButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_settings.png"] forState:UIControlStateNormal];
    [settingsButton setTag:HeaderButtonTypeSettings];
    
    closeButton = [[UIButton alloc] init];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"btn_nav_std_cancel.png"] forState:UIControlStateNormal];
    [closeButton setTag:HeaderButtonTypeClose];
    
    
    return @[profileButton, notificationButton, searchButton, addPeople, settingsButton, closeButton];
}


-(void)designPostView
{
    [_postView designPostView];
}

-(void)designPostListView
{
}

-(void)addNewObserverForDelegateProfileDetails
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyDelegate:) name:kNOTIFY_PROFILE_DETAILS object:nil];
}

-(void)notifyDelegate:(NSNotification *)notification
{
    id object = [notification object];
    DPostHeaderView *profileDetailsView = (DPostHeaderView *)object;
    DUser *user = [profileDetailsView user];
    NSLog(@"user profile id:%@", user.userId);
}

#pragma mark View Operations -
#pragma mark Model Operations -


#pragma mark Event Actions -
- (void)pushToCompositionScreen
{
//    _compositionViewController = [[CMViewController alloc] initWithNibName:@"CMViewController" bundle:nil];
//    [self.navigationController pushViewController:_compositionViewController animated:YES];
    

}

- (void)addPost:(id)sender
{
    [self pushToCompositionScreen];
    return;
    NSString *compositionPath = [NSString stringWithFormat:@"%@/%@", COMPOSITION_TEMP_FOLDER_PATH, COMPOSITION_DICT];
    if([[NSFileManager defaultManager] fileExistsAtPath:compositionPath]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Describe", @"") message:NSLocalizedString(@"Would you like to continue previous composition?", @"") delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert show];
    }
    else {
        [self pushToCompositionScreen];
    }
}

- (void)reloadPostList:(id)sender
{
    
}

- (void)morePost:(id)sender
{
    
}

- (void)rightSwipeGesture:(UISwipeGestureRecognizer *)rightSwipeGesture withPost:(DPost *)post
{
    [self getConversationDetailsOfPost:post];
    
    //mar 2
    //[self getTheConverSationData];
    return;
    //NSLog(@"Right Swipe Gesture Activated");
    dispatch_async(dispatch_get_main_queue(), ^{
        DConversationViewController *conversationController = [[DConversationViewController alloc] initWithNibName:@"DConversationViewController" bundle:nil];
        [self.navigationController pushViewController:conversationController animated:YES];
    });

}

-(void)leftSwipeGesture:(UISwipeGestureRecognizer *)leftSwipeGesture
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)moreButtonClicked:(id)sender
{
    [self getTheConverSationData];
    return;
    DConversationViewController *conversationController = [[DConversationViewController alloc] initWithNibName:@"DConversationViewController" bundle:nil];
    [self.navigationController pushViewController:conversationController animated:YES];
}

-(void)commentButtonClicked:(id)sender
{
    [self getTheConverSationData];
    return;
    DConversationViewController *conversationController = [[DConversationViewController alloc] initWithNibName:@"DConversationViewController" bundle:nil];
    [self.navigationController pushViewController:conversationController animated:NO];
}

-(void)likesAndCommentButtonClicked:(id)sender
{
    [self getTheConverSationData];
    return;
    DConversationViewController *conversationController = [[DConversationViewController alloc] initWithNibName:@"DConversationViewController" bundle:nil];
    [self.navigationController pushViewController:conversationController animated:YES];
}

-(void)profileDetailsDidSelected:(DPostHeaderView *)headerView
{
    //Navigate to the profile screen...
    DUser *user = [headerView user];
    NSLog(@"user profile id:%@", user.userId);
    
}

-(void)getTheConverSationData
{
    WSModelClasses * dataClass = [WSModelClasses sharedHandler];
    dataClass.delegate =self;
    [dataClass getThePostConversationDetails:@"" andPostId:@""];
}

-(void)getConversationDetailsOfPost:(DPost *)post
{
    NSString *currencUserId = @"45";
    NSString *postId = post.postId;
    
    
    WSModelClasses * dataClass = [WSModelClasses sharedHandler];
    dataClass.delegate =self;
    [dataClass getThePostConversationDetails:currencUserId andPostId:postId];
}


-(void)getThePostConversationDetailsFromServer:(NSDictionary *) responceDict error:(NSError*)error
{
    //    NSLog(@"converstion data from server %@",responceDict);
    if(responceDict != nil || ![responceDict isKindOfClass:[NSNull class]])
    {
        NSMutableArray * conversatonDataArray = [[NSMutableArray alloc]init];
        for (NSDictionary * dic in [responceDict valueForKeyPath:@"DataTable.PostConversation"]) {
            
            DConversation * data = [[DConversation alloc]init];
            //    data.authUserUID = [dic valueForKey:@"AuthUserUID"];
            data.comment = [dic valueForKey:@"Comment"];
            data.numberOfLikes = [[dic valueForKey:@"LikeCount"]integerValue];
            data.postId = [dic valueForKey:@"PostUID"];
            //data.conversationID = [dic valueForKey:@"conversationID"];
            data.elapsedTime = [dic valueForKey:@"conversationMadeTime"];
            data.type = [[dic valueForKey:@"conversationType"]integerValue];
            // data.conversationUserID = [dic valueForKey:@"conversationUserID"];
            data.profilePic = [dic valueForKey:@"conversationUserProfilePicture"];
            data.username = [dic valueForKey:@"conversationUsername"];
            [conversatonDataArray addObject:data];
            
        }
        DConversationViewController *conversationController = [[DConversationViewController alloc] initWithNibName:@"DConversationViewController" bundle:nil];
        conversationController.conversationListArray = conversatonDataArray;
        [self.navigationController pushViewController:conversationController animated:YES];
    }
}



#pragma mark - UIAlertViewDelegate Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *compositionPath = [NSString stringWithFormat:@"%@/%@", COMPOSITION_TEMP_FOLDER_PATH, COMPOSITION_DICT];
    NSMutableDictionary *compositionDict = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:compositionPath]) {
        NSData *data = [NSData dataWithContentsOfFile:compositionPath];
        compositionDict = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data] copyItems:YES];
    }
    
    if(buttonIndex == 0) {
        // remove the previous images and video from path
        [[CMAVCameraHandler sharedHandler] setVideoFilenamePath:nil];
        if(compositionDict != nil && compositionDict[COMPOSITION_VIDEO_PATH_KEY]) {
            NSString *videoPath = compositionDict[COMPOSITION_VIDEO_PATH_KEY];
            if([[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
                NSError *error;
                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:videoPath error:&error];
                if(!success) {
                    NSLog(@"%s success = %d, error = %@", __func__, success, error.localizedDescription);
                }
            }
        }
        
        if(compositionDict != nil && compositionDict[COMPOSITION_IMAGE_ARRAY_KEY]) {
            NSArray *compositionArray = compositionDict[COMPOSITION_IMAGE_ARRAY_KEY];
            for(NSDictionary *aDict in compositionArray) {
                if(aDict[COMPOSITION_ARRAY_DICT_ORIGINAL_IMG_PATH_KEY]) {
                    NSString *imgPath = aDict[COMPOSITION_ARRAY_DICT_ORIGINAL_IMG_PATH_KEY];
                    if([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
                        NSError *error;
                        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:imgPath error:&error];
                        if(!success) {
                            NSLog(@"%s success = %d, error = %@", __func__, success, error.localizedDescription);
                        }
                    }
                }
            }
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:compositionPath]) {
            NSError *error;
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:compositionPath error:&error];
            if(!success) {
                NSLog(@"%s success = %d, error = %@", __func__, success, error.localizedDescription);
            }
        }
    }
    else {
        if(compositionDict != nil && compositionDict[COMPOSITION_VIDEO_PATH_KEY]) {
            [[CMAVCameraHandler sharedHandler] setVideoFilenamePath:compositionDict[COMPOSITION_VIDEO_PATH_KEY]];
        }
    }
    
    [self pushToCompositionScreen];
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
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    [temp addObjectsFromArray:postModelList];
    
    
    
    _listView = [[DPostListView alloc] initWithFrame:_postView.frame andPostsList:postModelList];
    [self.view addSubview:_listView];
    
    [self addNewObserverForDelegateProfileDetails];
    
}


-(void)showMoreDetailsOfPost:(DPost *)post
{
    _currentPost = post;
    
    NSString *currentUserId = @"45";
    NSString *postAuthId = [[post user] userId];
    
    
    _isSelfPost = [currentUserId isEqualToString:postAuthId];
    if(_isSelfPost)
    {
        _moreActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete",nil];
        _moreActionSheet.tag = 111;
    }
    else
    {
        _moreActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report",nil];
        _moreActionSheet.tag = 222;
    }
    
    [_moreActionSheet setFrame:CGRectMake(0, 0, 320, 400)];
    [_moreActionSheet showInView:self.view];
}

-(void)showConversationForThisPost:(DPost *)post
{
//    DConversationViewController *conversationController = [[DConversationViewController alloc] initWithNibName:@"DConversationViewController" bundle:nil];
//    conversationController.conversationListArray = nil;
//    [self.navigationController pushViewController:conversationController animated:NO];
//    
    
    //return;
    [self getConversationDetailsOfPost:post];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(actionSheet.tag == 111)
    {
        if(buttonIndex == 0)
        {
            
            
            //Delete the post...
            [_listView deletePost:_currentPost];
            
            
            [[WSModelClasses sharedHandler] deletePost:_currentPost.postId response:^(BOOL success, id response) {
                if(success)
                {
                    //Successfully deleted the post...
                    NSLog(@"Response:%@",response);
                }
                else
                {
                    //Failed to delete the post...
                    NSLog(@"Error:%@",response);
                }
            }];
            
        }
    }
    else if(actionSheet.tag == 222)
    {
        if(buttonIndex == 0)
        {
            //Report the post...
            [[WSModelClasses sharedHandler] reportPost:_currentPost.postId userId:@"45" response:^(BOOL success, id response) {
                if(success)
                {
                    //Successfully deleted the post...
                    NSLog(@"Response:%@",response);
                }
                else
                {
                    //Failed to delete the post...
                    NSLog(@"Error:%@",response);
                }
            }];
        }
    }
 }


#pragma mark Header View Delegate Methods -
-(void)headerView:(DHeaderView *)headerView didSelectedHeaderViewButton:(UIButton *)headerButton
{
    HeaderButtonType buttonType = [headerButton tag];
    switch (buttonType)
    {
        case HeaderButtonTypeAdd:
            [self addPost:headerButton];
            break;
        case HeaderButtonTypeReload:
            [self reloadPostList:headerButton];
            break;
        case HeaderButtonTypeHome:
            break;
        case HeaderButtonTypeProfile:
        {
            DProfileDetailsViewController *profileController = [[DProfileDetailsViewController alloc] initWithNibName:@"DProfileDetailsViewController" bundle:nil];
            [self.navigationController pushViewController:profileController animated:YES];
        }
            break;
        case HeaderButtonTypeNotification:
        {
            NotificationsViewController *notificationViewController = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:nil];
            [self.navigationController pushViewController:notificationViewController animated:YES];
        }
            break;
        case HeaderButtonTypeSearch:
        {
            DesSearchPeopleViewContrlooerViewController *searchViewController = [[DesSearchPeopleViewContrlooerViewController alloc] initWithNibName:@"DesSearchPeopleViewContrlooerViewController" bundle:nil];
            [self.navigationController pushViewController:searchViewController animated:YES];
        }
            break;
        case HeaderButtonTypeAddPeople:
        {
            DescAddpeopleViewController *addPeopleViewController = [[DescAddpeopleViewController alloc] initWithNibName:@"DescAddpeopleViewController" bundle:nil];
            [self.navigationController pushViewController:addPeopleViewController animated:YES];
        }
        case HeaderButtonTypeSettings:
        {
            DESSettingsViewController *settingViewController = [[DESSettingsViewController alloc] initWithNibName:@"DESSettingsViewController" bundle:nil];
            [self.navigationController pushViewController:settingViewController animated:YES];
        }
            break;
        default:
            break;
    }
}

@end




