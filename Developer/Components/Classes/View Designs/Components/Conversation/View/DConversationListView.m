//
//  DConversationList.m
//  Describe
//
//  Created by LaxmiGopal on 25/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DConversationListView.h"
#import <QuartzCore/QuartzCore.h>
#import "DConversation.h"
#import "DConversationView.h"

@interface DConversationListView ()<UITableViewDataSource, UITableViewDelegate, DConversationDelegate>
{
    UITableView *_listView ;
  //  NSMutableArray *_conversationList;
    NSIndexPath *_currentExpandingIndexPath;
    UIView *_tempContent;
    BOOL _isNeedToExpandUserCommentView;
    
    float _userCommentViewHeight;
    DConversationView *_userCommentView;
}
@end

@implementation DConversationListView
@synthesize _conversationList;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)designConversationListView
{
    _userCommentViewHeight = 60;
    [self createConversationListView];
    
    
}

-(void)createConversationListView
{
    //[self dummyConversationList];
    _listView = [[UITableView alloc] initWithFrame:self.bounds];
    [_listView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_listView setBackgroundColor:[UIColor clearColor]];
    _listView.showsVerticalScrollIndicator =NO;
    [_listView setDataSource:self];
    [_listView setDelegate:self];
    
    [self createListHeaderView];
    
    [self addSubview:_listView];
}

-(void)dummyConversationList
{
    _conversationList = [[NSMutableArray alloc] init];
    
    for (int i=0; i<30; i++)
    {
        {
            DConversation *conversation = [[DConversation alloc] init];
            [conversation setUsername:@"rouchea and wizer"];
            [conversation setComment:@"Thanks for choosing our products. We expect you to return for other beautifull accessories for your aqquarium."];
            [conversation setElapsedTime:@"27 S"];
            [conversation setType:DConversationTypeComment];
            [conversation setProfilePic:@"user2.png"];
            [_conversationList addObject:conversation];
        }
        {
            DConversation *conversation = [[DConversation alloc] init];
            [conversation setUsername:@"elle_ortiz"];
            [conversation setComment:@"Whoal And i thought you loved nothing but the wine you brew Sp there's much more to you huh? interesting.Whoal And i thought you loved nothing but the wine you brew Sp there's much more to you huh? interesting.Whoal And i thought you loved nothing but the wine you brew Sp there's much more to you huh? interesting.Whoal And i thought you loved nothing but the wine you brew Sp there's much more to you huh? interesting.Whoal And i thought you loved nothing but the wine you brew Sp there's much more to you huh? interesting."];
            [conversation setShowFullConversation:NO];
            [conversation setElapsedTime:@"3 m"];
            [conversation setType:DConversationTypeComment];
            [conversation setProfilePic:@"user2.png"];
            [_conversationList addObject:conversation];
        }
        {
            DConversation *conversation = [[DConversation alloc] init];
            [conversation setUsername:@"maurice fuchs"];
            [conversation setElapsedTime:@"4 S"];
            [conversation setNumberOfLikes:4];
            [conversation setType:DConversationTypeLike];
            [conversation setProfilePic:@"user2.png"];
            [_conversationList addObject:conversation];
        } 

    }
}


-(void)createListHeaderView
{
    float x,y,w,h,headerHeight = 40;
    
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    x = 20, y = 12;
    w = 320 - 2*x , h = 20;
    UILabel *titleLabel = [self createLabelOnView:headerView withText:@"Animals & Pets" atRect:CGRectMake(x,y,w,h)];
    [titleLabel setTextColor:[UIColor grayColor]];
    
    y = y + h;
    NSArray *tags = @[@"#theBestCompositePhotography", @"#aStoryAboutNothingness"];
    int count = tags.count;
    
    for (int i=0; i<count; i++)
    {
        UILabel *label = [self createLabelOnView:headerView withText:tags[i] atRect:CGRectMake(x,y,w,h)];
        [label setTextColor:[UIColor colorWithRed:140.0/255.0 green:185.0/255.0 blue:210.0/255.0 alpha:1]];
        [label setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0]];        
        y = y + h;
        headerHeight = headerHeight + h;
    }
    [headerView setFrame:CGRectMake(0, 0, 320, headerHeight)];
    [_listView setTableHeaderView:headerView];
}

-(UILabel *)createLabelOnView:(UIView *)view withText:(NSString *)text atRect:(CGRect)rect
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:text];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0]];
    [titleLabel setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    [view addSubview:titleLabel];
    
    return titleLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _userCommentViewHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(_userCommentView == nil)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        
        
        DConversation *conversation = [[DConversation alloc] init];
        [conversation setUsername:[userDefaults valueForKey:@"UserName"]];
        [conversation setProfilePic:[userDefaults valueForKey:@"UserProfilePicture"]];
        [conversation setType:DConversationTypeCurrentUser];
        
        _userCommentView = [[DConversationView alloc] initWithFrame:CGRectMake(0, 0, 320, 60) withConversation:conversation];
        [_userCommentView setDelegate:self];
        _userCommentView.backgroundColor = [UIColor clearColor];
    }
 
    
    return _userCommentView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_conversationList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"identifier_%d_%d",indexPath.section, indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    BOOL isNeedToShowExpandView = NO;
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    if(_currentExpandingIndexPath != nil)
    {
        if(_currentExpandingIndexPath.row == indexPath.row)
        {
            _currentExpandingIndexPath = nil;
            isNeedToShowExpandView = YES;
            //[self cleanView:cell.contentView];
        }
    }
    
    if([cell.contentView viewWithTag:111] == nil || isNeedToShowExpandView)
    {
        
        [self removePreviousContentFromTableView:cell];

        DConversationView *conversationView = [[DConversationView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath])  withConversation:_conversationList[indexPath.row]];
        [conversationView setDelegate:self];
        [cell.contentView addSubview:conversationView];
        [conversationView setTag:111];
    }
    
    return cell;
}


-(void)removePreviousContentFromTableView:(UITableViewCell *)cell
{
    DConversationView *previousConversationView = (DConversationView *)[cell.contentView viewWithTag:111];
    [previousConversationView setDelegate:nil];
    _tempContent = [[UIView alloc] initWithFrame:previousConversationView.bounds];
    [_tempContent addSubview:previousConversationView];
    [cell addSubview:_tempContent];
    [self performSelector:@selector(removeTempContent) withObject:nil afterDelay:0.0];
}

-(void)removeTempContent
{
    [_tempContent setHidden:YES];
    [_tempContent removeFromSuperview];
    _tempContent = nil;
}

-(void)cleanView:(UIView *)superView
{
    for (UIView *view in superView.subviews)
    {
        if(view!= nil)
        {
            [view removeFromSuperview];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = (indexPath.row == 0)?60:80;
    
    DConversation *conversation = _conversationList[indexPath.row];
    switch (conversation.type)
    {
        case DConversationTypeCurrentUser:
            height = 60;
            break;
        case DConversationTypeLike:
            height = 62;
            if(conversation.showAllLikes)
            {
                NSInteger totalLikes = [conversation numberOfLikes];
                height = height + totalLikes*height;
            }
            
            break;
        case DConversationTypeComment:
        {
            CGSize commentSize = [conversation.comment sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.0] constrainedToSize:CGSizeMake(230, 1500) lineBreakMode:UILineBreakModeWordWrap];
            if(conversation.showFullConversation)
            {
                //Caliculate the full conversation length...
                
                height = commentSize.height + 56;
            }
            else
            {
                height = 90;
                if(commentSize.height > 45)
                {
                    height = height + 20;
                }

            }
        }
            break;
        default:
            break;
    }
    
    return height;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark Conversation View Delegate Methods -

-(void)conversationView:(DConversationView *)conversationView expandOthersLikeView:(NSNumber *)expand
{
    BOOL showFullConversation = [expand boolValue];
    if(showFullConversation)
    {
        DConversation *conversation = [conversationView conversation];
        if(conversation != nil)
        {
            _currentExpandingIndexPath = [NSIndexPath indexPathForRow:[_conversationList indexOfObject:conversation] inSection:0];
        }
        
        //Increase height of cell...
        [_listView beginUpdates];
        [_listView reloadData];
        [_listView endUpdates];
    }
}

-(void)conversationView:(DConversationView *)conversationView needToExpand:(NSNumber *)expand
{
    BOOL showFullConversation = [expand boolValue];
    
    if(showFullConversation)
    {
        //Show full conversation here...
        DConversation *conversation = [conversationView conversation];
        if(conversation != nil)
        {
            _currentExpandingIndexPath = [NSIndexPath indexPathForRow:[_conversationList indexOfObject:conversation] inSection:0];
        }
        
        
        [_listView beginUpdates];
        [_listView reloadData];
        [_listView endUpdates];
        
    }
    else
    {
        //Hide full conversation here....
        
    }
}

-(void)conversationView:(DConversationView *)conversationView expandCommentView:(NSNumber *)height
{
    _isNeedToExpandUserCommentView = YES;
    
    //NSLog(@"new height available:%@",height);
    
    
    _userCommentViewHeight = [height floatValue]+30;
    [_userCommentView setFrame:CGRectMake(0, 0, 320, _userCommentViewHeight)];
    [_userCommentView increaseContentSize];
    
    [_listView beginUpdates];
    [_listView reloadData];
    [_listView endUpdates];
}


@end
