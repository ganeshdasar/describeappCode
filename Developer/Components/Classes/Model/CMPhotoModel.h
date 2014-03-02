//
//  CMPhotoModel.h
//  Composition
//
//  Created by Describe Administrator on 18/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMPhotoModel : NSObject

@property (nonatomic, assign) NSUInteger indexNumber;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, readonly) CGRect cropRect;
@property (nonatomic, strong) UIImage *editedImage;
@property (nonatomic, assign) BOOL isRecorded;
@property (nonatomic, assign) CGFloat startAppearanceTime;
@property (nonatomic, assign) CGFloat endAppearanceTime;
@property (nonatomic, assign) CGFloat pauseTime;
@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, strong) NSString *originalImagePath;

- (id)initWithDictionary:(NSDictionary *)photoDict;
- (void)setCropRect:(CGRect)rect;
- (void)resetRecordingValues;

@end
