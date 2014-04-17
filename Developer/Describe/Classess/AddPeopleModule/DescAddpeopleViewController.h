//
//  DescAddpeopleViewController.h
//  Describe
//
//  Created by NuncSys on 07/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DUserData.h"
@interface DescAddpeopleViewController : UIViewController{
    BOOL isSearching;
}

@property (nonatomic, assign)BOOL isCommmingFromFeed;
@property (weak, nonatomic) IBOutlet UITableView *addPeopleTableview;
@property (nonatomic, retain) UIButton *selectedType;
@property (nonatomic,strong) NSMutableArray * peopleListArray;
@property (nonatomic,strong) NSMutableArray * searchListArray;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImg;


- (IBAction)followAndInviteActions:(id)sender;

@end
