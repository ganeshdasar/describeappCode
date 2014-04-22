//
//  DSearchBarComponent.h
//  Describe
//
//  Created by NuncSys on 26/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DSearchBarComponent;
@protocol DSearchBarComponentDelegate <NSObject>
@optional
- (void)searchBarSearchButtonClicked:(DSearchBarComponent *)searchBar;
- (void)searchBarClicked:(BOOL)inClicked;
// called when keyboard search
//- (void)searchBarCancelButtonClicked:(CRSearchView *) searchBar;                    // called when cancel or Close button
@end
@interface DSearchBarComponent : UIView{
    
}
-(void)designSerachBar;
@property (nonatomic,strong)     UITextField *searchTxt;

@property (nonatomic,assign) id <DSearchBarComponentDelegate> searchDelegate;
@end
