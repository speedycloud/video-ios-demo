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

// WebRTC (headers copied from WebRTC project)
#import <PureRTC/RTCAVFoundationVideoSource.h>
#import <PureRTC/RTCCameraPreviewView.h>
#import <PureRTC/RTCConfiguration.h>
#import <PureRTC/RTCEAGLVideoView.h>
#import <PureRTC/RTCIceServer.h>
#import <PureRTC/RTCLogging.h>
#import <PureRTC/RTCMacros.h>
#import <PureRTC/RTCMediaConstraints.h>
#import <PureRTC/RTCVideoFrame.h>
#import <PureRTC/RTCVideoRenderer.h>
#import <PureRTC/RTCVideoSource.h>
#import <PureRTC/RTCCameraPreviewView.h>

// Base SDK
#import <PureRTC/RTCAVFoundationVideoSource+PureRTC.h>
#import <PureRTC/RTCErrors.h>
#import <PureRTC/RTCFrameGeneratorProtocol.h>
#import <PureRTC/RTCGlobalConfiguration.h>
#import <PureRTC/RTCLocalCameraStream.h>
#import <PureRTC/RTCLocalCustomizedStream.h>
#import <PureRTC/RTCLocalStream.h>
#import <PureRTC/RTCMediaCodec.h>
#import <PureRTC/RTCMediaFormat.h>
#import <PureRTC/RTCRemoteCameraStream.h>
#import <PureRTC/RTCRemoteMixedStream.h>
#import <PureRTC/RTCRemoteMixedStreamObserver.h>
#import <PureRTC/RTCRemoteScreenStream.h>
#import <PureRTC/RTCRemoteStream.h>
#import <PureRTC/RTCStream.h>

// P2P SDK
#import <PureRTC/RTCP2PErrors.h>
#import <PureRTC/RTCPeerClient.h>

// Conference SDK
#import <PureRTC/RTCConferenceClient.h>
#import <PureRTC/RTCConferenceErrors.h>

