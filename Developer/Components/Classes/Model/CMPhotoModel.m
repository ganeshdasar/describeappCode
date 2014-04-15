//
//  CMPhotoModel.m
//  Composition
//
//  Created by Describe Administrator on 18/01/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "CMPhotoModel.h"

#define COMPOSITION_TEMP_FOLDER_PATH            [NSString stringWithFormat:@"%@/Library/Caches/Composition", NSHomeDirectory()]

@implementation CMPhotoModel

@synthesize imageUrl = _imageUrl;

- (id)initWithDictionary:(NSDictionary *)photoDict
{
    self = [super init];
    if(self) {
        
        if(photoDict != nil && photoDict[COMPOSITION_ARRAY_DICT_CROP_RECT_KEY]) {
            _cropRect = [photoDict[COMPOSITION_ARRAY_DICT_CROP_RECT_KEY] CGRectValue];
        }
        
        if(photoDict != nil && photoDict[COMPOSITION_ARRAY_DICT_ORIGINAL_IMG_PATH_KEY]) {
            _originalImagePath = photoDict[COMPOSITION_ARRAY_DICT_ORIGINAL_IMG_PATH_KEY];
            NSData *imgData = [NSData dataWithContentsOfFile:_originalImagePath];
            if(imgData) {
                _originalImage = [UIImage imageWithData:imgData];
                
                CGImageRef imgRef = CGImageCreateWithImageInRect(_originalImage.CGImage, _cropRect);
                UIImage *image = [UIImage imageWithCGImage:imgRef];
                _editedImage = image;
            }
        }
        
        if(photoDict != nil && photoDict[COMPOSITION_ARRAY_DICT_INDEXNUMBER_KEY]) {
            _indexNumber = [photoDict[COMPOSITION_ARRAY_DICT_INDEXNUMBER_KEY] integerValue];
        }
        
        if(photoDict != nil && photoDict[COMPOSITION_ARRAY_DICT_IS_RECORDED_KEY]) {
            _isRecorded = [photoDict[COMPOSITION_ARRAY_DICT_IS_RECORDED_KEY] boolValue];
        }
        
        if(photoDict != nil && photoDict[COMPOSITION_ARRAY_DICT_START_APPEARANCE_KEY]) {
            _startAppearanceTime = [photoDict[COMPOSITION_ARRAY_DICT_START_APPEARANCE_KEY] floatValue];
        }
        
        if(photoDict != nil && photoDict[COMPOSITION_ARRAY_DICT_END_APPEARANCE_KEY]) {
            _endAppearanceTime = [photoDict[COMPOSITION_ARRAY_DICT_END_APPEARANCE_KEY] floatValue];
        }
        
        if(photoDict != nil && photoDict[COMPOSITION_ARRAY_DICT_PAUSE_KEY]) {
            _pauseTime = [photoDict[COMPOSITION_ARRAY_DICT_PAUSE_KEY] floatValue];
        }
        
        if(photoDict != nil && photoDict[COMPOSITION_ARRAY_DICT_VIDEO_DURATION_KEY]) {
            _duration = [photoDict[COMPOSITION_ARRAY_DICT_VIDEO_DURATION_KEY] floatValue];
        }
    }
    
    return self;
}

- (void)setCropRect:(CGRect)rect
{
    _cropRect = rect;
    
    if(_originalImage) {
        CGImageRef imgRef = CGImageCreateWithImageInRect(_originalImage.CGImage, _cropRect);
        UIImage *image = [UIImage imageWithCGImage:imgRef];
        _editedImage = image;
        
        [self saveModelToCompositionArray];
    }
}

- (void)setOriginalImage:(UIImage *)originalImage
{
    _originalImage = originalImage;
    
    // save the image into composition folder of library for autosave purpose
    if(_originalImagePath) {
        BOOL deleteSuccess = [[NSFileManager defaultManager] removeItemAtPath:_originalImagePath error:nil];
        if(deleteSuccess == NO) {
//            NSLog(@"deleteSuccess = %d", deleteSuccess);
        }
        _originalImagePath = nil;
    }
    
    if(!originalImage) {
        [self removeModelFromCompositionArray];
        return;
    }
    
    BOOL isDir;
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:COMPOSITION_TEMP_FOLDER_PATH isDirectory:&isDir]) {
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:COMPOSITION_TEMP_FOLDER_PATH withIntermediateDirectories:NO attributes:nil error:&error];
        if(!success || error) {
            NSLog(@"Folder creation error = %@", [error localizedDescription]);
            return;
        }
//        NSLog(@"success = %d", success);
    }
    
    _originalImagePath = [[NSString alloc] initWithFormat:@"%@/%@.png", COMPOSITION_TEMP_FOLDER_PATH, [self generateUniqueFilename]];
    BOOL imageSuccess = [UIImagePNGRepresentation(_originalImage) writeToFile:_originalImagePath options:NSAtomicWrite error:nil];
    if(!imageSuccess) {
//        NSLog(@"imageSuccess = %d", imageSuccess);
    }
    
}

- (void)setIsRecorded:(BOOL)isRecorded
{
    _isRecorded = isRecorded;
    [self saveModelToCompositionArray];
}

- (void)setStartAppearanceTime:(CGFloat)startAppearanceTime
{
    _startAppearanceTime = startAppearanceTime;
    [self saveModelToCompositionArray];
}

- (void)setEndAppearanceTime:(CGFloat)endAppearanceTime
{
    _endAppearanceTime = endAppearanceTime;
    [self saveModelToCompositionArray];
}

- (void)setPauseTime:(CGFloat)pauseTime
{
    _pauseTime = pauseTime;
    [self saveModelToCompositionArray];
}

- (NSString *)generateUniqueFilename
{
    NSString *prefixString = [NSString stringWithFormat:@"ImageIndex%lu", (unsigned long)_indexNumber];
    
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    
//    NSLog(@"uniqueFileName: '%@'", uniqueFileName);
    return uniqueFileName;
}

- (void)resetRecordingValues
{
    _isRecorded = NO;
    _startAppearanceTime = 0.0f;
    _endAppearanceTime = 0.0f;
    _pauseTime = 0.0f;
    _duration = 0.0f;
    
    [self saveModelToCompositionArray];
}

- (void)saveModelToCompositionArray
{
    BOOL insert = NO;
    NSString *compositionPath = [NSString stringWithFormat:@"%@/%@", COMPOSITION_TEMP_FOLDER_PATH, COMPOSITION_DICT];
    NSMutableDictionary *compositionDict = nil;
    NSMutableArray *compositionArray = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:compositionPath]) {
        NSData *data = [NSData dataWithContentsOfFile:compositionPath];
        compositionDict = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data] copyItems:YES];
        compositionArray = [[NSMutableArray alloc] initWithArray:compositionDict[COMPOSITION_IMAGE_ARRAY_KEY] copyItems:YES];
    }
    else {
        compositionArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    NSMutableDictionary *modelDict = nil;
    if(compositionArray.count <= _indexNumber-1) {
        insert = YES;
        modelDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    else {
        modelDict = [[NSMutableDictionary alloc] initWithDictionary:compositionArray[_indexNumber-1] copyItems:YES];
    }
    
    [modelDict setObject:[NSNumber numberWithInteger:_indexNumber] forKey:COMPOSITION_ARRAY_DICT_INDEXNUMBER_KEY];
    [modelDict setObject:_originalImagePath forKey:COMPOSITION_ARRAY_DICT_ORIGINAL_IMG_PATH_KEY];
    [modelDict setObject:[NSValue valueWithCGRect:_cropRect] forKey:COMPOSITION_ARRAY_DICT_CROP_RECT_KEY];
    [modelDict setObject:[NSNumber numberWithBool:_isRecorded] forKey:COMPOSITION_ARRAY_DICT_IS_RECORDED_KEY];
    [modelDict setObject:[NSNumber numberWithFloat:_startAppearanceTime] forKey:COMPOSITION_ARRAY_DICT_START_APPEARANCE_KEY];
    [modelDict setObject:[NSNumber numberWithFloat:_endAppearanceTime] forKey:COMPOSITION_ARRAY_DICT_END_APPEARANCE_KEY];
    [modelDict setObject:[NSNumber numberWithFloat:_pauseTime] forKey:COMPOSITION_ARRAY_DICT_PAUSE_KEY];
    [modelDict setObject:[NSNumber numberWithFloat:_duration] forKey:COMPOSITION_ARRAY_DICT_VIDEO_DURATION_KEY];
    
    if(insert) {
        [compositionArray addObject:modelDict];
    }
    else {
        [compositionArray replaceObjectAtIndex:_indexNumber-1 withObject:modelDict];
    }
    
    [compositionDict setObject:compositionArray forKey:COMPOSITION_IMAGE_ARRAY_KEY];
    BOOL arraySuccess = [NSKeyedArchiver archiveRootObject:compositionDict toFile:compositionPath];
    if(!arraySuccess) {
//        NSLog(@"arraySuccess = %d", arraySuccess);
    }
}

- (void)removeModelFromCompositionArray
{
    NSString *compositionPath = [NSString stringWithFormat:@"%@/%@", COMPOSITION_TEMP_FOLDER_PATH, COMPOSITION_DICT];
    NSMutableArray *compositionArray = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:compositionPath]) {
        NSData *data = [NSData dataWithContentsOfFile:compositionPath];
        NSMutableDictionary *compositionDict = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data] copyItems:YES];
        compositionArray = [[NSMutableArray alloc] initWithArray:compositionDict[COMPOSITION_IMAGE_ARRAY_KEY] copyItems:YES];
        
        if(compositionArray && compositionArray.count > _indexNumber-1) {
            NSDictionary *modelDict = compositionArray[_indexNumber-1];
            if(modelDict) {
                [compositionArray removeObject:modelDict];
                
                [compositionDict setObject:compositionArray forKey:COMPOSITION_IMAGE_ARRAY_KEY];
                BOOL arraySuccess = [NSKeyedArchiver archiveRootObject:compositionDict toFile:compositionPath];
                if(!arraySuccess) {
    //                NSLog(@"arraySuccess = %d", arraySuccess);
                }
            }
        }
    }
    
}

@end
