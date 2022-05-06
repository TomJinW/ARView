//
//  ARImageRecognizerDelegate.h
//  ImageRecognizer
//
//  Created by Plex on 2018/12/26.
//  Copyright © 2018 Dgene. All rights reserved.
//

#ifndef ARImageRecognizerDelegate_h
#define ARImageRecognizerDelegate_h

@protocol ARImageRecognizerDelegate <NSObject>

@required
- (void)onSuccess: (NSArray<NSString *> *) data;

@end

#endif /* ARImageRecognizerDelegate_h */
