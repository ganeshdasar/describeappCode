//
//  DUserComponent.m
//  Describe
//
//  Created by NuncSys on 26/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DUserComponent.h"
#import "UIImageView+AFNetworking.h"
#import <CoreGraphics/CoreGraphics.h>

#define WERECOMMENDED_TITLE_COLOR           [UIColor colorWithRed:53/255.0 green:168/255.0 blue:157/255.0 alpha:1.0]
#define WERECOMMENDED_SUBTITLE_COLOR        [UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:1.0]
#define WERECOMMENDED_TITLE_FONT            [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0]
#define WERECOMMENDED_SUBTITLE_FONT         [UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0]

#define INVITATION_TITLE_COLOR              [UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:1.0]
#define INVITATION_SUBTITLE_COLOR           [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0]
#define INVITATION_TITLE_FONT               [UIFont fontWithName:@"HelveticaNeue-Thin" size:17.0]
#define INVITATION_SUBTITLE_FONT            [UIFont fontWithName:@"HelveticaNeue" size:12.0]

@interface DUserComponent ()
{
    UILabel *_title;
    UILabel *_subTitle;
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

- (id)initWithFrame:(CGRect)frame AndUserData:(SearchPeopleData*)inUserData{
    self = [super initWithFrame:frame];
    if (self) {
        data = inUserData;
        self.backgroundColor = [UIColor clearColor];

       [self createUserComponent];//247,247,246
    }
    return self;
}

- (void)createUserComponent
{
    self.thumbnailImg = [[UIImageView alloc]initWithFrame:CGRectMake(15, 8, 40, 40)];
    self.thumbnailImg.layer.cornerRadius = CGRectGetHeight(self.thumbnailImg.frame)/2.0f;;
    self.thumbnailImg.layer.masksToBounds = YES;
    [self addSubview:self.thumbnailImg];
    
    [thumbnailImg setImage:[UIImage imageNamed:@"thumb_user_std_null.png"]];
    
    UILabel * firsLineLbl = [[UILabel alloc]initWithFrame:CGRectMake(65, 0, 150, 30)];
    firsLineLbl.text = data.profileUserName;
    firsLineLbl.font = WERECOMMENDED_TITLE_FONT;
    firsLineLbl.textColor = WERECOMMENDED_TITLE_COLOR;
    firsLineLbl.numberOfLines = 0;
    [self addSubview:firsLineLbl];
    
    UILabel * secondLineLbl = [[UILabel alloc]initWithFrame:CGRectMake(65, 20, 150, 30)];
    secondLineLbl.text =data.profileUserFullName;
    secondLineLbl.font = WERECOMMENDED_SUBTITLE_FONT;
    secondLineLbl.textColor = WERECOMMENDED_SUBTITLE_COLOR;
    secondLineLbl.numberOfLines = 0;
    [self addSubview:secondLineLbl];
    
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(275, 9, 30, 30)];
    _followUnfollowBtn = button;
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
    _statusButton = button;

}

- (void)updateContent:(SearchPeopleData *)userData
{
    [self.thumbnailImg cancelImageRequestOperation];
    
    data = userData;
    
    [self.thumbnailImg setImage:[UIImage imageNamed:@"thumb_user_std_null.png"]];
    [self.thumbnailImg setImageWithURL:[NSURL URLWithString:data.profileUserProfilePicture] placeholderImage:[UIImage imageNamed:@"thumb_user_std_null.png"]];
    
    _title.text = data.profileUserName ? data.profileUserName : @"";
     if ([WSModelClasses sharedHandler].loggedInUserModel.isInvitation == YES) {
         _subTitle.text = data.gateWayType ? [data.gateWayType isEqualToString:@"fb"] ? @"facebook" : @"google+" : @"";
         
         _title.font = INVITATION_TITLE_FONT;
         _title.textColor = INVITATION_TITLE_COLOR;
         _subTitle.font = INVITATION_SUBTITLE_FONT;
         _subTitle.textColor = INVITATION_SUBTITLE_COLOR;

        CGRect statusFrame = CGRectZero;
        statusFrame = CGRectMake(250, 9, 60, 26);
        [_statusButton setFrame:statusFrame];

        if ([data.followingStatus isEqualToString:@"1"]) {
         [_statusButton setBackgroundImage:[UIImage imageNamed:@"btn_txt_remind.png"] forState:UIControlStateNormal];
        }
        else {
         [_statusButton setBackgroundImage:[UIImage imageNamed:@"btn_txt_invite.png"] forState:UIControlStateNormal];
        }
     }
     else {
         _subTitle.text = data.profileUserFullName ? data.profileUserFullName : @"";
         
         _title.font = WERECOMMENDED_TITLE_FONT;
         _title.textColor = WERECOMMENDED_TITLE_COLOR;
         _subTitle.font = WERECOMMENDED_SUBTITLE_FONT;
         _subTitle.textColor = WERECOMMENDED_SUBTITLE_COLOR;

        CGRect statusFrame = CGRectZero;
        statusFrame = CGRectMake(275, 9, 30, 30);
        [_statusButton setFrame:statusFrame];
         
        //Updating the details on the content...
        if ([data.followingStatus isEqualToString:@"1"]) {
            [_statusButton setBackgroundImage:[UIImage imageNamed:@"btn_line_follow.png"] forState:UIControlStateNormal];
        }
        else {
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
    
    if(_delegate != nil && [_delegate respondsToSelector:@selector(statusChange)]) {
        [_delegate statusChange];
    }
    
}

- (void)downloadUserImageview:(NSString*)inUrlString{
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
