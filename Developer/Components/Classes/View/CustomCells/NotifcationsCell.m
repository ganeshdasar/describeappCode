//
//  NotifcationsCell.m
//  Composition
//
//  Created by Describe Administrator on 17/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "NotifcationsCell.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface NotifcationsCell ()

@property (nonatomic, strong) NotificationModel *notificationModel;

@end

@implementation NotifcationsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)notificationImageTapped:(id)sender
{
//    NSLog(@"%s", __func__);
    if(_delegate != nil && [_delegate respondsToSelector:@selector(notificationImageSelectedAtIndexpath:)]) {
        NSIndexPath *indexpath = [NotifcationsCell getIndexPathFromCell:self];
        [_delegate notificationImageSelectedAtIndexpath:indexpath];
    }
}

- (IBAction)notificationTitleLabelTapped:(id)sender
{
//    NSLog(@"%s", __func__);
    if(_delegate != nil && [_delegate respondsToSelector:@selector(notificationTitleSelectedAtIndexpath:)]) {
        NSIndexPath *indexpath = [NotifcationsCell getIndexPathFromCell:self];
        [_delegate notificationTitleSelectedAtIndexpath:indexpath];
    }
}

- (IBAction)friendsLabelTapped:(id)sender
{
//    NSLog(@"%s", __func__);
    if(_delegate != nil && [_delegate respondsToSelector:@selector(notificationFriendsJoinedSelectedAtIndexpath:)]) {
        NSIndexPath *indexpath = [NotifcationsCell getIndexPathFromCell:self];
        [_delegate notificationFriendsJoinedSelectedAtIndexpath:indexpath];
    }
}

#pragma mark - set Data on cell

- (void)setData:(NotificationModel *)dataModel
{
    _notificationModel = dataModel;
    
    if(_notificationModel.notificationType == kNotificationTypeFollowing || _notificationModel.notificationType == kNotificationTypeFriendJoined) {
        // the imageView should be circle
        self.imageView.layer.cornerRadius = CGRectGetHeight(self.imageView.frame)/2.0f;
    }
    else {
        self.imageView.layer.cornerRadius = 0.0f;
    }
    
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.borderColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0].CGColor;
    self.imageView.layer.borderWidth = 0.5f;
    
    [self.imageView setImageWithURL:[NSURL URLWithString:_notificationModel.imageUrlString]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              self.imageView.image = image;
                          }
        usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
//    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_notificationModel.imageUrlString]]];
//    [self setThumbnailUrlString:_notificationModel.imageUrlString];
    
    [self setTitleFromDataModel];
    [self setSubTitlefromDataModel];
    
    _timeLabel.text = [_notificationModel.timeStamp stringValue];
}

- (void)setTitleFromDataModel
{
    // check the type of notification and form the string and place it on titleLabel
    if(_notificationModel.notificationType == kNotificationTypeFriendJoined) {
        _titleLabel.hidden = YES;
        _titleLabel.text = @"";
        return;
    }
    
    _titleLabel.hidden = NO;
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] init];
    NSAttributedString *nameString = [[NSAttributedString alloc] initWithString:_notificationModel.fromUserName
                                                                         attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:53.0/255.0f green:168.0f/255.0f blue:157.0f/255.0f alpha:1.0f]}];
    [titleString appendAttributedString:nameString];
    
    switch (_notificationModel.notificationType) {
        case kNotificationTypeLike:
        case kNotificationTypeComment:
        case kNotificationTypeMentionedInCommment:
        {
            if(_notificationModel.similarCount && [_notificationModel.similarCount integerValue] > 1) {
                NSInteger value = [_notificationModel.similarCount integerValue] - 1;
                NSAttributedString *moreString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %ld %@", (long)value,
                                                                                             value > 1 ? NSLocalizedString(@"others", nil):NSLocalizedString(@"other", nil)]
                                                                                 attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f]}];
                [titleString appendAttributedString:moreString];
            }
            
            break;
        }
            
        case kNotificationTypeFollowing:
        {
            break;
        }
            
        default:
            break;
    }
    
    if(_notificationModel.notificationType != kNotificationTypeFriendJoined) {
        _titleLabel.attributedText = titleString;
    }
}

- (void)setSubTitlefromDataModel
{
    // check the type of notification and form the string and place it on subTitleLabel
    _subTitleLable.hidden = NO;
    _friendsTypeLabel.text = @"";
    _friendsTypeLabel.hidden = YES;
    
    NSMutableAttributedString *subTitleString = [[NSMutableAttributedString alloc] init];
    NSString *string = @"";
    NSString *fromUserName = nil;
    
    switch (_notificationModel.notificationType) {
        case kNotificationTypeLike:
        {
            NSInteger value = [_notificationModel.similarCount integerValue];
            
            string = [NSString stringWithFormat:@"%@ your post.", value > 1 ? NSLocalizedString(@"like", @""):NSLocalizedString(@"likes", @"")];
            break;
        }
            
        case kNotificationTypeComment:
        {
            string = @"commented on your post.";
            break;
        }
            
        case kNotificationTypeMentionedInCommment:
        {
            string = @"mentioned you in a comment";
            break;
        }
            
        case kNotificationTypeFollowing:
        {
            string = @"is following you.";
            break;
        }
            
        case kNotificationTypeFriendJoined:
        {
            _subTitleLable.hidden = YES;
            _subTitleLable.text = @"";
            
            string = [NSString stringWithFormat:@"%@ from %@ has joined Describe as ", _notificationModel.frndSocialName, _notificationModel.socialName];
            fromUserName = [NSString stringWithFormat:@"%@", _notificationModel.fromUserName];
            break;
        }
            
        default:
            break;
    }
    
    NSAttributedString *startString = [[NSAttributedString alloc] initWithString:string
                                                                      attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f], NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.0f]}];
    [subTitleString appendAttributedString:startString];
    
    if(fromUserName) {
        NSAttributedString *fromUser = [[NSAttributedString alloc] initWithString:fromUserName
                                                                       attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:53.0/255.0f green:168.0f/255.0f blue:157.0f/255.0f alpha:1.0f], NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]}];
        [subTitleString appendAttributedString:fromUser];
    }
    
    if(_notificationModel.notificationType == kNotificationTypeFriendJoined) {
        _friendsTypeLabel.hidden = NO;
        _friendsTypeLabel.attributedText = subTitleString;
    }
    else {
        _subTitleLable.attributedText = subTitleString;
    }
}

+ (NSIndexPath*) getIndexPathFromCell:(UITableViewCell*)tableCell
{
    NSIndexPath *cellIndexpath;
    if([[tableCell superview] isKindOfClass:[UITableView class]]){ // Condition to get UItableView Refernce in ios below 7.0
        
        cellIndexpath  = [(UITableView *)[tableCell superview] indexPathForCell:tableCell];
    }
    else{
        cellIndexpath = [(UITableView *)[[tableCell superview] superview] indexPathForCell:tableCell];
    }
    
    return cellIndexpath;
}

@end
