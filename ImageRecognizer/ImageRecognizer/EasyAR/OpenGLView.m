//=============================================================================================================================
//
// Copyright (c) 2015-2018 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#import "OpenGLView.h"
#import "ARImageRecognizer.h"

//extern ARImageRecognizer * sharedRecognizer;
extern NSString * cloud_server_address;
extern NSString * cloud_key;
extern NSString * cloud_secret;

@interface OpenGLView ()
{
    
}

@end

@implementation OpenGLView {

}

int view_size[] = {0, 0};
int view_rotation = 0;
int viewport[] = {0, 0, 1280, 720};



- (BOOL)initialize
{
    _camera = [easyar_CameraDevice create];
    _streamer = [easyar_CameraFrameStreamer create];
    [_streamer attachCamera:_camera];
    _cloud_recognizer = [easyar_CloudRecognizer create];
    [_cloud_recognizer attachStreamer:_streamer];
    
    bool status = true;
    status &= [_camera open:easyar_CameraDeviceType_Default];
    [_camera setSize:[easyar_Vec2I create:@[@1280, @720]]];
    _uids = [[NSMutableSet<NSString *> alloc] init];
    [_cloud_recognizer open:cloud_server_address appKey:cloud_key appSecret:cloud_secret callback_open:^(easyar_CloudStatus status) {
        if (status == easyar_CloudStatus_Success ) {
            NSLog(@"CloudRecognizerInitCallBack: Success");
        } else if (status == easyar_CloudStatus_Reconnecting) {
            NSLog(@"CloudRecognizerInitCallBack: Reconnecting");
        } else if (status == easyar_CloudStatus_Fail) {
            NSLog(@"CloudRecognizerInitCallBack: Fail");
        } else {
            NSLog(@"CloudRecognizerInitCallBack: %ld", (long)status);
        }
    } callback_recognize:^(easyar_CloudStatus status, NSArray<easyar_Target *> * targets) {
        if (status == easyar_CloudStatus_Success ) {
            NSLog(@"CloudRecognizerCallBack: Success");
            
            if (self.delegate != nil){
                NSString * str = @"BIG SUCCESS";
                if (!self.ifDetected){
                    if (targets != nil){
                        if (targets.count >= 1){
                            NSLog(targets[0].name);
                            NSLog(targets[0].meta);
                            str = targets[0].meta;
                            
                            NSData * decoded = [[NSData alloc]initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
                            NSString * decodedStr = [[NSString alloc]initWithData:decoded encoding:kCFStringEncodingUTF8];
                            str = decodedStr;
                            
                        }
                    }
                    NSArray * lines=[str componentsSeparatedByString:@"\n"];
                    if (lines.count >= 4){
                        self.ifDetected = YES;
                    }
                    [self.delegate onSuccess:lines];
                }
            }
            
            
        } else if (status == easyar_CloudStatus_Reconnecting) {
            NSLog(@"CloudRecognizerCallBack: Reconnecting");
        } else if (status == easyar_CloudStatus_Fail) {
            NSLog(@"CloudRecognizerCallBack: Fail");
        } else {
            NSLog(@"CloudRecognizerCallBack: %ld", (long)status);
        }
        @synchronized (self->_uids) {
            for (easyar_Target * t in targets) {
                if (![self->_uids containsObject:[t uid]]) {
                    NSLog(@"add cloud target: %@", [t uid]);
                    [self->_uids addObject:[t uid]];
                    [[self->_trackers objectAtIndex:0] loadTarget:t callback:^(easyar_Target *target, bool status) {
                        NSLog(@"load target (%@): %@ (%d)", status ? @"true" : @"false", [target name], [target runtimeID]);
                    }];
                }
            }
        }
    }];
    
    if (!status) { return status; }
    easyar_ImageTracker * tracker = [easyar_ImageTracker create];
    [tracker attachStreamer:_streamer];
    _trackers = [[NSMutableArray<easyar_ImageTracker *> alloc] init];
    [_trackers addObject:tracker];
    
    return status;
}

- (void) remove
{
    [_trackers removeAllObjects];
    _cloud_recognizer = nil;
    _box_renderer = nil;
    _videobg_renderer = nil;
    _streamer = nil;
    _camera = nil;
}

- (BOOL) startDetect
{
    bool status = true;
    status &= (_camera != nil) && [_camera start];
    status &= (_streamer != nil) && [_streamer start];
    status &= (_cloud_recognizer != nil) && [_cloud_recognizer start];
    [_camera setFocusMode:easyar_CameraDeviceFocusMode_Continousauto];
    for (easyar_ImageTracker * tracker in _trackers) {
        status &= [tracker start];
    }
    return status;
}

- (BOOL) stopDetect
{
    bool status = true;
    for (easyar_ImageTracker * tracker in _trackers) {
        status &= [tracker stop];
    }
    status &= (_cloud_recognizer != nil) && [_cloud_recognizer stop];
    status &= (_streamer != nil) && [_streamer stop];
    status &= (_camera != nil) && [_camera stop];
    return status;
}

- (void) initGL
{
    _videobg_renderer = [easyar_Renderer create];
    _box_renderer = [[BoxRenderer alloc] init];
}

- (void) resizeGL:(int) width: (int) height
{
    view_size[0] = width;
    view_size[1] = height;
    _viewport_changed = true;
}

- (void) updateViewport
{
    easyar_CameraCalibration * calib = _camera != nil ? [_camera cameraCalibration] : nil;
    int rotation = calib != nil ? [calib rotation] : 0;
    if (rotation != view_rotation) {
        view_rotation = rotation;
        _viewport_changed = true;
    }
    if (_viewport_changed) {
        int size[] = {1, 1};
        if (_camera && [_camera isOpened]) {
            size[0] = [[[_camera size].data objectAtIndex:0] intValue];
            size[1] = [[[_camera size].data objectAtIndex:1] intValue];
        }
        if (rotation == 90 || rotation == 270) {
            int t = size[0];
            size[0] = size[1];
            size[1] = t;
        }
        float scaleRatio = MAX((float)view_size[0] / (float)size[0], (float)view_size[1] / (float)size[1]);
        int viewport_size[] = {(int)roundf(size[0] * scaleRatio), (int)roundf(size[1] * scaleRatio)};
        int viewport_new[] = {(view_size[0] - viewport_size[0]) / 2, (view_size[1] - viewport_size[1]) / 2, viewport_size[0], viewport_size[1]};
        memcpy(&viewport[0], &viewport_new[0], 4 * sizeof(int));
        
        if (_camera && [_camera isOpened])
            _viewport_changed = false;
    }
}

- (void) render
{
    glClearColor(1.f, 1.f, 1.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    if (_videobg_renderer != nil) {
        int default_viewport[] = {0, 0, view_size[0], view_size[1]};
        easyar_Vec4I * oc_default_viewport = [easyar_Vec4I create:@[[NSNumber numberWithInt:default_viewport[0]], [NSNumber numberWithInt:default_viewport[1]], [NSNumber numberWithInt:default_viewport[2]], [NSNumber numberWithInt:default_viewport[3]]]];
        glViewport(default_viewport[0], default_viewport[1], default_viewport[2], default_viewport[3]);
        if ([_videobg_renderer renderErrorMessage:oc_default_viewport]) {
            return;
        }
    }

    if (_streamer == nil) { return; }
    easyar_Frame * frame = [_streamer peek];
    [self updateViewport];
    glViewport(viewport[0], viewport[1], viewport[2], viewport[3]);

    if (_videobg_renderer != nil) {
        [_videobg_renderer render:frame viewport:[easyar_Vec4I create:@[[NSNumber numberWithInt:viewport[0]], [NSNumber numberWithInt:viewport[1]], [NSNumber numberWithInt:viewport[2]], [NSNumber numberWithInt:viewport[3]]]]];
    }
    
}





- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self->_initialized = false;
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    [self bindDrawable];
    return self;
}



- (void)dealloc
{
    [_trackers removeAllObjects];
    _trackers = nil;
    _cloud_recognizer = nil;
    _box_renderer = nil;
    _videobg_renderer = nil;
    _streamer = nil;
    _camera = nil;
}

- (void)start
{
    if ([self initialize]) {
        if (![self startDetect]){
            NSLog(@"Start fail\n");
        }
    }else{
        NSLog(@"initialize fail\n");
    }
}

- (void)stop
{
    
    if (![self stopDetect]){
        NSLog(@"stop fail\n");
    }
    [self remove];
}

- (void)resize:(CGRect)frame orientation:(UIInterfaceOrientation)orientation
{
    float scale;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
        scale = [[UIScreen mainScreen] nativeScale];
#pragma clang diagnostic pop
    } else {
        scale = [[UIScreen mainScreen] scale];
    }

    [self resizeGL:frame.size.width * scale :frame.size.height * scale];
}

- (void)drawRect:(CGRect)rect
{
    if (!_initialized) {
        [self initGL];
        _initialized = YES;
    }
    [self render];
}



- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
            [easyar_Engine setRotation:270];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [easyar_Engine setRotation:90];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [easyar_Engine setRotation:180];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [easyar_Engine setRotation:0];
            break;
        default:
            break;
    }
}

@end
