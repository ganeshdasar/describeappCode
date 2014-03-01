//
//  UIColor+DesColors.m
//  Describe
//
//  Created by NuncSys on 02/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "UIColor+DesColors.h"

@implementation UIColor (DesColors)
+ (UIColor*) headerColor{
    
    return [UIColor colorWithRed:56.0/255.0 green:162.0/255.0 blue:152.0/255.0 alpha:1];
}
+ (UIColor*) backGroundColor{
    return [UIColor colorWithRed:248/255.0 green:248/255.0 blue:247/255.0 alpha:1];

}
+(UIColor*)textPlaceholderColor;{
    return [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];

}
+(UIColor*)textFieldTextColor;{
    return [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0];

}
+(UIColor*)segmentButtonSelectedColor{
    
    return [UIColor colorWithRed:53/255.0 green:168/255.0 blue:157/255.0 alpha:1.0];

}




@end
