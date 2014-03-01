//
//  VideoEncoder.h
//  Encoder Demo
//
//  Created by Geraint Davies on 14/01/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//
//    # GDCL Source Code License
//
//    Last updated: 20th February 2013
//
//    **License Agreement for Source Code provided by GDCL**
//
//    This software is supplied to you by Geraint Davies Consulting Ltd ('GDCL') in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this software constitutes acceptance of these terms. If you do not agree with these terms, please do not use, install, modify or redistribute this software.
//
//    In consideration of your agreement to abide by the following terms, and subject to these terms, GDCL grants you a personal, non-exclusive license, to use, reproduce, modify and redistribute the software, with or without modifications, in source and/or binary forms; provided that if you redistribute the software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the software, and that in all cases attribution of GDCL as the original author of the source code shall be included in all such resulting software products or distributions.
//
//    Neither the name, trademarks, service marks or logos of Geraint Davies or GDCL may be used to endorse or promote products derived from the software without specific prior written permission from GDCL. Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by GDCL herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the software may be incorporated.
//
//    The software is provided by GDCL on an "AS IS" basis. GDCL MAKE NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
//    IN NO EVENT SHALL GDCL BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF GDCL HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>
#import "AVFoundation/AVAssetWriter.h"
#import "AVFoundation/AVAssetWriterInput.h"
#import "AVFoundation/AVMediaFormat.h"
#import "AVFoundation/AVVideoSettings.h"
#import "AVFoundation/AVAudioSettings.h"

@interface VideoEncoder : NSObject
{
    AVAssetWriterInput* _videoInput;
    AVAssetWriterInput* _audioInput;
    NSString* _path;
}

@property NSString* path;
@property (nonatomic, strong)     AVAssetWriter* writer;

+ (VideoEncoder*) encoderForPath:(NSString*) path Height:(NSInteger) cy width:(NSInteger) cx channels: (NSInteger)ch samples:(Float64) rate;

- (void) initPath:(NSString*)path Height:(NSInteger) cy width:(NSInteger) cx channels:(NSInteger)ch samples:(Float64)rate;
- (void) finishWithCompletionHandler:(void (^)(void))handler;
- (BOOL) encodeFrame:(CMSampleBufferRef) sampleBuffer isVideo:(BOOL) bVideo;


@end
