//
//  DESAboutTextView.m
//  Describe
//
//  Created by Describe Administrator on 19/04/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DESAboutTextView.h"

@implementation DESAboutTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    CGRect originalRect = [super caretRectForPosition:position];
    originalRect.size.height = 22.0f;
    return originalRect;
}

@end
