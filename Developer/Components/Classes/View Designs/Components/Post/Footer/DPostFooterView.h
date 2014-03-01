//
//  DPostFooterView.h
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPostAttachments;
@interface DPostFooterView : UIView

- (id)initWithFrame:(CGRect)frame withPostAttachements:(DPostAttachments *)attachements;
@property(nonatomic, strong)DPostAttachments *postAttachments;
@end
