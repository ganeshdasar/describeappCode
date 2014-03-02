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
static WSModelClasses *_sharedInstance;

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

    NSString *ur = [NSString stringWithFormat:@"%@getUserSignin/format=json/Username=%@/UserPwd=%@", BaseURLString,username,password];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:ur
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [self loginStatus:responseObject error:nil];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self loginStatus:nil error:error];
         }
     ];
}

- (void)loginStatus:(id)status error:(NSError *)error
{
    if(_delegate && [_delegate respondsToSelector:@selector(loginStatus:error:)]) {
        [_delegate loginStatus:status error:error];
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

    NSDictionary* userDetails = @{@"Username": username, @"UserEmail":email,@"UserPwd":password,@"UserFullName":fullName,@"OAuthType":gatewayName,@"OAuthID":idFromGateway};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@postUserSignup", BaseURLString]
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

#pragma mark BasicInfo
- (void)postBasicInfoWithUserUID:(NSString*)inUID
                     userBioData:(NSString*)inBioData
                        userCity:(NSString*)inUserCity
                         userDob:(NSString*)inUserDob
                      userGender:(NSString*)inuserGender
                      profilePic:(UIImage*)inImage
{
    if (![self checkTheInterConnection]) return;

    NSData *imageData = UIImageJPEGRepresentation(inImage,0.9f);
	//NSLog(@"url string for photo is:%@",urlString);
	// setting up the request object now
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setHTTPMethod:@"POST"];
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	//retrieving user name for uploading image
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Disposition: form-data; name=\"userfile\"; filename=\"test.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:imageData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDictionary* userDetails = @{@"UserUID": inUID, @"UserBiodata":inBioData,@"UserCity":inUserCity,@"UserDob":inUserDob,@"UserGender":inuserGender,@"profilePic":body};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@setUserBasicInfo", BaseURLString]
       parameters:userDetails
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [self postbasicInfoResult:responseObject error:nil];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self postbasicInfoResult:nil error:error];
          }
     ];
}

- (void)postbasicInfoResult:(id)inResult error:(NSError*)inError
{
    if(_delegate && [_delegate respondsToSelector:@selector(basicinfoStatus:error:)]) {
        [_delegate basicinfoStatus:inResult error:nil];
    }
}

#pragma mark ResetPassword
- (void)resetPassword:(NSString*)inUserEmailID
{
    if (![self checkTheInterConnection]) return;
    
    NSString *ur = [NSString stringWithFormat:@"%@getUserForgotPassword/format=json/userEmailID=%@", BaseURLString,inUserEmailID];
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
    NSString *ur = [NSString stringWithFormat:@"%@getSearchPeople/format=json/UserUID=%@/SearchWord=%@", BaseURLString,inUserID,inSearchString];
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
    
    NSString *ur = [NSString stringWithFormat:@"%@checkExistUsers/format=json/chkType=%@/chkValue=%@", BaseURLString,inCheckType,inCheckValue];
    
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
    [manager POST:[NSString stringWithFormat:@"%@postInvitations",BaseURLString]
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
    
    NSString *postURLString = [NSString stringWithFormat:@"%@insertPost", BaseURLString];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:postURLString
       parameters:argDict
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"%s %@", __func__, responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%s %@", __func__, error.localizedDescription);
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

@end
