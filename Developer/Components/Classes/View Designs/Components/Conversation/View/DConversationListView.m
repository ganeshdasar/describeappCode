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
#import "WSModelClasses.h"

@interface DConversationListView ()<UITableViewDataSource, UITableViewDelegate, DConversationDelegate, UIActionSheetDelegate>
{
    UITableView *_listView ;
  //  NSMutableArray *_conversationList;
    NSIndexPath *_currentExpandingIndexPath;
    UIView *_tempContent;
    BOOL _isNeedToExpandUserCommentView;
    
    float _userCommentViewHeight;
    DConversationView *_userCommentView;
    UIView *_keyboardToolBar;
    
    BOOL _isSelfConversation;
    DConversation *_actionConversation;//Will take action on this conversation...
    UIActionSheet *_moreActionSheet;
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
    //[self registerKeyboardNotifications];
    
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

//@{@"PostCategory":dic[@"PostCategory"],@"PostTag1":dic[@"PostTag1"],@"PostTag2":dic[@"PostTag2"],@"PostUID":dic[@"PostUID"]};

-(void)createListHeaderView
{
    float x,y,w,h,headerHeight = 0;
    
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    x = 20, y = 12;
    w = 320 - 2*x , h = 20;
    UILabel *titleLabel = [self createLabelOnView:headerView withText:self.header[@"PostCategory"] atRect:CGRectMake(x,y,w,h)];
    [titleLabel setTextColor:[UIColor grayColor]];
    
    y = y + h;
    
    
    NSMutableArray *tags = [[NSMutableArray alloc] init];
  
    if(self.header[@"PostCategory"] != nil)
        headerHeight = 40;
    
    if(self.header[@"PostTag1"] != nil)
        [tags addObject:[NSString stringWithFormat:@"#%@",self.header[@"PostTag1"]]];
    
    if(self.header[@"PostTag2"] != nil)
        [tags addObject:[NSString stringWithFormat:@"#%@",self.header[@"PostTag2"]]];
    
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
        [conversation setPostId:self.header[@"PostUID"]];
        [conversation setUserId:[[[WSModelClasses sharedHandler] loggedInUserModel].userID stringValue]];
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
    
    
    cell.contentView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.8];
    
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
    float height = (indexPath.row == 0)?34:80;
    
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

            UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0];
            
            CGRect rect = [conversation.comment boundingRectWithSize:CGSizeMake(224, 60) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
            CGSize commentSize = rect.size;
            
            if(conversation.showFullConversation)
            {
                //Caliculate the full conversation length...
                
                height = height + commentSize.height + 10;
            }
            else
            {
                if(commentSize.height > 45)
                {
                    height = height + 30;
                }
                else
                {
                    height = height + commentSize.height;
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

-(void)postComment:(NSString *)comment forConversation:(DConversation *)conversation
{
    [conversation setType:DConversationTypeComment];
    [conversation setComment:comment];
    
    [_conversationList addObject:conversation];
    [_listView reloadData];
    
    
    
    NSString *convertedString = [comment stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[WSModelClasses sharedHandler] commentUserId:[[[[WSModelClasses sharedHandler] loggedInUserModel] userID] stringValue] authUId:conversation.userId post:conversation.postId comment:convertedString response:^(BOOL success, id response) {
        //Handle response...
        if(success)
        {
            //Comment posted...
            NSLog(@"Successfully Commented: %@",response);
        }
        else
        {
            //Commented failed...
            NSLog(@"Failed to commentL: %@", response);
        }
    }];
    
}


-(void)registerKeyboardNotifications
{
    {
        //Keyboard toll bar...
        _keyboardToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, 320, 44)];
        [_keyboardToolBar setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
        [self addSubview:_keyboardToolBar];
        
        //Done button on tool bar...
        UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 2, 50, 40)];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(resignKeyboard) forControlEvents:UIControlEventTouchUpInside];
        [_keyboardToolBar addSubview:doneButton];
    }
    
    // Add two notifications for the keyboard. One when the keyboard is shown and one when it's about to hide.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)resignKeyboard
{
    [_userCommentView resignKeyboard];
}

-(void)keyboardWillShown:(id)notification
{
    CGRect rect = _keyboardToolBar.frame;
    rect.origin.y = self.frame.size.height - (218+20);
    
    [UIView animateWithDuration:.26 animations:^{
        [_keyboardToolBar setFrame:rect];
    } completion:^(BOOL finished) {
        //Animation finished...
    }];
}

-(void)keyboardWillHide:(id)notification
{
    CGRect rect = _keyboardToolBar.frame;
    rect.origin.y = self.frame.size.height+20;
    
    [UIView animateWithDuration:.3 animations:^{
        [_keyboardToolBar setFrame:rect];
    } completion:^(BOOL finished) {
        //Animation finished...
    }];
}

-(void)actionOnThisConversation:(DConversation *)conversation
{
    NSNumber *currentUserId = [[[WSModelClasses sharedHandler] loggedInUserModel] userID];
    NSString *userId = [currentUserId stringValue];
    _isSelfConversation = [userId isEqualToString:conversation.userId];
    if(_isSelfConversation)
    {
        _moreActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete",nil];
        _moreActionSheet.tag = 111;
    }
    else
    {
        _moreActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report",nil];
        _moreActionSheet.tag = 222;
    }
    
    [_moreActionSheet setFrame:CGRectMake(0, 0, 320, 400)];
    [_moreActionSheet showInView:self];
    
    _actionConversation = conversation;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 111)
    {
        switch (buttonIndex) {
            case 0:
                //Delete the conversation...
                //And update the ui...
               
               
                break;
            case 1:
                
                break;
            default:
                break;
        }
    }
    else
    {
        switch (buttonIndex) {
            case 0:
                //Report the conversation....
                //and update the ui....
                [[WSModelClasses sharedHandler] reportComment:_actionConversation.conversationId   forUser:[[[[WSModelClasses sharedHandler] loggedInUserModel] userID] stringValue]
                                                     response:^(BOOL success, id response) {
                                                         if(success)
                                                         {
                                                             //Reported the success fully...
                                                         }
                                                         else
                                                         {
                                                             //Reported failed...
                                                         }
                                                     }];
                
                break;
            case 1:
                //
                break;
            default:
                break;
        }
    }

    //Will simply reload the data to update content...
    [_conversationList removeObject:_actionConversation];
    [_listView reloadData];
    _actionConversation = nil;

}


@end
