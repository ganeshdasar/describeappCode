//
//  DHeaderView.h
//  Describe
//
//  Created by LaxmiGopal on 23/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum DHeaderButtonType
{
    HeaderButtonTypeAdd             = 0x100,
    HeaderButtonTypeNext            = 0x101,
    HeaderButtonTypePrev            = 0x102,
    HeaderButtonTypeMenu            = 0x103,
    HeaderButtonTypeReload          = 0x104,
    HeaderButtonTypeHome            = 0x105,
    HeaderButtonTypeProfile         = 0x106,
    HeaderButtonTypeNotification    = 0x107,
    HeaderButtonTypeSearch          = 0x108,
    HeaderButtonTypeAddPeople       = 0x109,
    HeaderButtonTypeSettings        = 0x110,
    HeaderButtonTypeClose           = 0x10A,
    HeaderButtonTypeEdit            = 0x10B,
    HeaderButtonTypeDone            = 0x10C,
    HeaderButtonTypeFollow          = 0x10D
    
}HeaderButtonType;

@class DHeaderView;
@protocol DHeaderViewDelegate<NSObject>


@optional
-(void)headerView:(DHeaderView *)headerView didSelectedHeaderViewButton:(UIButton *)headerButton;


@end

@interface DHeaderView : UIView


@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSArray *buttons;
@property(nonatomic, assign)id<DHeaderViewDelegate> delegate;

-(void)designHeaderViewWithTitle:(NSString *)title andWithButtons:(NSArray *)buttons andMenuButtons:(NSArray *)menuButtons;
-(void)designHeaderViewWithTitle:(NSString *)title andWithButtons:(NSArray *)buttons;
-(void)reachMe;
-(void)removeSubviewFromHedderView;
@end


