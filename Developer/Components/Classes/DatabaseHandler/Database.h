//
//  Database.h
//  Composition
//
//  Created by Describe Administrator on 20/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Database : NSObject

@property (nonatomic, strong) NSString * dataFilePath;
@property (nonatomic) sqlite3 * database;

// open the database file
- (void)openDatabase;

// to close the database
- (void)closeDatabase;

// Enable or disable PRAGMA foriegn key of database
- (void)makeDBForeignKey:(BOOL)enable;

// SINGLE ROW, SINGLE VALUE SELECT FUNCTIONALITY
- (NSString *)stringSelectWithSQL:(NSString *)mySQL;

// MULTIPLE LINE, MULTIPLE VALUE SELECT FUNCTIONALTIY - USE THESE TOGETHER
- (int)executeSelectSQL:(NSString *)mySQL usingStatement:(sqlite3_stmt **)myStatement;
- (int)step:(sqlite3_stmt *)myStatement;
- (BOOL)isAdditionalRowForResultCode:(int)myResultCode;
- (void)processErrorIfApplicableForSQL:(NSString *)mySQL statement:(sqlite3_stmt *)myStatement resultCode:(int)myResultCode;
- (void)finalize:(sqlite3_stmt *)myStatement;
- (void)reset:(sqlite3_stmt *)myStatement;

// INSERT OR UPDATE FUNCTIONALITY
- (void)executeWriteWithSQL:(NSString *)mySQL;

// Method quick & easy to get list in the desired arrayObject named content
- (BOOL)executeSQLQuery:(NSString *)query into:(NSMutableArray *)content usingDatabaseAtPath:(NSString *)aPath;

@end
