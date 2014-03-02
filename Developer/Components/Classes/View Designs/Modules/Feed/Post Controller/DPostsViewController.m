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
#import "WSModelClasses.h"
#import "DConversation.h"
@interface DPostsViewController ()<DPostHeaderViewDelegate,WSModelClassDelegate>
{   
    IBOutlet DHeaderView *_headerView;
    IBOutlet DPostListView *_listView;
    IBOutlet DPostView *_postView;
    
    CMViewController *_compositionViewController;
}
@end

@implementation DPostsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreButtonClicked:) name:POST_MORE_BUTTON_NOTIFICATION_KEY object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentButtonClicked:) name:POST_COMMENT_BUTTON_NOTIFICATION_KEY object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likesAndCommentButtonClicked:) name:POST_LIKES_BUTTON_NOTIFICATION_KEY object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor greenColor];
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeGesture:)];
    [rightSwipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:rightSwipeGesture];
    
    
    
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeGesture:)];
    [leftSwipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:leftSwipeGesture];
    
    //[self designPostView];
    [self designHeaderView];
    [self designPostListView];
}


-(void)viewDidAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:POST_MORE_BUTTON_NOTIFICATION_KEY];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:POST_COMMENT_BUTTON_NOTIFICATION_KEY];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:POST_LIKES_BUTTON_NOTIFICATION_KEY];
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
    [addButton setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addPost:) forControlEvents:UIControlEventTouchUpInside];
    
    reloadButton = [[UIButton alloc] init];
    [reloadButton setBackgroundImage:[UIImage imageNamed:@"reload.png"] forState:UIControlStateNormal];
    [reloadButton addTarget:self action:@selector(reloadPostList:) forControlEvents:UIControlEventTouchUpInside];
    
    moreButton = [[UIButton alloc] init];
    [moreButton setBackgroundImage:[UIImage imageNamed:@"more1.png"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(morePost:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *moreButton1 = [[UIButton alloc] init];
    [moreButton1 setBackgroundImage:[UIImage imageNamed:@"more1.png"] forState:UIControlStateNormal];
    [moreButton1 addTarget:self action:@selector(morePost:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_headerView designHeaderViewWithTitle:@"Following" andWithButtons:@[addButton, moreButton, reloadButton]];
}


-(void)designPostView
{
    [_postView designPostView];
}

-(void)designPostListView
{
    DPost *post, *post2, *post3, *post4, *post5;
    {
        DPostVideo *video = [[DPostVideo alloc] init];
        [video setDuration:@"25"];
        [video setUrl:[[NSBundle mainBundle] pathForResource:@"222" ofType:@"mp4"]];
        
        DPostImage *imagePost = [[DPostImage alloc] init];
//        [imagePost setImages:[[NSArray alloc] initWithObjects:@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg",@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg",@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg",@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg", nil]];
//        [imagePost setDurationList:[[NSArray alloc] initWithObjects:@"10",@"2",@"1",@"4",@"3",@"10",@"2",@"1",@"4",@"3",@"10",@"2",@"1",@"4",@"3",@"10",@"2",@"1",@"4",@"3", nil]];
        NSMutableArray *images = [[NSMutableArray alloc] init];
        {
            CMPhotoModel *photoModel = [[CMPhotoModel alloc] init];
            [photoModel setEditedImage:[UIImage imageNamed:@"1.jpg"]];
            [photoModel setDuration:8];
            [images addObject:photoModel];
        }
        {
            CMPhotoModel *photoModel = [[CMPhotoModel alloc] init];
            [photoModel setEditedImage:[UIImage imageNamed:@"2.jpg"]];
            [photoModel setDuration:10];
            [images addObject:photoModel];
        }
        [imagePost setImages:images];
        [imagePost setVideo:video];
        
        DUser *user = [[DUser alloc] init];
        [user setUserId:@"111"];
        [user setName:@"Irfan "];
        [user setAddress:nil];
        
        post = [[DPost alloc] init];
        [post setUser:user];
        [post setImagePost:imagePost];
        
        DPostTag *postTag = [[DPostTag alloc] init];
        [postTag setTagId:@""];
        [postTag setTagName:@"#TheBestofCompositePhotography"];
        
        DPostTag *postTag2 = [[DPostTag alloc] init];
        [postTag2 setTagId:@""];
        [postTag2 setTagName:@"#AstoryAboutNothingness"];
        
        NSArray *tags = @[postTag, postTag2];
        
        
        
        DPostAttachments *attachements = [[DPostAttachments alloc] init];
        [attachements setLikeRating:2];
        [attachements setNumberOfComments:10];
        [attachements setNumberOfLikes:2];
        [attachements setTagsList:tags];
        
        [post setAttachements:attachements];
        
    }
    
    {
        DPostVideo *video = [[DPostVideo alloc] init];
        [video setDuration:@"30"];
        [video setUrl:[[NSBundle mainBundle] pathForResource:@"111" ofType:@"mp4"]];
        
        DPostImage *imagePost = [[DPostImage alloc] init];
//        [imagePost setImages:[[NSArray alloc] initWithObjects:@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg", nil]];
//        //[[NSArray alloc] initWithObjects:@"22_1.png",@"22_2.png",@"22_3.png",@"22_4.png",@"22_5.png",@"22_6.png",@"22_7.png",@"22_8.png",@"22_9.png", nil]
//        [imagePost setDurationList:[[NSArray alloc] initWithObjects:@"3",@"2",@"1",@"4",@"3",@"2",@"1",@"4", nil]];
        NSMutableArray *images = [[NSMutableArray alloc] init];
        {
            CMPhotoModel *photoModel = [[CMPhotoModel alloc] init];
            [photoModel setEditedImage:[UIImage imageNamed:@"1.jpg"]];
            [photoModel setDuration:8];
            [images addObject:photoModel];
        }
        {
            CMPhotoModel *photoModel = [[CMPhotoModel alloc] init];
            [photoModel setEditedImage:[UIImage imageNamed:@"2.jpg"]];
            [photoModel setDuration:10];
            [images addObject:photoModel];
        }
        [imagePost setImages:images];
        [imagePost setVideo:video];
        
        DUser *user = [[DUser alloc] init];
        [user setUserId:@"222"];
        [user setName:@"Gopal "];
        [user setAddress:@"Hyderabad"];
        
        post2 = [[DPost alloc] init];
        [post2 setUser:user];
        [post2 setImagePost:imagePost];
    }
    
    {
        DPostVideo *video = [[DPostVideo alloc] init];
        [video setDuration:@"25"];
        [video setUrl:[[NSBundle mainBundle] pathForResource:@"333" ofType:@"mp4"]];
        
        DPostImage *imagePost = [[DPostImage alloc] init];
        //[imagePost setImages:[[NSArray alloc] initWithObjects:@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg", nil]];
        //[imagePost setDurationList:[[NSArray alloc] initWithObjects:@"10",@"2",@"1",@"4",@"3", nil]];
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        {
            CMPhotoModel *photoModel = [[CMPhotoModel alloc] init];
            [photoModel setEditedImage:[UIImage imageNamed:@"1.jpg"]];
            [photoModel setDuration:8];
            [images addObject:photoModel];
        }
        {
            CMPhotoModel *photoModel = [[CMPhotoModel alloc] init];
            [photoModel setEditedImage:[UIImage imageNamed:@"2.jpg"]];
            [photoModel setDuration:10];
            [images addObject:photoModel];
        }
        [imagePost setImages:images];
        
        [imagePost setVideo:video];
        
        DUser *user = [[DUser alloc] init];
        [user setUserId:@"333"];
        [user setName:@"Irfan "];
        [user setAddress:nil];
        
        post3 = [[DPost alloc] init];
        [post3 setUser:user];
        [post3 setImagePost:imagePost];
        
        DPostTag *postTag = [[DPostTag alloc] init];
        [postTag setTagId:@""];
        [postTag setTagName:@"#TheBestofCompositePhotography"];
        
        
        NSArray *tags = @[postTag];
        
        
        
        DPostAttachments *attachements = [[DPostAttachments alloc] init];
        [attachements setLikeRating:2];
        [attachements setNumberOfComments:10];
        [attachements setNumberOfLikes:2];
        [attachements setTagsList:tags];
        
        [post3 setAttachements:attachements];
        
    }
    
    {
        DPostVideo *video = [[DPostVideo alloc] init];
        [video setDuration:@"25"];
        [video setUrl:[[NSBundle mainBundle] pathForResource:@"444" ofType:@"mp4"]];
        
        DPostImage *imagePost = [[DPostImage alloc] init];
        NSMutableArray *images = [[NSMutableArray alloc] init];
        {
            CMPhotoModel *photoModel = [[CMPhotoModel alloc] init];
            [photoModel setEditedImage:[UIImage imageNamed:@"1.jpg"]];
            [photoModel setDuration:8];
            [images addObject:photoModel];
        }
        {
            CMPhotoModel *photoModel = [[CMPhotoModel alloc] init];
            [photoModel setEditedImage:[UIImage imageNamed:@"2.jpg"]];
            [photoModel setDuration:10];
            [images addObject:photoModel];
        }
        
        [imagePost setImages:images];
        // [imagePost setDurationList:[[NSArray alloc] initWithObjects:@"10",@"2",@"1",@"4",@"3", nil]];
        [imagePost setVideo:video];
        
        DUser *user = [[DUser alloc] init];
        [user setUserId:@"444"];
        [user setName:@"Irfan "];
        [user setAddress:nil];
        
        post4 = [[DPost alloc] init];
        [post4 setUser:user];
        [post4 setImagePost:imagePost];
        
        DPostTag *postTag = [[DPostTag alloc] init];
        [postTag setTagId:@""];
        [postTag setTagName:@"#TheBestofCompositePhotography"];
        
        
        NSArray *tags = @[postTag];
        
        
        
        DPostAttachments *attachements = [[DPostAttachments alloc] init];
        [attachements setLikeRating:2];
        [attachements setNumberOfComments:10];
        [attachements setNumberOfLikes:2];
        [attachements setTagsList:tags];
        
        [post4 setAttachements:attachements];
        
    }
    
    {
        post5 = [[DPost alloc] init];
        [post5 setType:DpostTypePrompter];
        
        DPrompterProfile *profile0 = [[DPrompterProfile alloc] init];
        [profile0 setProfilePromterImageName:@"profile_example2.png"];
        
        DPrompterProfile *profile1 = [[DPrompterProfile alloc] init];
        [profile1 setProfilePromterImageName:@"profile_example1.png"];
        
        DPrompterProfile *profile2 = [[DPrompterProfile alloc] init];
        [profile2 setProfilePromterImageName:@"profile_example2.png"];
        
        DPrompterProfile *profile3 = [[DPrompterProfile alloc] init];
        [profile3 setProfilePromterImageName:@"prompter_profile.png"];
        
        DPrompterProfile *profile4 = [[DPrompterProfile alloc] init];
        [profile4 setProfilePromterImageName:@"profile_example1.png"];
        
        [post5 setPrompters:@[profile0,profile1, profile2, profile4]];
    }
    
    
    
    _listView = [[DPostListView alloc] initWithFrame:_postView.frame andPostsList:[NSArray arrayWithObjects:post, post2,post5, post3, post4, nil]];
    [self.view addSubview:_listView];
    [self addNewObserverForDelegateProfileDetails];
    
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
-(void)addPost:(id)sender
{
    _compositionViewController = [[CMViewController alloc] initWithNibName:@"CMViewController" bundle:nil];
    [self.navigationController pushViewController:_compositionViewController animated:YES];
}

-(void)reloadPostList:(id)sender
{
    
}

-(void)morePost:(id)sender
{
    
}

-(void)rightSwipeGesture:(UISwipeGestureRecognizer *)rightSwipeGesture
{
    //mar 2
    [self getTheConverSationData];
    return;
    //NSLog(@"Right Swipe Gesture Activated");
    DConversationViewController *conversationController = [[DConversationViewController alloc] initWithNibName:@"DConversationViewController" bundle:nil];
    [self.navigationController pushViewController:conversationController animated:YES];
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
-(void)getTheConverSationData{
    
    WSModelClasses * dataClass = [WSModelClasses sharedHandler];
    dataClass.delegate =self;
    [dataClass getThePostConversationDetails:@"" andPostId:@""];
    
    
}
-(void)getThePostConversationDetailsFromServer:(NSDictionary *) responceDict error:(NSError*)error{
    
    
    NSLog(@"converstion data from server %@",responceDict);
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

@end
