//
//  ARImageRecognizer.m
//  ImageRecognizer
//
//  Created by Plex on 2018/12/26.
//  Copyright © 2018 Dgene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <easyar/engine.oc.h>


#import "OpenGLView.h"
#import "ARImageRecognizer.h"

@interface ARImageRecognizer()
    @property (retain,nonatomic) OpenGLView * glView;

@end

ARImageRecognizer * sharedRecognizer = nil;

@implementation ARImageRecognizer


// App 的 Key 和云识别的 Key 都在这里更换
NSString * key = @"";
NSString * cloud_server_address = @"cn1.crs.easyar.com:8080";
NSString * cloud_key = @"a072e799bf2806fc633dcccda22e538b";
NSString * cloud_secret = @"1Ed8RFnxejZ7pgxtELKOeKkqlXlIdpuIiHkpXE2i0EpJEhowGPFZtIMxcP4OAa40SKjWONZ5sIGFClSjHnK4CI7HHC8sPRooa5tTASal0GWKHfAhgOdflzjlKSeSCOkZ";

- (instancetype) initWith: (GLKViewController *) controller{
    _glView = [[OpenGLView alloc] initWithFrame:CGRectZero];
    _glView.backgroundColor = [UIColor redColor];
    controller.view = _glView;
    
    
//    [controller.view addSubview:_glView];
//    [controller.view bringSubviewToFront:_glView];
//    [inputView addSubview:_glView];
//    inputView = _glView;
    
    [self initEngine];
    sharedRecognizer = self;
    
    return self;
}

- (void) initEngine{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    if ([bundleIdentifier isEqualToString:@"com.dgene.ARDictionaryApp"]){
        // 这个是我们的测试 App
        key = @"O7jDKZ0rvXvG5Nuvee0CI38omeLRKPkEiWtbG4qxKDjWYUCMaIxkJVl4DOegIweXrrDrGAQNeG5moxGTAMQrn3mEp1flQaDjpkocjlBG7mLaaI0lQVjULkGT0gOGogZkgfaWmluNprHEFj4E86K812NdD5wEW7c2NYP5vBFl8DlMTHnD2qLczRqEjWW0NdcN4babpsTy";
    }else{
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
           /* Device is iPad */
            // 这个是甲方 iPad 版应用的 Key
            key = @"tJojnUGwqGweoixyF8Pbmzt9TAMhjPskjGVjShRPV5c8a3xu4qarSspPObd8rK75h1F31Nf9jFFfkwtjiT1cAY9MZ1Wg1MAJcV8W401qu8Dk3kyTsWybU7UzTGCT8NAf1ff6qNnMO9ZiAzrcEeEymIi3TVcQmnUvsNLwH01stgRwllgYo4UWC1QBNReCuh90JLtvrs9o";
        }else{
            // 这个是甲方 iPhone 版应用的 Key
            key = @"Efij7en5mqz0WnV02gKkduhiT2jDMldFB6K29EUIeJYwAwlAMgGmYpKTZMN7kdwzq1oJXNuEc6yuTALPfK6c9eLIbCgqNBKg14g6AMfeUmfk01S1l5KgTpCTfmT886fCAN1kUcqw83XmQwyfaIY88Olx7gVi2tNjfZScHFtX5kIGp5SCgZyib5A7F8H7YtMoHngi0mVF";
        }
    }
    
    if (![easyar_Engine initialize:key]) {
        NSLog(@"Initialization Failed.");
    }else{
        
    }
}


- (void) startDetect{
//    _controller.view = _glView;
    [_glView start];
}

- (void) stopDetect{
    @autoreleasepool {
        [_glView stop];
    }
}

- (void) dealloc{
    [EAGLContext setCurrentContext:_glView.context];
    ((GLKView *)_glView).context = nil; //设置视图的上下文属性为nil
    [EAGLContext setCurrentContext:nil]; //设置当前上下文的属性为nil
    _glView = nil;
}
- (void) resetRenderer{
    _glView.initialized = NO;
}

- (void) setOrientation: (UIInterfaceOrientation) orientation{
    [_glView setOrientation:orientation];
}

- (void) resize:(CGRect)bound orientation:(UIInterfaceOrientation)orientation{
    [_glView resize:bound orientation:orientation];
}

+(void) onPause{
    [easyar_Engine onPause];
}

+(void) onResume{
    [easyar_Engine onResume];
}


@end
