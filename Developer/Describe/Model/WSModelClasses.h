
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
    kWebserviesType_addPeople_wRecommended,
    kWebserviesType_addPeople_wInvitations,
    KWebserviesType_followand,
    KWebserviesType_unfollowand,
    KWebserviesType_invitations

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

- (void)updateTheuserModelObject:(UsersModel*)inUserData;
- (void)getPostDetailsOfUserId:(NSString *)userId andRange:(NSInteger)range;
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


-(void)getWeRecommendedpeople:(NSString*)userId GateWay:(NSString*)inGateWay Accesstoken:(NSString*)accessToken AndRange:(NSInteger)inRange;
-(void)getInvitationListpeople:(NSString*)userId GateWay:(NSString*)inGateWay Accesstoken:(NSString*)accessToken AndRange:(NSInteger)inRange;

//    //http://mirusstudent.com/service/describe-service/getBeAFollower/UserUID=8/OtherUserId=4

-(void)followingTheUseruserId:(NSString*)userId
                  otherUserId:(NSString*)friendUserId;

-(void)unfollowingTheUseruserId:(NSString*)userId
                    otherUserId:(NSString*)friendUserId;

// http://mirusstudent.com/service/describe-service/getUnFollower/UserUID=8/OtherUserId=7

-(void)deletePost:(NSString *)postid response:(void (^)(BOOL success, id response))response;
-(void)reportPost:(NSString *)postid userId:(NSString *)userId response:(void (^)(BOOL success, id response))response;



-(void)commentUserId:(NSString *)userId authUId:(NSString *)authId post:(NSString *)postid comment:(NSString *)comment response:(void (^)(BOOL success, id response))response;
-(void)sendGateWayInvitationUserId:(NSString*)userid gateWayType:(NSString*)gateWayType gateWayToken:(NSString*)gateWayToken userName:(NSString*)userName;

#pragma mark Settings Services
-(void)checkingTheUserPassword:(NSString*)password UserUID:(NSString*)userID response:(void (^)(BOOL success, id response))response;

-(void)updateTheUserEmaiIdAndPassword:(NSString*)emilId AndPassword:(NSString*)password responce:(void(^)(BOOL success, id response))response;

-(void)getTheUserPushNotificationresponce:(void(^)(BOOL success, id response))response;

-(void)updatTheUserPushNotifications:(NSNumber*)likeStatus CommentsStatus:(NSNumber*)commentSts mymentionsStatus:(NSNumber*)metionsStc followsStatus:(NSNumber*)followStc responce:(void(^)(BOOL success, id response))response;

-(void)getTHeUserEmailNotificationsresponce:(void(^)(BOOL success, id response))response;

-(void)updatTheUserEmailNotifications:(NSNumber*)likeStatus CommentsStatus:(NSNumber*)commentSts mymentionsStatus:(NSNumber*)metionsStc followsStatus:(NSNumber*)followStc activityUpdates:(NSNumber*)activitystc importentUpdates:(NSNumber*)importentStc responce:(void(^)(BOOL success, id response))response;
//http://mirusstudent.com/service/describe-service/updateUserInfoSettings/UserUID=1/UserFullName=shekahr/UserCity=hyderabad/UserDob=yyyy-mm-dd/UserGender=1/UserBiodata=biodataoftheuser

-(void)updateTheUserInformationDataUSerID:(NSString*)userId userName:(NSString*)userName userCity:(NSString*)city userDob:(NSString*)dob userGender:(NSString*)gender userBioData:(NSString*)bioData responce:(void(^)(BOOL success, id response))response;


- (void)getPostDetailsOfUserId:(NSString *)userId anotherUserId:(NSString *)anotherUserId response:(void (^)(BOOL success, id response))response;
-(void)getFeedForThisTag:(NSString *)tag forUser:(NSString *)userId andRange:(NSInteger)range response:(void (^)(BOOL success, id response))response;

#pragma mark followAllAndInviteAll
-(void)followAllActionUserID:(NSString*)userId followAllString:(NSString*)followAll rageValue:(NSString*)rangeValue responce:(void(^)(BOOL success, id responce))responce;

-(void)inviteAllActionUserID:(NSString*)userId inviteAllString:(NSString*)followAll rageValue:(NSString*)rangeValue responce:(void(^)(BOOL success, id responce))responce;


-(void)getFollowingListForUserId:(NSString *)currentUserId ofPersons:(NSString *)profileId pageNumber:(NSInteger )pageNumber  response:(void (^)(BOOL success, id response))response;
-(void)getFollowersListForUserId:(NSString *)currentUserId ofPersons:(NSString *)profileId pageNumber:(NSInteger )pageNumber  response:(void (^)(BOOL success, id response))response;

-(void)reportComment:(NSString *)commentId forUser:(NSString *)userId response:(void (^)(BOOL success, id response))response;

@end
