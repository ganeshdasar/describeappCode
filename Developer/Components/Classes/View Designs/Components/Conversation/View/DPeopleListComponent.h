//
//  DPeopleListComponent.h
//  Describe
//
//  Created by NuncSys on 26/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPeopleListDelegate;



@interface DPeopleListComponent : UIView{
    
}
@property (nonatomic, assign) BOOL isAddPeople;
@property (nonatomic, assign) BOOL isSearchPeople;
@property (nonatomic, assign) id<DPeopleListDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *_peopleList;

- (id)initWithFrame:(CGRect)frame andPeopleList:(NSArray *)list;
-(void)reloadTableView:(NSMutableArray*)inArray;
-(void)addHeaderViewForTable:(UIView *)headerView;

- (void)loadMorePeople:(NSArray *)peopleList;

@end


@protocol DPeopleListDelegate <NSObject>

@optional
- (void)scrollView:(UIScrollView *)scrollView scrollingDirection:(NSString *)direction;
- (void)scrollView:(UIScrollView *)scrollView didHoldingFinger:(NSString *)finger;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)peopleListView:(DPeopleListComponent *)listView didSelectedItemIndex:(NSUInteger )index;
- (void)loadNextPage;
- (void)statusChange;

@end
