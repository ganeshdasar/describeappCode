//
//  DLikesView.h
//  Describe
//
//  Created by LaxmiGopal on 19/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DLikesViewDelegate;


@interface DLikesView : UIView

@property(nonatomic, assign)id<DLikesViewDelegate> delegate;
@end

@protocol DLikesViewDelegate <NSObject>

-(void)likesView:(DLikesView *)likeView didSelectedStars:(NSNumber *)stars;

@end
