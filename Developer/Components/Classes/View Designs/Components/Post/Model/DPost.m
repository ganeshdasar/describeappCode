//
//  DPost.m
//  Describe
//
//  Created by LaxmiGopal on 13/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DPost.h"

@implementation DPost

@synthesize type;
@synthesize postId;
@synthesize user;
@synthesize imagePost;
@synthesize attachements;
@end




@implementation DPostImage

@synthesize postId;
@synthesize userId;
@synthesize durationList;
@synthesize numberOfImages;
@synthesize images;
@synthesize video;

@end



@implementation DPostVideo

@synthesize postId;
@synthesize userId;
@synthesize url;
@synthesize duration;

@end



@implementation DPostAttachments

@synthesize postId = _postId;
@synthesize tagsList = _tagsList;
@synthesize likeRating;
@synthesize numberOfLikes;
@synthesize numberOfComments;

-(id)init
{
    self = [super init];
    if(self != nil)
    {
        _postId = @"111";
        //_tagsList = [[NSMutableArray alloc] init];
    }
    return self;
}

@end



@implementation DPostTag

@synthesize tagId;
@synthesize tagName;
@synthesize postedByUserId;

@end


@implementation DPrompterProfile

@synthesize profilePromterImageName;

@end
