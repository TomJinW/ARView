//=============================================================================================================================
//
// EasyAR 2.3.0
// Copyright (c) 2015-2018 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#import "easyar/types.oc.h"
#import "easyar/targettracker.oc.h"

@interface easyar_ImageTracker : easyar_TargetTracker

+ (easyar_ImageTracker *) create;
+ (easyar_ImageTracker *)createWithMode:(easyar_ImageTrackerMode)mode;
- (void)loadTarget:(easyar_Target *)target callback:(void (^)(easyar_Target * target, bool status))callback;
- (void)unloadTarget:(easyar_Target *)target callback:(void (^)(easyar_Target * target, bool status))callback;
- (bool)loadTargetBlocked:(easyar_Target *)target;
- (bool)unloadTargetBlocked:(easyar_Target *)target;
- (NSArray<easyar_Target *> *)targets;
- (bool)setSimultaneousNum:(int)num;
- (int)simultaneousNum;
- (bool)attachStreamer:(easyar_FrameStreamer *)obj;
- (bool)start;
- (bool)stop;

@end
