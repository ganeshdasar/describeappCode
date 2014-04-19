//
//  NSDate+DDate.m
//  Describe
//
//  Created by Aashish Raj on 3/30/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "NSDate+DDate.h"

@implementation NSDate (DDate)

+(NSDate *)dateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM DD, yyyy"];
    NSDate *requiredDate = [dateFormatter dateFromString:dateString];
    
    return requiredDate;
}

-(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM DD, yyyy"];
    return [dateFormatter stringFromDate:(NSDate *)self];
}


@end
