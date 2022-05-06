//
//  ARImageRecognizer.h
//  ImageRecognizer
//
//  Created by Plex on 2018/12/26.
//  Copyright © 2018 Dgene. All rights reserved.
//

#ifndef ARImageRecognizer_h
#define ARImageRecognizer_h

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "ARImageRecognizerDelegate.h"


@interface ARImageRecognizer : NSObject


//@property (weak,nonatomic) GLKViewController * controller;
@property (weak,nonatomic) id delegate;


- (instancetype) initWith: (GLKViewController *) controller;
- (void) resetRenderer;
- (void) initEngine;
- (void) startDetect;
- (void) stopDetect;
- (void) setOrientation: (UIInterfaceOrientation) orientation;
- (void) resize:(CGRect)bound orientation:(UIInterfaceOrientation)orientation;
+ (void) onPause;
+ (void) onResume;
@end


#endif /* ARImageRecognizer_h */
