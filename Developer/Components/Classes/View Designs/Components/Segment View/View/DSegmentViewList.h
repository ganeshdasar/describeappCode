//
//  DSegmentViewList.h
//  Describe
//
//  Created by Aashish Raj on 2/15/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DSegementListViewDelegate;

@class DSegmentView;


@interface DSegmentViewList : UIView
@property(nonatomic, copy)NSArray *segments;
@property(nonatomic, assign)id<DSegementListViewDelegate> delegate;

-(void)designSegmentView;
-(void)selectSegmentAtIndex:(NSInteger )index;
@end



@protocol DSegementListViewDelegate <NSObject>

-(void)segmentViewDidSelected:(DSegmentView *)segmentView;
-(void)segmentViewDidSelected:(DSegmentView *)segmentView atIndex:(NSNumber *)index;
@end
