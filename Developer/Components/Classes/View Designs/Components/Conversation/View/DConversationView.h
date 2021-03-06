//
//  DConversationView.h
//  Describe
//
//  Created by LaxmiGopal on 31/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>




@protocol DConversationDelegate;

@class DConversation;
@interface DConversationView : UIView

@property(nonatomic, strong)id<DConversationDelegate> delegate;

- (id)initWithConversation:(DConversation *)conversation;
- (id)initWithFrame:(CGRect)frame withConversation:(DConversation *)conversation;

-(void)increaseContentSize;
-(void)resignKeyboard;
-(DConversation *)conversation;
@end



@protocol DConversationDelegate <NSObject>

@optional
-(void)actionOnThisConversation:(DConversation *)conversation;
-(void)postComment:(NSString *)comment forConversation:(DConversation *)conversation;
-(void)conversationView:(DConversationView *)conversationView needToExpand:(NSNumber *)expand;
-(void)conversationView:(DConversationView *)conversationView expandOthersLikeView:(NSNumber *)expand;
-(void)conversationView:(DConversationView *)conversationView expandCommentView:(NSNumber *)height;

//Mentioning the conversation...
-(void)conversationViewDidStartMentioning:(DConversationView *)conversationView;
-(void)conversationView:(DConversationView *)conversationView mentioningText:(NSString *)text;
-(void)conversationView:(DConversationView *)conversationView didFinishedMentioningPerson:(NSString *)person;
-(void)conversationViewDidEndMentioning:(DConversationView *)conversationView;
@end
