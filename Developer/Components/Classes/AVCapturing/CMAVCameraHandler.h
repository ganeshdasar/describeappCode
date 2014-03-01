//
//  CMAVCameraHandler.h
//  Composition
//
//  Created by Describe Administrator on 01/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

typedef enum {
    kCameraDeviceNone = -1,
    kCameraDeviceFront,
    kCameraDeviceRear,
} CameraDevice;

@protocol CMAVCameraHandlerDelegate <NSObject>

@optional
- (void)didFinishCapturingStillImage:(UIImage *)image error:(NSError *)error withContextInfo:(void *)contextInfo;

@end

@interface CMAVCameraHandler : NSObject

@property (nonatomic, assign) AVCaptureFlashMode flashMode;
@property (nonatomic, assign)id <CMAVCameraHandlerDelegate> delegate;

+ (instancetype)sharedHandler;

- (void)startCaptureSession;

- (void)stopCaptureSession;

- (BOOL)isCaptureSessionRunning;

- (BOOL)isPreviewLayerDisplaying;

- (BOOL)isVideoRecordingStarted;

- (CameraDevice)selectedCameraDeviceMode;

- (BOOL)changeCameraFlashMode:(AVCaptureFlashMode)mode;

- (void)addvideoAudioOutputForUsingAssetLibrary;

- (void)removeVideoAudioOutput;

- (void)addVideoInputFromFrontCamera:(CameraDevice)cameraMode;

- (void)showCameraPreviewInView:(UIView *)previewView;

- (void)removePreviewLayer;

- (void)captureStillImage;

- (void)startOrStopRecordingVideo;

- (void)pauseOrResumeRecordingVideo;

- (BOOL)isRecordingPaused;

@end
