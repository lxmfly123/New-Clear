//
// Created by FLY.lxm on 2016.9.20.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LXMAnimationBlock)(BOOL);

@interface LXMAnimationQueue : NSObject

@property (copy) LXMAnimationBlock (^blockCompletion)(void);
@property (copy) LXMAnimationBlock queueCompletion;

- (void)addAnimations:(LXMAnimationBlock)animation1, ... NS_REQUIRES_NIL_TERMINATION;
- (void)clearQueue;

- (void)play;

@end