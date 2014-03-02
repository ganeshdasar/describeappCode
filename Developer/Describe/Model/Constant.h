//
//  Constant.h
//  WebServicesTesting
//
//  Created by Pramod on 29/01/14.
//  Copyright (c) 2014 Nagaraja Velicharla. All rights reserved.
//

#ifndef WebServicesTesting_Constant_h
#define WebServicesTesting_Constant_h

#define BaseURLString @"http://mirusstudent.com/service/describe-service/"




//Will used to notify the details of the profiles...
#define kNOTIFY_PROFILE_DETAILS                 @"notify profile details"


// Composition related keys
#define COMPOSITION_TEMP_FOLDER_PATH            [NSString stringWithFormat:@"%@/Library/Caches/Composition", NSHomeDirectory()]

#define COMPOSITION_DICT                        @"composition.plist"
#define COMPOSITION_IMAGE_ARRAY_KEY             @"compositionImageArrayKey"
#define COMPOSITION_VIDEO_PATH_KEY              @"compositionVideoPathKey"

#define COMPOSITION_ARRAY_DICT_INDEXNUMBER_KEY          @"IndexNumberKey"
#define COMPOSITION_ARRAY_DICT_ORIGINAL_IMG_PATH_KEY    @"OriginalImagePathKey"
#define COMPOSITION_ARRAY_DICT_CROP_RECT_KEY            @"CropRectKey"
#define COMPOSITION_ARRAY_DICT_IS_RECORDED_KEY          @"IsRecordedKey"
#define COMPOSITION_ARRAY_DICT_START_APPEARANCE_KEY     @"StartAppearanceKey"
#define COMPOSITION_ARRAY_DICT_END_APPEARANCE_KEY       @"EndAppearanceKey"
#define COMPOSITION_ARRAY_DICT_PAUSE_KEY                @"PauseKey"
#define COMPOSITION_ARRAY_DICT_VIDEO_DURATION_KEY       @"VideoDurationKey"

#define NOTIFICATION_VIDEO_RECORDING_COMPLETED          @"VideoRecordingCompleteNotification"

#define USER_MODAL_KEY_BLOCKEDSTATUS                    @"BlockedUserStatus"
#define USER_MODAL_KEY_FOLLOWINGSTATUS                  @"FollowingStatus"
#define USER_MODAL_KEY_PROFILECANVAS                    @"ProfileCanvas"
#define USER_MODAL_KEY_BIODATA                          @"UserBiodata"
#define USER_MODAL_KEY_CITY                             @"UserCity"
#define USER_MODAL_KEY_COMMENTSCOUNT                    @"UserCommentsCount"
#define USER_MODAL_KEY_DOB                              @"UserDOB"
#define USER_MODAL_KEY_FOLLOWERCOUNT                    @"UserFollowerCount"
#define USER_MODAL_KEY_FOLLOWINGCOUNT                   @"UserFollowingCount"
#define USER_MODAL_KEY_FULLNAME                         @"UserFullName"
#define USER_MODAL_KEY_GENDER                           @"UserGender"
#define USER_MODAL_KEY_LIKESCOUNT                       @"UserLikesCount"
#define USER_MODAL_KEY_POSTCOUNT                        @"UserPostCount"
#define USER_MODAL_KEY_PROFILEPIC                       @"UserProfilePicture"
#define USER_MODAL_KEY_SNIPPETIMAGE                     @"UserSnippet"
#define USER_MODAL_KEY_SNIPPETPOSITION                  @"UserSnippetPosition"
#define USER_MODAL_KEY_STATUSMESSAGE                    @"UserStatusMsg"
#define USER_MODAL_KEY_UID                              @"UserUID"
#define USER_MODAL_KEY_USERNAME                         @"Username"

#endif
