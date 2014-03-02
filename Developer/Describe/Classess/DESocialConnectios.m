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
    });
    return _sharedInstance;
    
    
}
// Google Plus
#pragma mark Get the Friends List from google plus

- (void)googlePlusSignIn
{
    GPPSignIn *signedIn = [GPPSignIn sharedInstance];
    signedIn.delegate = self;
    signedIn.shouldFetchGoogleUserEmail = YES;
    signedIn.shouldFetchGooglePlusUser = YES;
    signedIn.clientID = kClientID;
    signedIn.scopes = [NSArray arrayWithObjects:kGTLAuthScopePlusLogin,kGTLAuthScopePlusMe,nil];
    signedIn.actions = [NSArray arrayWithObjects:@"http://schemas.google.com/ListenActivity",nil];
    [signedIn authenticate];
    
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


/// risperidone,risperdal


- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    //    NSLog(@"Received error %@ and auth object %@",error, auth);
    NSMutableDictionary * dataDic = [[NSMutableDictionary alloc]init];
    self.googlePlusFriendsListArry = [[NSMutableArray alloc]init];

    if (error) {
        NSLog(@"Error is %@",[error description]);
    } else {
        __block NSArray* peoplesList;
        
        GTLPlusPerson *person = [GPPSignIn sharedInstance].googlePlusUser;
        [dataDic setObject:person.name forKey:@"name"];
        [dataDic setObject:auth.userEmail forKey:@"email"];
        [dataDic setObject:person.identifier forKey:@"id"];
        [dataDic setObject:person.displayName forKey:@"displayName"];
        [dataDic setObject:person.url forKey:@"url"];
        [dataDic setObject:person.gender forKey:@"gender"];
        
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
                  
                    for (GTLPlusPerson *person  in peoplesList) {
                       // NSLog(@"Person name is %@", person.displayName);
                        //NSLog(@"Person ID is %@", person.identifier);
                        //NSLog(@"Person Image is %@", person.image);
                        ModelData * data = [[ModelData alloc]init];
                        data.userId = person.identifier;
                        [self.googlePlusFriendsListArry addObject:data];
                    }
                    if ([self.delegate respondsToSelector:@selector(googlePlusResponce:andFriendsList:)]) {
                        [self.delegate googlePlusResponce:dataDic andFriendsList:self.googlePlusFriendsListArry];
                        
                    }
                    
                }];
        
    }
   

}

#pragma mark facebook signIn

-(void)facebookSignIn
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getUserDetail)
                                                 name:@"getUserDetail"
                                               object:nil];
    
    
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        //,@"friends_birthday"
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info",@"user_photos",@"read_friendlists",@"email",@"user_birthday",@"friends_about_me"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             DESAppDelegate* appdelegate =(DESAppDelegate*) [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appdelegate sessionStateChanged:session state:state error:error];
             
         }];
    }

}

-(void)getUserDetail
{
    //NSLog (@"Successfully received the test notification!");
    
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me?fields=email,birthday,last_name,first_name,gender,location,picture"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  NSLog(@"%@",result);
                                //  [self checkTheuserSocialIdWithDescriveServer:result];
                                  
                                  [FBRequestConnection startWithGraphPath:@"/me/friends?fields=id"
                                                        completionHandler:^(FBRequestConnection *connection1, id result1, NSError *error1) {
                                                            if (!error1){
                                                                NSLog(@"friends list%@",result1);
                                                                if (self.facebookFriendsListArray==nil) {
                                                                    self.facebookFriendsListArray = [[NSMutableArray alloc]init];
                                                                }
                                                                for (NSDictionary* datadic in [result1 valueForKey:@"data"]) {
                                                                    ModelData * data = [[ModelData alloc]init];
                                                                    data.userId =[datadic valueForKey:@"id"];
                                                                   [self.facebookFriendsListArray addObject:data ];
                                                                }
                                                                if ([self.delegate respondsToSelector:@selector(googlePlusResponce:andFriendsList:)]) {
                                                                    [self.delegate googlePlusResponce:result andFriendsList:self.facebookFriendsListArray];
                                                                }
                                                            } else {
                                                                // An error occurred, we need to handle the error
                                                                // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                                                NSLog(@"%@",[NSString stringWithFormat:@"error %@", error1.description]);
                                                            }
                                                        }];
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"%@",[NSString stringWithFormat:@"error %@", error.description]);
                              }
                          }];
}


@end
