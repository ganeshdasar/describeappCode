//
//  DPeopleListComponent.m
//  Describe
//
//  Created by NuncSys on 26/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DPeopleListComponent.h"
#import "DUserComponent.h"
#import "DUserData.h"

@interface DPeopleListComponent () <UITableViewDataSource, UITableViewDelegate, DUserComponentDelegate>
{
    UITableView *_peopleListView;
    DUserComponent * _userComponent;
}

@end
@implementation DPeopleListComponent
@synthesize _peopleList;
@synthesize isAddPeople;
@synthesize isSearchPeople;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andPeopleList:(NSArray *)list
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self._peopleList = [[NSMutableArray alloc] initWithArray:list];
        [self createPeopleListView];
        self.backgroundColor = [UIColor clearColor];
     
    
    }
    return self;
}

- (void)addHeaderViewForTable:(UIView *)headerView
{
    [headerView setFrame:CGRectMake(0, 0, self.bounds.size.width, 60)];
    [_peopleListView setTableHeaderView:headerView];
    [_peopleListView reloadData];
}

- (void)createPeopleListView
{
    _peopleListView = [[UITableView alloc] initWithFrame:self.bounds];
    _peopleListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_peopleListView setShowsHorizontalScrollIndicator:NO];
    [_peopleListView setShowsVerticalScrollIndicator:NO];
    [_peopleListView setDataSource:self];
    [_peopleListView setDelegate:self];
    [_peopleListView setBackgroundColor: [UIColor clearColor]];
    _peopleListView.backgroundView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_std_4in.png"]];
    _peopleListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_peopleListView];

    [_peopleListView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)loadMorePeople:(NSArray *)peopleList
{
    [_peopleList addObjectsFromArray:peopleList];
    [_peopleListView reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self._peopleList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"identifier_%ld_%ld", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.selectedBackgroundView = nil;
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        
    }
    
    DUserComponent * userDataView = (DUserComponent *)[cell.contentView viewWithTag:111];
    
    if (userDataView == nil)
    {
        SearchPeopleData * data = self._peopleList[indexPath.row];
        userDataView = [[DUserComponent alloc] initWithFrame:CGRectMake(0, 0, 320, 56) AndUserData:data];
        userDataView.tag = 111;
        userDataView.delegate = self;
        [cell.contentView addSubview:userDataView];
        [userDataView setBackgroundColor:[UIColor clearColor]];
    }
    
    [userDataView updateContent:self._peopleList[indexPath.row]];
    
    //40Px 16*2
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(_delegate != nil && [_delegate respondsToSelector:@selector(peopleListView:didSelectedItemIndex:)])
    {
        [_delegate peopleListView:self didSelectedItemIndex:indexPath.row];
    }
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}


#pragma mark - DUserComponentDelegate Method

- (void)statusChange
{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(statusChange)]) {
        [_delegate statusChange];
    }
}

/*- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,0,320,40)];
    tempView.backgroundColor = [UIColor clearColor];
    UIImageView *_imgeView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,320,40)];
    if ([WSModelClasses sharedHandler].loggedInUserModel.isInvitation == YES) {
        _imgeView.image =[UIImage imageNamed:@"btn_invite_all.png"];
    }else{
        _imgeView.image =[UIImage imageNamed:@"btn_follow_all.png"];

    }
    [tempView addSubview:_imgeView];
    return nil;
}*/


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGFloat newOffset = [[change objectForKey:@"new"] CGPointValue].y;
    CGFloat oldOffset = [[change objectForKey:@"old"] CGPointValue].y;
    CGFloat diff = newOffset - oldOffset;
    if (diff < 0 ) { //scrolling down...
        // do something
        //NSLog(@"Scrolling Down");
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
    if(_delegate != nil && [_delegate respondsToSelector:@selector(scrollView:scrollingDirection:)])
    {
        [_delegate performSelector:@selector(scrollView:scrollingDirection:) withObject:_peopleListView withObject:direction];
    }
}


-(void)scrollViewDidEndDeceleratingOfPostList:(UIScrollView *)scrollView
{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
    {
        [_delegate performSelector:@selector(scrollViewDidEndDecelerating:) withObject:_peopleListView ];
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndDeceleratingOfPostList:scrollView];
}

-(void)scrollviewDidHoldingFinger:(NSString *)holding
{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(scrollView:didHoldingFinger:)])
    {
        [_delegate scrollView:_peopleListView didHoldingFinger:holding];
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scroll view did begin dragging");
    [self scrollviewDidHoldingFinger:@"HOLDING"];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self scrollviewDidHoldingFinger:@"UNHOLDING"];
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
    
    float reload_distance = 200.0f;//100;
    if(y > (h - reload_distance)) {
        // Call the method.
        if((_delegate != nil && [_delegate respondsToSelector:@selector(loadNextPage)])) {
            [_delegate performSelector:@selector(loadNextPage) withObject:nil];
        }
        
        return;
    }
    
}


-(void)reloadTableView:(NSMutableArray*)inArray{
    
    self._peopleList = inArray;
    [_peopleListView reloadData];
}

-(void)dealloc
{
    [_peopleListView removeObserver:self forKeyPath:@"contentOffset" context:nil];
}

@end
