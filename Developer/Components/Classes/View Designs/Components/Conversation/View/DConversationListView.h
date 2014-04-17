//
//  DConversationList.h
//  Describe
//
//  Created by LaxmiGopal on 25/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DConversationListView : UIView



@property (nonatomic, strong) NSDictionary *header;
@property (nonatomic,strong)     NSMutableArray *_conversationList;


-(void)designConversationListView;

@end
