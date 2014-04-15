//
//  DesSearchPeopleViewContrlooerViewController.h
//  Describe
//
//  Created by NuncSys on 08/02/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPeopleListComponent.h"

@interface DesSearchPeopleViewContrlooerViewController : UIViewController
{
    
}
@property (nonatomic,strong)  IBOutlet DPeopleListComponent *_peoplelistView;
@property (nonatomic,strong) NSMutableArray * searchListArray;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImg;

@end
