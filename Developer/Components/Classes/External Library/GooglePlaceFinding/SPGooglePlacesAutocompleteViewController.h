//
//  SPGooglePlacesAutocompleteViewController.h
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

@class SPGooglePlacesAutocompleteQuery;
@class SPGooglePlacesAutocompleteViewController;

@protocol SPGooglePlacesAutocompleteViewControllerDelegate <NSObject>

@optional
- (void)searchbarEditingWillBegin:(SPGooglePlacesAutocompleteViewController *)placeViewController;
- (void)searchbarEditingWillEnd:(SPGooglePlacesAutocompleteViewController *)placeViewController;

@end

@interface SPGooglePlacesAutocompleteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
    NSArray *searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    
    BOOL shouldBeginEditing;
}

@property (nonatomic, assign) id <SPGooglePlacesAutocompleteViewControllerDelegate> delegate;

@end


