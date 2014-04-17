//
//  DUserComponent.m
//  Describe
//
//  Created by NuncSys on 26/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DUserComponent.h"
#import "UIImageView+AFNetworking.h"


@interface DUserComponent ()
{
    UILabel *_title;
    UILabel *_subTitle;
    UIImageView *_thumIcon;
    UIButton *_statusButton;
}
@end

@implementation DUserComponent
@synthesize _userData;
@synthesize data;
@synthesize thumbnailImg;
@synthesize _followUnfollowBtn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame AndUserData:(SearchPeopleData*)inUserData{
    self = [super initWithFrame:frame];
    if (self) {
        data = inUserData;
        self.backgroundColor = [UIColor clearColor];

       [self createUserComponent];//247,247,246
    }
    return self;
}
-(void)createUserComponent{
    UIImageView * roundImg = [[UIImageView alloc]initWithFrame:CGRectMake(15, 8, 40, 40)];
    roundImg.image = [UIImage imageNamed:@"thumb_user_std.png"];
    [self addSubview:roundImg];
//    self.thumbnailImg = [[UIImageView alloc]initWithFrame:CGRectMake(15, 8, 40, 40)];
////    self.thumbnailImg.layer.cornerRadius = CGRectGetHeight(self.thumbnailImg.frame)/2.0f;
//    [self addSubview:self.thumbnailImg];
    
//    if (data.profileUserProfilePicture) {
//        [self downloadUserImageview:data.profileUserProfilePicture];
//    }
    
    UILabel * firsLineLbl = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, 150, 30)];
    firsLineLbl.text = data.profileUserName;
    firsLineLbl.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    firsLineLbl.textColor = [UIColor colorWithRed:53/255.0 green:168/255.0 blue:157/255.0 alpha:1.0];
    firsLineLbl.numberOfLines = 0;
    [self addSubview:firsLineLbl];
    
    UILabel * secondLineLbl = [[UILabel alloc]initWithFrame:CGRectMake(65, 20, 150, 30)];
    secondLineLbl.text =data.profileUserFullName;
    secondLineLbl.font = [UIFont fontWithName:@"HelveticaNeue-thin" size:15];
    secondLineLbl.textColor = [UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:1.0];
    secondLineLbl.numberOfLines = 0;
    [self addSubview:secondLineLbl];
    
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(275, 9, 30, 30)];
    _followUnfollowBtn =button;
    if ([WSModelClasses sharedHandler].loggedInUserModel.isInvitation == YES) {
        button.frame = CGRectMake(250, 9, 60, 26);
        if ([data.followingStatus isEqualToString:@"1"]) {
            [button setBackgroundImage:[UIImage imageNamed:@"btn_txt_remind.png"] forState:UIControlStateNormal];
        }else{
            [button setBackgroundImage:[UIImage imageNamed:@"btn_txt_invite.png"] forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(inviteThePerson:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }else{
        if ([data.followingStatus isEqualToString:@"1"]) {
            [button setBackgroundImage:[UIImage imageNamed:@"btn_line_follow.png"] forState:UIControlStateNormal];
        }else{
            [button setBackgroundImage:[UIImage imageNamed:@"btn_line_unfollow.png"] forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(followAndUnfollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    
    
    _title = firsLineLbl;
    _subTitle = secondLineLbl;
    _thumIcon = roundImg;
    _statusButton = button;
    _thumIcon.layer.cornerRadius = CGRectGetHeight(_thumIcon.frame)/2.0f;
    _thumIcon.layer.masksToBounds = YES;
}

-(void)updateContent:(SearchPeopleData *)userData
{
    data = userData;
    
    [_thumIcon setImageWithURL:[NSURL URLWithString:data.profileUserProfilePicture] placeholderImage:[UIImage imageNamed:@"thumb_user_std.png"]];
    _title.text = data.profileUserName;
    _subTitle.text =data.profileUserFullName;
     if ([WSModelClasses sharedHandler].loggedInUserModel.isInvitation == YES) {
         if ([data.followingStatus isEqualToString:@"1"])
         {
             [_statusButton setBackgroundImage:[UIImage imageNamed:@"btn_txt_remind.png"] forState:UIControlStateNormal];
         }else{
             [_statusButton setBackgroundImage:[UIImage imageNamed:@"btn_txt_invite.png"] forState:UIControlStateNormal];
         }
     }else{
    
    //Updating the details on the content...
    if ([data.followingStatus isEqualToString:@"1"])
    {
        [_statusButton setBackgroundImage:[UIImage imageNamed:@"btn_line_follow.png"] forState:UIControlStateNormal];
    }else{
        [_statusButton setBackgroundImage:[UIImage imageNamed:@"btn_line_unfollow.png"] forState:UIControlStateNormal];
    }
     }
}



-(void)followAndUnfollowButtonAction:(id)inAction
{
    if ([data.followingStatus isEqualToString:@"0"]) {
        [self follwingTheUser];
    }else if ([data.followingStatus isEqualToString:@"1"]){
        [self unfollowTherUser];
    }
}


-(void)follwingTheUser
{
    [WSModelClasses sharedHandler].delegate =self;
    [[WSModelClasses sharedHandler]followingTheUseruserId:(NSString*)[WSModelClasses sharedHandler].loggedInUserModel.userID otherUserId:data.profileUserUID];
}


-(void)unfollowTherUser
{
    [WSModelClasses sharedHandler].delegate =self;
    [[WSModelClasses sharedHandler]unfollowingTheUseruserId:(NSString*)[WSModelClasses sharedHandler].loggedInUserModel.userID otherUserId:data.profileUserUID];
    
}


-(void)inviteThePerson:(id)inAction
{
    [WSModelClasses sharedHandler].delegate =self;
    [[WSModelClasses sharedHandler]sendGateWayInvitationUserId:@"" gateWayType:data.gateWayType gateWayToken:data.gateWayToken userName:@""];
    
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
        case KWebserviesType_followand:
        {
            if ([[[responseDict valueForKeyPath:@"ResponseData.DataTable.NewData.Msg"]objectAtIndex:0] isEqualToString:@"You are following this User now."]) {
                [_followUnfollowBtn setBackgroundImage:[UIImage imageNamed:@"btn_line_follow.png"] forState:UIControlStateNormal];
             data.followingStatus = @"1";
            }else{
                [_followUnfollowBtn setBackgroundImage:[UIImage imageNamed:@"btn_line_unfollow.png"] forState:UIControlStateNormal];
                data.followingStatus = @"0";

            }
            break;
        }
            case KWebserviesType_unfollowand:
        {
            if ([[[responseDict valueForKeyPath:@"ResponseData.DataTable.NewData.Msg"]objectAtIndex:0] isEqualToString:@"You have unfollowed this User."]) {
                [_followUnfollowBtn setBackgroundImage:[UIImage imageNamed:@"btn_line_unfollow.png"] forState:UIControlStateNormal];
                data.followingStatus = @"0";
            }else{
                [_followUnfollowBtn setBackgroundImage:[UIImage imageNamed:@"btn_line_follow.png"] forState:UIControlStateNormal];
                data.followingStatus = @"1";

            }
            break;
        }
        case KWebserviesType_invitations:
        {
            
            if ([[[responseDict valueForKeyPath:@"ResponseData.DataTable.NewData.Msg"]objectAtIndex:0] isEqualToString:@"You are successfully invited your friend."]) {
                [_followUnfollowBtn setBackgroundImage:[UIImage imageNamed:@"btn_txt_remind.png"] forState:UIControlStateNormal];
                data.followingStatus = @"1";
            }else{
                [_followUnfollowBtn setBackgroundImage:[UIImage imageNamed:@"btn_txt_invite.png"] forState:UIControlStateNormal];
                data.followingStatus = @"0";
                
            }
            break;
            
        }

        default:
            break;
    }
}

-(void)downloadUserImageview:(NSString*)inUrlString{
    dispatch_queue_t backgroundQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
        NSData *avatarData = nil;
        NSString *imageURLString = inUrlString;
        if (imageURLString) {
            NSURL *imageURL = [NSURL URLWithString:imageURLString];
            avatarData = [NSData dataWithContentsOfURL:imageURL];
        }
        if (avatarData) {
            // Update UI from the main thread when available
            dispatch_async(dispatch_get_main_queue(), ^{
                self.thumbnailImg.image = [UIImage imageWithData:avatarData];
                
            });
        }
    });
}

@end
