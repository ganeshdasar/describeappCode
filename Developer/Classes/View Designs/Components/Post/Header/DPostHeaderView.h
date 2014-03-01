//
//  DPostHeaderView.h
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DUser;
@interface DPostHeaderView : UIView

@property(nonatomic, strong)NSString *duration;
@property(nonatomic, strong)DUser *user;
@end
