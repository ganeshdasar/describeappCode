//
//  WSModelClasses.m
//  WebServicesTesting
//
//  Created by Pramod on 30/01/14.
//  Copyright (c) 2014 Nagaraja Velicharla. All rights reserved.
//

#import "WSModelClasses.h"
#import "Constant.h"
#import "AFNetworking.h"
#import <CoreFoundation/CoreFoundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import "NotificationModel.h"
#import "MBProgressHUD.h"

static WSModelClasses *_sharedInstance;

@interface WSModelClasses ()
{
    MBProgressHUD *loadingView;
}

@end

@implementation WSModelClasses

+ (instancetype)sharedHandler
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[WSModelClasses alloc] init];
    });
    return _sharedInstance;
}

// Use this for login in to the Describe app.
#pragma mark signIn
- (void)getSignInWithUsername:(NSString *)username
                     password:(NSString *)password
{
    if (![self checkTheInterConnection]) return;

    NSString *ur = [NSString stringWithFormat:@"%@/getUserSignin/format=json/Username=%@/UserPwd=%@", BaseURLString,username,password];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:ur
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDict = (NSDictionary *)responseObject;
             NSDictionary *userDataDict = (NSDictionary *)responseDict[@"DataTable"][0][@"UserData"];
             UsersModel *userModelObj = [[UsersModel alloc] initWithDictionary:userDataDict];
             _loggedInUserModel = userModelObj;
                 NSDictionary *signInResponseDict = @{WS_RESPONSEDICT_KEY_RESPONSEDATA: responseObject, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:kWebserviesType_SignIn]};
             [_delegate didFinishWSConnectionWithResponse:signInResponseDict];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSDictionary *responseDict = @{WS_RESPONSEDICT_KEY_ERROR: error, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:kWebserviesType_SignIn]};
             [_delegate didFinishWSConnectionWithResponse:responseDict];
         }
     ];
}

- (void)updateTheuserModelObject:(UsersModel*)inUserData
{
    if (inUserData.dobDate) {
        _loggedInUserModel.dobDate = inUserData.dobDate;
    }
    
    if (inUserData.city) {
        _loggedInUserModel.city = inUserData.city;
    }
    
    if (inUserData.commentsCount) {
        _loggedInUserModel.commentsCount = inUserData.commentsCount;
    }
    
    if (inUserData.dobDate) {
        _loggedInUserModel.dobDate = inUserData.dobDate;
    }
    
    if (inUserData.userEmail) {
        _loggedInUserModel.userEmail = inUserData.userEmail;
    }
    
    if (inUserData.followerCount) {
        _loggedInUserModel.followerCount = inUserData.followerCount;
    }
    
    if (inUserData.followingCount) {
        _loggedInUserModel.followingCount = inUserData.followingCount;
    }
    
    if (inUserData.fullName) {
        _loggedInUserModel.fullName = inUserData.fullName;
    }
    
    if (inUserData.gender) {
        _loggedInUserModel.gender = inUserData.gender;
    }
    
    if (inUserData.userEmail) {
        _loggedInUserModel.userEmail = inUserData.userEmail;
    }
    
    if (inUserData.followerCount) {
        _loggedInUserModel.followerCount = inUserData.followerCount;
    }
    
    if (inUserData.followingCount) {
        _loggedInUserModel.followingCount = inUserData.followingCount;
    }
    
    if (inUserData.fullName) {
        _loggedInUserModel.fullName = inUserData.fullName;
    }
    
    if (inUserData.gender) {
        _loggedInUserModel.gender = inUserData.gender;
    }
    
    if (inUserData.likesCount) {
        _loggedInUserModel.likesCount = inUserData.likesCount;
    }
    
    if (inUserData.postCount) {
        _loggedInUserModel.postCount = inUserData.postCount;
    }
    
    if (inUserData.canvasImageName) {
        _loggedInUserModel.canvasImageName = inUserData.canvasImageName;
    }
    
    if (inUserData.profileImageName) {
        _loggedInUserModel.profileImageName = inUserData.profileImageName;
    }
    if (inUserData.snippetImageName) {
        _loggedInUserModel.snippetImageName = inUserData.snippetImageName;
    }
    
    if (inUserData.snippetPosition) {
        _loggedInUserModel.snippetPosition = inUserData.snippetPosition;
    }
    
    if (inUserData.statusMessage) {
        _loggedInUserModel.statusMessage = inUserData.statusMessage;
    }
    
    if (inUserData.userID) {
        _loggedInUserModel.userID = inUserData.userID;
    }
    if (inUserData.userName) {
        _loggedInUserModel.userName = inUserData.userName;
    }
    
}


// SignUp to Describe App.
#pragma mark SignUp
- (void)postSignUpWithUsername:(NSString *)username
                      password:(NSString *)password
                         email:(NSString *)email
                      fullName:(NSString *)fullName
                     OAuthType:(NSString *)gatewayName
                       OAuthID:(NSString *)idFromGateway
{
    if (![self checkTheInterConnection]) return;

    NSDictionary* userDetails = @{@"Username": username, @"UserEmail":email,@"UserPwd":password,@"UserFullName":fullName,@"GateWay":gatewayName,@"GateWayId":idFromGateway};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/postUserSignup", BaseURLString]
       parameters:userDetails
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [self postSignUpResult:responseObject error:Nil];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self postSignUpResult:Nil error:error];
          }
     ];
}

- (void)postSignUpResult:(id)inResult error:(NSError*)inError
{
    if(_delegate && [_delegate respondsToSelector:@selector(signUpStatus:error:)]) {
        [_delegate signUpStatus:inResult error:nil];
    }
}


-(void)signInWithSocialNetwork:(NSString*)inGateWay
              andGateWauTokern:(NSString *)inGatewayToken;
{
    
    NSString *url = [NSString stringWithFormat:@"%@/getUserSignin/format=json/GateWay=%@/GateWayToken=%@", BaseURLString,inGateWay,inGatewayToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDict = (NSDictionary *)responseObject;
             NSDictionary *userDataDict = (NSDictionary *)responseDict[@"DataTable"][0][@"UserData"];
             UsersModel *userModelObj = [[UsersModel alloc] initWithDictionary:userDataDict];
             _loggedInUserModel = userModelObj;
             NSDictionary *signInResponseDict = @{WS_RESPONSEDICT_KEY_RESPONSEDATA: responseObject, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:kWebserviesType_SignIn]};
             [_delegate didFinishWSConnectionWithResponse:signInResponseDict];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSDictionary *responseDict = @{WS_RESPONSEDICT_KEY_ERROR: error, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:kWebserviesType_SignIn]};
             [_delegate didFinishWSConnectionWithResponse:responseDict];
         }
     ];
    
    
    
    
}
#pragma mark BasicInfo
-  (void)postBasicInfoWithUserUID:(NSString*)inUID
                     userBioData:(NSString*)inBioData
                        userCity:(NSString*)inUserCity
                         userDob:(NSString*)inUserDob
                      userGender:(NSString*)inuserGender
                      profilePic:(UIImage*)inImage
{
    if (![self checkTheInterConnection]) return;
    NSData *imgData = UIImageJPEGRepresentation(inImage, 0.8);
    NSString *imgEncodedString = [imgData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    if(imgEncodedString == nil) {
        imgEncodedString = @"";
    }
    NSDictionary* parameters = @{@"UserUID": inUID, @"UserBiodata":inBioData,@"UserCity":inUserCity,@"UserDob":inUserDob,@"UserGender":inuserGender, @"profilePic":imgEncodedString};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [manager POST:[NSString stringWithFormat:@"%@/setUserBasicInfo",BaseURLString]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // NSLog(@"%s Success: %@",  __func__, responseObject);
              if(_delegate != nil && [_delegate respondsToSelector:@selector(didFinishWSConnectionWithResponse:)]) {
                  NSDictionary *responseDict = @{WS_RESPONSEDICT_KEY_RESPONSEDATA: responseObject, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:kWebservicesType_SaveBasicInfo]};
                  NSDictionary *basicInfodic = (NSDictionary *)responseObject;
                  NSDictionary *userDataDict = (NSDictionary *)basicInfodic[@"DataTable"][0][@"UserData"];
                  UsersModel *userModelObj = [[UsersModel alloc] initWithDictionary:userDataDict];
                  [self updateTheuserModelObject:userModelObj];
                  [_delegate didFinishWSConnectionWithResponse:responseDict];
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%s Error: %@",  __func__, error.localizedDescription);
              if(_delegate != nil && [_delegate respondsToSelector:@selector(didFinishWSConnectionWithResponse:)]) {
                  NSDictionary *responseDict = @{WS_RESPONSEDICT_KEY_ERROR: error, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:kWebservicesType_SaveBasicInfo]};
                  [_delegate didFinishWSConnectionWithResponse:responseDict];
              }
          }
     ];
}

#pragma mark ResetPassword
- (void)resetPassword:(NSString*)inUserEmailID
{
    if (![self checkTheInterConnection]) return;
    NSString *ur = [NSString stringWithFormat:@"%@/getUserForgotPassword/format=json/userEmailID=%@", BaseURLString,inUserEmailID];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:ur
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [self resetPasswordResult:responseObject error:nil];
         }
         failure:^(AFHTTPRequestOperation *operation,  id responseObject) {
             [self resetPasswordResult:nil error:nil];
         }
     ];
}

- (void)resetPasswordResult:(id)inReslut error:(NSError*)inError
{
    if(_delegate && [_delegate respondsToSelector:@selector(resetPasswordStatus:error:)]) {
        [_delegate resetPasswordStatus:inReslut error:Nil];
    }
}

#pragma mrak SearchResult
- (void)getSearchDetailsUserID:(NSString*)inUserID
                   searchType:(NSString*)inSearchType
                   searchWord:(NSString*)inSearchString;
{
    if (![self checkTheInterConnection]) return;
    //http://mirusstudent.com/service/describe-service/getSearchPeople/format=json/UserUID=1/SearchWord=a
    NSString *ur = [NSString stringWithFormat:@"%@/getSearchPeople/format=json/UserUID=%@/SearchWord=%@", BaseURLString,inUserID,inSearchString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:ur
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [self getSearchDetails:responseObject error:nil];
         }
         failure:^(AFHTTPRequestOperation *operation,  id responseObject) {
             [self getSearchDetails:responseObject error:nil];
         }
     ];
}

- (void)getSearchDetails:(id)inResult error:(NSError *)error
{
    if(_delegate && [_delegate respondsToSelector:@selector(getSearchDetails:error:)]) {
        [_delegate getSearchDetails:inResult error:Nil];
    }
}

#pragma mark CheckTheSocialId with DescriveServer
- (void)checkTheSocialIDwithDescriveServerCheckType:(NSString*) inCheckType
                                     andCheckValue:(NSString*)inCheckValue
{
    if (![self checkTheInterConnection]) return;
    //http://www.mirusstudent.com/service/describe-service/checkExistUsers/format=json/
    //chkType=Username/chkValue=shekardfdf
    NSString *ur = [NSString stringWithFormat:@"%@/checkExistUsers/format=json/chkType=%@/chkValue=%@", BaseURLString,inCheckType,inCheckValue];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:ur
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if(_delegate && [_delegate respondsToSelector:@selector(chekTheExistingUser:error:)]) {
                 [_delegate chekTheExistingUser:responseObject error:nil];
             }
         }
         failure:^(AFHTTPRequestOperation *operation,  id responseObject) {
             if(_delegate && [_delegate respondsToSelector:@selector(chekTheExistingUser:error:)]) {
                 [_delegate chekTheExistingUser:responseObject error:nil];
             }
         }
     ];
}

#pragma mark SendTheSocialFriendsToServer
- (void)sendTheSocialFriensToServeUserUID:(NSString*)inUserUID
                                  gateWay:(NSString*)inGateWay
                                      IDs:(NSString*)inIDs
{
    if (![self checkTheInterConnection]) return;
    //http://mirusstudent.com/service/describe-service/postInvitations/UserUID=1/GateWay=FB/IDs=100002615683191,100007710180215,
    NSDictionary* userDetails = @{@"UserUID":inUserUID, @"GateWay":inGateWay,@"IDs":inIDs};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/postInvitations",BaseURLString]
       parameters:userDetails
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if(_delegate && [_delegate respondsToSelector:@selector(getThePeopleListFromServer:error:)]) {
                  [_delegate getThePeopleListFromServer:responseObject  error:nil];
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if(_delegate && [_delegate respondsToSelector:@selector(getThePeopleListFromServer:error:)]) {
                  [_delegate getThePeopleListFromServer:nil error:nil];
              }
          }
     ];
}

#pragma mark - Post composition
- (void)postComposition:(NSDictionary *)argDict
{
    if (![self checkTheInterConnection]) return;
    NSString *postURLString = [NSString stringWithFormat:@"%@/insertPost", BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:postURLString
       parameters:argDict
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"%s %@", __func__, responseObject);
              if(_delegate != nil && [_delegate respondsToSelector:@selector(didFinishWSConnectionWithResponse:)]) {
                  NSDictionary *responseDict = @{WS_RESPONSEDICT_KEY_RESPONSEDATA: responseObject, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:kWebservicesType_PostComposition]};
                  [_delegate didFinishWSConnectionWithResponse:responseDict];
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%s %@", __func__, error.localizedDescription);
              if(_delegate != nil && [_delegate respondsToSelector:@selector(didFinishWSConnectionWithResponse:)]) {
                  NSDictionary *responseDict = @{WS_RESPONSEDICT_KEY_ERROR: error, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:kWebservicesType_PostComposition]};
                  [_delegate didFinishWSConnectionWithResponse:responseDict];
              }
          }
     ];
}

#pragma mark - Get Notifications
- (void)getNotificationListForUser:(NSNumber *)userId
                         withSubId:(NSNumber *)subId
                     andPageNumber:(NSNumber *)pageNo
{
    if (![self checkTheInterConnection]) return;
    //2.	http://mirusstudent.com/service/describe-service/getNotifications/format=json/UserUID=4/ SubId=36/PageValue=0
    NSString *getNotificationURL = nil;
    if(subId == nil) {
        getNotificationURL = [NSString stringWithFormat:@"%@/getNotifications/format=json/UserUID=%@/PageValue=%@", BaseURLString, userId.stringValue, pageNo.stringValue];
    }
    else {
        getNotificationURL = [NSString stringWithFormat:@"%@/getNotifications/format=json/UserUID=%@/SubId=%@/PageValue=%@", BaseURLString, userId.stringValue, subId.stringValue, pageNo.stringValue];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:getNotificationURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"%s %@", __func__, responseObject);
              if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFinishFetchingNotification:error:)]) {
                  NSArray *notificationListArray = nil;
                  if([responseObject[@"DataTable"][@"NotificationsData"] isKindOfClass:[NSArray class]]) {
                      notificationListArray = (NSArray *)responseObject[@"DataTable"][@"NotificationsData"];
                  }
                  else {
                      notificationListArray = [NSArray array];
                  }
                  
                  NSMutableArray *notificationModelArray = [[NSMutableArray alloc] initWithCapacity:notificationListArray.count];
                  for(NSDictionary *notificationDict in notificationListArray) {
                      NotificationModel *notificationModel = [[NotificationModel alloc] initWithDictionary:notificationDict];
                      [notificationModelArray addObject:notificationModel];
                      notificationModel = nil;
                  }
                
                  [self.delegate didFinishFetchingNotification:(NSArray *)notificationModelArray error:nil];
              }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%s %@", __func__, error.localizedDescription);
             if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFinishFetchingNotification:error:)]) {
                 [self.delegate didFinishFetchingNotification:nil error:error];
             }
         }
     ];
}

#pragma mark getTheGenaralFeedService

- (void)getTheGenaralFeedServices:(NSString *)inUserId
                    andPageValue:(NSString *)inPageValue
{
    inUserId  = @"45";
    inPageValue = @"0";
    NSString *ur = [NSString stringWithFormat:@"%@/getFeeds/format=json/UserUID=%@/PageValue=%@", BaseURLString,inUserId,inPageValue];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:ur
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [self gettheFeeds:responseObject error:nil];
         }
         failure:^(AFHTTPRequestOperation *operation,  id responseObject) {
             [self gettheFeeds:responseObject error:nil];
         }
     ];
}

- (void)gettheFeeds:(id)responce error:(id)inError
{
    if(_delegate && [_delegate respondsToSelector:@selector(getTheGenaralFeedsFromServer:error:)]) {
        [_delegate getTheGenaralFeedsFromServer:responce error:inError];
    }
}

#pragma mark GetTheConversationDetails
- (void)getThePostConversationDetails:(NSString *)inUserId
                            andPostId:(NSString *)inPostId
{
    NSString *ur = [NSString stringWithFormat:@"%@/getPostConversationDetails/format=json/UserUID=%@/PostUID=%@", BaseURLString,inUserId,inPostId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:ur
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [self getTheCoverSationDetails:responseObject andError:nil];
         }
         failure:^(AFHTTPRequestOperation *operation,  id responseObject) {
             [self getTheCoverSationDetails:nil andError:responseObject];
         }
     ];
}

- (void)getTheCoverSationDetails:(id)inResult andError:(id)inError
{
    if(_delegate && [_delegate respondsToSelector:@selector(getThePostConversationDetailsFromServer:error:)]) {
        [_delegate getThePostConversationDetailsFromServer:inResult error:inError];
    }
}

#pragma mark getTheUserProfiles
- (void)getProfileDetailsForUserID:(NSString *)profileUserID
{
    if (![self checkTheInterConnection]) return;
    
    NSString *ur = [NSString stringWithFormat:@"%@/getUserProfile/format=json/UserUID=%@/ProfileUserUID=%@", BaseURLString, [_loggedInUserModel.userID stringValue], profileUserID];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:ur
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDict = (NSDictionary *)responseObject;
             NSDictionary *profileDict = responseDict[@"DataTable"][0];
             [self getTheProfiles:profileDict error:nil];
         }
         failure:^(AFHTTPRequestOperation *operation,  id responseObject) {
             [self getTheProfiles:responseObject error:nil];
         }
     ];
}

- (void)getTheProfiles:(id)inResponce error:(id)inError
{
    if(_delegate && [_delegate respondsToSelector:@selector(getTheUserProfileDataFromServer:error:)]) {
        [_delegate getTheUserProfileDataFromServer:inResponce error:inError];
    }
}


- (void)saveUserProfile:(UsersModel *)userDetail profilePic:(UIImage *)profileImg canvasPic:(UIImage *)canvasImg snippetPic:(UIImage *)snippetImg
{
    if (![self checkTheInterConnection]) return;
    
    NSData *profileImgData = UIImageJPEGRepresentation(profileImg, 0.8);
    NSString *profilePicStr = @"";
    if(profileImgData != nil) {
        profilePicStr = [profileImgData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    
    NSData *canvasImgData = UIImageJPEGRepresentation(canvasImg, 0.8);
    NSString *canvasPicStr = @"";
    if(canvasImgData != nil) {
        canvasPicStr = [canvasImgData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    
    NSData *snippetImgData = UIImageJPEGRepresentation(profileImg, 0.8);
    NSString *snippetPicStr = @"";
    if(snippetImgData != nil) {
        snippetPicStr = [snippetImgData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    
    NSMutableDictionary *argDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [argDict setObject:[userDetail.userID stringValue] forKey:@"UserUID"];
    [argDict setObject:(userDetail.biodata && userDetail.biodata.length) ? userDetail.biodata : @"" forKey:@"UserBiodata"];
    [argDict setObject:(userDetail.city && userDetail.city.length) ? userDetail.city : @"" forKey:@"UserCity"];
    [argDict setObject:(userDetail.statusMessage && userDetail.statusMessage.length) ? userDetail.statusMessage : @"" forKey:@"StsMsg"];
    [argDict setObject:profilePicStr forKey:@"profilePic"];
    [argDict setObject:canvasPicStr forKey:@"canvasPic"];
    [argDict setObject:snippetPicStr forKey:@"snippetPic"];
    [argDict setObject:userDetail.snippetPosition ? userDetail.snippetPosition : @"" forKey:@"yPos"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/setUserBasicInfo",BaseURLString]
       parameters:argDict
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"%s Success: %@",  __func__, responseObject);
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%s Error: %@",  __func__, error.localizedDescription);
              
          }
     ];
}

#pragma mark CheckThe Internet conncetion
- (BOOL)networkReachable
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *) &zeroAddress);
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
        if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
            // if target host is not reachable
            return NO;
        }
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
            // if target host is reachable and no connection is required
            //  then we'll assume (for now) that your on Wi-Fi
            return YES; // This is a wifi connection.
        }
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0)
             ||(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
            // ... and the connection is on-demand (or on-traffic) if the
            //     calling application is using the CFSocketStream or higher APIs
                    if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
                // ... and no [user] intervention is needed
                return YES; // This is a wifi connection.
            }
        }
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
            // ... but WWAN connections are OK if the calling application
            //     is using the CFNetwork (CFSocketStream?) APIs.
            return YES; // This is a cellular connection.
        }
    }
    return NO;
}

- (BOOL)checkTheInterConnection
{
    if (![self networkReachable]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"NetWorkConnection"
                                                         message:@"Please check the internet connection."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    return YES;
}

- (void)showLoadView
{
    if(loadingView == nil) {
        loadingView = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
        [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
    //    loadingView.delegate = self;
        loadingView.labelText = @"Loading";
        [loadingView show:YES];
    }
}

- (void)removeLoadingView
{
    if(loadingView != nil) {
        [loadingView hide:YES];
        [loadingView removeFromSuperview];
        loadingView = nil;
    }
}

#pragma mark - Remove Composition path
- (void)removeCompositionPath
{
    NSString *compositionPath = [NSString stringWithFormat:@"%@/%@", COMPOSITION_TEMP_FOLDER_PATH, COMPOSITION_DICT];
    if([[NSFileManager defaultManager] fileExistsAtPath:compositionPath]) {
        NSError *err;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:compositionPath error:&err];
        if(!success) {
            NSLog(@"%d, error = %@ \n%@", success, err.description, err.debugDescription);
        }
    }
}

#pragma mark Feed Details -
//http://mirusstudent.com/service/describe-service/getUserFeeds/format=json/UserUID=1/OtherUserUID=11
- (void)getPostDetailsOfUserId:(NSString *)userId anotherUserId:(NSString *)anotherUserId
{
    //    userId = @"1";
    //    anotherUserId = @"4";
    //http://mirusstudent.com/service/describe-servicegetUserFeeds/format=json/UserUID=45/OtherUserUID=45
    //http://mirusstudent.com/service/describe-service/getUserFeeds/format=json/UserUID=45/OtherUserUID=45
    NSString *ur = [NSString stringWithFormat:@"%@/getUserFeeds/format=json/UserUID=%@/OtherUserUID=%@", BaseURLString, userId, anotherUserId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:ur
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"Feed Details: %@",responseObject);
             [self getPostDetailsResponse:responseObject withError:nil];
         }
         failure:^(AFHTTPRequestOperation *operation,  id responseObject) {
             NSLog(@"Feed Details Failed: %@", responseObject);
             [self getPostDetailsResponse:responseObject withError:nil];
         }
     ];
}

-(void)getPostDetailsResponse:(NSDictionary *)response withError:(NSError *)error
{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(getPostDetailsResponse:withError:)])
    {
        [_delegate getPostDetailsResponse:response withError:error];
    }
}


#pragma mark Like Post
- (void)likePost:(NSString *)postId userId:(NSString *)userId authUserId:(NSString *)authUID status:(NSInteger)count
{
    NSString *ur = [NSString stringWithFormat:@"%@/makeLike/format=json/UserUID=%@/AuthUserUID=%@/PostUID=%@/likeStatus=%d", BaseURLString, userId, authUID, postId, count];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:ur
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"Like Status: %@",responseObject);
             [self likeStatus:responseObject withError:nil];
         }
         failure:^(AFHTTPRequestOperation *operation,  id responseObject) {
             NSLog(@"Like Status Failed: %@", responseObject);
             [self likeStatus:nil withError:responseObject];
         }
     ];
}

-(void)likeStatus:(id)status withError:(NSError *)error
{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(likeStatus:withError:)])
    {
        [_delegate likeStatus:status withError:error];
    }
}


-(void)getWeRecommendedpeople:(NSString*)userId GateWay:(NSString*)inGateWay Accesstoken:(NSString*)accessToken AndRange:(NSString*)inRange;
{
    if (![self checkTheInterConnection]) return;
    
    if(accessToken == nil)
    {
        [_delegate didFinishWSConnectionWithResponse:nil];
        return;
    }
    
    
    NSDictionary* userDetails = @{@"UserUID":userId, @"GateWay":inGateWay,@"accessToken":accessToken,@"range":inRange};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/getWeRecommendedList", BaseURLString]
       parameters:userDetails
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDict = @{WS_RESPONSEDICT_KEY_RESPONSEDATA: responseObject, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:kWebserviesType_addPeople_wRecommended]};
              [_delegate didFinishWSConnectionWithResponse:responseDict];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSDictionary *responseDict = @{WS_RESPONSEDICT_KEY_ERROR: error, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:kWebserviesType_addPeople_wRecommended]};
              [_delegate didFinishWSConnectionWithResponse:responseDict];
          }
     ];
}


-(void)getInvitationListpeople:(NSString*)userId GateWay:(NSString*)inGateWay Accesstoken:(NSString*)accessToken AndRange:(NSString*)inRange;
{
    if (![self checkTheInterConnection]) return;
    
    NSDictionary* userDetails = @{@"UserUID":userId, @"GateWay":inGateWay,@"accessToken":accessToken,@"range":inRange};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/getInvitationList", BaseURLString]
       parameters:userDetails
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDict = @{WS_RESPONSEDICT_KEY_RESPONSEDATA: responseObject, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:kWebserviesType_addPeople_wInvitations]};
              [_delegate didFinishWSConnectionWithResponse:responseDict];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSDictionary *responseDict = @{WS_RESPONSEDICT_KEY_ERROR: error, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:kWebserviesType_addPeople_wInvitations]};
              [_delegate didFinishWSConnectionWithResponse:responseDict];
          }
     ];
}

-(void)followingTheUseruserId:(NSString*)userId
                  otherUserId:(NSString*)friendUserId
{
    //
    // http://mirusstudent.com/service/describe-service/getBeAFollower/UserUID=8/OtherUserId=4
    
    NSString *url = [NSString stringWithFormat:@"%@/getBeAFollower/UserUID=%@/OtherUserId=%@", BaseURLString,userId,friendUserId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *signInResponseDict = @{WS_RESPONSEDICT_KEY_RESPONSEDATA: responseObject, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:KWebserviesType_followand]};
             [_delegate didFinishWSConnectionWithResponse:signInResponseDict];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSDictionary *responseDict = @{WS_RESPONSEDICT_KEY_ERROR: error, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:KWebserviesType_followand]};
             [_delegate didFinishWSConnectionWithResponse:responseDict];
         }
     ];
    
}

-(void)unfollowingTheUseruserId:(NSString*)userId
                    otherUserId:(NSString*)friendUserId
{
    //  http://mirusstudent.com/service/describe-service/getUnFollower/UserUID=8/OtherUserId=7
    NSString *url = [NSString stringWithFormat:@"%@/getUnFollower/UserUID=%@/OtherUserId=%@", BaseURLString,userId,friendUserId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *signInResponseDict = @{WS_RESPONSEDICT_KEY_RESPONSEDATA: responseObject, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:KWebserviesType_unfollowand]};
             [_delegate didFinishWSConnectionWithResponse:signInResponseDict];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSDictionary *responseDict = @{WS_RESPONSEDICT_KEY_ERROR: error, WS_RESPONSEDICT_KEY_SERVICETYPE:[NSNumber numberWithInteger:KWebserviesType_unfollowand]};
             [_delegate didFinishWSConnectionWithResponse:responseDict];
         }
     ];
    
}


-(void)deletePost:(NSString *)postid response:(void (^)(BOOL success, id response))response
{
    NSString *url = [NSString stringWithFormat:@"%@/deleteThePost/format=json/PostUID=%@", BaseURLString,postid];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             response(YES, responseObject);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          response(NO, error);
                      }
     ];
}

-(void)reportPost:(NSString *)postid userId:(NSString *)userId response:(void (^)(BOOL success, id response))response
{
    NSString *url = [NSString stringWithFormat:@"%@/reportThePost/format=json/UserUID=%@/PostUID=%@", BaseURLString, userId, postid];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             response(YES, responseObject);
                      }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           response(NO, error);
         }
     ];
}

//Comment the post....
-(void)commentUserId:(NSString *)userId authUId:(NSString *)authId post:(NSString *)postid comment:(NSString *)comment response:(void (^)(BOOL success, id response))response
{
    NSString *url = [NSString stringWithFormat:@"%@/UserUID=%@/AuthUserUID=%@/PostUID=%@/comment=%@", BaseURLString, userId, authId, postid, comment];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             response(YES, responseObject);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             response(NO, error);
         }
     ];
}

@end
