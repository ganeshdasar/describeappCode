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
@interface DPeopleListComponent ()<UITableViewDataSource,UITableViewDelegate>{
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

-(void)addHeaderViewForTable:(UIView *)headerView
{
    [headerView setFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
    [_peopleListView setTableHeaderView:headerView];
    [_peopleListView reloadData];
}

-(void)createPeopleListView
{
    _peopleListView = [[UITableView alloc] initWithFrame:self.bounds];
    _peopleListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_peopleListView setShowsHorizontalScrollIndicator:NO];
    [_peopleListView setShowsVerticalScrollIndicator:NO];
    [_peopleListView setDataSource:self];
    [_peopleListView setDelegate:self];
    [_peopleListView setBackgroundColor: [UIColor clearColor]];
    _peopleListView.backgroundView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_std_4in.png"]];
    
    [self addSubview:_peopleListView];

    [_peopleListView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self._peopleList count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"identifier_%d_%ld",indexPath.section, (long)indexPath.row];
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
        userDataView.tag =111;
        [cell.contentView addSubview:userDataView];
        [userDataView setBackgroundColor:[UIColor clearColor]];
    }
    else
    {
        
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


-(void)reloadTableView:(NSMutableArray*)inArray{
    
    self._peopleList = inArray;
    [_peopleListView reloadData];
}

-(void)dealloc
{
    [_peopleListView removeObserver:self forKeyPath:@"contentOffset" context:nil];
}

@end
