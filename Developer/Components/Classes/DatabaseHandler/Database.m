//
//  Database.h
//  Composition
//
//  Created by Describe Administrator on 20/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "Database.h"

static int myDBCallback(void *context, int count, char **values, char **columns)
{
	NSMutableArray *contentCB = (__bridge NSMutableArray *)context;
	
	for(int i = 0; i < count; i++)
		[contentCB addObject:[NSString stringWithFormat:@"%s",values[i]]];
	return SQLITE_OK;
}

@implementation Database

#pragma mark - LIFE CYCLE METHODS

- (id)init
{
    if(self = [super init]) {
        // initialize variable here
    }
    
    return self;
}

- (void)dealloc
{
    [self closeDatabase];
    _dataFilePath = nil;
}

#pragma mark - OPEN AND CLOSE DATABASE METHODS

- (void)openDatabase
{
    NSAssert3(self.dataFilePath, @"%s: %d; %s; Invalid precondition. dataFilePath == nil",  __FILE__, __LINE__, __PRETTY_FUNCTION__);
	
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([self.dataFilePath UTF8String], &_database) == SQLITE_OK) {
        NSLog(@"%s: %d; %s; SQLite database successfully opened at %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, self.dataFilePath);
        
        // from here we are making the PRAGMA foreign_keys=ON
        
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(self.database);
        NSAssert4(0, @"%s: %d; %s; Failed to open database with message '%s'.",  __FILE__, __LINE__, __PRETTY_FUNCTION__, sqlite3_errmsg(self.database));
    }
}

- (void)closeDatabase
{
    sqlite3_close(self.database);
}

#pragma mark - OPERATIONS ON SQLITE3, METHODS

// Enable or disable PRAGMA foriegn key of database
- (void)makeDBForeignKey:(BOOL)enable
{
    NSString *sqlString = [NSString stringWithFormat:@"PRAGMA foreign_keys = %@", enable?@"ON":@"OFF"];
    [self executeWriteWithSQL:sqlString];
}

#pragma mark Single row value select functionality
- (NSString *)stringSelectWithSQL:(NSString *)mySQL
{
    sqlite3_stmt *sqlStatement = NULL;
    int rows = 0;
    int resultCode = 0;
    NSString * result = nil;
    
    @try {
        // Preconditions
        NSAssert3(self.database, @"%s: %d; %s; Failed to obtain pointer to SQLite database. database == NULL",  __FILE__, __LINE__, __PRETTY_FUNCTION__);
        NSAssert3([mySQL length], @"%s: %d; %s; Failed to obtain pointer to SQLite database. [mySQL length] == 0",  __FILE__, __LINE__, __PRETTY_FUNCTION__);
        
        if (sqlite3_prepare_v2(self.database, [mySQL cStringUsingEncoding: NSUTF8StringEncoding] , -1, &sqlStatement, NULL) != SQLITE_OK) {
            NSAssert5(0, @"%s: %d; %s; Failed to prepare statement, %@, with message '%s'.",  __FILE__, __LINE__, __PRETTY_FUNCTION__, [mySQL length] ? mySQL : @"<nil or zero-length string>", sqlite3_errmsg(self.database));
        }
        
        while ((resultCode = sqlite3_step(sqlStatement)) == SQLITE_ROW) {
            rows++;
            if (1 == rows) {
                result = [NSString stringWithFormat: @"%s", sqlite3_column_text(sqlStatement, 0)];
            } 
        }
    }
    
    @catch (NSException * exception) {
         @throw exception;
    }
    
    @finally {
        sqlite3_finalize(sqlStatement);
    }
    
    return result;
}

#pragma mark Multiple line, multiple value select functionality
- (int)executeSelectSQL:(NSString *)mySQL usingStatement:(sqlite3_stmt **)myStatement
{
    // Preconditions
    NSAssert3(self.database, @"%s: %d; %s; Failed to obtain pointer to SQLite database. database == NULL",  __FILE__, __LINE__, __PRETTY_FUNCTION__);
    NSAssert3(mySQL, @"%s: %d; %s; Invalid argument. mySQL = nil",  __FILE__, __LINE__, __PRETTY_FUNCTION__);
    NSAssert3(myStatement, @"%s: %d; %s; Invalid argument. myStatement == NULL",  __FILE__, __LINE__, __PRETTY_FUNCTION__);
	int resultCode = 0;
    resultCode = sqlite3_prepare_v2(self.database, [mySQL cStringUsingEncoding: NSUTF8StringEncoding] , -1, myStatement, NULL);
    if (resultCode != SQLITE_OK) {
        NSAssert5(0, @"%s: %d; %s; Failed to prepare statement, %@, with message '%s'.",  __FILE__, __LINE__, __PRETTY_FUNCTION__, [mySQL length] ? mySQL : @"<nil or zero-length string>", sqlite3_errmsg(self.database));
    }
    
    return resultCode;
}

- (int)step:(sqlite3_stmt *)myStatement
{
    int resultCode = 0;
	
    @try {
        resultCode = sqlite3_step(myStatement);
    }
	
    @catch (NSException * exception) {
        @throw exception;
    }
    
    return resultCode;
}

- (BOOL)isAdditionalRowForResultCode:(int)myResultCode
{
    switch (myResultCode) {
        case SQLITE_ROW : return YES;
    }
    
    return NO;
}

- (void)processErrorIfApplicableForSQL:(NSString *)mySQL statement:(sqlite3_stmt *)myStatement resultCode:(int)myResultCode
{
    if (myResultCode == SQLITE_DONE) {
        return;
    }
    
    if (myResultCode == SQLITE_ERROR) {
        NSLog(@"%s: %d; %s; Error while executing select SQL, %@: %s", __FILE__, __LINE__, __PRETTY_FUNCTION__, mySQL, sqlite3_errmsg(self.database));
    }
    
}

- (void)finalize:(sqlite3_stmt *)myStatement
{
    sqlite3_finalize(myStatement);
}

- (void)reset:(sqlite3_stmt *)myStatement
{
    sqlite3_reset(myStatement);
}

#pragma mark Insert OR Update functionality
- (void)executeWriteWithSQL:(NSString *)mySQL
{
    sqlite3_stmt *sqlStatement = NULL;
    int resultCode = 0;
    
    // Preconditions
    NSAssert3(mySQL, @"%s: %d; %s; Invalid argument. mySQL == nil",  __FILE__, __LINE__, __PRETTY_FUNCTION__);
    NSAssert3(self.database, @"%s: %d; %s; Invalid precondition. database == NULL",  __FILE__, __LINE__, __PRETTY_FUNCTION__);
	
    @try {
		if (sqlite3_prepare_v2(self.database, [mySQL cStringUsingEncoding: NSUTF8StringEncoding] , -1, &sqlStatement, NULL) != SQLITE_OK) {
			NSAssert5(0, @"%s: %d; %s; Failed to prepare statement, %@, with message '%s'.",  __FILE__, __LINE__, __PRETTY_FUNCTION__, [mySQL length] ? mySQL : @"<nil or zero-length string>", sqlite3_errmsg(self.database));
        }
        
        resultCode = sqlite3_step(sqlStatement);
    }
    
    @catch (NSException * exception) {
        @throw exception;
    }
    @finally {
        if (resultCode == SQLITE_DONE) {
            NSLog(@"%s: %d; %s; SQL successfully executed: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, mySQL);
        } else if (resultCode == SQLITE_ERROR) {
            NSLog(@"%s: %d; %s; Error while executing select SQL, %@: %s", __FILE__, __LINE__, __PRETTY_FUNCTION__, mySQL, sqlite3_errmsg(self.database));
        } else {
            NSLog(@"%s: %d; %s; An error may have occurred while executing insert, %@: %d", __FILE__, __LINE__, __PRETTY_FUNCTION__, mySQL, resultCode);
        }
		
        sqlite3_finalize(sqlStatement);
    }
    
}

#pragma mark Method quick & easy to get list in the desired arrayObject named content
- (BOOL)executeSQLQuery:(NSString *)query into:(NSMutableArray *)content usingDatabaseAtPath:(NSString *)aPath
{
	BOOL isQuerySuccess = NO;

	if(sqlite3_exec(self.database,[query UTF8String], myDBCallback, (__bridge void *)(content),nil) == SQLITE_OK)
		isQuerySuccess = YES;
    
	return isQuerySuccess;
}

@end
