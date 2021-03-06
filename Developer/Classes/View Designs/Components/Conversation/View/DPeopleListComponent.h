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
@property (nonatomic,assign) BOOL isAddPeople;
@property (nonatomic,assign) BOOL isSearchPeople;
@property(nonatomic, strong)id<DPeopleListDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andPeopleList:(NSArray *)list;
@property (nonatomic,strong)     NSMutableArray *_peopleList;
-(void)reloadTableView:(NSMutableArray*)inArray;
-(void)addHeaderViewForTable:(UIView *)headerView;

@end




@protocol DPeopleListDelegate <NSObject>

-(void)scrollView:(UIScrollView *)scrollView scrollingDirection:(NSString *)direction;
-(void)scrollView:(UIScrollView *)scrollView didHoldingFinger:(NSString *)finger;
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
@end
