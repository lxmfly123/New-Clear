//
// Created by FLY.lxm on 2016.9.19.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import "LXMTableViewHelper.h"
#import "LXMGlobalSettings.h"
#import "LXMTableViewState.h"
#import "LXMStrikeThroughText.h"
#import "LXMTodoList.h"
#import "LXMTodoItem.h"
#import "LXMAnimationQueue.h"
#import "LXMTableViewGestureRecognizer.h"
#import "UIColor+LXM.h"
#import "UITableView+LXM.h"
#import <pop/POP.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface LXMTableViewHelper ()

@property (nonatomic, weak) LXMGlobalSettings *globalSettings;
@property (nonatomic, weak) LXMTableViewState *tableViewState;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) LXMTableViewGestureRecognizer *tableViewGestureRecognizer;
@property (nonatomic, weak) LXMTableViewGestureRecognizerHelper *recognizerHelper;
@property (nonatomic, weak) LXMTodoList *list;
@property (nonatomic, strong) LXMAnimationQueue *animationQueue;

@end

@implementation LXMTableViewHelper

#pragma mark - getters

- (LXMGlobalSettings *)globalSettings {

  return [LXMGlobalSettings sharedInstance];
}

- (LXMTableViewState *)tableViewState {

  return [LXMTableViewState sharedInstance];
}

- (LXMTableViewGestureRecognizer *)tableViewGestureRecognizer {

  return self.tableViewState.tableViewGestureRecognizer;
}

- (UITableView *)tableView {

  return self.tableViewState.tableView;
}

- (LXMTableViewGestureRecognizerHelper *)recognizerHelper {

  return self.tableViewState.recognizerHelper;
}

- (LXMTodoList *)list {

  return self.tableViewState.list;
}

- (LXMAnimationQueue *)animationQueue {

  if (!_animationQueue) {
    _animationQueue = [LXMAnimationQueue new];
  }

  return _animationQueue;
}

#pragma mark - data

- (NSUInteger)todoItemIndexForIndexPath:(NSIndexPath *)indexPath {

  NSAssert(indexPath.section < 2, @"indexPath.section is Out Of Range");

  if (indexPath.section == 0) {
    return (NSUInteger)indexPath.row;
  } else {
    return (NSUInteger)(indexPath.row + self.list.numberOfUncompleted);
  }
}

- (LXMTodoItem *)todoItemForRowAtIndexPath:(NSIndexPath *)indexPath {

  NSUInteger index = [self todoItemIndexForIndexPath:indexPath];
  return self.list.todoItems[index];
}

- (NSIndexPath *)movingDestinationIndexPathForCheckedRowAtIndexPath:(NSIndexPath *)indexPath {

  if ([self todoItemForRowAtIndexPath:indexPath].isCompleted) {
    return [NSIndexPath indexPathForRow:self.list.numberOfUncompleted inSection:0];
  } else {
    return [NSIndexPath indexPathForRow:0 inSection:1];
  }
}


#pragma mark - appearances

- (UIColor *)colorForRowAtIndexPath:(NSIndexPath *)indexPath ignoreTodoItem:(BOOL)shouldIgnore {

  UIColor *backgroundColor = nil;

  LXMTodoItem *todoItem = [self todoItemForRowAtIndexPath:indexPath];
  backgroundColor = [self.globalSettings.itemBaseColor lxm_colorWithHueOffset:self.globalSettings.rowColorHueOffset * ([self.list.todoItems indexOfObject:todoItem] + 1) / self.list.todoItems.count];

  if (!shouldIgnore && [self todoItemForRowAtIndexPath:indexPath].isCompleted) {
    backgroundColor = [UIColor blackColor];
  }

  return backgroundColor;
}

- (UIColor *)colorForRowAtIndexPath:(NSIndexPath *)indexPath {

  return [self colorForRowAtIndexPath:indexPath ignoreTodoItem:NO];
}

- (UIColor *)textColorForRowAtIndexPath:(NSIndexPath *)indexPath {

  return [self todoItemForRowAtIndexPath:indexPath].isCompleted ? [UIColor grayColor] : [UIColor whiteColor];
}

#pragma mark - animations

- (void)acceptAddingRowAtIndexPath:(NSIndexPath *)indexPath {

  @weakify(self);

  self.animationQueue.queueCompletion = ^(BOOL finished) {
    @strongify(self);
    self.tableViewState.addingProgress = 0;
    self.tableViewState.addingRowIndexPath = nil;
    [self.tableViewState.tableViewGestureRecognizer.operationState switchToOperationState:self.tableViewState.tableViewGestureRecognizer.operationStateModifying];
  };

  [self recoverRowAtIndexPath:indexPath forAdding:YES];
  [self.animationQueue play];
}

- (void)rejectAddingRowAtIndexPath:(NSIndexPath *)indexPath {

  @weakify(self);

  self.animationQueue.queueCompletion = ^(BOOL finished) {
    @strongify(self);
    self.tableViewState.addingProgress = 0;
    self.tableViewState.addingRowIndexPath = nil;
    [self.tableViewState.tableView reloadData];
    [self.tableViewState.tableViewGestureRecognizer.operationState switchToOperationState:self.tableViewState.tableViewGestureRecognizer.operationStateNormal];
  };

  [self recoverRowAtIndexPath:indexPath forAdding:NO];
  [self.animationQueue play];
}

- (void)recoverRowAtIndexPath:(NSIndexPath *)indexPath forAdding:(BOOL)shouldAdd {

  // recover content offset

  POPAnimatableProperty *contentOffset = [POPAnimatableProperty propertyWithName:kPOPScrollViewContentOffset];

  POPBasicAnimation *recoverContentOffset = [POPBasicAnimation easeInEaseOutAnimation];
  recoverContentOffset.property = contentOffset;
  recoverContentOffset.fromValue = [NSValue valueWithCGPoint:self.tableView.contentOffset];
  recoverContentOffset.toValue = [NSValue valueWithCGPoint:self.tableViewState.lastContentOffset];
  recoverContentOffset.duration = LXMTableViewRowAnimationDurationNormal;

  // recover content inset

//  POPAnimatableProperty *contentInset = [POPAnimatableProperty propertyWithName:kPOPScrollViewContentInset];
//
//  POPBasicAnimation *recoverContentInset = [POPBasicAnimation easeInEaseOutAnimation];
//  recoverContentInset.property = contentInset;
//  recoverContentInset.fromValue = [NSValue valueWithUIEdgeInsets:self.tableView.contentInset];
//  recoverContentInset.toValue = [NSValue valueWithUIEdgeInsets:self.tableViewState.lastContentInset];
//  recoverContentInset.duration = LXMTableViewRowAnimationDurationNormal;

  // recover row height

  POPAnimatableProperty *rowHeightProperty = [POPAnimatableProperty propertyWithName:@"LXMRowHeight" initializer:^(POPMutableAnimatableProperty *prop) {
    prop.writeBlock = ^(id obj, const CGFloat values[]) {
      [self.tableView beginUpdates];
      self.tableViewState.addingProgress = values[0];
      [self.tableView endUpdates];
    };
  }];

  POPBasicAnimation *recoverRowHeight = [POPBasicAnimation easeInEaseOutAnimation];
  recoverRowHeight.property = rowHeightProperty;
  recoverRowHeight.fromValue = @(self.tableViewState.addingProgress);
  recoverRowHeight.toValue = @(shouldAdd ? 1 : 0);
  recoverRowHeight.duration = LXMTableViewRowAnimationDurationNormal;
  recoverRowHeight.completionBlock = ^(POPAnimation *animation, BOOL finished) {
    self.tableView.contentInset = self.tableViewState.lastContentInset;
    [self recoverTodoItemForRowAtIndexPath:indexPath forAdding:shouldAdd];
    self.animationQueue.blockCompletion()(YES);
  };

  // run all animations at once

  LXMAnimationBlock recoverAll = ^(BOOL finished) {
    recoverContentOffset.beginTime = CACurrentMediaTime();
    [self.tableView pop_addAnimation:recoverContentOffset forKey:@"LXMRecoverOffset"];

//    recoverContentInset.beginTime = CACurrentMediaTime();
//    NSLog(@"%f", recoverContentInset.beginTime);
//    [self.tableView pop_addAnimation:recoverContentInset forKey:@"LXMRecoverInset"];

    recoverRowHeight.beginTime = CACurrentMediaTime();
    [self pop_addAnimation:recoverRowHeight forKey:@"LXMRecoverRowHeight"];

//    // completion (play next LXMAnimationBlock block)
//    NSTimeInterval timeErrorFix = 0.05; ///< Add this to time param of dispatch_after to avoid a jump in the view appears in a chance
//    dispatch_time_t duration = dispatch_time(DISPATCH_TIME_NOW, (int64_t)((timeErrorFix + LXMTableViewRowAnimationDurationNormal) * NSEC_PER_SEC));
//    dispatch_after(duration, dispatch_get_main_queue(), ^{

//    });
  };

  [self.animationQueue addAnimations:recoverAll, nil];
}

- (void)bounceRowAtIndexPath:(NSIndexPath *)indexPath check:(BOOL)shouldCheck{

  [self.tableViewState.bouncingRowIndexPaths addObject:indexPath];

  LXMTableViewCell *bouncingCell = [self.tableView cellForRowAtIndexPath:indexPath];


//  if (!shouldCheck) {
//    [bouncingCell.strikeThroughText setNeedsLayout];
//  }

//  [UIView animateWithDuration:1 animations:^{
//    bouncingCell.actualContentView.frame = bouncingCell.bounds;
//  } completion:^(BOOL finished) {
//    NSLog(@"bounce finished");
//    [self.tableViewState.bouncingRowIndexPaths removeObjectAtIndex:0];
//    bouncingCell.editingState = LXMTableViewCellEditingStateNormal;
//    if (shouldCheck) {
//      [self moveRowAtIndexPath:indexPath toIndexPath:[self movingDestinationIndexPathForCheckedRowAtIndexPath:indexPath]];
//    } else {
//      if ([self.tableViewState.uneditableRowIndexPaths count] == 0) {
//        [self.tableView reloadData];
//        [self.tableViewGestureRecognizer.operationState switchToOperationState:self.tableViewGestureRecognizer.operationStateNormal];
//      }
//    }
//  }];

  if (!shouldCheck) {
    [bouncingCell.strikeThroughText setNeedsLayout];
  }

  POPSpringAnimation *bounceRow = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
  bounceRow.fromValue = [NSValue valueWithCGRect:bouncingCell.actualContentView.frame];
  bounceRow.toValue = [NSValue valueWithCGRect:bouncingCell.contentView.bounds];
  bounceRow.springBounciness = 20;
  bounceRow.springSpeed = 100;
  bounceRow.beginTime = CACurrentMediaTime();
  bounceRow.completionBlock = ^(POPAnimation *animation, BOOL finished) {
    bouncingCell.actualContentView.frame = bouncingCell.actualContentView.bounds;
    [self.tableViewState.bouncingRowIndexPaths removeObjectAtIndex:0];
    bouncingCell.editingState = LXMTableViewCellEditingStateNormal;
    if (shouldCheck) {
      [self moveRowAtIndexPath:indexPath toIndexPath:[self movingDestinationIndexPathForCheckedRowAtIndexPath:indexPath]];
    } else {
      if ([self.tableViewState.uneditableRowIndexPaths count] == 0) {
        [self.tableView reloadData];
        [self.tableViewGestureRecognizer.operationState switchToOperationState:self.tableViewGestureRecognizer.operationStateNormal];
      }
    }
  };

  [bouncingCell.actualContentView pop_addAnimation:bounceRow forKey:@"LXMBounceRow"];
}

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath {

  LXMTableViewCell *willDeletedCell = [self.tableView cellForRowAtIndexPath:indexPath];

  POPBasicAnimation *moveLeftToDeleteRow = [POPBasicAnimation easeInAnimation];
  moveLeftToDeleteRow.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
  moveLeftToDeleteRow.fromValue = [NSValue valueWithCGRect:willDeletedCell.contentView.frame];
  moveLeftToDeleteRow.toValue = [NSValue valueWithCGRect:CGRectOffset(willDeletedCell.contentView.frame, -willDeletedCell.bounds.size.width, 0)];
  moveLeftToDeleteRow.duration = LXMTableViewRowAnimationDurationShort;
  moveLeftToDeleteRow.completionBlock = ^(POPAnimation *animation, BOOL finished) {
    willDeletedCell.editingState = LXMTableViewCellEditingStateNormal;
    [self.tableView lxm_updateTableViewWithDuration:LXMTableViewRowAnimationDurationShort updates:^{
      [self.tableViewGestureRecognizer.delegate gestureRecognizer:self.tableViewGestureRecognizer needsDiscardRowAtIndexPath:indexPath];
      [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } completion:^{
      willDeletedCell.contentView.frame = willDeletedCell.contentView.bounds;
      willDeletedCell.actualContentView.frame = willDeletedCell.contentView.bounds;
      [self.tableView reloadData];
      [self.tableViewGestureRecognizer.operationState switchToOperationState:self.tableViewGestureRecognizer.operationStateNormal];
    }];
  };

  [willDeletedCell.contentView pop_addAnimation:moveLeftToDeleteRow forKey:@"LXMDeleteRow"];
}

- (LXMTableViewCell *)p_creatSnapshotCellForCell:(LXMTableViewCell *)sourceCell {

  LXMTableViewCell *snapshotCell = [[LXMTableViewCell alloc] initWithReuseIdentifier:@"Snapshot"];

  LXMTodoItem *snapshotTodo = [LXMTodoItem todoItemWithText:sourceCell.todoItem.text];
  snapshotTodo.isCompleted = sourceCell.todoItem.isCompleted;

  snapshotCell.frame = sourceCell.frame;
  snapshotCell.actualContentView.frame = snapshotCell.bounds;
  snapshotCell.editingState = LXMTableViewCellEditingStateWillCheck;
  snapshotCell.todoItem = snapshotTodo;
  snapshotCell.actualContentView.backgroundColor = sourceCell.actualContentView.backgroundColor;
  snapshotCell.strikeThroughText.textColor = sourceCell.strikeThroughText.textColor;

  return snapshotCell;
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {

  [self.tableViewState.floatingRowIndexPaths addObject:newIndexPath];

  LXMTableViewCell *willMovedCell = [self.tableView cellForRowAtIndexPath:indexPath];
  NSInteger movingDirection = newIndexPath.section == 1 ? 1 : -1;
  CGFloat realVerticalOffset = ((NSInteger)[self todoItemIndexForIndexPath:newIndexPath] - (NSInteger)[self todoItemIndexForIndexPath:indexPath] - (movingDirection == 1 ? 1 : 0)) * self.tableView.rowHeight;
  BOOL newRowIsVisible = YES;

  NSTimeInterval animationDuration = 0.25;

  if (movingDirection == 1) {
    newRowIsVisible = (self.tableView.contentOffset.y + self.tableView.bounds.size.height) - (([self todoItemIndexForIndexPath:newIndexPath] - 1) * self.tableView.rowHeight) > 0;
  } else if (movingDirection == -1) {
    newRowIsVisible = self.tableView.contentOffset.y - ([self todoItemIndexForIndexPath:newIndexPath] + 1) * self.tableView.rowHeight < 0;
  }

  if (!newRowIsVisible) {
//    CGFloat verticalOffset = movingDirection == 1 ?
//    ABS(self.tableView.bounds.size.height - (willMovedCell.frame.origin.y - self.tableView.contentOffset.y)) :
//    -ABS(willMovedCell.frame.origin.y - self.tableView.contentOffset.y + self.tableView.rowHeight);

    CGFloat verticalOffset = realVerticalOffset;

    LXMTableViewCell *snapshotCell = [self p_creatSnapshotCellForCell:willMovedCell];
    [self.tableView addSubview:snapshotCell];

    // move snapshot
    POPBasicAnimation *moveSnapshotCell = [POPBasicAnimation easeInEaseOutAnimation];
    moveSnapshotCell.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    moveSnapshotCell.duration = animationDuration;
    moveSnapshotCell.fromValue = [NSValue valueWithCGRect:snapshotCell.frame];
    moveSnapshotCell.toValue = [NSValue valueWithCGRect:CGRectOffset(snapshotCell.frame, 0, verticalOffset)];
    [snapshotCell pop_addAnimation:moveSnapshotCell forKey:@"LXMMoveSnapshot"];

    // delete row
    willMovedCell.contentView.alpha = 0;
    LXMTodoItem *todoItem = [self todoItemForRowAtIndexPath:indexPath];
    [self.tableView lxm_updateTableViewWithDuration:animationDuration updates:^{
      [self.list.todoItems removeObjectAtIndex:[self todoItemIndexForIndexPath:indexPath]];
      [self.list.todoItems insertObject:todoItem atIndex:[self todoItemIndexForIndexPath:newIndexPath]];
      [todoItem toggleCompleted];
//      [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
      [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    } completion:^{
//      [self.tableViewState.floatingRowIndexPaths removeObjectAtIndex:0];
//      willMovedCell.contentView.alpha = 1;
//      if (self.tableViewState.uneditableRowIndexPaths.count == 0) {
//        [self.tableView reloadData];
//        [self.tableViewGestureRecognizer.operationState switchToOperationState:self.tableViewGestureRecognizer.operationStateNormal];
//      }
    }];

    // insert row
//    [self.tableView lxm_updateTableViewWithDuration:animationDuration updates:^{
//      [self.list.todoItems insertObject:todoItem atIndex:[self todoItemIndexForIndexPath:newIndexPath]];
//      [todoItem toggleCompleted];
//      [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//    } completion:nil];

    // change background color to it should be
    POPBasicAnimation *changeBackgroundColor = [POPBasicAnimation linearAnimation];
    changeBackgroundColor.property = [POPAnimatableProperty propertyWithName:kPOPViewBackgroundColor];
    changeBackgroundColor.duration = animationDuration;
    changeBackgroundColor.fromValue = willMovedCell.actualContentView.backgroundColor;
    changeBackgroundColor.toValue = [self colorForRowAtIndexPath:newIndexPath];
    changeBackgroundColor.beginTime = CACurrentMediaTime();
    [snapshotCell.actualContentView pop_addAnimation:changeBackgroundColor forKey:@"LXMChangeCellBackgroundColor"];

    // change text color to it should be
    POPBasicAnimation *changeTextColor = [POPBasicAnimation linearAnimation];
    changeTextColor.property = [POPAnimatableProperty propertyWithName:@"ChangeTextColor" initializer:^(POPMutableAnimatableProperty *prop) {
      prop.writeBlock = ^(LXMStrikeThroughText *obj, const CGFloat values[]) {
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGColorRef color = CGColorCreate(space, values);
        CGColorSpaceRelease(space);
        obj.textColor = [UIColor colorWithCGColor:color];
        obj.strikeThroughLine.backgroundColor = color;
      };
    }];
    changeTextColor.duration = animationDuration;
    changeTextColor.fromValue = willMovedCell.strikeThroughText.textColor;
    changeTextColor.toValue = [self textColorForRowAtIndexPath:newIndexPath];
    changeTextColor.beginTime = CACurrentMediaTime();
    changeBackgroundColor.completionBlock = ^(POPAnimation *animation, BOOL finished) {
      // delete row
      willMovedCell.alpha = 0;
      [self.tableViewState.floatingRowIndexPaths removeObjectAtIndex:0];
      if (self.tableViewState.uneditableRowIndexPaths.count == 0) {
        [self.tableView reloadData];
        [self.tableViewGestureRecognizer.operationState switchToOperationState:self.tableViewGestureRecognizer.operationStateNormal];
      }

      // move snap shot
      [snapshotCell removeFromSuperview];

      willMovedCell.alpha = 1;
      willMovedCell.contentView.alpha = 1;
    };
    [snapshotCell.strikeThroughText pop_addAnimation:changeTextColor forKey:nil];


    // ------------

//    // 获取拖动 cell 的位图快照。
//    UIGraphicsBeginImageContextWithOptions(willMovedCell.bounds.size, NO, 0);
//    [willMovedCell.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *cellSnapshot = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    // 将位图快照作为 UIImageView 覆盖显示在拖动 cell 的位置上。
//    UIImageView *snapshotView = [self.tableView viewWithTag:10086];
//    if (!snapshotView) {
//      snapshotView = [[UIImageView alloc] initWithImage:cellSnapshot];
//      snapshotView.tag = 10086;
//      [self.tableView addSubview:snapshotView];
//      [self.tableView bringSubviewToFront:snapshotView];
//      snapshotView.frame = [self.tableView rectForRowAtIndexPath:indexPath];
//    }
//
//    POPBasicAnimation *moveSnapshot = [POPBasicAnimation easeInEaseOutAnimation];
//    moveSnapshot.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
//    moveSnapshot.duration = /*LXMTableViewRowAnimationDurationNormal*/5;
//    moveSnapshot.fromValue = [NSValue valueWithCGRect:snapshotView.frame];
//    moveSnapshot.toValue = [NSValue valueWithCGRect:CGRectOffset(snapshotView.frame, 0, verticalOffset)];
//    moveSnapshot.completionBlock = ^(POPAnimation *animation, BOOL finished) {
//      [snapshotView removeFromSuperview];
//    };
//
//    [snapshotView pop_addAnimation:moveSnapshot forKey:@"LXMMoveSnapshot"];
//
//    // update data and play original sdk animation
//    willMovedCell.contentView.alpha = 0;
//    LXMTodoItem *todoItem = [self todoItemForRowAtIndexPath:indexPath];
//    [self.tableView lxm_updateTableViewWithDuration:/*LXMTableViewRowAnimationDurationNormal*/5 updates:^{
//      [self.list.todoItems removeObjectAtIndex:[self todoItemIndexForIndexPath:indexPath]];
////      [self.list.todoItems insertObject:todoItem atIndex:[self todoItemIndexForIndexPath:newIndexPath]];
////      [todoItem toggleCompleted];
//
////      [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
//      [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    } completion:^{
//      [self.tableViewState.floatingRowIndexPaths removeObjectAtIndex:0];
//      willMovedCell.contentView.alpha = 1;
//      if (self.tableViewState.uneditableRowIndexPaths.count == 0) {
//        [self.tableView reloadData];
//        [self.tableViewGestureRecognizer.operationState switchToOperationState:self.tableViewGestureRecognizer.operationStateNormal];
//      }
//    }];
//    [self.tableView lxm_updateTableViewWithDuration:5 updates:^{
//      [self.list.todoItems insertObject:todoItem atIndex:[self todoItemIndexForIndexPath:newIndexPath]];
//      [todoItem toggleCompleted];
//      [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//    } completion:^{
//      [self.tableView cellForRowAtIndexPath:newIndexPath].contentView.alpha = 1;
//    }];
//    LXMTableViewCell *newCell = [self.tableView cellForRowAtIndexPath:newIndexPath];
//    newCell.contentView.alpha = 0;
  } else {
    [self.tableView lxm_updateTableViewWithDuration:LXMTableViewRowAnimationDurationNormal updates:^{
      LXMTodoItem *todoItem = [self todoItemForRowAtIndexPath:indexPath];
      [self.list.todoItems removeObjectAtIndex:[self todoItemIndexForIndexPath:indexPath]];
      [self.list.todoItems insertObject:todoItem atIndex:[self todoItemIndexForIndexPath:newIndexPath]];
      [todoItem toggleCompleted];
      [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    } completion:^{
      [self.tableViewState.floatingRowIndexPaths removeObjectAtIndex:0];
      if (self.tableViewState.uneditableRowIndexPaths.count == 0) {
        [self.tableView reloadData];
        [self.tableViewGestureRecognizer.operationState switchToOperationState:self.tableViewGestureRecognizer.operationStateNormal];
      }
    }];

    // change background color to it should be
    POPBasicAnimation *changeBackgroundColor = [POPBasicAnimation linearAnimation];
    changeBackgroundColor.property = [POPAnimatableProperty propertyWithName:kPOPViewBackgroundColor];
    changeBackgroundColor.duration = LXMTableViewRowAnimationDurationNormal;
    changeBackgroundColor.fromValue = willMovedCell.actualContentView.backgroundColor;
    changeBackgroundColor.toValue = [self colorForRowAtIndexPath:newIndexPath];
    changeBackgroundColor.beginTime = CACurrentMediaTime();
    [willMovedCell.actualContentView pop_addAnimation:changeBackgroundColor forKey:@"LXMChangeCellBackgroundColor"];

    // change text color to it should be
    POPBasicAnimation *changeTextColor = [POPBasicAnimation linearAnimation];
    changeTextColor.property = [POPAnimatableProperty propertyWithName:@"ChangeTextColor" initializer:^(POPMutableAnimatableProperty *prop) {
      prop.writeBlock = ^(LXMStrikeThroughText *obj, const CGFloat values[]) {
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGColorRef color = CGColorCreate(space, values);
        CGColorSpaceRelease(space);
        obj.textColor = [UIColor colorWithCGColor:color];
        obj.strikeThroughLine.backgroundColor = color;
      };
    }];
    changeTextColor.duration = LXMTableViewRowAnimationDurationNormal;
    changeTextColor.fromValue = willMovedCell.strikeThroughText.textColor;
    changeTextColor.toValue = [self textColorForRowAtIndexPath:newIndexPath];
    changeTextColor.beginTime = CACurrentMediaTime();
    [willMovedCell.strikeThroughText pop_addAnimation:changeTextColor forKey:nil];
  }
}


#pragma mark - animation helper

- (void)assignRowAtIndexPathAsFirstResponder:(NSIndexPath *)indexPath {

  if (![self todoItemForRowAtIndexPath:indexPath].isCompleted) {
    LXMTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.strikeThroughText becomeFirstResponder];
  }
}

- (void)recoverTodoItemForRowAtIndexPath:(NSIndexPath *)indexPath forAdding:(BOOL)shouldAdd {

  [UIView performWithoutAnimation:^{
    if (shouldAdd) {
      [self.tableViewGestureRecognizer.delegate gestureRecognizer:self.tableViewGestureRecognizer
                                        needsCommitRowAtIndexPath:indexPath];
      [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                            withRowAnimation:UITableViewRowAnimationNone];
    } else {
      [self.tableViewGestureRecognizer.delegate gestureRecognizer:self.tableViewGestureRecognizer
                                       needsDiscardRowAtIndexPath:indexPath];
      [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                            withRowAnimation:UITableViewRowAnimationNone];
    }
  }];

  if (shouldAdd) {
    [self assignRowAtIndexPathAsFirstResponder:indexPath];
  }
}

#pragma mark - offset and inset

- (void)saveContentOffsetAndInset {

  self.tableViewState.lastContentOffset = self.tableView.contentOffset;
  self.tableViewState.lastContentInset = self.tableView.contentInset;
}

- (void)recoverContentOffsetAndInset {

  self.tableView.contentOffset = self.tableViewState.lastContentOffset;
  self.tableView.contentInset = self.tableViewState.lastContentInset;

  self.tableViewState.lastContentOffset = CGPointZero;
  self.tableViewState.lastContentInset = UIEdgeInsetsZero;
}



@end