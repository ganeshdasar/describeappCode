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
- (void)didStartedVideoRecordingAtPath:(NSString *)recordingPath;

@end

@interface CMAVCameraHandler : NSObject

@property (nonatomic, assign) AVCaptureFlashMode flashMode;
@property (nonatomic, assign)id <CMAVCameraHandlerDelegate> delegate;
@property (nonatomic, readonly) BOOL isRecordingDone;
@property (nonatomic, strong) NSString *videoFilenamePath;

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

- (void)changeCapturesSessionPreset:(NSString *)presetString;

- (void)showCameraPreviewInView:(UIView *)previewView withRect:(CGRect)layerRect;

- (void)removePreviewLayer;

- (void)captureStillImage;

- (void)startOrStopRecordingVideo;

- (void)pauseOrResumeRecordingVideo;

- (BOOL)isRecordingPaused;

@end
