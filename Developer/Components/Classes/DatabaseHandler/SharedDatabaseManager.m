//
//  SharedDatabaseManager.m
//  Composition
//
//  Created by Describe Administrator on 20/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "SharedDatabaseManager.h"

#define DATABASE_FILENAME               @"Database.sqlite"

@implementation SharedDatabaseManager

+ (id)sharedInstance
{    
    static SharedDatabaseManager * _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)copyDatabaseFromResourceToDocumentAndOpenDatabase
{
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPath objectAtIndex:0];
    self.dataFilePath = [documentDir stringByAppendingPathComponent:DATABASE_FILENAME];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL sucess = [manager fileExistsAtPath:self.dataFilePath];
    
    if(sucess) {
        // UserExist
        [self openDatabase];
    }
    else {
        // Adding database from resource to document folder and opening.
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_FILENAME];
        if([manager copyItemAtPath:databasePathFromApp toPath:self.dataFilePath error:nil] == YES){
            [self openDatabase];
        }
    }
}

- (void)closeAndRemoveDatabase
{
    if([[NSFileManager defaultManager] fileExistsAtPath:self.dataFilePath]) {
        [self closeDatabase];
        [[NSFileManager defaultManager] removeItemAtPath:self.dataFilePath error:nil];
    }
}

@end
