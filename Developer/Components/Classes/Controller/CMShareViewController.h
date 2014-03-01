//
//  CMShareViewController.h
//  Composition
//
//  Created by Describe Administrator on 26/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPGooglePlacesAutocompleteViewController.h"
#import "CMCategoryVC.h"
#import "CMShareCompositionCell.h"

@interface CMShareViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SPGooglePlacesAutocompleteViewControllerDelegate, CMCategoryVCDelegate, CMShareCompositionCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *shareTableView;
@property (weak, nonatomic) IBOutlet UIView *locationContainerView;

@property (nonatomic, strong) NSMutableArray *capturedPhotoList;

- (IBAction)listOptionClicked:(id)sender;
- (IBAction)dismissOptionCLicked:(id)sender;
- (IBAction)prevOptionClicked:(id)sender;
- (IBAction)socailButtonClicked:(id)sender;
- (IBAction)shareButtonClicked:(id)sender;

@end
