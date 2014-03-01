//
//  DHeaderView.h
//  Describe
//
//  Created by LaxmiGopal on 23/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHeaderView : UIView


@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSArray *buttons;

-(void)designHeaderViewWithTitle:(NSString *)title andWithButtons:(NSArray *)buttons;
-(void)reachMe;
-(void)removeSubviewFromHedderView;
@end
