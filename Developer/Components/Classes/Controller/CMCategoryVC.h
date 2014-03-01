//
//  CMCategoryVC.h
//  Composition
//
//  Created by Describe Administrator on 05/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMCategoryVC;

@protocol CMCategoryVCDelegate <NSObject>

@optional
- (void)categoryTableViewConroller:(CMCategoryVC *)viewController didSelectObjectAtIndex:(NSIndexPath *)indexpath;

@end

@interface CMCategoryVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
@property (nonatomic, weak) id <CMCategoryVCDelegate> delegate;
@property (assign)     BOOL showCategoryOptions;

@end
