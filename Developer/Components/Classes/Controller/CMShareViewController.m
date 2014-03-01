//
//  CMShareViewController.m
//  Composition
//
//  Created by Describe Administrator on 26/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "CMShareViewController.h"
#import "CMShareCategoryCell.h"
#import "CMShareTagCell.h"
#import "CMShareCompositionCell.h"
#import "CMPhotoModel.h"
#import "DPost.h"

#define LOCATION_CELLIDENTIFIER             @"LocationCell"
#define COMPOSITION_CELLIDENTIFIER          @"CompositionCell"
#define CATEGORY_CELLIDENTIFIER             @"CategoryCell"
#define TAG_CELLIDENTIFIER                  @"TagCell"
#define SHARE_CELLIDENTIFIER                @"ShareCell"

typedef enum {
    ShareSectionLocation = -1,
    ShareSectionComposition = 0,
    ShareSectionCategory,
    ShareSectionTag,
    ShareSectionShare,
}ShareSection;

#define NO_CATEGORY_SELECTED_COLOR          [UIColor colorWithR:212.0f G:212.0f B:212.0f A:255.0f]

@interface CMShareViewController ()
{
    BOOL showCompositionCell;
    BOOL showCategoryOption;    // identifies whether to show category options or not
    NSArray *sectionCellIdentiferList;      // holds the cell idenitifer of all sections
    NSArray *categoryList;          // holds all the category names
    NSArray *categoryColorList;     // holds color object for the category
    
    NSInteger selectedCategoryIndex;
    SPGooglePlacesAutocompleteViewController *vc;
    
    CMCategoryVC *categoryController;
    DPostImage *_imagePost;
}

@end

@implementation CMShareViewController

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
	// Do any additional setup after loading the view.
    
    DPostVideo *video = [[DPostVideo alloc] init];
    [video setDuration:@"25"];
    [video setUrl:[[NSBundle mainBundle] pathForResource:@"444" ofType:@"mp4"]];
    
    _imagePost = [[DPostImage alloc] init];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    {
        CMPhotoModel *photoModel = [[CMPhotoModel alloc] init];
        [photoModel setEditedImage:[UIImage imageNamed:@"1.jpg"]];
        [photoModel setDuration:8];
        [images addObject:photoModel];
    }
    {
        CMPhotoModel *photoModel = [[CMPhotoModel alloc] init];
        [photoModel setEditedImage:[UIImage imageNamed:@"2.jpg"]];
        [photoModel setDuration:10];
        [images addObject:photoModel];
    }
    [_imagePost setImages:images];
    
   // [_imagePost setImages:[[NSArray alloc] initWithObjects:@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg", nil]];
   // [_imagePost setDurationList:[[NSArray alloc] initWithObjects:@"10",@"2",@"1",@"4",@"3", nil]];
    [_imagePost setVideo:video];
    
    
    
    
    UINib *nib = [UINib nibWithNibName:@"CMShareCompositionCell" bundle:nil];
    [self.shareTableView registerNib:nib forCellReuseIdentifier:COMPOSITION_CELLIDENTIFIER];
    
//    nib = [UINib nibWithNibName:@"CMShareCategoryCell" bundle:nil];
//    [self.shareTableView registerNib:nib forCellReuseIdentifier:CATEGORY_CELLIDENTIFIER];
    
    nib = [UINib nibWithNibName:@"CMShareTagCell" bundle:nil];
    [self.shareTableView registerNib:nib forCellReuseIdentifier:TAG_CELLIDENTIFIER];
    
    nib = [UINib nibWithNibName:@"CMShareSocialCell" bundle:nil];
    [self.shareTableView registerNib:nib forCellReuseIdentifier:SHARE_CELLIDENTIFIER];
    
    selectedCategoryIndex = -1;  // default should be -1
    showCategoryOption = NO;  // default do not show category option
    sectionCellIdentiferList = [[NSArray alloc] initWithObjects:COMPOSITION_CELLIDENTIFIER, CATEGORY_CELLIDENTIFIER, TAG_CELLIDENTIFIER, SHARE_CELLIDENTIFIER, nil];
    
//    categoryList = [[NSArray alloc] initWithObjects:NSLocalizedString(@"No category", @""), NSLocalizedString(@"Activities", @""), NSLocalizedString(@"Animals & Pets", @""), NSLocalizedString(@"Architecture & Spaces", @""), NSLocalizedString(@"Arts & Crafts", @""), NSLocalizedString(@"Books", @""), NSLocalizedString(@"Celebration", @""), NSLocalizedString(@"Care", @""), NSLocalizedString(@"Design", @""), NSLocalizedString(@"Events", @""), NSLocalizedString(@"Education", @""), NSLocalizedString(@"Family", @""), NSLocalizedString(@"Food", @""), NSLocalizedString(@"Lifestyle", @""), NSLocalizedString(@"Places", @""), NSLocalizedString(@"Humor", @""), NSLocalizedString(@"Inspiration", @""), NSLocalizedString(@"Movies & TV", @""), NSLocalizedString(@"Music", @""), NSLocalizedString(@"News", @""), NSLocalizedString(@"Opinions", @""), NSLocalizedString(@"People", @""), NSLocalizedString(@"Photography", @""), NSLocalizedString(@"Products", @""), NSLocalizedString(@"Stories", @""), NSLocalizedString(@"Science & Nature", @""), NSLocalizedString(@"Technology", @""), NSLocalizedString(@"Things I Love", @""), nil];
//    
//    categoryColorList = [[NSArray alloc] initWithObjects:NO_CATEGORY_COLOR, ACTIVITIES_COLOR, ANIMALS_PETS_COLOR, ARCHITECTURE_SPACES_COLOR, ARTS_CRAFTS_COLOR, BOOKS_COLOR, CELEBRATION_COLOR, CARE_COLOR, DESIGN_COLOR, EVENTS_COLOR, EDUCATION_COLOR, FAMILY_COLOR, FOOD_COLOR, LIFESTYLE_COLOR, PLACES_COLOR, HUMOR_COLOR, INSPIRATION_COLOR, MOVIES_TV_COLOR, MUSIC_COLOR, NEWS_COLOR, OPINIONS_COLOR, PEOPLE_COLOR, PHOTOGRAPHY_COLOR, PRODUCTS_COLOR, STORIES_COLOR, SCIENCE_NATURE_COLOR, TECHNOLOGY_COLOR, THINGS_I_LOVE_COLOR, nil];
    
    vc = [[SPGooglePlacesAutocompleteViewController alloc] initWithNibName:@"SPGooglePlacesAutocompleteViewController" bundle:nil];
    vc.delegate = self;
    [self.locationContainerView addSubview:vc.view];
    
    categoryController = [[CMCategoryVC alloc] initWithNibName:@"CMCategoryVC" bundle:nil];
    [categoryController.view setFrame:CGRectMake(0, 0, 320, 41.0)];
    categoryController.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Header button action methods

- (IBAction)listOptionClicked:(id)sender
{
    
}

- (IBAction)dismissOptionCLicked:(id)sender
{
    
}

- (IBAction)prevOptionClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Share cell action methods

- (IBAction)socailButtonClicked:(id)sender
{
    NSLog(@"%s, tag = %d", __func__, [sender tag]);
}

- (IBAction)shareButtonClicked:(id)sender
{
    NSLog(@"%s", __func__);
}

#pragma mark - UITableDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 1;
    ShareSection sectionVal = (ShareSection)section;
    switch (sectionVal) {
        case ShareSectionLocation:
        case ShareSectionComposition:
        case ShareSectionShare:
        {
            rowCount = 1;
            break;
        }
            
        case ShareSectionCategory:
        {
            rowCount = 1;
            break;
        }
            
        case ShareSectionTag:
        {
            rowCount = 2;
            break;
        }
            
        default:
            rowCount = 1;
            break;
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = (NSString *)sectionCellIdentiferList[indexPath.section];
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    ShareSection sectionVal = (ShareSection)indexPath.section;
    switch (sectionVal) {
        case ShareSectionLocation:
        {
            break;
        }
            
        case ShareSectionComposition:
        {
            CMShareCompositionCell *compositeCell = (CMShareCompositionCell *)cell;
            compositeCell.delegate = self;
            CMPhotoModel *model = (CMPhotoModel *)self.capturedPhotoList[0];
            compositeCell.compositionImageView.image = model.editedImage;
            [compositeCell setPostImage:_imagePost];
            
            
            
            break;
        }
            
        case ShareSectionCategory:
        {
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            [categoryController.view removeFromSuperview];
            [cell.contentView addSubview:categoryController.view];
            
//            CMShareCategoryCell *categoryCell = (CMShareCategoryCell *)cell;
//            if(indexPath.row == 0 && !showCategoryOption) {
//                categoryCell.categoryNameLabel.text = selectedCategoryIndex != -1 ? categoryList[selectedCategoryIndex]:NSLocalizedString(@"tap to choose a category", @"");
//                categoryCell.contentView.backgroundColor = selectedCategoryIndex != -1 ? categoryColorList[selectedCategoryIndex]:NO_CATEGORY_SELECTED_COLOR;
//            }
//            else {
//                categoryCell.categoryNameLabel.text = (NSString *)categoryList[indexPath.row];
//                categoryCell.contentView.backgroundColor = (UIColor *)categoryColorList[indexPath.row];
//            }
            break;
        }
            
        case ShareSectionTag:
        {
            CMShareTagCell *tagCell = (CMShareTagCell *)cell;
            tagCell.tagTxtfld.delegate = self;
            if(indexPath.row == 0) {
                tagCell.tagTxtfld.placeholder = @"#FirstTag";
                tagCell.seperatorLineView.hidden = NO;
            }
            else {
                tagCell.tagTxtfld.placeholder = @"#SecondTag";
                tagCell.seperatorLineView.hidden = YES;
            }
            
            break;
        }
            
        case ShareSectionShare:
        {
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowheight = 41.0f;
    ShareSection sectionVal = (ShareSection)indexPath.section;
    switch (sectionVal) {
        case ShareSectionLocation:
        case ShareSectionTag:
        {
            rowheight = 41.0f;
            break;
        }
        
        case ShareSectionCategory:
        {
            if(showCategoryOption) {
                rowheight = CGRectGetHeight(tableView.frame) - 100.0f;
                categoryController.categoryTableView.scrollEnabled = YES;
            }
            else {
                rowheight = 41.0f;
                categoryController.categoryTableView.scrollEnabled = NO;
            }
            break;
        }
            
        case ShareSectionComposition:
        {
            if(!showCompositionCell) {
                rowheight = 100.0f;
            }
            else {
                rowheight = 320.0f;
            }
            break;
        }
        
        case ShareSectionShare:
        {
            if([UIScreen mainScreen].bounds.size.height > 480) {
                rowheight = 238.0f;
            }
            else {
                rowheight = 182.0f;
            }
            break;
        }
            
        default:
            rowheight = 41.0f;
            break;
    }
    
    return rowheight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if(indexPath.section == ShareSectionCategory) {
        if(showCategoryOption) {
//            if(selectedCategoryIndex != indexPath.row) {
                selectedCategoryIndex = indexPath.row;
//            }
//            else {
//                selectedCategoryIndex = -1;
//            }
        }
        showCategoryOption = !showCategoryOption;

        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:showCategoryOption?UITableViewRowAnimationBottom:UITableViewRowAnimationTop];
    }*/
}

#pragma mark - UITextfield delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"%@", [[textField superview] superview]);
    NSLog(@"%@", [[[textField superview] superview] superview]);
    UITableViewCell *cell = (UITableViewCell *)[[[textField superview] superview] superview];
    NSIndexPath *txtfldIndexPath = [self.shareTableView indexPathForCell:cell];
    if (txtfldIndexPath.section == ShareSectionTag && !textField.text.length) {
        textField.text = @"#";
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITableViewCell *cell = (UITableViewCell *)[[[textField superview] superview] superview];
    NSIndexPath *txtfldIndexPath = [self.shareTableView indexPathForCell:cell];
    if (txtfldIndexPath.section == ShareSectionTag) {
        if(textField.text.length == 1 && string.length == 0) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    UITableViewCell *cell = (UITableViewCell *)[[[textField superview] superview] superview];
    NSIndexPath *txtfldIndexPath = [self.shareTableView indexPathForCell:cell];
    if (txtfldIndexPath.section == ShareSectionTag && textField.text.length == 1) {
        textField.text = @"";
    }
    
    return YES;
}

#pragma mark - SPGooglePlacesAutoCompleteViewControllerDelegate Methods

- (void)searchbarEditingWillBegin:(SPGooglePlacesAutocompleteViewController *)placeViewController
{
    CGRect rect = self.locationContainerView.frame;
    rect.size.height = CGRectGetHeight([UIScreen mainScreen].bounds);
    self.locationContainerView.frame = rect;
//    self.shareTableView.hidden = YES;
}

- (void)searchbarEditingWillEnd:(SPGooglePlacesAutocompleteViewController *)placeViewController
{
    CGRect rect = self.locationContainerView.frame;
    rect.size.height = 40;
    self.locationContainerView.frame = rect;
//    self.shareTableView.hidden = NO;
}

#pragma mark - CMCategoryVCDelegate Methods

- (void)categoryTableViewConroller:(CMCategoryVC *)viewController didSelectObjectAtIndex:(NSIndexPath *)indexpath
{
    showCategoryOption = !showCategoryOption;
    
    if(showCompositionCell) {
        showCompositionCell = NO;

        [self.shareTableView beginUpdates];
        [self.shareTableView reloadSections:[NSIndexSet indexSetWithIndex:ShareSectionComposition] withRowAnimation:UITableViewRowAnimationFade];
        [self.shareTableView reloadSections:[NSIndexSet indexSetWithIndex:ShareSectionCategory] withRowAnimation:UITableViewRowAnimationFade]; //
        [self.shareTableView endUpdates];
    }
    else {
        [self.shareTableView beginUpdates];
        [self.shareTableView reloadSections:[NSIndexSet indexSetWithIndex:ShareSectionCategory] withRowAnimation:UITableViewRowAnimationFade]; //
        [self.shareTableView endUpdates];
    }
    
}

#pragma mark - CMShareCompositionCellDelegate Methods

- (void)compositionCellIsTapped
{
    showCompositionCell = !showCompositionCell;
    
    if(showCategoryOption) {
        showCategoryOption = NO;
        categoryController.showCategoryOptions = NO;
        [categoryController.categoryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        
        [self.shareTableView beginUpdates];
        [self.shareTableView reloadSections:[NSIndexSet indexSetWithIndex:ShareSectionCategory] withRowAnimation:UITableViewRowAnimationFade]; //
        [self.shareTableView reloadSections:[NSIndexSet indexSetWithIndex:ShareSectionComposition] withRowAnimation:UITableViewRowAnimationFade];
        [self.shareTableView endUpdates];
    }
    else {
        [self.shareTableView reloadSections:[NSIndexSet indexSetWithIndex:ShareSectionComposition] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

@end
