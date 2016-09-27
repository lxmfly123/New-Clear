//
// Created by FLY.lxm on 2016.9.21.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import "UITableView+LXM.h"


@implementation UITableView (LXM)

- (void)lxm_updateTableViewWithDuration:(NSTimeInterval)duration updates:(void (^__nullable) ())updates completion:(void (^__nullable) ())completion {

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:duration];
  [CATransaction begin];
  [CATransaction setCompletionBlock:completion];
  [self beginUpdates];
  if (updates) updates();
  [self endUpdates];
  [CATransaction commit];
  [UIView commitAnimations];
}

- (void)lxm_reloadVisibleRowsExceptIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {

  NSMutableArray *visibleIndexPaths = [self.indexPathsForVisibleRows mutableCopy];
  for (NSIndexPath *indexPath in indexPaths) {
    [visibleIndexPaths removeObject:indexPath];
  }
  [UIView performWithoutAnimation:^{
    [self reloadRowsAtIndexPaths:visibleIndexPaths withRowAnimation:UITableViewRowAnimationNone];
  }];
}

@end