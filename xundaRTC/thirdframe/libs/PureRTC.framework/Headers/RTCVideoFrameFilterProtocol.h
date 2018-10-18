/*
 * Copyright © 2016 Intel Corporation. All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <CoreVideo/CoreVideo.h>
#import <PureRTC/RTCMacros.h>

RTC_EXPORT
/**
 * @brief Protocol for video frame filter.
 * @detail Customized video frame filter should implement this protocol.
 **/
@protocol RTCVideoFrameFilterProtocol<NSObject>

/**
 * @brief Apply filter on input image.
 * @param image Input image.
 * @param callback When a frame is processed, call |callback| with filtered
 * image buffer reference so SDK can send it to next unit of the video pipeline.
 * @detail This method will be called for each input image. The output image
 * should have the same resolution as original one. Consider GPU, CPU and memory
 * usage when implementing this method.
 */
- (void)filterImage:(CVImageBufferRef)image
         onComplete:(void (^)(CVImageBufferRef))callback;

@end

