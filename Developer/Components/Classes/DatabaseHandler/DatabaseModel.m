//
//  DatabaseModel.m
//  Composition
//
//  Created by Describe Administrator on 20/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "DatabaseModel.h"
#import <objc/runtime.h>

@implementation DatabaseModel

+ (SharedDatabaseManager *)database
{
    return [SharedDatabaseManager sharedInstance];
}

+ (NSString *)allObjectsOfSqlTableColumns
{
    NSAssert4(0, @"%s: %d; %s; Required method not implemented in subclass, %s.",  __FILE__, __LINE__, __PRETTY_FUNCTION__, class_getName(self));
    return nil;
}

+ (DatabaseModel *)processRawRow:(sqlite3_stmt *)selectStatement
{
    NSAssert4(0, @"%s: %d; %s; Required method not implemented in subclass, %s.",  __FILE__, __LINE__, __PRETTY_FUNCTION__, class_getName(self));
    return nil;
}

+ (NSMutableArray *)allObjectsWithDatabase:(SharedDatabaseManager *)myDatabase
{
    // Preconditions
    NSAssert3(myDatabase, @"%s: %d; %s; Invalid argument. myDatabase == nil",  __FILE__, __LINE__, __PRETTY_FUNCTION__);
    
    NSMutableArray * results = [NSMutableArray array];
    sqlite3_stmt * selectStatement = NULL;
    NSString * selectSQL = [self allObjectsOfSqlTableColumns];
    int myResultCode = 0;
    
    @try {
        [myDatabase executeSelectSQL:selectSQL usingStatement:&selectStatement];
        
        while ([myDatabase isAdditionalRowForResultCode:(myResultCode = [[self database] step:selectStatement])]) {
            DatabaseModel * myObject = [self processRawRow:selectStatement];
            if (myObject) {
                [results addObject: myObject];
            } else {
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
    
    return results;
}

+ (NSMutableArray *)getAllObjects
{
    return [self allObjectsWithDatabase:[self database]];
}

+ (NSString *)insertOrReplaceSqlQuery
{
    NSAssert4(0, @"%s: %d; %s; Required method not implemented in subclass, %s.",  __FILE__, __LINE__, __PRETTY_FUNCTION__, class_getName(self));
    return nil;
}

+ (void)bindRawDataToSql:(sqlite3_stmt *)bindStatement forModel:(DatabaseModel *)bindingModel
{
    NSAssert4(0, @"%s: %d; %s; Required method not implemented in subclass, %s.",  __FILE__, __LINE__, __PRETTY_FUNCTION__, class_getName(self));
}

+ (void)batchInsert:(NSArray *)items
{
    SharedDatabaseManager *myDatabase = [self database];
    NSString* statement;
//    statement = @"BEGIN";
    sqlite3_stmt *beginStatement = nil;
    sqlite3_stmt *compiledStatement = nil;
    sqlite3_stmt *commitStatement = nil;
    NSInteger myResultCode = 0;

    @try {
//        [myDatabase executeSelectSQL:statement usingStatement:&beginStatement];
//        
//        if ([myDatabase step:beginStatement] != SQLITE_DONE) {
//            [myDatabase finalize:beginStatement];
//            printf("db error: %s\n", sqlite3_errmsg(myDatabase.database));
//            return;
//        }
        
//        NSTimeInterval timestampB = [[NSDate date] timeIntervalSince1970];
        statement = [self insertOrReplaceSqlQuery]; //@"INSERT OR REPLACE INTO item (hash, tag, owner, timestamp, dictionary) VALUES (?, ?, ?, ?, ?)";
        myResultCode = [myDatabase executeSelectSQL:statement usingStatement:&compiledStatement];
        if(myResultCode == SQLITE_OK)
        {
            for(int i = 0; i < [items count]; i++) {
                [self bindRawDataToSql:compiledStatement forModel:items[i]];
                
                NSInteger result = [myDatabase step:compiledStatement];
                if(SQLITE_DONE != result) {
                    NSLog(@"Error while inserting data. %s, %s", __PRETTY_FUNCTION__, sqlite3_errmsg(myDatabase.database));
//                    NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(myDatabase.database));
                }
                
                NSLog(@"Insertion code = %d", result);
                
                [myDatabase reset:compiledStatement];
            }
            
//            timestampB = [[NSDate date] timeIntervalSince1970] - timestampB;
//            NSLog(@"Insert Time Taken: %f",timestampB);
            
            // COMMIT
//            statement = @"COMMIT";
//            myResultCode = [myDatabase executeSelectSQL:statement usingStatement:&commitStatement];
//            
//            NSLog(@"COMMIT TRANSACTION code = %d", myResultCode);
            
//            [myDatabase processErrorIfApplicableForSQL:statement statement:commitStatement resultCode:myResultCode];
        }
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        if(nil != beginStatement) {
            [myDatabase finalize:beginStatement];
        }
        
        if(nil != compiledStatement) {
            [myDatabase finalize:compiledStatement];
        }
        
        if(nil != commitStatement) {
            [myDatabase finalize:commitStatement];
        }
    }
    
}

+ (NSString*)isValidStringFromDatabase:(sqlite3_stmt *)selectStatement forbindingIndex:(NSInteger)index
{
   NSString *valueString = [DatabaseModel isStringValid:[NSString stringWithFormat:@"%s", sqlite3_column_text(selectStatement, index)]]?[NSString stringWithFormat:@"%s", sqlite3_column_text(selectStatement, index)]:@"";
    
    return valueString;
}

+ (BOOL)isStringValid:(id)value{
    
    if([value isKindOfClass:[NSNull class]] || value == [NSNull null] || ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"<null>"]) || ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"(null)"])) {
        return NO;
    }
    else{
        return YES;
    }
    
}

@end
