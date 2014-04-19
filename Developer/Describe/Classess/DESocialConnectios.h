//
//  DESocialConnectios.h
//  Describe
//
//  Created by NuncSys on 28/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <FacebookSDK/FacebookSDK.h>
@protocol DESocialConnectiosDelegate <NSObject>

@optional
- (void)googlePlusResponce:(NSMutableDictionary *)responseDict andFriendsList:(NSMutableArray*)inFriendsList;
- (void)finishedSharingGooglePlusWithError:(NSError *)error;

@end

@interface DESocialConnectios : NSObject<GPPSignInDelegate, GPPShareDelegate>


@property (nonatomic, assign) id <DESocialConnectiosDelegate> delegate;

+ (instancetype)sharedInstance;
- (void)googlePlusSignIn;
- (void)facebookSignIn;
- (void)removeTheAccessTokenInUserDefaults;
- (BOOL)isFacebookLoggedIn;
- (BOOL)isGooglePlusLoggeIn;
- (void)logoutFacebook;
- (void)logoutGooglePlus;

- (void)facebookSharing:(NSString*)inName
               picture:(NSURL*)inImage
               caption:(NSString*)inCaption
               andLink:(NSURL*)inUrl
            decription:(NSString*)inDescription;

- (void)shareLinkOnGooglePlus:(NSString *)urlLink;

@property (nonatomic,strong) NSMutableArray * googlePlusFriendsListArry;
@property (nonatomic,strong) NSMutableArray * facebookFriendsListArray;



@end
