//
//  DConversationView.m
//  Describe
//
//  Created by LaxmiGopal on 31/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import "DConversationView.h"
#import <QuartzCore/QuartzCore.h>
#import "DConversation.h"
#import "DLikesList.h"
#import "UIImageView+AFNetworking.h"


#define SUBTITLE_FONT   [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0]
#define TITLE_FONT      [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0]

@interface DConversationView ()<UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UIImageView *_icon;
    UILabel     *_titleLbl;
    UILabel     *_subTitle;
    UILabel     *_elapsedTimeLbl;
    
    UITextView  *_commentTextView;
    UIButton    *_othersLikesButton;
    UIButton    *_seeMoreButton;
    UIView      *_contentView;
    UIButton    *_moreButton;
    
    DConversation *_conversation;
    float           _commentTextHeight;
    float           _subTitleYPosition;
    float           _elapsedYPostion;
    float           _seeMoreButtonYPosition;
    NSString       *_subTitleString;
    BOOL            _isNeedToShowSeeMoreButton;
    DLikesList  *_likesListView;
    
    float       _textViewMinimumHeight;
    float       _textViewMaximumHeight;
    float       _textViewCurrentHeight;
    
    
    NSMutableString    *mentioning;
    
    UITableView *_mentioningTableView;
}
@end

@implementation DConversationView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame withConversation:(DConversation *)conversation
{
    self = [super initWithFrame:frame];
    if (self) {
       
        // Initialization code...
        _conversation = conversation;
        _commentTextHeight = 48.0;
        _subTitleYPosition = 26.0;
        
        _textViewMaximumHeight = 240;
        _textViewMinimumHeight = 30;
        _textViewCurrentHeight = _textViewMinimumHeight;
        
        self.backgroundColor = [UIColor whiteColor];
        [self createContentView];
    }
    return self;
}

- (id)initWithConversation:(DConversation *)conversation
{
    
   
    self = [super init];
    if (self) {
               // Initialization code...
        _conversation = conversation;
        _commentTextHeight = 48.0;
        _subTitleYPosition = 26.0;
        
        _textViewMaximumHeight = 240;
        _textViewMinimumHeight = 30;
        _textViewCurrentHeight = _textViewMinimumHeight;
        
        self.backgroundColor = [UIColor clearColor];
        
        [self createContentView];
    }
    return self;
}

-(void)increaseContentSize
{
    if(_contentView != nil)
    {
        [_contentView setFrame:self.bounds];
    }
    else
    {
        [self createContentView];
    }
    
    
    if (_commentTextView != nil)
    {
        CGSize size = self.bounds.size;
        [_commentTextView setFrame:CGRectMake(64, 26, 230, size.height-26)];
    }
    else
    {
        [self createCommentTextView];
    }
    
    [self performSelector:@selector(activeCommentTextViewToEdit) withObject:nil afterDelay:0.0];
}

-(void)createMoreButton
{
    CGRect moreFrame = CGRectMake(290, _elapsedYPostion-10, 19, 40);
    
    _moreButton = [[UIButton alloc] initWithFrame:moreFrame];
    [_moreButton setImage:[UIImage imageNamed:@"btn_overflow.png"] forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreButton:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_moreButton];
}

-(void)moreButton:(id)sender
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(actionOnThisConversation:)])
    {
        [self.delegate actionOnThisConversation:_conversation];
    }
}



-(void)activeCommentTextViewToEdit
{
    //[_commentTextView becomeFirstResponder];
    [_commentTextView performSelectorOnMainThread:@selector(becomeFirstResponder) withObject:nil waitUntilDone:YES];

}

-(DConversation *)conversation
{
    return _conversation;
}

-(UILabel *)createLabelOnView:(UIView *)view withText:(NSString *)text atRect:(CGRect)rect
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:text];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0]];
    [titleLabel setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    [view addSubview:titleLabel];
    
    return titleLabel;
}

-(void)createContentView
{
    self.backgroundColor = [UIColor clearColor];
    
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_contentView];
    if(_conversation.type == DConversationTypeComment)
        [self calculateGeometryCalculations];
    [self designConversationView];
}


-(void)createOthersLikeButtton:(NSString *)text
{
    CGSize size =  [_conversation.username sizeWithFont:TITLE_FONT
                                      constrainedToSize:CGSizeMake(230, 30)
                                          lineBreakMode:NSLineBreakByWordWrapping];
    
    float x = 60 + size.width;
    _othersLikesButton = [[UIButton alloc] initWithFrame:CGRectMake(x , 8, 300-x, 20)];
    [_othersLikesButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_othersLikesButton setTitle:text forState:UIControlStateNormal];
    [_othersLikesButton.titleLabel setFont:TITLE_FONT];
    [_othersLikesButton addTarget:self action:@selector(othersLikesButton:) forControlEvents:UIControlEventTouchUpInside];
    [_othersLikesButton setBackgroundColor:[UIColor clearColor]];
    [_contentView addSubview:_othersLikesButton];
}

-(void)createSeeMoreButton
{
    _seeMoreButton = [[UIButton alloc] initWithFrame:CGRectMake(70,_seeMoreButtonYPosition,60,16)];
    [_seeMoreButton setTitle:@"See More..." forState:UIControlStateNormal];
    [_seeMoreButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.0]];
    [_seeMoreButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_seeMoreButton addTarget:self action:@selector(seeMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [_seeMoreButton setBackgroundColor:[UIColor clearColor]];
    [_contentView addSubview:_seeMoreButton];
}


-(void)createTitle:(NSString *)title
{
    _titleLbl = [self createLabelOnView:_contentView withText:title atRect:CGRectMake(70,8,230,20)];
    [_titleLbl setTextColor:[UIColor colorWithRed:58.0/255.0 green:169.0/255.0 blue:155.0/255.0 alpha:1.0]];
}



-(void)createSubTitle:(NSString *)subTitle
{
    _subTitle = [self createLabelOnView:_contentView withText:subTitle atRect:CGRectMake(70,_subTitleYPosition,230,_commentTextHeight)];
    [_subTitle setNumberOfLines:0];
    [_subTitle setBackgroundColor:[UIColor clearColor]];
    [_subTitle setTextColor:[UIColor lightGrayColor]];
    [_subTitle setFont:SUBTITLE_FONT];
    //[_subTitle sizeToFit];
}

-(void)createIcon
{
    _icon = [[UIImageView alloc] initWithFrame:CGRectMake(20,12,40,40)];
    [_icon setBackgroundColor:[UIColor clearColor]];
    //[_icon setImage:[UIImage imageNamed:_conversation.profilePic]];
    [_icon setImageWithURL:[NSURL URLWithString:_conversation.profilePic]];
    [_contentView addSubview:_icon];
    [_icon.layer setCornerRadius:20];
    [_icon.layer setMasksToBounds:YES];
}
-(void)downloadUserImageview:(NSString*)inUrlString{
    dispatch_queue_t backgroundQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
        NSData *avatarData = nil;
        NSString *imageURLString = inUrlString;
        if (imageURLString) {
            NSURL *imageURL = [NSURL URLWithString:imageURLString];
            avatarData = [NSData dataWithContentsOfURL:imageURL];
        }
        if (avatarData) {
            // Update UI from the main thread when available
            dispatch_async(dispatch_get_main_queue(), ^{
               _icon.image = [UIImage imageWithData:avatarData];
                
            });
        }
    });
}

-(void)createElapsedTime:(NSString *)elapsedTime
{
    _elapsedTimeLbl = [self createLabelOnView:_contentView withText:elapsedTime atRect:CGRectMake(70,_elapsedYPostion,200,16)];
    [_elapsedTimeLbl setTextColor:[UIColor lightGrayColor]];
    [_elapsedTimeLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.0]];
    [_elapsedTimeLbl setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.2]];
    
//    NSDate * originalDate = [NSDate date];
//    NSTimeInterval interval = [elapsedTime doubleValue];
//    NSDate * futureDate = [originalDate dateByAddingTimeInterval:interval];
    
}

-(void)createCommentTextView
{
    _commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(70, 26, 220, 30)];
    [_commentTextView setBackgroundColor:[UIColor clearColor]];
    [_commentTextView setFont:SUBTITLE_FONT];
    [_commentTextView setTextColor:[UIColor grayColor]];
    [_commentTextView setDelegate:self];
    [_commentTextView setText:@"Add your comment here."];
    [_contentView addSubview:_commentTextView];
    [_commentTextView setDelegate:self];
    [_commentTextView setReturnKeyType:UIReturnKeyDone];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangedText:) name:UITextViewTextDidChangeNotification object:nil];
}

-(void)designConversationView
{
    [self createIcon];
    [self createTitle:_conversation.username];
    
    switch (_conversation.type)
    {
        case DConversationTypeNone:
            break;
        case DConversationTypeLike:
            _commentTextHeight = 16;
            _subTitleYPosition = 26;
            _elapsedYPostion = 36;
            [self createSubTitle:@"likes this post."];
            if(_conversation.showAllLikes)
            {
                CGRect rect = _contentView.bounds;
                rect.origin.y = 62;
                rect.size.height = rect.size.height - 62;
                
                NSMutableArray *array = [[NSMutableArray alloc] init];
                
                for (int i=0; i<_conversation.numberOfLikes; i++)
                {
                    {
                        DConversation *conversation = [[DConversation alloc] init];
                        [conversation setUsername:@"Tamanna"];
                        [conversation setElapsedTime:@"14 m"];
                        [conversation setType:DConversationTypeLike];
                        [conversation setProfilePic:@"user3.png"];
                        [array addObject:conversation];
                    } 
                }
                                
                _likesListView = [[DLikesList alloc] initWithFrame:rect andWithLikes:array];
                
                [_contentView addSubview:_likesListView];
            }
            else
                if(_conversation.numberOfLikes)
                    [self createOthersLikeButtton:[NSString stringWithFormat:@"and %d others",_conversation.numberOfLikes]];
            
            break;
        case DConversationTypeComment:
            [self createSubTitle:_conversation.comment];
            if(_isNeedToShowSeeMoreButton)
            {
                [self createSeeMoreButton];
            }
            [self createMoreButton];

            break;
        case DConversationTypeCurrentUser:
            [self createCommentTextView];
            return;
            break;
        default:
            break;
    }
    [self createElapsedTime:_conversation.elapsedTime];
}


#pragma mark Event Actions -

-(void)othersLikesButton:(id)sender
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(conversationView:expandOthersLikeView:)])
    {
        //send neccessary event...
        _conversation.showAllLikes = YES;
        [(UIButton *)sender setHidden:YES];
        self.backgroundColor = [UIColor clearColor];
        [self.delegate performSelector:@selector(conversationView:expandOthersLikeView:) withObject:self withObject:[NSNumber numberWithBool:YES]];
    }
}

-(void)seeMoreButton:(id)sender
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(conversationView:needToExpand:)])
    {
        //See more button...
        _conversation.showFullConversation = YES;
        [(UIButton *)sender setHidden:YES];
        self.backgroundColor = [UIColor clearColor];
        [self.delegate performSelector:@selector(conversationView:needToExpand:)    withObject:self withObject:[NSNumber numberWithBool:YES]];
    }
}

#pragma mark Animations -

-(void)expandComment
{
//    [self calculateGeometryCalculations];
}

#pragma mark Algebra Caliculations -


-(void)calculateGeometryCalculations
{
    UIFont *font = SUBTITLE_FONT;
    CGRect rect = [_conversation.comment boundingRectWithSize:CGSizeMake(224, 60) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    CGSize commentSize = rect.size;
    if(!_conversation.showFullConversation)
    {
        if(commentSize.height > _commentTextHeight)
        {
            _isNeedToShowSeeMoreButton = YES;
        }
        else
        {
            _commentTextHeight = commentSize.height;
        }
    }
    else
        _commentTextHeight = commentSize.height;
    
    
    _elapsedYPostion = _commentTextHeight + _subTitleYPosition+6;

    if(_isNeedToShowSeeMoreButton)
    {
        _seeMoreButtonYPosition = _elapsedYPostion;
        _elapsedYPostion = _elapsedYPostion  + 26;
    }
}

-(float)heightOfContentView
{
    float height = 90;
    
    switch (_conversation.type)
    {
        case DConversationTypeCurrentUser:
            height = 60;
            break;
        case DConversationTypeLike:
            height = 62;
            break;
        case DConversationTypeComment:
        {
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0];
            
            CGRect rect = [_conversation.comment boundingRectWithSize:CGSizeMake(224, 60) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
            CGSize commentSize = rect.size;
            
            if(_conversation.showFullConversation)
            {
                //Caliculate the full conversation length...
                height = commentSize.height + 20;
            }
            else
            {
                if(commentSize.height > 45)
                {
                    height = height + 20 ;
                }
            }
            
        }
            break;
        default:
            break;
    }
    return height;
    
}


#pragma mark UITextViewDelegate Methods -

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"Add your comment here."])
        textView.text = @"";
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    NSString *text = textView.text;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(text.length)
        [self postComment:textView.text forConversation:_conversation];
    
    textView.text = @"Add your comment here.";
}

-(void)resignKeyboard
{
    [_commentTextView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        [self removeMentioningTableView];
        return NO;
    }
    
    return YES;
    
    //Will finish this mentioning feature in the comming versions...
    
    
    if ([text isEqualToString:@"@"] && (mentioning == nil || mentioning.length == 0) )
    {
        //Start Mentioning from here...
        //Display drop down box for related tagging users details...
        if(mentioning == nil)
            mentioning = [[NSMutableString alloc] init];
        [mentioning appendString:text];
        
        //Display mentioning list view...
        
    }
    else if(mentioning != nil && mentioning.length)
    {
        //Mentioning the person...
        if(text.length && ![text isEqualToString:@"\n"])
        {
            [mentioning appendString:text];
        }
        else if(![text isEqualToString:@"\n"])
        {
            [mentioning deleteCharactersInRange:NSMakeRange(mentioning.length-1, 1)];
        }
        
        if([text isEqualToString:@"\n"])
        {
            NSLog(@"Picked ---%@--- as Mentioning",mentioning);
            
            [mentioning deleteCharactersInRange:NSMakeRange(0, mentioning.length)];
            textView.text = [textView.text stringByAppendingString:@" "];
            
            
            [self hideMentioningListview];
            return NO;
        }
        
        
        //NSLog(@"%@",mentioning);
    }
    
    
     if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        [self removeMentioningTableView];
        return NO;
    }
    
    
    return YES;
}

-(void)textViewDidChangedText:(NSNotification *)notification
{
    UITextView *textView = (UITextView *)[notification object];
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0];
    CGRect rect = [textView.text boundingRectWithSize:CGSizeMake(224, 60) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    
    CGSize commentSize = rect.size;
    float height = 0;
    if(commentSize.height > _textViewMinimumHeight)
    {
        if(commentSize.height < _textViewMaximumHeight)
            height = commentSize.height;
        else
            height = _textViewMaximumHeight;
    }
    else
        height = _textViewMinimumHeight;
    
    
    if(_textViewCurrentHeight != height)
    {
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(conversationView:expandCommentView:)])
        {
            self.conversation.elapsedTime = @"0 m";
            self.conversation.comment = textView.text;
            [self.delegate performSelector:@selector(conversationView:expandCommentView:) withObject:self withObject:[NSNumber numberWithFloat:height+10]];
        }
    }
    
    _textViewCurrentHeight = height;
}


-(void)startMentioning
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(conversationViewDidStartMentioning:)])
    {
        [self.delegate conversationViewDidStartMentioning:self];
    }
}

-(void)mentioningText:(NSString *)mentioingText
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(conversationView:mentioningText:)])
    {
        [self.delegate conversationView:self mentioningText:mentioingText];
    }
}

-(void)personPicked:(NSString *)mentionedPerson
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(conversationView:didFinishedMentioningPerson:)])
    {
        [self.delegate conversationView:self mentioningText:mentionedPerson];
    }
}

-(void)endMentioning
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(conversationViewDidEndMentioning:)])
    {
        [self.delegate conversationViewDidEndMentioning:self];
    }
}



-(void)showMentioningListView
{
    if(_mentioningTableView == nil)
    {
        _mentioningTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, 260, 100) style:UITableViewStyleGrouped];
        [_mentioningTableView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.15]];
        [_mentioningTableView setDelegate:self];
        [_mentioningTableView setDataSource:self];
        [self addSubview:_mentioningTableView];
    }
    
    _mentioningTableView.hidden = NO;
}

-(void)hideMentioningListview
{
    _mentioningTableView.hidden = YES;
}

-(void)removeMentioningTableView
{
    _mentioningTableView.delegate = nil;
    _mentioningTableView.dataSource = nil;
    [_mentioningTableView removeFromSuperview];
    _mentioningTableView = nil;
}



-(void)postComment:(NSString *)comment forConversation:(DConversation *)conversation
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(postComment:forConversation:)])
    {
        [self.delegate performSelector:@selector(postComment:forConversation:) withObject:comment withObject:conversation];
    }
}



-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 26.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"indexPath_%d_%d",indexPath.section, indexPath.row];
    
    UITableViewCell *cell =  (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return cell;
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
