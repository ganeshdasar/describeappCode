//
//  DLikesList.m
//  Describe
//
//  Created by LaxmiGopal on 01/02/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DLikesList.h"
#import "DConversationView.h"

@interface DLikesList ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_listView ;
    NSMutableArray *_likesList;
}
@end

@implementation DLikesList

- (id)initWithFrame:(CGRect)frame andWithLikes:(NSArray *)likes
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor redColor];
        if(likes != nil)
            _likesList = [[NSMutableArray alloc] initWithArray:likes];
        
        [self createLikesListView];
    }
    return self;
}



-(void)createLikesListView
{
    _listView = [[UITableView alloc] initWithFrame:self.bounds];
    [_listView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_listView setBackgroundColor:[UIColor clearColor]];
    [_listView setDataSource:self];
    [_listView setDelegate:self];
    [self addSubview:_listView];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_likesList count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"identifier_%d_%d",indexPath.section, indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    if([cell.contentView viewWithTag:111] == nil )
    {
        DConversationView *conversationView = [[DConversationView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 62)  withConversation:_likesList[indexPath.row]];
        [cell.contentView addSubview:conversationView];
        [conversationView setTag:111];
    }
    
    return cell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
