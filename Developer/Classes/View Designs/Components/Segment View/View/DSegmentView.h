//
//  DSegmentView.h
//  Describe
//
//  Created by Aashish Raj on 2/15/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DSegment;

@protocol DSegementViewDelegate;

@interface DSegmentView : UIView

@property(nonatomic, strong)DSegment *segment;
@property(nonatomic, assign)id<DSegementViewDelegate> delegate;


-(void)selectSegment;
-(void)unSelectSegment;

@end



@protocol DSegementViewDelegate <NSObject>

-(void)segmentViewDidSelected:(DSegmentView *)segmentView;

@end

