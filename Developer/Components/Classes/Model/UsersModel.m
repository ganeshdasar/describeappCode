//
//  UsersModel.m
//  Composition
//
//  Created by Describe Administrator on 01/03/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "UsersModel.h"
#import "NotificationModel.h"

#define DATABASE_TABLE_USERS         @"UserTable"

@implementation UsersModel

#pragma mark - Life Cycle

- (id)initWithDictionary:(NSDictionary *)userDict
{
    if(self = [super init]) {
        if(userDict[USER_MODAL_KEY_UID] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_UID]] ) {
            self.userID = [NSNumber numberWithInteger:[userDict[USER_MODAL_KEY_UID] integerValue]];
        }
        
        if(userDict[USER_MODAL_KEY_EMAIL] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_EMAIL]] ) {
            self.userEmail = userDict[USER_MODAL_KEY_EMAIL];
        }
        
        if(userDict[USER_MODAL_KEY_USERNAME] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_USERNAME]] ) {
            self.userName = userDict[USER_MODAL_KEY_USERNAME];
        }
        
        if(userDict[USER_MODAL_KEY_FULLNAME] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_FULLNAME]] ) {
            self.fullName = userDict[USER_MODAL_KEY_FULLNAME];
        }
        
        if(userDict[USER_MODAL_KEY_DOB] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_DOB]] ) {
            self.dobDate = [NSNumber numberWithDouble:[userDict[USER_MODAL_KEY_DOB] doubleValue]];
        }
        
        if(userDict[USER_MODAL_KEY_GENDER] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_GENDER]] ) {
            self.gender = [NSNumber numberWithInteger:[userDict[USER_MODAL_KEY_GENDER] integerValue]];
        }
        
        if(userDict[USER_MODAL_KEY_PROFILEPIC] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_PROFILEPIC]] ) {
            self.profileImageName = userDict[USER_MODAL_KEY_PROFILEPIC];
        }
        
        if(userDict[USER_MODAL_KEY_PROFILECANVAS] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_PROFILECANVAS]] ) {
            self.canvasImageName = userDict[USER_MODAL_KEY_PROFILECANVAS];
        }
        
        if(userDict[USER_MODAL_KEY_SNIPPETIMAGE] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_SNIPPETIMAGE]] ) {
            self.snippetImageName = userDict[USER_MODAL_KEY_SNIPPETIMAGE];
        }
        
        if(userDict[USER_MODAL_KEY_SNIPPETPOSITION] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_SNIPPETPOSITION]] ) {
            self.snippetPosition = userDict[USER_MODAL_KEY_SNIPPETPOSITION];
        }
        
        if(userDict[USER_MODAL_KEY_STATUSMESSAGE] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_STATUSMESSAGE]] ) {
            self.statusMessage = userDict[USER_MODAL_KEY_STATUSMESSAGE];
        }
        
        if(userDict[USER_MODAL_KEY_BIODATA] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_BIODATA]] ) {
            self.biodata = userDict[USER_MODAL_KEY_BIODATA];
        }
        
        if(userDict[USER_MODAL_KEY_CITY] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_CITY]] ) {
            self.city = userDict[USER_MODAL_KEY_CITY];
        }
        
        if(userDict[USER_MODAL_KEY_LIKESCOUNT] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_LIKESCOUNT]] ) {
            self.likesCount = [NSNumber numberWithInteger:[userDict[USER_MODAL_KEY_LIKESCOUNT] integerValue]];
        }
        
        if(userDict[USER_MODAL_KEY_COMMENTSCOUNT] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_COMMENTSCOUNT]] ) {
            self.commentsCount = [NSNumber numberWithInteger:[userDict[USER_MODAL_KEY_COMMENTSCOUNT] integerValue]];
        }
        
        if(userDict[USER_MODAL_KEY_POSTCOUNT] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_POSTCOUNT]] ) {
            self.postCount = [NSNumber numberWithInteger:[userDict[USER_MODAL_KEY_POSTCOUNT] integerValue]];
        }
        
        if(userDict[USER_MODAL_KEY_FOLLOWINGCOUNT] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_FOLLOWINGCOUNT]] ) {
            self.followingCount = [NSNumber numberWithInteger:[userDict[USER_MODAL_KEY_FOLLOWINGCOUNT] integerValue]];
        }
        
        if(userDict[USER_MODAL_KEY_FOLLOWERCOUNT] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_FOLLOWERCOUNT]] ) {
            self.followerCount = [NSNumber numberWithInteger:[userDict[USER_MODAL_KEY_FOLLOWERCOUNT] integerValue]];
        }
        
        if(userDict[USER_MODAL_KEY_FOLLOWINGSTATUS] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_FOLLOWINGSTATUS]] ) {
            self.followingStatus = [userDict[USER_MODAL_KEY_FOLLOWINGSTATUS] boolValue];
        }
        
        if(userDict[USER_MODAL_KEY_BLOCKEDSTATUS] && [NotificationModel isValidValue:userDict[USER_MODAL_KEY_BLOCKEDSTATUS]] ) {
            self.blockedStatus = [userDict[USER_MODAL_KEY_BLOCKEDSTATUS] boolValue];
        }
        
        if(userDict[@"isLoggedInUser"] && [NotificationModel isValidValue:userDict[@"isLoggedInUser"]] ) {
            self.isLoggedInUser = [userDict[@"isLoggedInUser"] boolValue];
        }
    }
    
    return self;
}

#pragma mark - Sql Operation methods

+ (NSString *)allObjectsOfSqlTableColumns
{
    return [NSString stringWithFormat:@"Select * FROM %@", DATABASE_TABLE_USERS];
}

+ (UsersModel *)processRawRow:(sqlite3_stmt *)selectStatement
{
    UsersModel *userDetail = [[UsersModel alloc] init];
    
    userDetail.userID = [NSNumber numberWithInt:sqlite3_column_int(selectStatement, 0)];
    userDetail.userEmail = [self isValidStringFromDatabase:selectStatement forbindingIndex:1];
    userDetail.userName = [self isValidStringFromDatabase:selectStatement forbindingIndex:2];
    userDetail.fullName = [self isValidStringFromDatabase:selectStatement forbindingIndex:3];
    userDetail.dobDate = [NSNumber numberWithDouble:sqlite3_column_double(selectStatement, 4)];
    userDetail.gender = [NSNumber numberWithInt:sqlite3_column_int(selectStatement, 5)];
    userDetail.profileImageName = [self isValidStringFromDatabase:selectStatement forbindingIndex:6];
    userDetail.canvasImageName = [self isValidStringFromDatabase:selectStatement forbindingIndex:7];
    userDetail.snippetImageName = [self isValidStringFromDatabase:selectStatement forbindingIndex:8];
    userDetail.snippetPosition = [self isValidStringFromDatabase:selectStatement forbindingIndex:9];
    userDetail.statusMessage = [self isValidStringFromDatabase:selectStatement forbindingIndex:10];
    userDetail.biodata = [self isValidStringFromDatabase:selectStatement forbindingIndex:11];
    userDetail.city = [self isValidStringFromDatabase:selectStatement forbindingIndex:12];
    userDetail.likesCount = [NSNumber numberWithInt:sqlite3_column_int(selectStatement, 13)];
    userDetail.commentsCount = [NSNumber numberWithInt:sqlite3_column_int(selectStatement, 14)];
    userDetail.postCount = [NSNumber numberWithInt:sqlite3_column_int(selectStatement, 15)];
    userDetail.followingCount = [NSNumber numberWithInt:sqlite3_column_int(selectStatement, 16)];
    userDetail.followerCount = [NSNumber numberWithInt:sqlite3_column_int(selectStatement, 17)];
    userDetail.followingStatus = sqlite3_column_int(selectStatement, 18);
    userDetail.blockedStatus = sqlite3_column_int(selectStatement, 19);
    userDetail.isLoggedInUser = sqlite3_column_int(selectStatement, 20);
    
    return userDetail;
}

+ (NSString *)insertOrReplaceSqlQuery
{
    return [NSString stringWithFormat:@"REPLACE INTO %@  (userID, userEmail, userName, fullName, dob, gender, profileImageName, canvasImageName, snippetImageName, snippetPosition, statusMessage, biodata, city, likesCount, commentsCount, postCount, followingCount, followerCount, followingStatus, blockedStatus, isLoggedInUser) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", DATABASE_TABLE_USERS];
}

+ (void)bindRawDataToSql:(sqlite3_stmt *)bindStatement forModel:(UsersModel *)bindingModel
{
    sqlite3_bind_int(bindStatement, 1, [bindingModel.userID intValue]);
    sqlite3_bind_text(bindStatement, 2, [bindingModel.userEmail UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(bindStatement, 3, [bindingModel.userName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(bindStatement, 4, [bindingModel.fullName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(bindStatement, 5, [bindingModel.dobDate doubleValue]);
    sqlite3_bind_int(bindStatement, 6, [bindingModel.gender intValue]);
    sqlite3_bind_text(bindStatement, 7, [bindingModel.profileImageName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(bindStatement, 8, [bindingModel.canvasImageName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(bindStatement, 9, [bindingModel.snippetImageName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(bindStatement, 10, [bindingModel.snippetPosition UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(bindStatement, 11, [bindingModel.statusMessage UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(bindStatement, 12, [bindingModel.biodata UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(bindStatement, 13, [bindingModel.city UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(bindStatement, 14, [bindingModel.likesCount intValue]);
    sqlite3_bind_int(bindStatement, 15, [bindingModel.commentsCount intValue]);
    sqlite3_bind_int(bindStatement, 16, [bindingModel.postCount intValue]);
    sqlite3_bind_int(bindStatement, 17, [bindingModel.followingCount intValue]);
    sqlite3_bind_int(bindStatement, 18, [bindingModel.followerCount intValue]);
    sqlite3_bind_int(bindStatement, 19, bindingModel.followingStatus);
    sqlite3_bind_int(bindStatement, 20, bindingModel.blockedStatus);
    sqlite3_bind_int(bindStatement, 21, bindingModel.isLoggedInUser);
}

#pragma mark Get user model for userId

+ (UsersModel *)getUserDetailsForUserId:(NSNumber*)userID
{
    SharedDatabaseManager *myDatabase = [self database];
    UsersModel * myObject = nil;
    sqlite3_stmt * selectStatement = NULL;
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE userID = %@", DATABASE_TABLE_USERS, userID];
    int myResultCode = 0;
    
    @try {
        [myDatabase executeSelectSQL:selectSQL usingStatement:&selectStatement];
        
        if([myDatabase isAdditionalRowForResultCode:(myResultCode = [[self database] step:selectStatement])]) {
            myObject = (UsersModel *)[self processRawRow:selectStatement];
            if (nil == myObject ) {
                NSLog(@"%s: %d; %s; No object returned from invocation of processRawRow:", __FILE__, __LINE__, __PRETTY_FUNCTION__);
            }
        }
        
        [myDatabase processErrorIfApplicableForSQL:selectSQL statement:selectStatement resultCode:myResultCode];
    }
    @catch (NSException * e) {
        NSLog(@"%s: %d; %s; Exception raised: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, [e description]);
        @throw e;
    }
    @finally {
        [myDatabase finalize:selectStatement];
    }
    
    return myObject;
}

+ (void)udpateValue:(NSString *)value forColumn:(NSString *)columnName ofUserId:(NSNumber *)userID
{
    SharedDatabaseManager *myDatabase = [self database];
    sqlite3_stmt * selectStatement = NULL;
    NSString * selectSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %@ WHERE userID = %@", DATABASE_TABLE_USERS, columnName, value, userID];
    int myResultCode = 0;
    
    @try {
        [myDatabase executeSelectSQL:selectSQL usingStatement:&selectStatement];
        myResultCode = [[self database] step:selectStatement];
        [myDatabase processErrorIfApplicableForSQL:selectSQL statement:selectStatement resultCode:myResultCode];
    }
    @catch (NSException * e) {
        NSLog(@"%s: %d; %s; Exception raised: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, [e description]);
        @throw e;
    }
    @finally {
        [myDatabase finalize:selectStatement];
    }
}

+ (void)deleteUser:(NSNumber *)userID
{
    SharedDatabaseManager *myDatabase = [self database];
    sqlite3_stmt * deleteSpotScreenStatement = NULL;
    NSString * selectSQL = [NSString stringWithFormat:@"Delete from %@ where userID = %@", DATABASE_TABLE_USERS, userID];
    
    int myResultCode = 0;
    
    @try {
        myResultCode = [myDatabase executeSelectSQL:selectSQL usingStatement:&deleteSpotScreenStatement];
        if(myResultCode == SQLITE_OK) {
            while ([myDatabase isAdditionalRowForResultCode:(myResultCode = [[self database] step:deleteSpotScreenStatement])]) {
                NSLog(@"%s deleting data successfully for user", __PRETTY_FUNCTION__);
            }
            
        }
    }
    @catch (NSException * e) {
        NSLog(@"%s: %d; %s; Exception raised: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, [e description]);
        @throw e;
    }
    @finally {
        [myDatabase makeDBForeignKey:NO];
        [myDatabase finalize:deleteSpotScreenStatement];
    }
}

@end
