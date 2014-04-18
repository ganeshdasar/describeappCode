//
//  DPostListView.h
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPostListViewDelegate;


@class DPost;
@interface DPostListView : UIView


@property(nonatomic, strong)id<DPostListViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame andPostsList:(NSArray *)list;
- (id)initWithFrame:(CGRect)frame andPostsList:(NSArray *)list withHeaderView:(UIView *)headerView;
-(void)deletePost:(DPost *)post;
-(void)addHeaderViewForTable:(UIView *)headerView;
-(void)reloadData:(NSArray *)details;
- (void)appendMorePosts:(NSArray *)details;

@end



@protocol DPostListViewDelegate <NSObject>

@optional
-(void)didSelectedTag:(NSString *)tag forThisPost:(DPost *)post;
-(void)showMoreDetailsOfThisPost:(DPost *)post;
-(void)showConversationOfThisPost:(DPost *)post;
-(void)userProfileSelectedForPost:(DPost *)selected;
-(void)scrollView:(UIScrollView *)scrollView scrollingDirection:(NSString *)direction;
-(void)scrollView:(UIScrollView *)scrollView didHoldingFinger:(NSString *)finger;
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)loadNextPage;
@end