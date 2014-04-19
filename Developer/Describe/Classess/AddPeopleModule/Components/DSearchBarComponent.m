//
//  DSearchBarComponent.m
//  Describe
//
//  Created by NuncSys on 26/01/14.
//  Copyright (c) 2014 App. All rights reserved.
//

#import "DSearchBarComponent.h"
#import "UIColor+DesColors.h"
@interface DSearchBarComponent ()<UITextFieldDelegate>
{
    UIImageView * searchImgView;
    UIButton * cancelBtnImage;
}

@end
@implementation DSearchBarComponent
@synthesize searchDelegate;
@synthesize searchTxt;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self designSerachBar];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
-(void)designSerachBar{
    
    self.backgroundColor = [UIColor clearColor];
    self.searchTxt= [[UITextField alloc]initWithFrame:CGRectMake(30, 0, 280, 41)];
    self.searchTxt.returnKeyType = UIReturnKeySearch;
    self.searchTxt.delegate =self;
    self.searchTxt.font =[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f];
    self.searchTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"search by name or username" attributes:@{NSForegroundColorAttributeName: [UIColor textPlaceholderColor]}];
    [self.searchTxt setTextColor:[UIColor textFieldTextColor]];

    [self.searchTxt addTarget:self action:@selector(searchTextFieldClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.searchTxt];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:self.searchTxt];
    
    searchImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 10, 14)];
    searchImgView.image =[UIImage imageNamed:@"icon_search.png"];
    [self addSubview:searchImgView];
    
//search by name or username ,13px ,14Px,helvictic neue thin ,20Px, 200,200,200.(pls), same font (150,150,150);
    
    cancelBtnImage    = [[UIButton alloc]init];
    cancelBtnImage.frame = CGRectMake(295, 13, 15, 15);
    [cancelBtnImage setImage:[UIImage imageNamed:@"btn_cancel.png"] forState:UIControlStateNormal];
    cancelBtnImage.hidden = YES;
    [cancelBtnImage addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtnImage];
    
   
    
}
/*// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)cancelButtonClicked:(id)inSender{
    
    //NSLog(@"search bar button clicked");
    self.searchTxt.text = @"";
    cancelBtnImage.hidden = YES;
    [self.searchTxt resignFirstResponder];
   

}
-(void)searchTextFieldClicked:(id)insender{
   // NSLog(@"search bar button clicked");
}
#pragma mark seachTextfield Delegate mathod
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if([self.searchDelegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]){
        [self.searchDelegate searchBarSearchButtonClicked:self];
    }
  
    return YES;
}
-(BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
    
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    searchImgView.hidden = NO;
    if([self.searchDelegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]){
        [self.searchDelegate searchBarSearchButtonClicked:self];
    }

    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([string isEqualToString:@"\n"]) {
		[textField resignFirstResponder];
		return FALSE;
	}
    else{
        if([textField.text length] >=2 || [string length]){
          //  searchImgView.hidden = YES;
            cancelBtnImage.hidden = NO;
        }
        else{
            cancelBtnImage.hidden = YES;
           // searchImgView.hidden = NO;

        }
    }
	return YES;
}

- (void)textFieldTextDidChangeNotification:(NSNotification *)inNotification{
    
    
}
@end
