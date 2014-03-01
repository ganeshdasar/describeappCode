//
//  DPostListView.h
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPostListViewDelegate;
@interface DPostListView : UIView


@property(nonatomic, strong)id<DPostListViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame andPostsList:(NSArray *)list;
- (id)initWithFrame:(CGRect)frame andPostsList:(NSArray *)list withHeaderView:(UIView *)headerView;


@end



@protocol DPostListViewDelegate <NSObject>

-(void)scrollView:(UIScrollView *)scrollView scrollingDirection:(NSString *)direction;
-(void)scrollView:(UIScrollView *)scrollView didHoldingFinger:(NSString *)finger;
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
@end