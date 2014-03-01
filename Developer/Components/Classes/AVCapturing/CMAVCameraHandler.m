//
//  CMAVCameraHandler.m
//  Composition
//
//  Created by Describe Administrator on 01/02/14.
//  Copyright (c) 2014 Describe Administrator. All rights reserved.
//

#import "CMAVCameraHandler.h"
#import "VideoEncoder.h"
#import "AssetsLibrary/ALAssetsLibrary.h"

@interface CMAVCameraHandler () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_captureSession;
    AVCaptureDeviceInput *_captureDeviceInput;
    AVCaptureStillImageOutput *_stillImageOutput;
    
    AVCaptureVideoPreviewLayer *_captureVideoPreviewLayer;
    
    AVCaptureMovieFileOutput *_movieFileOutput;
    AVCaptureVideoDataOutput* videoout;
    AVCaptureAudioDataOutput* audioout;
    
    CameraDevice _cameraDeviceMode;
    
    dispatch_queue_t _captureQueue;
    AVCaptureConnection* _audioConnection;
    AVCaptureConnection* _videoConnection;
    
    CMTime _timeOffset;
    CMTime _lastVideo;
    CMTime _lastAudio;
    VideoEncoder* _encoder;
    
    NSInteger _cx;
    NSInteger _cy;
    NSInteger _channels;
    Float64 _samplerate;
    
    BOOL _isCapturing;
    BOOL _isPaused;
    BOOL _discont;
    
}

@property (nonatomic, strong) NSString *videoFilename;
@property (nonatomic, strong) AVCaptureDeviceInput *frontFaceCamera;
@property (nonatomic, strong) AVCaptureDeviceInput *rearFaceCamera;

@end

static CMAVCameraHandler *_sharedInstance = nil;

#define CAPTURE_FRAMES_PER_SECOND		20

@implementation CMAVCameraHandler

+ (instancetype)sharedHandler
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CMAVCameraHandler alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if(self) {
        _cameraDeviceMode = kCameraDeviceNone;
        _flashMode = AVCaptureFlashModeAuto;
        
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        
        _captureQueue = dispatch_queue_create("uk.co.gdcl.cameraengine.capture", DISPATCH_QUEUE_SERIAL);
        
        [self getDeviceVideoInputs];
        [self addVideoInputFromFrontCamera:kCameraDeviceFront];
        [self addAudioInput];
        [self addStillImageOutput];
//        [self addvideoAudioOutputForUsingAssetLibrary];
    }
    
    return self;
}

- (void)getDeviceVideoInputs
{
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        //NSLog(@"Device name: %@", [device localizedName]);
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device position] == AVCaptureDevicePositionBack) {
                //NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                //NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
    if (!error) {
        self.frontFaceCamera = frontFacingCameraDeviceInput;
    }

    AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    if (!error) {
        self.rearFaceCamera = backFacingCameraDeviceInput;
    }
}

#pragma mark - Starting and stopping captureSession

- (void)startCaptureSession
{
    if(_captureSession) {
        [_captureSession startRunning];
    }
}

- (void)stopCaptureSession
{
    if(_captureSession && _captureSession.isRunning) {
        [_captureSession stopRunning];
    }
}

- (BOOL)isCaptureSessionRunning
{
    return _captureSession.isRunning;
}

- (CameraDevice)selectedCameraDeviceMode
{
    return _cameraDeviceMode;
}

#pragma mark - Change camera flash mode

- (BOOL)changeCameraFlashMode:(AVCaptureFlashMode)mode
{
    if(_captureDeviceInput) {
        if ([_captureDeviceInput.device isFlashModeSupported:mode]) {
            NSError *error = nil;
            if ([_captureDeviceInput.device lockForConfiguration:&error]) {
                _captureDeviceInput.device.flashMode = mode;
                [_captureDeviceInput.device unlockForConfiguration];
                
                _flashMode = mode;
                return YES;
            }
            else {
                // Respond to the failure as appropriate.
                return NO;
            }
        }
    }
    
    return YES;
}

#pragma mark - Configuring video/audio output to captureSession

- (void)addvideoAudioOutputForUsingAssetLibrary
{    
    if([_captureSession isRunning]) {
        [_captureSession beginConfiguration];
    }
    
    videoout = [[AVCaptureVideoDataOutput alloc] init];
    [videoout setSampleBufferDelegate:self queue:_captureQueue];
    NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                    nil];
    videoout.videoSettings = setcapSettings;
    [_captureSession addOutput:videoout];
    _videoConnection = [videoout connectionWithMediaType:AVMediaTypeVideo];
    [_videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];

    // find the actual dimensions used so we can set up the encoder to the same.
    NSDictionary* actual = videoout.videoSettings;
    _cy = [[actual objectForKey:@"Height"] integerValue];
    _cx = [[actual objectForKey:@"Width"] integerValue];
    
    audioout = [[AVCaptureAudioDataOutput alloc] init];
    [audioout setSampleBufferDelegate:self queue:_captureQueue];
    [_captureSession addOutput:audioout];
    _audioConnection = [audioout connectionWithMediaType:AVMediaTypeAudio];
    // for audio, we want the channels and sample rate, but we can't get those from audioout.audiosettings on ios, so
    // we need to wait for the first sample
    
    if([_captureSession isRunning]) {
        [_captureSession commitConfiguration];
    }
}

- (void)removeVideoAudioOutput
{
    if([_captureSession isRunning]) {
        [_captureSession beginConfiguration];
    }
    
    if(videoout) {
        [_captureSession removeOutput:videoout];
    }
    
    if(audioout) {
        [_captureSession removeOutput:audioout];
    }
    
    if([_captureSession isRunning]) {
        [_captureSession commitConfiguration];
    }
}

#pragma mark - Configuring video input as front camera or rear camera to current capture session

- (void)addVideoInputFromFrontCamera:(CameraDevice)cameraMode
{
    if(cameraMode == _cameraDeviceMode) {
        return;
    }
    
    BOOL hadDeviceInput = NO;
    if(_captureDeviceInput) {
        hadDeviceInput = YES;
        [_captureSession beginConfiguration];
        [_captureSession removeInput:_captureDeviceInput];
        
        if(cameraMode == kCameraDeviceNone) {
            [_captureSession commitConfiguration];
        }
    }
    
    if(cameraMode == kCameraDeviceNone) {
        return;
    }
    
    BOOL front = cameraMode == kCameraDeviceFront;
    
    if (front) {
        if ([_captureSession canAddInput:self.frontFaceCamera]) {
            _captureDeviceInput = self.frontFaceCamera;
            _cameraDeviceMode = kCameraDeviceFront;
            [_captureSession addInput:self.frontFaceCamera];
        } else {
            NSLog(@"Couldn't add front facing video input");
        }
    } else {
        if ([_captureSession canAddInput:self.rearFaceCamera]) {
            _captureDeviceInput = self.rearFaceCamera;
            _cameraDeviceMode = kCameraDeviceRear;
            [_captureSession addInput:self.rearFaceCamera];
        } else {
            NSLog(@"Couldn't add back facing video input");
        }
    }
    
    [self changeCameraFlashMode:_flashMode];
    
    if(hadDeviceInput) {
        [_captureSession commitConfiguration];
    }
}

#pragma mark Add Audio input to capture session

- (void)addAudioInput
{
    AVCaptureDevice* mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput* micinput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:nil];
    [_captureSession addInput:micinput];
}

#pragma mark - Adding/removing preview layer to/from custom view for showing current capture session video on screen.

- (void)showCameraPreviewInView:(UIView *)previewView
{
    [self removePreviewLayer];
    
    CALayer *viewLayer = previewView.layer;
    CGRect layerRect = [previewView bounds];
    
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _captureVideoPreviewLayer.frame = layerRect;
    [_captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResize];
    
    [viewLayer setMasksToBounds:YES];
    [viewLayer addSublayer:_captureVideoPreviewLayer];
}

- (void)removePreviewLayer
{
    if(_captureVideoPreviewLayer) {
        [_captureVideoPreviewLayer removeFromSuperlayer];
        _captureVideoPreviewLayer = nil;
    }
}

- (BOOL)isPreviewLayerDisplaying
{
    return _captureVideoPreviewLayer ? YES:NO;
}

#pragma mark - Configuring still image output to capture session for getting stillImage capture

- (void)addStillImageOutput
{
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, [NSNumber numberWithInt:320], AVVideoWidthKey, [NSNumber numberWithInt:320], AVVideoHeightKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    
    [_captureSession addOutput:_stillImageOutput];
}

- (void)captureStillImage
{
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [_stillImageOutput connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
            break;
        }
	}
    
//	NSLog(@"about to request a capture from: %@", _stillImageOutput);
	[_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                         completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                                                             CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                             if (exifAttachments) {
//                                                                 NSLog(@"attachements: %@", exifAttachments);
                                                             } else {
//                                                                 NSLog(@"no attachments");
                                                             }
                                                             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                                                             UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 if(_delegate && [_delegate respondsToSelector:@selector(didFinishCapturingStillImage:error:withContextInfo:)]) {
                                                                     [_delegate didFinishCapturingStillImage:[image copy] error:error withContextInfo:nil];
                                                                 }
                                                             });
//                                                             UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//                                                             [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:nil];
                                                         }];
}

// method to identify when saving stillImage to photo library was successfull
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"%@", [error description]);
    if(_delegate && [_delegate respondsToSelector:@selector(didFinishCapturingStillImage:error:withContextInfo:)]) {
        [_delegate didFinishCapturingStillImage:image error:error withContextInfo:contextInfo];
    }
}

#pragma mark - Record handling methods like Start/Stop/Pause/Resume

- (BOOL)isVideoRecordingStarted
{
    return _isCapturing;
}

- (BOOL)isRecordingPaused
{
    return _isPaused;
}

- (void)startOrStopRecordingVideo
{
    @synchronized(self)
    {
        if (!_isCapturing)
        {
            NSLog(@"starting capture");
            
            // create the encoder once we have the audio params
            _encoder = nil;
            _isPaused = NO;
            _discont = NO;
            _timeOffset = CMTimeMake(0, 0);
            _isCapturing = YES;
        }
        else {
            // serialize with audio and video capture
            _isCapturing = NO;
            _isPaused = NO;
            dispatch_async(_captureQueue, ^{
                [_encoder finishWithCompletionHandler:^{
                    NSLog(@"writeStatus = %d, error = %@", _encoder.writer.status, _encoder.writer.error);
//                    _encoder.writer = nil;
                    _isCapturing = NO;
                    _encoder = nil;
                    
                    // Copy recorded video path and store it in secured place
//                    NSString* filename = [NSString stringWithFormat:@"%lf.mp4", [[NSDate date] timeIntervalSince1970]];
                    __block NSString* path = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), _videoFilename];
                    NSURL* url = [NSURL fileURLWithPath:path];
                    
                    
                    
                    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                    [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error){
                        
                        //.......................
                        //To Do: Share this Url as video file path for that post....
                        //.......................
                        //url
                        
                        NSLog(@"save completed error = %@, url = %@, path = %@", error, [assetURL absoluteString], path);
                        if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                            
                            
//                            NSError *err;
//                            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
//                            NSLog(@"%d, error = %@ \n%@", success, err.description, err.debugDescription);
                        }
                    }];
                }];
            });
        }
    }
}

- (void)pauseOrResumeRecordingVideo
{
    @synchronized(self)
    {
        if (_isPaused) {
            NSLog(@"Resuming capture");
            _isPaused = NO;
            
        }
        else if(_isCapturing) {
            NSLog(@"Pausing capture");
            _isPaused = YES;
            _discont = YES;
        }
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate methods

- (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset
{
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; i++)
    {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    return sout;
}

- (BOOL)setAudioFormat:(CMFormatDescriptionRef)fmt
{
    const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
    if(asbd) {
        _samplerate = asbd->mSampleRate;
        _channels = asbd->mChannelsPerFrame;
        
        return YES;
    }
    
    return NO;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    BOOL bVideo = YES;
    
    @synchronized(self)
    {
        if (!_isCapturing  || _isPaused)
        {
            return;
        }
        if (connection != _videoConnection)
        {
            bVideo = NO;
        }
        if ((_encoder == nil) && !bVideo)
        {
            CMFormatDescriptionRef fmt = CMSampleBufferGetFormatDescription(sampleBuffer);
            if([self setAudioFormat:fmt] == NO) {
                return;
            }
            
            _videoFilename = [NSString stringWithFormat:@"%ld.mp4", (long)[[NSDate date] timeIntervalSince1970]];
            NSString* path = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), _videoFilename];
            NSLog(@"path for video recording = %@", path);
            _encoder = [VideoEncoder encoderForPath:path Height:_cy width:_cx channels:_channels samples:_samplerate];
        }
        
        if (_discont)
        {
            if (bVideo)
            {
                return;
            }
            _discont = NO;
            // calc adjustment
            CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            CMTime last = bVideo ? _lastVideo : _lastAudio;
            if (last.flags & kCMTimeFlags_Valid)
            {
                if (_timeOffset.flags & kCMTimeFlags_Valid)
                {
                    pts = CMTimeSubtract(pts, _timeOffset);
                }
                CMTime offset = CMTimeSubtract(pts, last);
                
                NSLog(@"Setting offset from %s", bVideo?"video": "audio");
                NSLog(@"Adding %f to %f (pts %f)", ((double)offset.value)/offset.timescale, ((double)_timeOffset.value)/_timeOffset.timescale, ((double)pts.value/pts.timescale));
                
                // this stops us having to set a scale for _timeOffset before we see the first video time
                if (_timeOffset.value == 0)
                {
                    _timeOffset = offset;
                }
                else
                {
                    _timeOffset = CMTimeAdd(_timeOffset, offset);
                }
            }
            _lastVideo.flags = 0;
            _lastAudio.flags = 0;
        }
        
        // retain so that we can release either this or modified one
        CFRetain(sampleBuffer);
        
        if (_timeOffset.value > 0)
        {
            CFRelease(sampleBuffer);
            sampleBuffer = [self adjustTime:sampleBuffer by:_timeOffset];
        }
        
        // record most recent time so we know the length of the pause
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CMTime dur = CMSampleBufferGetDuration(sampleBuffer);
        if (dur.value > 0)
        {
            pts = CMTimeAdd(pts, dur);
        }
        if (bVideo)
        {
            _lastVideo = pts;
        }
        else
        {
            _lastAudio = pts;
        }
    }
    
    // pass frame to encoder
    [_encoder encodeFrame:sampleBuffer isVideo:bVideo];
    CFRelease(sampleBuffer);
}

@end
