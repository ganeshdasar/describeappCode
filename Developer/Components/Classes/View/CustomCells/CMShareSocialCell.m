//
//  CMShareSocialCell.m
//  Composition
//
//  Created by Describe Administrator on 29/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "CMShareSocialCell.h"
#import "DESocialConnectios.h"

@implementation CMShareSocialCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    if([[DESocialConnectios sharedInstance] isFacebookLoggedIn]) {
        [self.fbButton setImage:[UIImage imageNamed:@"btn_shareScreen_fb_off.png"] forState:UIControlStateNormal];
    }
    
    if([[DESocialConnectios sharedInstance] isGooglePlusLoggeIn]) {
        [self.gpButton setImage:[UIImage imageNamed:@"btn_shareScreen_goog_off.png"] forState:UIControlStateNormal];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
