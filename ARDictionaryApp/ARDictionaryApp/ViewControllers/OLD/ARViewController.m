//
//  ViewController.m
//  ARDictionaryApp
//
//  Created by Plex on 2018/12/25.
//  Copyright © 2018 Dgene. All rights reserved.
//

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#import "ARViewController.h"
//#import <ImageRecognizer/ARImageRecognizer.h>
#import <ARDictionaryLib/ARDictionaryLib.h>
@interface ARViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnSpeed;
@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
@property (nonatomic, strong) ARController * controller;
@property (nonatomic, strong) AudioPlayer * player;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnSpeaker;
@property (weak, nonatomic) IBOutlet UILabel *lblIndicator;
@property (weak, nonatomic) IBOutlet UIButton *btnCap1;
@property (weak, nonatomic) IBOutlet UIButton *btnCap2;

@end

    
@implementation ARViewController


//- (void)didReceiveNotificationWithState:(NSInteger)state msg:(NSString * _Nonnull)msg {
//}
//override var preferredStatusBarStyle: UIStatusBarStyle {
//    return .lightContent
//}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL) prefersStatusBarHidden{
    if (SYSTEM_VERSION_LESS_THAN(@"12.0")) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL) prefersHomeIndicatorAutoHidden{
    return YES;
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    
    NSLog(@"did become active notification");
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    [_controller resetTracking];
    NSLog(@"will enter foreground notification");
}

- (void)viewDidLoad {
    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orient))
    {
        [_btnCap1 setHidden:YES];
        [_btnCap2 setHidden:NO];
    }else{
        [_btnCap1 setHidden:NO];
        [_btnCap2 setHidden:YES];
    }
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // 仅用于 SceneKitView Debug 目的
//    self.sceneView.showsStatistics = YES;
    
    // Set Directory
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsM4AURL = [paths lastObject];
    NSURL *documentsDAEURL = [paths lastObject];
    
    // 未来的模型将会用下面两行地址来定位模型和音频URL
//    documentsM4AURL = [documentsM4AURL URLByAppendingPathComponent:@"model/model.m4a"];
//    documentsDAEURL = [documentsDAEURL URLByAppendingPathComponent:@"model/model.dae"];
    
    // 当前的模型 zip 使用的URL
    documentsM4AURL = [documentsM4AURL URLByAppendingPathComponent:@"model/model.m4a"];
    documentsDAEURL = [documentsDAEURL URLByAppendingPathComponent:@"model/model.scn"];
    
    // 将 m4a 音频文件传入到 player 中
    _player = [[AudioPlayer alloc]initWithUrl:documentsM4AURL block:^(BOOL playing) {
        if (playing){
            [self.btnSpeaker setImage:[UIImage imageNamed:@"Nospeaker.png"]];
            self.lblIndicator.text = @"点击喇叭按钮停止播放";
        }else{
            [self.btnSpeaker setImage:[UIImage imageNamed:@"speaker.png"]];
            self.lblIndicator.text = @"点击喇叭按钮再次播放";
        }
    }];
    
    // 创建一个 AR Session，传入 ARSCNView 和对应 dae 模型的 URL，同时传入一个 code block 来应对 AR Session中的状态变化
    _controller = [[ARController alloc]initWithScnView:self.sceneView url:documentsDAEURL delegate:^(NSInteger state,NSString * msg) {
        switch (state) {
            case -1:
            {
                UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                NSString * myMsg = @" 模型路径加载失败.";
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:[myMsg stringByAppendingString:msg] preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:action];
                [self presentViewController:alertController animated:YES completion:nil];
            }
                break;
            case 0:
                // 搜索合适的平面
                self.lblIndicator.text = @"正在搜索平面，请移动设备";
                break;
            case 1:
                // ARKit 找到了适当的平面
                self.lblIndicator.text = @"平面已识别，点击屏幕以放入3D物品";
                break;
            case 2:
                // ARKit 将指定的模型放入了画面中
                // 音频播放器播放指定音频
                (void)[self->_player play];
                break;
            default:
                break;
        }
        
    }];

}
- (IBAction)ResetBtnTapped:(UIButton *)sender {
    [_controller resetTracking];
}
- (IBAction)resetTracking:(UIBarButtonItem *)sender {
    // ARKit 识别错误时可以重置会话
    [_controller resetTracking];
}

int speedState = 0;
- (IBAction)changeAnimationSpeed:(UIBarButtonItem *)sender {
    // 修改 dae 中，动画的播放速度
    speedState++;
    if (speedState > 3){
        speedState = 0;
    }
    switch (speedState) {
        case 0:
            (void)[_controller setAnimationWithSpeed:0.25f];
            _btnSpeed.title = @"0.25x";
            break;
        case 1:
            (void)[_controller setAnimationWithSpeed:0.5f];
            _btnSpeed.title = @"0.5x";
            break;
        case 2:
            (void)[_controller setAnimationWithSpeed:1.0f];
            _btnSpeed.title = @"1.0x";
            break;
        case 3:
            (void)[_controller setAnimationWithSpeed:2.0f];
            _btnSpeed.title = @"2.0x";
            break;
        default:
            break;
    }
}

- (IBAction)audioPlayPause:(UIBarButtonItem *)sender {
    // 控制音频的播放与暂停
    if (!_player.isPlaying){
        (void)[_player play];
    }else{
        (void)[_player stop];
    }
}

// 保存 ARSCNView 画面
- (IBAction)captureTapped:(UIButton *)sender {
    UIImage * image = [_controller takeSnapShotWithAnimated:YES];
    if (image != nil){
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        self.lblIndicator.text = @"相片已保存到系统相册";
        
    }
}

- (IBAction)closeTapped:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)orientationChanged:(NSNotification *)notification{
   UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
   if (UIInterfaceOrientationIsLandscape(orient))
   {
       [_btnCap1 setHidden:YES];
       [_btnCap2 setHidden:NO];
   }else{
       [_btnCap1 setHidden:NO];
       [_btnCap2 setHidden:YES];
   }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];

    // 启动 AR 会话
    [_controller run];
    printf("test\n");
    
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    (void)[_player stop];
    [_controller pauseSession];
}


@end
