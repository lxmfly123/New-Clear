//
// Created by FLY.lxm on 2016.9.20.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LXMTableViewCell.h"


@interface LXMTableViewGestureRecognizerHelper : NSObject

// add
- (NSIndexPath *)addingRowIndexPathForGestureRecognizer:(UIGestureRecognizer *)recognizer; ///< 根据手势确定新增 todo 的 index path。
- (void)updateForPinchAdding:(UIPinchGestureRecognizer *)recognizer;
- (void)commitOrDiscardAddingRowAtIndexPath:(NSIndexPath *)indexPath;

// edit
- (CGFloat)horizontalPanOffset:(UIPanGestureRecognizer *)recognizer;
- (void)handleCommittedEditingState:(LXMTableViewCellEditingState)editingState forRowAtIndexPath:(NSIndexPath *)indexPath;

@end