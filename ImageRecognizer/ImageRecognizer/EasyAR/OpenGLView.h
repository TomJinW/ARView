//=============================================================================================================================
//
// Copyright (c) 2015-2018 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#import <GLKit/GLKView.h>
#import "BoxRenderer.h"
#import <easyar/types.oc.h>
#import <easyar/camera.oc.h>
#import <easyar/frame.oc.h>
#import <easyar/framestreamer.oc.h>
#import <easyar/imagetracker.oc.h>
#import <easyar/imagetarget.oc.h>
#import <easyar/renderer.oc.h>
#import <easyar/cloud.oc.h>
#import <easyar/engine.oc.h>

@interface OpenGLView : GLKView

@property (strong,nonatomic) easyar_CameraDevice * camera;
@property (strong,nonatomic) easyar_CameraFrameStreamer * streamer;
@property (strong,nonatomic) NSMutableArray<easyar_ImageTracker *> * trackers;
@property (strong,nonatomic) easyar_Renderer * videobg_renderer;
@property (strong,nonatomic) BoxRenderer * box_renderer;
@property (strong,nonatomic) easyar_CloudRecognizer * cloud_recognizer;
@property bool viewport_changed;
@property (strong,nonatomic) NSMutableSet<NSString *> * uids;
@property (weak,nonatomic) id delegate;

@property BOOL initialized;
@property BOOL ifDetected;

- (void)start;
- (void)stop;
- (void)resize:(CGRect)frame orientation:(UIInterfaceOrientation)orientation;
- (void)setOrientation:(UIInterfaceOrientation)orientation;

@end
