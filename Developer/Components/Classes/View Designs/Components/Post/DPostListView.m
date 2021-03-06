//
//  DPostListView.m
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DPostListView.h"
#import "DPostView.h"
#import "DPost.h"
#import "DPromterListView.h"

@interface DPostListView ()<UITableViewDataSource, UITableViewDelegate, DPostViewDelegate>
{
    UITableView *_postListView;
    
    DPostView *_currentPlayingPost;
    NSMutableArray *_postList;
    CGPoint _currentOffset;
    
}
@end

@implementation DPostListView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createPostListView];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame andPostsList:(NSArray *)list withHeaderView:(UIView *)headerView
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _postList = [[NSMutableArray alloc] init];
        [_postList addObjectsFromArray:list];
        [self createPostListView:headerView];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andPostsList:(NSArray *)list
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _postList = [[NSMutableArray alloc] initWithArray:list];
        [self createPostListView];
        
    }
    return self;
}



-(void)createPostListView:(UIView *)headerView
{
    self.backgroundColor = [UIColor clearColor];
    _postListView = [[UITableView alloc] initWithFrame:self.bounds];
    _postListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_postListView setDataSource:self];
    [_postListView setDelegate:self];
    [_postListView setBackgroundColor:[UIColor clearColor]];
    _postListView.backgroundView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_std_4in.png"]];
    _postListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_postListView];
    
    [headerView setFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    _postListView.tableHeaderView = headerView;
    
    
//    [_postListView removeObserver:self forKeyPath:@"contentOffset" context:nil];
    [_postListView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}


-(void)createPostListView
{
    self.backgroundColor = [UIColor clearColor];
    _postListView = [[UITableView alloc] initWithFrame:self.bounds];
    [_postListView setDataSource:self];
    [_postListView setDelegate:self];
    [_postListView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_postListView];
    
    _currentOffset = _postListView.contentOffset;
}

-(void)reloadData:(NSArray *)details
{
    _postList = [[NSMutableArray alloc] initWithArray:details];
    [_postListView reloadData];
}

- (void)appendMorePosts:(NSArray *)details
{
    [_postList addObjectsFromArray:details];
    [_postListView reloadData];
}

-(void)addHeaderViewForTable:(UIView *)headerView
{
    [headerView setFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
    [_postListView setTableHeaderView:headerView];
    [_postListView reloadData];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{   
    return [_postList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"identifier_%ld_%ld",(long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    DPostView *postView = (DPostView *)[cell.contentView viewWithTag:111];
    if(postView == nil)
    {
        DPost *post = _postList[indexPath.row];
        if([post type] == DpostTypePost)
        {
            float height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
            
            DPostView *postView = [[DPostView alloc] initWithFrame:CGRectMake(0, 0, 320, height-10) andPost:post];
            //[postView designPostView];
            [postView setDelegate:self];
            [cell.contentView addSubview:postView];
            [postView setTag:111];
        }
        else
        {
            float height = 400;
            
            DPromterListView *prompterListView = [[DPromterListView alloc] initWithFrame:CGRectMake(0, 0, 320, height) withPrompterImages:post.prompters];
            [cell.contentView addSubview:prompterListView];
            [prompterListView setTag:111];
        }
    }
    else
    {
        
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 456;
    DPost *post = _postList[indexPath.row];
    
    
    if([post type] == DpostTypePrompter)
    {
        height = 400;
    }
    else
    {
        DPostAttachments *attachments = post.attachements;
        if(attachments != nil)
        {
            NSArray *tags = attachments.tagsList;
            if(tags != nil)
            {
                int count = tags.count;
                height = height + count*20;
            }
        }
    }
    
    
    return height;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
    
    DPost *post = _postList[indexPath.row];
    if([post type] == DpostTypePost)
    {
        DPostView *postView = (DPostView *)[cell.contentView viewWithTag:111];
        if(postView != nil)
        {
            [postView pauseVideo];
            _currentPlayingPost = postView;
        }
    }
    
    
}

-(void)profileDidSelectedForPost:(DPost *)post
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(userProfileSelectedForPost:)])
    {
        [self.delegate userProfileSelectedForPost:post];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGFloat newOffset = [[change objectForKey:@"new"] CGPointValue].y;
    CGFloat oldOffset = [[change objectForKey:@"old"] CGPointValue].y;
    CGFloat diff = newOffset - oldOffset;
    if (diff < 0 )//scrolling down...
    {
        // NSLog(@"Scrolling Down");
        [self scrollViewScrollingDirection:@"DOWN"];
    }
    else//Scrolling Up...
    {
        //NSLog(@"Scrolling up");
        [self scrollViewScrollingDirection:@"UP"];
    }
}


-(void)scrollViewScrollingDirection:(NSString *)direction
{
    //return;
    
    if(_delegate != nil && [_delegate respondsToSelector:@selector(scrollView:scrollingDirection:)])
    {
        [_delegate performSelector:@selector(scrollView:scrollingDirection:) withObject:_postListView withObject:direction];
    }
}


-(void)scrollViewDidEndDeceleratingOfPostList:(UIScrollView *)scrollView
{
    //return;
    if(_delegate != nil && [_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
    {
        [_delegate performSelector:@selector(scrollViewDidEndDecelerating:) withObject:_postListView ];
    }
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //The auto play wont work if we return from here...
    return;
    
    [self scrollViewDidEndDeceleratingOfPostList:scrollView];
    
    //NSLog(@"will end decelerating");
    CGPoint contentOffset = scrollView.contentOffset;
    _currentOffset = contentOffset;
    
    NSArray *indexPaths = [_postListView indexPathsForVisibleRows];
    int count = indexPaths.count;
    for(int i=0; i<count; i++)
    {
        NSIndexPath *indexPath = indexPaths[i];
        BOOL visible = [self isCellCompletelyVisible:indexPath];
        if(visible)
        {
            if(_currentPlayingPost != nil)
            {
                [_currentPlayingPost pauseVideo];
            }
            
            //Then play/pause song here....
            DPost *post = _postList[indexPath.row];
            if(post.type == DpostTypePost)
            {
                UITableViewCell *cell = [_postListView cellForRowAtIndexPath:indexPath];
                DPostView *postView = (DPostView *)[cell.contentView viewWithTag:111];
                if(postView != nil)
                {
                    //NSLog(@"Visible cell:%d current:%@ Post:%@",indexPath.row, _currentPlayingPost, postView);
                    [postView playVideo];
                    [_currentPlayingPost pauseVideo];
                    _currentPlayingPost = postView;
                    break;
                }
                
            }
            else
            {
                
            }
            
            
            
            //break;
        }
        else
        {
            
        }
    }
}

-(void)scrollviewDidHoldingFinger:(NSString *)holding
{
    //return;
    
    if(_delegate != nil && [_delegate respondsToSelector:@selector(scrollView:didHoldingFinger:)])
    {
        [_delegate scrollView:_postListView didHoldingFinger:holding];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
   // return;
    // NSLog(@"scroll view did begin dragging");
    [self scrollviewDidHoldingFinger:@"HOLDING"];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //return;
    
    [self scrollviewDidHoldingFinger:@"UNHOLDING"];
    // NSLog(@"will end dragging");
    
    
    return;
    NSArray *indexPaths = [_postListView indexPathsForVisibleRows];
    int count = indexPaths.count;
    for(int i=0; i<count; i++)
    {
        NSIndexPath *indexPath = indexPaths[i];
        BOOL visible = [self isCellCompletelyVisible:indexPath];
        if(visible)
        {
            if(_currentPlayingPost != nil)
            {
                [_currentPlayingPost pauseVideo];
            }
            
            DPost *post = _postList[indexPath.row];
            if(post.type == DpostTypePost)
            {
                
                //Then play/pause song here....
                UITableViewCell *cell = [_postListView cellForRowAtIndexPath:indexPath];
                DPostView *postView = (DPostView *)[cell.contentView viewWithTag:111];
                if(postView != nil)
                {
                    
                    //NSLog(@"dragging visible cell:%d current:%@ Post:%@",indexPath.row, _currentPlayingPost, postView);
                    [_currentPlayingPost pauseVideo];
                    [postView playVideo];
                    _currentPlayingPost = postView;
                    break;
                }
                
            }
            //break;
        }
        else
        {
            
        }
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
//    NSLog(@"offset = %@, bounds = %@, size = %@, inset = %@", NSStringFromCGPoint(offset), NSStringFromCGRect(bounds), NSStringFromCGSize(size), NSStringFromUIEdgeInsets(inset));
    
    float reload_distance = 500.0f;//100;
    if(y > (h - reload_distance)) {
        // Call the method.
        if((_delegate != nil && [_delegate respondsToSelector:@selector(loadNextPageOfPost:)])) {
            [_delegate performSelector:@selector(loadNextPageOfPost:) withObject:self];
        }
        
        return;
    }
    
}


-(BOOL)isCellCompletelyVisible:(NSIndexPath *)indexPath
{
    return NO;
    
    CGPoint contentOffset = _postListView.contentOffset;
    float postYPosition = [self yPostionOfCellForIndexPath:indexPath] + 50;
    float postYBoundary = postYPosition + 320;//Where posting body contains fixed size.
    
    if(postYPosition >= contentOffset.y && postYBoundary <= (contentOffset.y + _postListView.bounds.size.height))
    {
        return YES;
    }
    
    return NO;
}


-(float)yPostionOfCellForIndexPath:(NSIndexPath *)indexPath
{
    float y = 0;
    
    for (int i=0; i<indexPath.row; i++)
    {
        float height = [self tableView:_postListView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        y = y+height;
        
    }
    
    return  y;
}


-(void)deletePost:(DPost *)post
{
    //Delete the post....
    NSInteger index = [_postList indexOfObject:post];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    if(indexPath != nil)
    {
        [_postList removeObjectAtIndex:index];

        [_postListView beginUpdates];
        [_postListView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];//Fade
        [_postListView endUpdates];
    }
    
    
}


-(void)showMoreDetailsOfThisPost:(DPost *)post
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(showMoreDetailsOfThisPost:)])
    {
        [self.delegate showMoreDetailsOfThisPost:post];
    }
}

-(void)showConversationOfThisPost:(DPost *)post
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(showConversationOfThisPost:)])
    {
        [self.delegate showConversationOfThisPost:post];
    }
}


-(void)didSelectedTag:(NSString *)tag forThisPost:(DPost *)post
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didSelectedTag:forThisPost:)])
    {
        [self.delegate didSelectedTag:tag forThisPost:post];
    }
}










/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)dealloc
{
//    [_postListView removeObserver:self forKeyPath:@"contentOffset" context:nil];
    [_postListView removeObserver:self forKeyPath:@"contentOffset"];

}

@end
