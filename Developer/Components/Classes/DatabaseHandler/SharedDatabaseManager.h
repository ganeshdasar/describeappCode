//
//  SharedDatabaseManager.h
//  Composition
//
//  Created by Describe Administrator on 20/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "Database.h"

@interface SharedDatabaseManager : Database

// Singleton object for usage of throught the app lifetime.
+ (id)sharedInstance;

// copy databse file from resource folder to document folder
- (void)copyDatabaseFromResourceToDocumentAndOpenDatabase;

// remove database file from document folder
- (void)closeAndRemoveDatabase;

@end
