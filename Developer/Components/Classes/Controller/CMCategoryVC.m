//
//  CMCategoryVC.m
//  Composition
//
//  Created by Describe Administrator on 05/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "CMCategoryVC.h"
#import "CMShareCategoryCell.h"

#define CATEGORY_CELLIDENTIFIER             @"CategoryCell"

#define NO_CATEGORY_COLOR                   [UIColor colorWithR:220.0f G:220.0f B:220.0f A:255.0f]
#define ACTIVITIES_COLOR                    [UIColor colorWithR:0.0f G:137.0f B:190.0f A:255.0f]
#define ANIMALS_PETS_COLOR                  [UIColor colorWithR:0.0f G:160.0f B:196.0f A:255.0f]
#define ARCHITECTURE_SPACES_COLOR           [UIColor colorWithR:0.0f G:188.0f B:143.0f A:255.0f]
#define ARTS_CRAFTS_COLOR                   [UIColor colorWithR:0.0f G:180.0f B:61.0f A:255.0f]
#define BOOKS_COLOR                         [UIColor colorWithR:14.0f G:172.0f B:0.0f A:255.0f]
#define CELEBRATION_COLOR                   [UIColor colorWithR:52.0f G:181.0f B:0.0f A:255.0f]
#define CARE_COLOR                          [UIColor colorWithR:94.0f G:191.0f B:0.0f A:255.0f]
#define DESIGN_COLOR                        [UIColor colorWithR:140.0f G:200.0f B:0.0f A:255.0f]
#define EVENTS_COLOR                        [UIColor colorWithR:175.0f G:218.0f B:0.0f A:255.0f]
#define EDUCATION_COLOR                     [UIColor colorWithR:213.0f G:237.0f B:0.0f A:255.0f]
#define FAMILY_COLOR                        [UIColor colorWithR:255.0f G:237.0f B:0.0f A:255.0f]
#define FOOD_COLOR                          [UIColor colorWithR:255.0f G:218.0f B:0.0f A:255.0f]
#define LIFESTYLE_COLOR                     [UIColor colorWithR:255.0f G:200.0f B:0.0f A:255.0f]
#define PLACES_COLOR                        [UIColor colorWithR:255.0f G:181.0f B:0.0f A:255.0f]
#define HUMOR_COLOR                         [UIColor colorWithR:255.0f G:163.0f B:0.0f A:255.0f]
#define INSPIRATION_COLOR                   [UIColor colorWithR:255.0f G:144.0f B:0.0f A:255.0f]
#define MOVIES_TV_COLOR                     [UIColor colorWithR:255.0f G:129.0f B:0.0f A:255.0f]
#define MUSIC_COLOR                         [UIColor colorWithR:255.0f G:113.0f B:0.0f A:255.0f]
#define NEWS_COLOR                          [UIColor colorWithR:255.0f G:98.0f B:0.0f A:255.0f]
#define OPINIONS_COLOR                      [UIColor colorWithR:255.0f G:65.0f B:0.0f A:255.0f]
#define PEOPLE_COLOR                        [UIColor colorWithR:255.0f G:33.0f B:0.0f A:255.0f]
#define PHOTOGRAPHY_COLOR                   [UIColor colorWithR:236.0f G:0.0f B:50.0f A:255.0f]
#define PRODUCTS_COLOR                      [UIColor colorWithR:217.0f G:0.0f B:92.0f A:255.0f]
#define STORIES_COLOR                       [UIColor colorWithR:198.0f G:0.0f B:125.0f A:255.0f]
#define SCIENCE_NATURE_COLOR                [UIColor colorWithR:186.0f G:0.0f B:165.0f A:255.0f]
#define TECHNOLOGY_COLOR                    [UIColor colorWithR:148.0f G:0.0f B:173.0f A:255.0f]
#define THINGS_I_LOVE_COLOR                 [UIColor colorWithR:97.0f G:0.0f B:161.0f A:255.0f]

@interface UIColor (JPExtras)
+ (UIColor *)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha;
@end

//.m file
@implementation UIColor (JPExtras)
+ (UIColor *)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha {
    return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:alpha];
}
@end

@interface CMCategoryVC ()
{
    NSArray *categoryList;
    NSArray *categoryColorList;
    
    NSInteger selectedCategoryIndex;
}

@end

@implementation CMCategoryVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    selectedCategoryIndex = -1;
    self.showCategoryOptions = 0;
    
    UINib *nib = [UINib nibWithNibName:@"CMShareCategoryCell" bundle:nil];
    [self.categoryTableView registerNib:nib forCellReuseIdentifier:CATEGORY_CELLIDENTIFIER];
    
    categoryList = [[NSArray alloc] initWithObjects:NSLocalizedString(@"No category", @""), NSLocalizedString(@"Activities", @""), NSLocalizedString(@"Animals & Pets", @""), NSLocalizedString(@"Architecture & Spaces", @""), NSLocalizedString(@"Arts & Crafts", @""), NSLocalizedString(@"Books", @""), NSLocalizedString(@"Celebration", @""), NSLocalizedString(@"Care", @""), NSLocalizedString(@"Design", @""), NSLocalizedString(@"Events", @""), NSLocalizedString(@"Education", @""), NSLocalizedString(@"Family", @""), NSLocalizedString(@"Food", @""), NSLocalizedString(@"Lifestyle", @""), NSLocalizedString(@"Places", @""), NSLocalizedString(@"Humor", @""), NSLocalizedString(@"Inspiration", @""), NSLocalizedString(@"Movies & TV", @""), NSLocalizedString(@"Music", @""), NSLocalizedString(@"News", @""), NSLocalizedString(@"Opinions", @""), NSLocalizedString(@"People", @""), NSLocalizedString(@"Photography", @""), NSLocalizedString(@"Products", @""), NSLocalizedString(@"Stories", @""), NSLocalizedString(@"Science & Nature", @""), NSLocalizedString(@"Technology", @""), NSLocalizedString(@"Things I Love", @""), nil];
    
    categoryColorList = [[NSArray alloc] initWithObjects:NO_CATEGORY_COLOR, ACTIVITIES_COLOR, ANIMALS_PETS_COLOR, ARCHITECTURE_SPACES_COLOR, ARTS_CRAFTS_COLOR, BOOKS_COLOR, CELEBRATION_COLOR, CARE_COLOR, DESIGN_COLOR, EVENTS_COLOR, EDUCATION_COLOR, FAMILY_COLOR, FOOD_COLOR, LIFESTYLE_COLOR, PLACES_COLOR, HUMOR_COLOR, INSPIRATION_COLOR, MOVIES_TV_COLOR, MUSIC_COLOR, NEWS_COLOR, OPINIONS_COLOR, PEOPLE_COLOR, PHOTOGRAPHY_COLOR, PRODUCTS_COLOR, STORIES_COLOR, SCIENCE_NATURE_COLOR, TECHNOLOGY_COLOR, THINGS_I_LOVE_COLOR, nil];
    
    [self.categoryTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewCell Datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if(!self.showCategoryOptions)
//        return 1;
    
    return categoryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = CATEGORY_CELLIDENTIFIER;
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    CMShareCategoryCell *categoryCell = (CMShareCategoryCell *)cell;
    
    if(indexPath.row == 0 && !self.showCategoryOptions) {
        categoryCell.categoryNameLabel.text = selectedCategoryIndex != -1 ? categoryList[selectedCategoryIndex]:NSLocalizedString(@"tap to choose a category", @"");
        categoryCell.contentView.backgroundColor = selectedCategoryIndex != -1 ? categoryColorList[selectedCategoryIndex]:NO_CATEGORY_COLOR;
    }
    else {
        categoryCell.categoryNameLabel.text = (NSString *)categoryList[indexPath.row];
        categoryCell.contentView.backgroundColor = (UIColor *)categoryColorList[indexPath.row];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.showCategoryOptions) {
        selectedCategoryIndex = indexPath.row;
    }
    
    self.showCategoryOptions = !self.showCategoryOptions;
    
    [tableView beginUpdates];
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:self.showCategoryOptions?UITableViewRowAnimationBottom:UITableViewRowAnimationTop];
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.showCategoryOptions?selectedCategoryIndex:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(categoryTableViewConroller:didSelectObjectAtIndex:)]) {
        [self.delegate categoryTableViewConroller:self didSelectObjectAtIndex:indexPath];
    }
    
    [tableView endUpdates];
}

@end
