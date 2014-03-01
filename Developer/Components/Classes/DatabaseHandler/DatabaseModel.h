//
//  DatabaseModel.h
//  Composition
//
//  Created by Describe Administrator on 20/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SharedDatabaseManager.h"
  

@interface DatabaseModel : NSObject

+ (SharedDatabaseManager *)database;
+ (NSString *)allObjectsOfSqlTableColumns;
+ (DatabaseModel *)processRawRow:(sqlite3_stmt *)selectStatement;
+ (NSMutableArray *)getAllObjects;
+ (NSString *)insertOrReplaceSqlQuery;
+ (void)bindRawDataToSql:(sqlite3_stmt *)bindStatement forModel:(DatabaseModel *)bindingModel;
+ (void)batchInsert:(NSArray *)items;

+ (NSString*)isValidStringFromDatabase:(sqlite3_stmt *)selectStatement forbindingIndex:(NSInteger)index;

@end
