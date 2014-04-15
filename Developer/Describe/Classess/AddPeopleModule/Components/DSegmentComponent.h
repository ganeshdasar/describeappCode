//
//  DSegmentComponent.h
//  Describe
//
//  Created by NuncSys on 26/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSegmentComponent : UIView
@property(nonatomic, strong)NSArray *buttons;
-(void)designSegmentControllerWithButtons:(NSArray *)inSegments;
@end
