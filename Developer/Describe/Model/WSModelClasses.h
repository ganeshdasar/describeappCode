//
//  WSModelClasses.h
//  WebServicesTesting
//
//  Created by Pramod on 30/01/14.
//  Copyright (c) 2014 Nagaraja Velicharla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsersModel.h"

typedef enum {
    kWebservicesType_SaveBasicInfo = 0,
    kWebservicesType_PostComposition,
    kWebserviesType_SignIn,
    kWebserviesType_addPeople
}WebservicesType;

@protocol WSModelClassDelegate <NSObject>

@optional
- (void)loginStatus:(NSDictionary *)responseDict error:(NSError *)error;

- (void)signUpStatus:(NSDictionary *)responseDict error:(NSError *)error;

- (void)resetPasswordStatus:(NSDictionary *)responseDict error:(NSError *)error;

- (void)getSearchDetails:(NSDictionary *)responseDict error:(NSError *)error;

- (void)chekTheExistingUser:(NSDictionary *)responseDict error:(NSError *)error;

-(void)getThePeopleListFromServer:(NSDictionary *) responceDict error:(NSError*)error;

-(void)getThePostConversationDetailsFromServer:(NSDictionary *) responceDict error:(NSError*)error;

-(void)getTheGenaralFeedsFromServer:(NSDictionary *) responceDict error:(NSError *) error;

-(void)getTheUserProfileDataFromServer:(NSDictionary *) responceDict error:(NSError *) error;

- (void)didFinishFetchingNotification:(NSArray *)responseList error:(NSError *)error;

- (void)didFinishWSConnectionWithResponse:(NSDictionary *)responseDict;


- (void)basicinfoStatus:(NSDictionary *)responseDict error:(NSError *)error;
-(void)getPostDetailsResponse:(NSDictionary *)response withError:(NSError *)error;

-(void)likeStatus:(id)status withError:(NSError *)error;

@end

@interface WSModelClasses : NSObject

@property (nonatomic, assign) id <WSModelClassDelegate> delegate;
@property (nonatomic, strong) UsersModel *loggedInUserModel;

- (BOOL)networkReachable;

- (BOOL)checkTheInterConnection;

- (void)removeCompositionPath;

- (void)showLoadView;

- (void)removeLoadingView;

+ (instancetype)sharedHandler;

#pragma mark signIn
- (void)getSignInWithUsername:(NSString *)username
                     password:(NSString *)password;

#pragma mark SignUp
- (void)postSignUpWithUsername:(NSString *)username
                      password:(NSString *)password
                         email:(NSString *)email
                      fullName:(NSString *)fullName
                     OAuthType:(NSString *)gatewayName
                       OAuthID:(NSString *)idFromGateway;

#pragma mark BasicInfo
- (void)postBasicInfoWithUserUID:(NSString*)inUID
                    userBioData:(NSString*)inBioData
                       userCity:(NSString*)inUserCity
                        userDob:(NSString*)inUserDob
                     userGender:(NSString*)inuserGender
                     profilePic:(UIImage*)inImage;

-(void)signInWithSocialNetwork:(NSString*)inGateWay
              andGateWauTokern:(NSString *)inGatewayToken;
#pragma mark ResetPassword
- (void)resetPassword:(NSString*)inUserEmailID;

#pragma mark Searchby people
- (void)getSearchDetailsUserID:(NSString*)inUserID
                    searchType:(NSString*)inSearchType
                    searchWord:(NSString*)inSearchString;

#pragma mark CheckTheSocialId with DescriveServer
- (void)checkTheSocialIDwithDescriveServerCheckType:(NSString*) inCheckType
                                     andCheckValue:(NSString*)inCheckValue;

#pragma mark SendTheSocialFriendsToServer
- (void)sendTheSocialFriensToServeUserUID:(NSString*)inUserUID
                                  gateWay:(NSString*)inGateWay
                                      IDs:(NSString*)inIDs;

#pragma mark - Post composition
- (void)postComposition:(NSDictionary *)argDict;

#pragma mark - Get Notifications
- (void)getNotificationListForUser:(NSNumber *)userId
                         withSubId:(NSNumber *)subId
                     andPageNumber:(NSNumber *)pageNo;

#pragma mark getTheGenaralFeedService
//http://www.mirusstudent.com/service/describe-service/getFeeds/format=json/UserUID=1/PageValue=0/
- (void)getTheGenaralFeedServices:(NSString *)inUserId
                     andPageValue:(NSString *)inPageValue;


#pragma mark GetTheConversationDetails
- (void)getThePostConversationDetails:(NSString *)inUserId
                            andPostId:(NSString *)inPostId;

#pragma mark getTheUserProfiles
//http://mirusstudent.com/service/describe-service/getUserProfile/format=json/UserUID=1/ProfileUserUID=4

- (void)getProfileDetailsForUserID:(NSString *)profileUserID;
-(void)getWeRecommendedpeople:(NSString*)inUSerId
                     AndRange:(NSString*)inRange;

- (void)saveUserProfile:(UsersModel *)userDetail
             profilePic:(UIImage *)profileImg
              canvasPic:(UIImage *)canvasImg
             snippetPic:(UIImage *)snippetImg;

- (void)getPostDetailsOfUserId:(NSString *)userId anotherUserId:(NSString *)anotherUserId;

- (void)likePost:(NSString *)postId userId:(NSString *)userId authUserId:(NSString *)authUID status:(NSInteger)count;
@end
