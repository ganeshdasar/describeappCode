//
//  DesPeopleSortingComponent.m
//  Describe
//
//  Created by NuncSys on 11/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DesPeopleSortingComponent.h"
#import "DUserData.h"
@implementation DesPeopleSortingComponent

+(NSMutableArray*)facebookFriendsListFiltring:(NSMutableArray*)inListFromServer andLocalfacebookFriendsList:(NSMutableArray*)inLocalFriendsLsit{
    
    
    for (int i=0; i<inListFromServer.count;i++) {
        
        for (int j =0; j<inLocalFriendsLsit.count; j++) {
            
            if ([[inLocalFriendsLsit objectAtIndex:j] isEqualToString:[inListFromServer objectAtIndex:i]]) {
                
                [inLocalFriendsLsit removeObjectAtIndex:j];
                
            }
            
            
        }
        NSLog(@"array %@",inLocalFriendsLsit);
        
        
    }
    NSLog(@"array last out put%@",inLocalFriendsLsit);

    
    
    return inLocalFriendsLsit;
    
    
}




+(NSString *)appendingTheFriendsIDsWithComma:(NSMutableArray*)inFriensList{
    
    NSString *mergedFriedIDs;
    int i =0;
    for (ModelData* data in inFriensList) {
        
        if (i==0) {
            mergedFriedIDs = [NSString stringWithFormat:@"%@",data.userId];
            i =1;
        }else{
            mergedFriedIDs = [mergedFriedIDs stringByAppendingString:[NSString stringWithFormat:@",%@",data.userId]];
        }
    }
    return mergedFriedIDs;
    
}

@end
