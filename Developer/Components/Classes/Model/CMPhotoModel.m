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



- (id)initWithDictionary:(NSDictionary *)photoDict
{
    self = [super init];
    if(self) {
        
        if(photoDict != nil && photoDict[@"CropRectKey"]) {
            _cropRect = [photoDict[@"CropRectKey"] CGRectValue];
        }
        
        if(photoDict != nil && photoDict[@"OriginalImagePathKey"]) {
            _originalImagePath = photoDict[@"OriginalImagePathKey"];
            NSData *imgData = [NSData dataWithContentsOfFile:_originalImagePath];
            if(imgData) {
                _originalImage = [UIImage imageWithData:imgData];
                
                CGImageRef imgRef = CGImageCreateWithImageInRect(_originalImage.CGImage, _cropRect);
                UIImage *image = [UIImage imageWithCGImage:imgRef];
                _editedImage = image;
            }
        }
        
        if(photoDict != nil && photoDict[@"IndexNumberKey"]) {
            _indexNumber = [photoDict[@"IndexNumberKey"] integerValue];
        }
        
        if(photoDict != nil && photoDict[@"IsRecordedKey"]) {
            _isRecorded = [photoDict[@"IsRecordedKey"] boolValue];
        }
        
        if(photoDict != nil && photoDict[@"StartAppearanceKey"]) {
            _startAppearanceTime = [photoDict[@"StartAppearanceKey"] floatValue];
        }
        
        if(photoDict != nil && photoDict[@"EndAppearanceKey"]) {
            _endAppearanceTime = [photoDict[@"EndAppearanceKey"] floatValue];
        }
        
        if(photoDict != nil && photoDict[@"PauseKey"]) {
            _pauseTime = [photoDict[@"PauseKey"] floatValue];
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

- (void)setStartAppearanceTime:(float)startAppearanceTime
{
    _startAppearanceTime = startAppearanceTime;
    [self saveModelToCompositionArray];
}

- (void)setEndAppearanceTime:(float)endAppearanceTime
{
    _endAppearanceTime = endAppearanceTime;
    [self saveModelToCompositionArray];
}

- (void)setPauseTime:(float)pauseTime
{
    _pauseTime = pauseTime;
    [self saveModelToCompositionArray];
}

- (NSString *)generateUniqueFilename
{
    NSString *prefixString = [NSString stringWithFormat:@"ImageIndex%d", _indexNumber];
    
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    
//    NSLog(@"uniqueFileName: '%@'", uniqueFileName);
    return uniqueFileName;
}

- (void)saveModelToCompositionArray
{
    BOOL insert = NO;
    NSString *arrayPath = [NSString stringWithFormat:@"%@/compositionArray.plist", COMPOSITION_TEMP_FOLDER_PATH];
    NSMutableArray *compositionArray = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:arrayPath]) {
        NSData *data = [NSData dataWithContentsOfFile:arrayPath];
        compositionArray = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data] copyItems:YES];
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
    
    [modelDict setObject:[NSNumber numberWithInteger:_indexNumber] forKey:@"IndexNumberKey"];
    [modelDict setObject:_originalImagePath forKey:@"OriginalImagePathKey"];
    [modelDict setObject:[NSValue valueWithCGRect:_cropRect] forKey:@"CropRectKey"];
    [modelDict setObject:[NSNumber numberWithBool:_isRecorded] forKey:@"IsRecordedKey"];
    [modelDict setObject:[NSNumber numberWithFloat:_startAppearanceTime] forKey:@"StartAppearanceKey"];
    [modelDict setObject:[NSNumber numberWithFloat:_endAppearanceTime] forKey:@"EndAppearanceKey"];
    [modelDict setObject:[NSNumber numberWithFloat:_pauseTime] forKey:@"PauseKey"];
    
    if(insert) {
        [compositionArray addObject:modelDict];
    }
    else {
        [compositionArray replaceObjectAtIndex:_indexNumber-1 withObject:modelDict];
    }
    
    BOOL arraySuccess = [NSKeyedArchiver archiveRootObject:compositionArray toFile:arrayPath];
    if(!arraySuccess) {
//        NSLog(@"arraySuccess = %d", arraySuccess);
    }
}

- (void)removeModelFromCompositionArray
{
    NSString *arrayPath = [NSString stringWithFormat:@"%@/compositionArray.plist", COMPOSITION_TEMP_FOLDER_PATH];
    NSMutableArray *compositionArray = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:arrayPath]) {
        NSData *data = [NSData dataWithContentsOfFile:arrayPath];
        compositionArray = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data] copyItems:YES];
        
        NSDictionary *modelDict = compositionArray[_indexNumber-1];
        if(modelDict) {
            [compositionArray removeObject:modelDict];
            
            BOOL arraySuccess = [NSKeyedArchiver archiveRootObject:compositionArray toFile:arrayPath];
            if(!arraySuccess) {
//                NSLog(@"arraySuccess = %d", arraySuccess);
            }
        }
    }
    
}

@end
