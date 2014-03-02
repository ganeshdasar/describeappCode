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
        if(userDict[@"userID"] && [NotificationModel isValidValue:userDict[@"userID"]] ) {
            self.userID = [NSNumber numberWithInteger:[userDict[@"userID"] integerValue]];
        }
        
        if(userDict[@"userEmail"] && [NotificationModel isValidValue:userDict[@"userEmail"]] ) {
            self.userEmail = userDict[@"userEmail"];
        }
        
        if(userDict[@"userName"] && [NotificationModel isValidValue:userDict[@"userName"]] ) {
            self.userName = userDict[@"userName"];
        }
        
        if(userDict[@"fullName"] && [NotificationModel isValidValue:userDict[@"fullName"]] ) {
            self.fullName = userDict[@"fullName"];
        }
        
        if(userDict[@"dobDate"] && [NotificationModel isValidValue:userDict[@"dobDate"]] ) {
            self.dobDate = [NSNumber numberWithDouble:[userDict[@"spotWord"] doubleValue]];
        }
        
        if(userDict[@"gender"] && [NotificationModel isValidValue:userDict[@"gender"]] ) {
            self.gender = [NSNumber numberWithInteger:[userDict[@"gender"] integerValue]];
        }
        
        if(userDict[@"profileImageName"] && [NotificationModel isValidValue:userDict[@"profileImageName"]] ) {
            self.profileImageName = userDict[@"profileImageName"];
        }
        
        if(userDict[@"canvasImageName"] && [NotificationModel isValidValue:userDict[@"canvasImageName"]] ) {
            self.canvasImageName = userDict[@"canvasImageName"];
        }
        
        if(userDict[@"snippetImageName"] && [NotificationModel isValidValue:userDict[@"snippetImageName"]] ) {
            self.snippetImageName = userDict[@"snippetImageName"];
        }
        
        if(userDict[@"snippetPosition"] && [NotificationModel isValidValue:userDict[@"snippetPosition"]] ) {
            self.snippetPosition = userDict[@"snippetPosition"];
        }
        
        if(userDict[@"statusMessage"] && [NotificationModel isValidValue:userDict[@"statusMessage"]] ) {
            self.statusMessage = userDict[@"statusMessage"];
        }
        
        if(userDict[@"biodata"] && [NotificationModel isValidValue:userDict[@"biodata"]] ) {
            self.biodata = userDict[@"biodata"];
        }
        
        if(userDict[@"city"] && [NotificationModel isValidValue:userDict[@"city"]] ) {
            self.city = userDict[@"city"];
        }
        
        if(userDict[@"likesCount"] && [NotificationModel isValidValue:userDict[@"likesCount"]] ) {
            self.likesCount = [NSNumber numberWithInteger:[userDict[@"likesCount"] integerValue]];
        }
        
        if(userDict[@"commentsCount"] && [NotificationModel isValidValue:userDict[@"commentsCount"]] ) {
            self.commentsCount = [NSNumber numberWithInteger:[userDict[@"commentsCount"] integerValue]];
        }
        
        if(userDict[@"postCount"] && [NotificationModel isValidValue:userDict[@"postCount"]] ) {
            self.postCount = [NSNumber numberWithInteger:[userDict[@"postCount"] integerValue]];
        }
        
        if(userDict[@"followingCount"] && [NotificationModel isValidValue:userDict[@"followingCount"]] ) {
            self.followingCount = [NSNumber numberWithInteger:[userDict[@"followingCount"] integerValue]];
        }
        
        if(userDict[@"followerCount"] && [NotificationModel isValidValue:userDict[@"followerCount"]] ) {
            self.followerCount = [NSNumber numberWithInteger:[userDict[@"followerCount"] integerValue]];
        }
        
        if(userDict[@"followingStatus"] && [NotificationModel isValidValue:userDict[@"followingStatus"]] ) {
            self.followingStatus = [userDict[@"followingStatus"] boolValue];
        }
        
        if(userDict[@"blockedStatus"] && [NotificationModel isValidValue:userDict[@"blockedStatus"]] ) {
            self.blockedStatus = [userDict[@"blockedStatus"] boolValue];
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
