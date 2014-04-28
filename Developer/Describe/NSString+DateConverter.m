//
//  NSString+DateConverter.m
//  Describe
//
//  Created by NuncSys on 23/03/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "NSString+DateConverter.h"

@implementation NSString (DateConverter)
+(NSString*)convertTheepochTimeToDate:(double)inString
{
    double unixTimeStamp =inString;
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateStyle:NSDateFormatterLongStyle];
    [_formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *_date=[_formatter stringFromDate:date];
    return _date;
}

+(NSString*)convertTheDateToepochtime:(NSString*)dateString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterLongStyle];
    [dateFormat setTimeStyle:NSDateFormatterNoStyle];
    NSDate *date = [dateFormat dateFromString:dateString];
    return  [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
}

+ (NSString*)convertThesocialNetworkDateToepochtime:(NSString*)dateString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [dateFormat dateFromString:dateString];
    return  [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    
}
@end
