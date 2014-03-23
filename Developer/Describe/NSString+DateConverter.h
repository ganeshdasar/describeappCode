//
//  NSString+DateConverter.h
//  Describe
//
//  Created by NuncSys on 23/03/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DateConverter)
+(NSString*)convertTheepochTimeToDate:(double)inString;
+(NSString*)convertTheDateToepochtime:(NSString*)dateString;
+(NSString*)convertThesocialNetworkDateToepochtime:(NSString*)dateString;
@end
