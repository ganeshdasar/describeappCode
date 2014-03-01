//
//  WSModelClasses.h
//  WebServicesTesting
//
//  Created by Pramod on 30/01/14.
//  Copyright (c) 2014 Nagaraja Velicharla. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WSModelClassDelegate <NSObject>

@optional
- (void)loginStatus:(NSDictionary *)responseDict
                  error:(NSError *)error;

- (void)signUpStatus:(NSDictionary *)responseDict error:(NSError *)error;

- (void)basicinfoStatus:(NSDictionary *)responseDict error:(NSError *)error;

- (void)resetPasswordStatus:(NSDictionary *)responseDict error:(NSError *)error;

- (void)getSearchDetails:(NSDictionary *)responseDict error:(NSError *)error;

- (void)chekTheExistingUser:(NSDictionary *)responseDict error:(NSError *)error;

-(void)getThePeopleListFromServer:(NSDictionary *) responceDict error:(NSError*)error;


@end

@interface WSModelClasses : NSObject


@property (nonatomic, assign) id <WSModelClassDelegate> delegate;
BOOL networkReachable();
-(BOOL)checkTheInterConnection;
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
-(void)postBasicInfoWithUserUID:(NSString*)inUID
                              userBioData:(NSString*)inBioData
                                    userCity:(NSString*)inUserCity
                                    userDob:(NSString*)inUserDob
                                userGender:(NSString*)inuserGender
                                   profilePic:(UIImage*)inImage;

#pragma mark ResetPassword
-(void)resetPassword:(NSString*)inUserEmailID;

#pragma mark Searchby people

-(void)getSearchDetailsUserID:(NSString*)inUserID
                           searchType:(NSString*)inSearchType
                           searchWord:(NSString*)inSearchString;

#pragma mark CheckTheSocialId with DescriveServer
-(void)checkTheSocialIDwithDescriveServerCheckType:(NSString*) inCheckType
                                                      andCheckValue:(NSString*)inCheckValue;


#pragma mark SendTheSocialFriendsToServer

-(void)sendTheSocialFriensToServeUserUID:(NSString*)inUserUID
                                                 gateWay:(NSString*)inGateWay
                                                       IDs:(NSString*)inIDs;
@end
