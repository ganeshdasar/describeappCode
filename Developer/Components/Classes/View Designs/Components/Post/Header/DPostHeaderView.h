//
//  DPostHeaderView.h
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DUser.h"

@class DUser;

@protocol DPostHeaderViewDelegate;

@interface DPostHeaderView : UIView

@property(nonatomic, strong)id<DPostHeaderViewDelegate> delegate;
@property(nonatomic, strong)NSString *duration;
@property(nonatomic, strong)DUser *user;

@end


@protocol DPostHeaderViewDelegate <NSObject>
-(void)profileDetailsDidSelected:(DPostHeaderView *)headerView;

@end
