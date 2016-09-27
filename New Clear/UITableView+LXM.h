//
// Created by FLY.lxm on 2016.9.21.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UITableView (LXM)

- (void)lxm_updateTableViewWithDuration:(NSTimeInterval)duration updates:(void (^__nullable) ())updates completion:(void (^__nullable) ())completion;

NS_ASSUME_NONNULL_BEGIN

//- (LXMTableViewGestureRecognizer *)lxm_enableGestureTableViewWithDelegate:(id)delegate;
- (void)lxm_reloadVisibleRowsExceptIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

NS_ASSUME_NONNULL_END

@end