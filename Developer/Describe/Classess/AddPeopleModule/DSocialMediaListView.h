//
//  DSocialMediaListView.h
//  Describe
//
//  Created by Aashish Raj on 4/9/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol DSocialMediaListViewDelegate <NSObject>

@optional
-(void)socailMediaDidSelectedItemAtIndex:(NSInteger )index;

@end

@interface DSocialMediaListView : UIView

@property(nonatomic, assign)id<DSocialMediaListViewDelegate>delegate;

- (void)setMedaiList:(NSArray *)medias;
- (void)makeSocialBtnSelected:(BOOL)isSelect withTag:(NSInteger)btnTag;

@end


