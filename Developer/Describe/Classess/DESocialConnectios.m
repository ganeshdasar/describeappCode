//
//  DESocialConnectios.m
//  Describe
//
//  Created by NuncSys on 28/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DESocialConnectios.h"
#import "DUserData.h"
#import "DESAppDelegate.h"
#import "Constant.h"
#import "NSString+DateConverter.h"
@implementation DESocialConnectios
@synthesize googlePlusFriendsListArry;
@synthesize facebookFriendsListArray;
@synthesize delegate;

static DESocialConnectios *_sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[DESocialConnectios alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:_sharedInstance
                                                 selector:@selector(getUserDetail)
                                                     name:@"getUserDetail"
                                                   object:nil];
    });
    return _sharedInstance;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Get the Friends List from google plus
- (void)googlePlusSignIn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"googlePlusButtonClicked" object:nil];

    GPPSignIn *signedIn = [GPPSignIn sharedInstance];
    signedIn.delegate = self;
    signedIn.shouldFetchGoogleUserEmail = YES;
    signedIn.shouldFetchGooglePlusUser = YES;
    signedIn.clientID = kClientID;
    signedIn.scopes = [NSArray arrayWithObjects:kGTLAuthScopePlusLogin,kGTLAuthScopePlusMe,nil];
    signedIn.actions = [NSArray arrayWithObjects:@"http://schemas.google.com/ListenActivity",nil];
    [signedIn authenticate];
}

- (void)logoutGooglePlus
{
    GPPSignIn *signedIn = [GPPSignIn sharedInstance];
    if(signedIn.idToken != nil) {
        [signedIn disconnect];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:GOOGLEPLUESACCESSTOKEN]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:GOOGLEPLUESACCESSTOKEN];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:GOOGLEPLUSEXPIRATIONDATE];
    }
}

- (BOOL)isGooglePlusLoggeIn
{
    return ([GPPSignIn sharedInstance].idToken != nil);
}

- (GTLServicePlus *)plusService
{
    static GTLServicePlus* service = nil;
    if (!service) {
        service = [[GTLServicePlus alloc] init];
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.retryEnabled = YES;
        // Have the service object set tickets to automatically fetch additional
        // pages of feeds when the feed's maxResult value is less than the number
        // of items in the feed
        service.shouldFetchNextPages = YES;
    }
    return service;
}


- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    // NSLog(@" %s Received error %@ and auth object %@",__func__,error, auth);
    [self insertTheGooglePluseAccessToken:auth.accessToken andExpiratonDate:auth.expirationDate];
    NSMutableDictionary * dataDic = [[NSMutableDictionary alloc]init];
    self.googlePlusFriendsListArry = [[NSMutableArray alloc]init];
    if (error) {
        NSLog(@"Error is %@",[error description]);
        if ([self.delegate respondsToSelector:@selector(googlePlusResponce:andFriendsList:)]) {
            [self.delegate googlePlusResponce:nil andFriendsList:nil];
        }
    } else {
        __block NSArray* peoplesList;
        GTLPlusPerson *person = [GPPSignIn sharedInstance].googlePlusUser;
        
        [dataDic setObject:person.name forKey:@"name"];
        [dataDic setObject:auth.userEmail forKey:@"email"];
        [dataDic setObject:person.identifier forKey:@"id"];
        [dataDic setObject:person.displayName forKey:@"displayName"];
        [dataDic setObject:person.url forKey:@"url"];
        [dataDic setObject:person.gender forKey:@"gender"];
        if (person.birthday){
            [dataDic setObject:[NSString convertThesocialNetworkDateToepochtime:person.birthday] forKey:@"dob"];
       if (person.currentLocation)  [dataDic setObject:person.currentLocation forKey:@"city"];
        }
        
        [[NSUserDefaults standardUserDefaults]setObject:person.identifier forKey:Google_plus_ID];
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        plusService.retryEnabled = YES;
        [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
        GTLQueryPlus *query =
        [GTLQueryPlus queryForPeopleListWithUserId:@"me"
                                        collection:kGTLPlusCollectionVisible];
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPeopleFeed *peopleFeed,
                                    NSError *error) {
                    if (error) {
                        GTMLoggerError(@"Error: %@", error);
                        return ;
                    } else {
                        peoplesList = peopleFeed.items;
                    }
//                    for (GTLPlusPerson *person  in peoplesList) {
//                    }
                    if ([self.delegate respondsToSelector:@selector(googlePlusResponce:andFriendsList:)]) {
                        [self.delegate googlePlusResponce:dataDic andFriendsList:nil];
                    }
                }];
    }
}

#pragma mark google plus sharing

- (void)shareLinkOnGooglePlus:(NSString *)urlLink
{
    [GPPShare sharedInstance].delegate = self;
    
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    
    // This line will fill out the title, description, and thumbnail from
    // the URL that you are sharing and includes a link to that URL.
    [shareBuilder setURLToShare:[NSURL URLWithString:urlLink]];
    
    [shareBuilder open];
}

- (void)finishedSharingWithError:(NSError *)error
{
    NSString *text;
    
    if (!error) {
        text = @"Success";
    } else if (error.code == kGPPErrorShareboxCanceled) {
        text = @"Canceled";
    } else {
        text = [NSString stringWithFormat:@"Error (%@)", [error localizedDescription]];
    }
    
    NSLog(@"Status: %@", text);
    
    if(delegate != nil && [delegate respondsToSelector:@selector(finishedSharingGooglePlusWithError:)]) {
        [delegate finishedSharingGooglePlusWithError:error];
    }
}

#pragma mark facebook signIn
- (void)facebookSignIn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"faceBookButtonClicked" object:nil];
    
    // If the session state is  any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        DESAppDelegate* appdelegate =(DESAppDelegate*) [UIApplication sharedApplication].delegate;
        // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
        [appdelegate sessionStateChanged:FBSession.activeSession state:FBSession.activeSession.state error:nil];
        
    }
    else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info",@"user_photos",@"read_friendlists",@"email",@"user_birthday",@"friends_about_me"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Retrieve the app delegate
                                         [self insertTheFacebookAccessTokenData:session.accessTokenData.accessToken andExpirationData:session.accessTokenData.expirationDate];
                                         DESAppDelegate* appdelegate = (DESAppDelegate*) [UIApplication sharedApplication].delegate;
                                         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
                                         [appdelegate sessionStateChanged:session state:state error:error];
                                         
                                         if(error) {
                                             if ([self.delegate respondsToSelector:@selector(googlePlusResponce:andFriendsList:)]) {
                                                 [self.delegate googlePlusResponce:nil andFriendsList:nil];
                                             }
                                         }
                                      }];
    }

}

- (void)logoutFacebook
{
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOKACCESSTOKENKEY]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:FACEBOOKACCESSTOKENKEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:FACEBOOKEXPIRATIONDATE];
    }
}

- (BOOL)isFacebookLoggedIn
{
    return ((FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) && [[NSUserDefaults standardUserDefaults] objectForKey:@"FACEBOOKACCESSTOKENKEY"]);
}

- (void)getUserDetail
{
    //NSLog (@"Successfully received the test notification!");
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me?fields=email,birthday,last_name,first_name,gender,location,picture"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  //  NSLog(@"%@",result);
                                  [[NSUserDefaults standardUserDefaults]setObject:[result objectForKey:@"id"] forKey:FACEBOK_ID];
                                  [FBRequestConnection startWithGraphPath:@"/me/friends?fields=id"
                                                        completionHandler:^(FBRequestConnection *connection1, id result1, NSError *error1) {
                                                            if (!error1) {
                                                                if ([self.delegate respondsToSelector:@selector(googlePlusResponce:andFriendsList:)]) {
                                                                    [self.delegate googlePlusResponce:result andFriendsList:nil];
                                                                }
                                                            } else {
                                                                // An error occurred, we need to handle the error
                                                                // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                                                NSLog(@"%@",[NSString stringWithFormat:@"error %@", error1.description]);
                                                                if ([self.delegate respondsToSelector:@selector(googlePlusResponce:andFriendsList:)]) {
                                                                    [self.delegate googlePlusResponce:nil andFriendsList:nil];
                                                                }
                                                            }
                                                        }];
                                                            } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"%@",[NSString stringWithFormat:@"error %@", error.description]);
                              }
                          }];
}

#pragma mark insert accesstoken in userdefaults
-(void)insertTheFacebookAccessTokenData:(NSString*)inAccessToken andExpirationData:(NSDate*)inExpirationDate
{
    [[NSUserDefaults standardUserDefaults]setObject:inAccessToken forKey:FACEBOOKACCESSTOKENKEY];
    [[NSUserDefaults standardUserDefaults]setObject:inExpirationDate forKey:FACEBOOKEXPIRATIONDATE];
    
}


-(void)removeTheAccessTokenInUserDefaults
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:FACEBOOKACCESSTOKENKEY];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:FACEBOOKEXPIRATIONDATE];
   
}

-(void)insertTheGooglePluseAccessToken:(NSString*)inAccessToken andExpiratonDate:(NSDate*)inExpirationDate
{
    [[NSUserDefaults standardUserDefaults]setObject:inAccessToken forKey:GOOGLEPLUESACCESSTOKEN];
    [[NSUserDefaults standardUserDefaults]setObject:inExpirationDate forKey:GOOGLEPLUSEXPIRATIONDATE];
    
}

#pragma mark facebook sharing
- (void)facebookSharing:(NSString*)inName
                     picture:(NSURL*)inImage
               caption:(NSString*)inCaption
                  andLink:(NSURL*)inUrl
              decription:(NSString*)inDescription
{
    // Check if the Facebook app is installed and we can present the share dialog
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    
    params.link = inUrl;//[NSURL URLWithString:@"http://www.youtube.com/watch?v=CGyAaR2aWcA"];
    params.name = inName;//@"Sharing Tutorial";
    params.caption =inCaption;// @"Build great social apps and get more installs.";
    params.picture = inImage;//[NSURL URLWithString:@"http://static.ibnlive.in.com/ibnlive/pix/sitepix/04_2013/main2states-apr21.jpg"];
    params.description =inDescription;// @"Allow your users to share stories on Facebook from your app using the iOS SDK.";
    
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                         name:params.name
                                      caption:params.caption
                                  description:params.description
                                      picture:params.picture
                                  clientState:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                            //  NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK: publish just a link using the Feed dialog
        
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Sharing Tutorial", @"name",
                                       @"Build great social apps and get more installs.", @"caption",
                                       @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
                                       @"https://developers.facebook.com/docs/ios/share/", @"link",
                                       @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                       nil];
        
        NSLog(@" parameters %@",params);
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                       //   NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User canceled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User canceled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}


- (NSDictionary*)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

@end

