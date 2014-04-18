//
//  DPostsViewController.h
//  Describe
//
//  Created by Aashish Raj on 11/01/14.
//  Copyright (c) 2014 Billion Micros. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPost;
@interface DPostsViewController : UIViewController <UIAlertViewDelegate>


+(id)sharedFeedController;

-(void)loadFeedDetails;
-(void)showPostDetails:(NSArray *)posts;



@end

/*
{
    SearchResultData =             {
        AuthUserUID = 45;
        ElapsedTime = "";
        FollowingStatus = 0;
        Image1 = "1397661740_45_postpic1.png";
        Image10 = "1397661740_45_postpic10.png";
        Image2 = "1397661740_45_postpic2.png";
        Image3 = "1397661740_45_postpic3.png";
        Image4 = "1397661740_45_postpic4.png";
        Image5 = "1397661740_45_postpic5.png";
        Image6 = "1397661740_45_postpic6.png";
        Image7 = "1397661740_45_postpic7.png";
        Image8 = "1397661740_45_postpic8.png";
        Image9 = "1397661740_45_postpic9.png";
        ImagesDuration = "7.70,9.30,8.30,9.30,9.20,8.10,8.70,9.60,8.70,0.00";
        PostCategory = "No Category";
        PostCommentCount = 22;
        PostImageCount = 10;
        PostLatLong = "17.393714, 78.483212";
        PostLikeCount = 9;
        PostLocation = "";
        PostRating = 3;
        PostUID = 54;
        PostViewCount = 0;
        PostedTime = "2014-04-17 17:09:14";
        PriorityCount = "";
        ServerTime = "2014-04-18 13:30:04";
        Tag1 = "";
        Tag2 = "";
        UserCanvasImage = "1394281755_45_1376709135604.jpg";
        UserCanvasSnippet = "1394281755_45_snippetttt.png";
        UserProfilePicture = "1397821647_45_profilepic.png";
        UserSnippetPosition = "";
        Username = gopalgundaram;
        VideoFile = "1397661740_45_postvideo.mp4";
    };
},

PostData =             {
    AuthUserDetails =                 {
        AuthUserUID = 110;
        FollowingStatus = 1;
        UserCanvasImage = "Canvas30.jpeg";
        UserCanvasSnippet = "";
        UserProfilePicture = "1397810405_110_profilepic.png";
        UserSnippetPosition = "";
        Username = ganesh;
    };
    BigImagePath = "http://mirusstudent.com/service/postimages/";
    PostDetails =                 {
        ElapsedTime = "17 m";
        Image1 = "1397826864_110_postpic1.png";
        Image10 = "";
        Image2 = "";
        Image3 = "";
        Image4 = "";
        Image5 = "";
        Image6 = "";
        Image7 = "";
        Image8 = "";
        Image9 = "";
        ImagesDuration = "4.40";
        PostCategory = "Architecture & Spaces";
        PostCommentCount = 0;
        PostImageCount = 10;
        PostLatLong = "";
        PostLikeCount = 0;
        PostLocation = "Hyderabad, Andhra Pradesh, India";
        PostRating = 0;
        PostUID = 73;
        PostViewCount = 0;
        Tag1 = "#tag";
        Tag2 = "#tagggg";
        VideoFile = "1397826864_110_postvideo.mp4";
    };
    PostType = 0;
    PriorityCount = "";
    ThumbImagePath = "http://mirusstudent.com/service/postimagessmall/";
};
},
*/
