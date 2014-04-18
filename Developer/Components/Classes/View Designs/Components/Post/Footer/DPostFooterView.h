//
//  DPostFooterView.h
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DPostFooterViewDelegate;

@class DPostAttachments;
@interface DPostFooterView : UIView


- (id)initWithFrame:(CGRect)frame withPostAttachements:(DPostAttachments *)attachements;


@property(nonatomic, strong)DPostAttachments *postAttachments;
@property(nonatomic, strong)id<DPostFooterViewDelegate> delegate;
@end


@class DPostFooterView;
@protocol DPostFooterViewDelegate <NSObject>

@optional
-(void)didSelectedTag:(NSString *)tagedString;
-(void)showMoreDetailsOfPost:(id)sender;
-(void)showCommmentsOfPost:(id)sernder;


@end
