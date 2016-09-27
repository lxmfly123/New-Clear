//
// Created by FLY.lxm on 2016.9.20.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import "LXMTableViewOperationState.h"
#import "LXMTableViewState.h"
#import "LXMGlobalSettings.h"
#import "LXMTableViewGestureRecognizer.h"
#import "LXMTableViewGestureRecognizerHelper.h"
#import "LXMTableViewHelper.h"
#import "LXMTodoItem.h"
#import "LXMTodoList.h"
#import "LXMStrikeThroughText.h"

NSString* assertFailure(NSString *state, NSString *gesture, NSString *gestureState) {

  return [NSString stringWithFormat:@"operation state: %@, recognizer: %@, recognizer state: %@", state, gesture, gestureState];
}

/// Normal

@interface LXMTableViewOperationStateNormal : LXMTableViewOperationState <LXMTableViewOperationState>
@end

@implementation LXMTableViewOperationStateNormal

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {

  if (recognizer.state == UIGestureRecognizerStateBegan) {
    self.tableViewState.addingRowIndexPath = [self.tableViewGestureRecognizer.recognizerHelper addingRowIndexPathForGestureRecognizer:recognizer];
    self.tableViewState.addingProgress = 0;
    NSAssert(self.tableViewState.addingRowIndexPath != nil, @"addingRowIndexPath 不能为 nil。");

    [self.tableViewState.tableViewHelper saveContentOffsetAndInset];
    self.tableView.contentInset =
      UIEdgeInsetsMake(self.tableView.contentInset.top + self.tableView.bounds.size.height,
        self.tableView.contentInset.left,
        self.tableView.contentInset.bottom + self.tableView.bounds.size.height,
        self.tableView.contentInset.right);

    [UIView performWithoutAnimation:^{
      [self.tableViewGestureRecognizer.delegate gestureRecognizer:self.tableViewGestureRecognizer
                                           needsAddRowAtIndexPath:self.tableViewState.addingRowIndexPath
                                                            usage:LXMTodoItemUsagePinchAdded];
      [self.tableView insertRowsAtIndexPaths:@[self.tableViewState.addingRowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];

    [self switchToOperationState:self.tableViewGestureRecognizer.operationStatePinchAdding];
  } else if (recognizer.state == UIGestureRecognizerStateChanged) {
    NSAssert(NO, assertFailure(@"normal", @"pinch", @"changed"));
  } else if (recognizer.state == UIGestureRecognizerStateEnded) {
    NSAssert(NO, assertFailure(@"normal", @"pinch", @"ended"));
  }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {

  if (recognizer.state == UIGestureRecognizerStateBegan) {
    self.tableViewState.panningRowIndexPath = [self.tableView indexPathForRowAtPoint:[recognizer locationInView:self.tableView]];
  } else if (recognizer.state == UIGestureRecognizerStateChanged) {
    CGFloat horizontalOffset = [self.tableViewGestureRecognizer.recognizerHelper horizontalPanOffset:recognizer];

    LXMTableViewCell *panningCell = self.tableViewState.panningCell;
    panningCell.actualContentView.frame = CGRectOffset(panningCell.contentView.bounds, horizontalOffset, 0);
    panningCell.strikeThroughText.isStrikeThrough = YES;

    if (horizontalOffset > [LXMGlobalSettings sharedInstance].editCommitTriggerWidth) {
//      if (panningCell.editingState != LXMTableViewCellEditingStateWillCheck) {
        NSLog(@"will check");
        panningCell.editingState = LXMTableViewCellEditingStateWillCheck;
//      }
    } else if (horizontalOffset < -[LXMGlobalSettings sharedInstance].editCommitTriggerWidth) {
//      if (panningCell.editingState != LXMTableViewCellEditingStateWillDelete) {
        NSLog(@"will delete");
        panningCell.editingState = LXMTableViewCellEditingStateWillDelete;
//      }
    } else {
//      if (panningCell.editingState != LXMTableViewCellEditingStateNormal) {
        NSLog(@"normal");
        panningCell.editingState = LXMTableViewCellEditingStateNormal;
//      }
    }

    [panningCell setNeedsLayout];

    [self.tableViewGestureRecognizer.delegate gestureRecognizer:self.tableViewGestureRecognizer
                                           didEnterEditingState:self.tableViewState.panningCell.editingState
                                              forRowAtIndexPath:self.tableViewState.panningRowIndexPath];

//    LXMTableViewOperationState *nextOperationState = horizontalOffset > 0 ? self.tableViewGestureRecognizer.operationStateChecking : self.tableViewGestureRecognizer.operationStateDeleting;
//    [self switchToOperationState:nextOperationState];
  } else if (recognizer.state == UIGestureRecognizerStateEnded) {
    NSLog(@"**********************");

    if (self.tableViewState.panningCell.editingState == LXMTableViewCellEditingStateNone) {
      [self switchToOperationState:self.tableViewGestureRecognizer.operationStateNormal];
      return;
    }

    // will check or delete
    if (self.tableViewState.panningCell.editingState == LXMTableViewCellEditingStateWillCheck &&
        [self.tableViewState.tableViewGestureRecognizer.delegate respondsToSelector:@selector(gestureRecognizer:willCheckRowAtIndexPath:)]) {
      [self.tableViewState.tableViewGestureRecognizer.delegate gestureRecognizer:self.tableViewState.tableViewGestureRecognizer willCheckRowAtIndexPath:self.tableViewState.panningRowIndexPath];
    } else if (self.tableViewState.panningCell.editingState == LXMTableViewCellEditingStateWillDelete &&
               [self.tableViewState.tableViewGestureRecognizer.delegate respondsToSelector:@selector(gestureRecognizer:willDeleteRowAtIndexPath:)]) {
      [self.tableViewState.tableViewGestureRecognizer.delegate gestureRecognizer:self.tableViewState.tableViewGestureRecognizer willDeleteRowAtIndexPath:self.tableViewState.panningRowIndexPath];
    }

    // commit check or delete
//    [self.tableViewState.recognizerHelper handleCommittedEditingState:self.tableViewState.panningCell.editingState forRowAtIndexPath:self.tableViewState.panningRowIndexPath];
    [self.tableViewGestureRecognizer.delegate gestureRecognizer:self.tableViewGestureRecognizer
                                        needsCommitEditingState:self.tableViewState.panningCell.editingState
                                              forRowAtIndexPath:self.tableViewState.panningRowIndexPath];
    self.tableViewGestureRecognizer.operationState = self.tableViewGestureRecognizer.operationStateProcessing;
//    self.tableViewGestureRecognizer.operationState =
//    self.tableViewState.panningCell.editingState == LXMTableViewCellEditingStateWillDelete ?
//    self.tableViewGestureRecognizer.operationStateRecovering :
//    self.tableViewGestureRecognizer.operationStateProcessing;
    self.tableViewState.panningCell.editingState = LXMTableViewCellEditingStateNone;
  } else if (recognizer.state == UIGestureRecognizerStateCancelled) {
    NSLog(@"canceled");
  }
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {

  if (recognizer.state == UIGestureRecognizerStateEnded) {
    CGPoint location = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    LXMTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    if ([cell isMemberOfClass:[LXMTableViewCell class]] && !cell.todoItem.isCompleted) {
      // 可以修改文字
      [cell.strikeThroughText becomeFirstResponder];
    } else {
      // 新建一个 todo
      [self.tableViewState.tableViewHelper saveContentOffsetAndInset];
      self.tableViewState.addingRowIndexPath = [self.tableViewState.recognizerHelper addingRowIndexPathForGestureRecognizer:recognizer];
      [LXMTableViewState sharedInstance].addingProgress = 0;
      [self.tableViewGestureRecognizer.delegate gestureRecognizer:self.tableViewGestureRecognizer
                                           needsAddRowAtIndexPath:self.tableViewState.addingRowIndexPath
                                                            usage:LXMTodoItemUsageTapAdded];
      [UIView performWithoutAnimation:^{
        [self.tableView insertRowsAtIndexPaths:@[self.tableViewState.addingRowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
      }];
      [self.tableViewState.tableViewHelper acceptAddingRowAtIndexPath:self.tableViewState.addingRowIndexPath];
    }

    [self switchToOperationState:self.tableViewGestureRecognizer.operationStateRecovering];
  }
}

- (void)handleScroll:(UITableView *)tableView {}

@end

/// Modifying

@interface LXMTableViewOperationStateModifying : LXMTableViewOperationState <LXMTableViewOperationState>
@end

@implementation LXMTableViewOperationStateModifying

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {}
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {}
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {

  if (recognizer.state == UIGestureRecognizerStateEnded &&
    [self.tableView indexPathForRowAtPoint:[recognizer locationInView:self.tableView]] != self.tableViewState.modifyingRowIndexPath) {
    [self.tableView endEditing:YES];
  }
}

- (void)handleScroll:(UITableView *)tableView {}

@end

/// Checking

@interface LXMTableViewOperationStateChecking : LXMTableViewOperationState <LXMTableViewOperationState>
@end

@implementation LXMTableViewOperationStateChecking

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {

  if (recognizer.state == UIGestureRecognizerStateBegan) {
    NSAssert(NO, assertFailure(@"checking", @"pan", @"began"));
  } else if (recognizer.state == UIGestureRecognizerStateChanged) {
    [self.tableViewState.tableViewGestureRecognizer.operationStateNormal handlePan:recognizer];
  } else if (recognizer.state == UIGestureRecognizerStateEnded) {
    [self.tableViewState.tableViewGestureRecognizer.operationStateNormal handlePan:recognizer];
  }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {}
- (void)handleTap:(UITapGestureRecognizer *)recognizer {}
- (void)handleScroll:(UITableView *)tableView {}

@end

/// Deleting

@interface LXMTableViewOperationStateDeleting : LXMTableViewOperationState <LXMTableViewOperationState>
@end

@implementation LXMTableViewOperationStateDeleting

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {

  if (recognizer.state == UIGestureRecognizerStateBegan) {
    NSAssert(NO, assertFailure(@"deleting", @"pan", @"began"));
  } else if (recognizer.state == UIGestureRecognizerStateChanged) {
    [self.tableViewState.tableViewGestureRecognizer.operationStateNormal handlePan:recognizer];
  } else if (recognizer.state == UIGestureRecognizerStateEnded) {
    [self.tableViewState.tableViewGestureRecognizer.operationStateNormal handlePan:recognizer];
  }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {}
- (void)handleTap:(UITapGestureRecognizer *)recognizer {}
- (void)handleScroll:(UITableView *)tableView {}

@end

/// PinchAdding

@interface LXMTableViewOperationStatePinchAdding : LXMTableViewOperationState <LXMTableViewOperationState>
@end

@implementation LXMTableViewOperationStatePinchAdding

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {

  if (recognizer.state == UIGestureRecognizerStateBegan) {
    NSAssert(NO, assertFailure(@"pinch adding", @"pinch", @"began"));
  } else if (recognizer.state == UIGestureRecognizerStateChanged && recognizer.numberOfTouches >= 2) {
    [self.tableViewGestureRecognizer.recognizerHelper updateForPinchAdding:recognizer];

    if ([self.tableViewGestureRecognizer.delegate respondsToSelector:@selector(gestureRecognizer:isAddingRowAtIndexPath:)]) {
      [self.tableViewGestureRecognizer.delegate gestureRecognizer:self.tableViewGestureRecognizer
                                           isAddingRowAtIndexPath:self.tableViewState.addingRowIndexPath];
    }

    [UIView performWithoutAnimation:^{
      [self.tableView reloadRowsAtIndexPaths:@[self.tableViewState.addingRowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
  } else if (recognizer.state == UIGestureRecognizerStateEnded) {
      [self.tableViewGestureRecognizer.recognizerHelper commitOrDiscardAddingRowAtIndexPath:self.tableViewState.addingRowIndexPath];
      [self switchToOperationState:self.tableViewGestureRecognizer.operationStateRecovering];
  }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {}
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {}
- (void)handleTap:(UITapGestureRecognizer *)recognizer {}
- (void)handleScroll:(UITableView *)tableView {}

@end

/// PinchTranslating

@interface LXMTableViewOperationStatePinchTranslating : LXMTableViewOperationState <LXMTableViewOperationState>
@end

@implementation LXMTableViewOperationStatePinchTranslating

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {}
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {}
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {}
- (void)handleTap:(UITapGestureRecognizer *)recognizer {}
- (void)handleScroll:(UITableView *)tableView {}

@end

/// PanTranslating

@interface LXMTableViewOperationStatePanTranslating : LXMTableViewOperationState <LXMTableViewOperationState>
@end

@implementation LXMTableViewOperationStatePanTranslating

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {}
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {}
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {}
- (void)handleTap:(UITapGestureRecognizer *)recognizer {}
- (void)handleScroll:(UITableView *)tableView {}

@end

/// PullAdding

@interface LXMTableViewOperationStatePullAdding : LXMTableViewOperationState <LXMTableViewOperationState>
@end

@implementation LXMTableViewOperationStatePullAdding

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {}
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {}
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {}
- (void)handleTap:(UITapGestureRecognizer *)recognizer {}
- (void)handleScroll:(UITableView *)tableView {}

@end

/// Rearranging

@interface LXMTableViewOperationStateRearranging : LXMTableViewOperationState <LXMTableViewOperationState>
@end

@implementation LXMTableViewOperationStateRearranging

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {}
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {}
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {}
- (void)handleTap:(UITapGestureRecognizer *)recognizer {}
- (void)handleScroll:(UITableView *)tableView {}

@end

/// Recovering

@interface LXMTableViewOperationStateRecovering : LXMTableViewOperationState <LXMTableViewOperationState>
@end

@implementation LXMTableViewOperationStateRecovering

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {}
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {}
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {}
- (void)handleTap:(UITapGestureRecognizer *)recognizer {}
- (void)handleScroll:(UITableView *)tableView {}

@end

/// Processing

@interface LXMTableViewOperationStateProcessing : LXMTableViewOperationState <LXMTableViewOperationState>
@end

@implementation LXMTableViewOperationStateProcessing

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {}
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {

//  [self.tableViewGestureRecognizer.operationStateNormal handlePan:recognizer];
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {}
- (void)handleTap:(UITapGestureRecognizer *)recognizer {}
- (void)handleScroll:(UITableView *)tableView {}

@end

/// Super Abstract Class

@interface LXMTableViewOperationState ()
@end

@implementation LXMTableViewOperationState

+ (instancetype)operationStateForOperationStateCode:(LXMTableViewOperationStateCode)stateCode {

  LXMTableViewOperationState *operationState;

  switch (stateCode) {
    case LXMTableViewOperationStateCodeNormal:
      operationState = [LXMTableViewOperationStateNormal new];
      break;

    case LXMTableViewOperationStateCodeModifying:
      return [LXMTableViewOperationStateModifying new];
      break;

    case LXMTableViewOperationStateCodeChecking:
      operationState = [LXMTableViewOperationStateChecking new];
      break;

    case LXMTableViewOperationStateCodeDeleting:
      operationState = [LXMTableViewOperationStateDeleting new];
      break;

    case LXMTableViewOperationStateCodePinchAdding:
      operationState = [LXMTableViewOperationStatePinchAdding new];
      break;

    case LXMTableViewOperationStateCodePinchTranslating:
      operationState = [LXMTableViewOperationStatePinchTranslating new];
      break;

    case LXMTableViewOperationStateCodePanTranslating:
      operationState = [LXMTableViewOperationStatePanTranslating new];
      break;

    case LXMTableViewOperationStateCodePullAdding:
      operationState = [LXMTableViewOperationStatePullAdding new];
      break;

    case LXMTableViewOperationStateCodeRearranging:
      operationState = [LXMTableViewOperationStateRearranging new];
      break;

    case LXMTableViewOperationStateCodeProcessing:
      operationState = [LXMTableViewOperationStateProcessing new];
      break;

    case LXMTableViewOperationStateCodeRecovering:
      operationState = [LXMTableViewOperationStateRecovering new];
      break;
  }
  return operationState;
}

#pragma mark - getters

- (LXMTableViewState *)tableViewState {

  return [LXMTableViewState sharedInstance];
}

- (UITableView *)tableView {

  return self.tableViewState.tableView;
}

- (LXMTableViewGestureRecognizer *)tableViewGestureRecognizer {

  return self.tableViewState.tableViewGestureRecognizer;
}

#pragma mark - <LXMTableViewOperationState>

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
  NSAssert(NO, @"仅能在子类中调用。");
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
  NSAssert(NO, @"仅能在子类中调用。");
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
  NSAssert(NO, @"仅能在子类中调用。");
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
  NSAssert(NO, @"仅能在子类中调用。");
}

- (void)handleScroll:(UITableView *)tableView {
  NSAssert(NO, @"仅能在子类中调用。");
}

- (void)switchToOperationState:(id <LXMTableViewOperationState>)operationState {

  self.tableViewGestureRecognizer.operationState = operationState;
}

@end