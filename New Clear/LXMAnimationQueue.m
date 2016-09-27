//
// Created by FLY.lxm on 2016.9.20.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import "LXMAnimationQueue.h"

@interface LXMAnimationQueue ()

@property (nonatomic, strong) NSMutableArray<LXMAnimationBlock> *animations;

@end

@implementation LXMAnimationQueue

- (instancetype)init {

  if (self = [super init]) {
    self.animations = [[NSMutableArray alloc] initWithCapacity:5];
  }

  return self;
}

- (void)addAnimations:(LXMAnimationBlock)animation1, ... {

  [self.animations addObject:animation1];

  va_list animations;
  va_start(animations, animation1);
  [self continueAddingAnimations:animations];
  va_end(animations);
}

- (void)continueAddingAnimations:(va_list)animations {

  LXMAnimationBlock animation;
  while ((animation = va_arg(animations, LXMAnimationBlock))) {
    [self.animations addObject:animation];
  }
}

- (void)clearQueue {

  [self.animations removeAllObjects];
}

- (void)play {

  self.blockCompletion()(YES);
}

#pragma mark - getters

- (LXMAnimationBlock (^)(void))blockCompletion {

  return ^LXMAnimationBlock {
    if (self.animations.count > 0) {
      LXMAnimationBlock block = self.animations[0];
      [self.animations removeObjectAtIndex:0];
      return block;
    } else {
      return self.queueCompletion;
    }
  };
}

- (LXMAnimationBlock)queueCompletion {

  if (!_queueCompletion) {
    return ^(BOOL finished) {
      NSLog(@"Queue finished. ");
    };
  } else {
    return _queueCompletion;
  }
}

@end