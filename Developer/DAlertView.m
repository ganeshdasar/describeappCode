//
//  DAlertView.m
//  Describe
//
//  Created by Aashish Raj on 3/30/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DAlertView.h"



@interface DAlertView ()<UIAlertViewDelegate>
{
    DAlertViewResponse alertViewResponse;
}
@end

@implementation DAlertView


- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles,nil];
    if(self!= nil)
    {
        //Customize the code....
       // alertViewResponse = response;
            [self show];
    }

    return self;
}

//-(void)setResponse:(DAlertViewResponse)response
//{
//    self.response = response;
//}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(self.response)
    {
        self.response(buttonIndex);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
