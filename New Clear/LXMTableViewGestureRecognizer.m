//
// Created by FLY.lxm on 2016.9.19.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import "LXMTableViewGestureRecognizer.h"
#import "LXMGlobalSettings.h"
#import "LXMTableViewState.h"
#import "LXMTableViewHelper.h"
#import "LXMTableViewGestureRecognizerHelper.h"

@interface LXMTableViewGestureRecognizer () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) LXMGlobalSettings *globalSettings;
@property (nonatomic, weak) LXMTableViewState *tableViewState;
@property (nonatomic, weak) UITableView *tableView;

// gesture recognizers
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer; ///< Gesture recognizer only recognize HOROZONTAL pan.
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;

@end

@implementation LXMTableViewGestureRecognizer

- (instancetype)init {

  if (self = [super init]) {
    [self configureGestureRecognizers];
  }

  return self;
}

- (void)configureGestureRecognizers {

  NSAssert(self.tableView, @"Table View does not exist. ");

  // tap recognizer
  self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
  self.tapRecognizer.delegate = self;
  [self.tableView addGestureRecognizer:self.tapRecognizer];

  // pinch recognizer
  self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
  self.pinchRecognizer.delegate = self;
  [self.tableView addGestureRecognizer:self.pinchRecognizer];

  // pan recognizer
  self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
  self.panRecognizer.delegate = self;
  [self.tableView addGestureRecognizer:self.panRecognizer];

  //long press recognizer
  UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
  longPressRecognizer.delegate = self;
  self.longPressRecognizer = longPressRecognizer;
  [self.tableView addGestureRecognizer:self.longPressRecognizer];

  // 注册响应操作完成的通知，将相关状态值设置为初始值。
//  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishNotification:) name:LXMOperationCompleteNotification object:nil];
}

#pragma mark - delegate conformability

- (BOOL)delegateConformsToProtocol:(Protocol *)aProtocol {

  if (![self.delegate conformsToProtocol:aProtocol]) {
    NSLog(@"Delegate does not conforms to %@ protocol", NSStringFromProtocol(aProtocol));
    return NO;
  }
  return YES;
}

- (BOOL)delegateConformsToAddingRowProtocol {

  return [self.delegate conformsToProtocol:@protocol(LXMTableViewGestureAddingRowDelegate)];
}

- (BOOL)delegateConformsToEditingRowProtocol {

  return [self.delegate conformsToProtocol:@protocol(LXMTableViewGestureEditingRowDelegate)];
}

- (BOOL)delegateConformsToRearrangingRowProtocol {

  return [self.delegate conformsToProtocol:@protocol(LXMTableViewGestureRearrangingRowDelegate)];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer {

  if (recognizer == self.tapRecognizer) { // tap
    return [self delegateConformsToAddingRowProtocol];
  } else if (recognizer == self.pinchRecognizer) { // pinch
    if (![self delegateConformsToAddingRowProtocol]) {
      return NO;
    } else {
      NSIndexPath *willAddedIndexPath = [self.recognizerHelper addingRowIndexPathForGestureRecognizer:recognizer];
      if (![self.delegate gestureRecognizer:self canAddRowAtIndexPath:willAddedIndexPath]) {
        return NO;
      }
      if ([self.delegate respondsToSelector:@selector(gestureRecognizer:willCreateRowAtIndexPath:)]) {
        [self.delegate gestureRecognizer:self willCreateRowAtIndexPath:willAddedIndexPath];
      }
      return YES;
    }
  } else if (recognizer == self.panRecognizer) { // pan
    if (![self delegateConformsToEditingRowProtocol]) {
      return NO;
    }

    CGPoint velocity = [self.panRecognizer velocityInView:self.tableView];
    if (ABS(velocity.x) > ABS(velocity.y)) {
      NSIndexPath *willEditedIndexPath = [self.tableView indexPathForRowAtPoint:[recognizer locationInView:self.tableView]];
      if (![self.delegate gestureRecognizer:self canEditRowAtIndexPath:willEditedIndexPath]) {
        return NO;
      }
      if ([self.delegate respondsToSelector:@selector(gestureRecognizer:willEditRowAtIndexPath:)]) {
        [self.delegate gestureRecognizer:self willEditRowAtIndexPath:willEditedIndexPath];
      }
      return YES;
    }
  }

  return NO;
}

#pragma mark - gesture handlers

- (void)handleTap:(UITapGestureRecognizer *)recognizer {

  [self.operationState handleTap:recognizer];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {

  [self.operationState handlePinch:recognizer];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {

  [self.operationState handlePan:recognizer];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {}

#pragma mark - getters

- (LXMGlobalSettings *)globalSettings {

  return [LXMGlobalSettings sharedInstance];
}

- (LXMTableViewState *)tableViewState {

  return [LXMTableViewState sharedInstance];
}

- (UITableView *)tableView {

  return self.tableViewState.tableView;
}

- (LXMTableViewHelper *)tableViewHelper {

  if (!_tableViewHelper) {
  }
    _tableViewHelper = [LXMTableViewHelper new];

  return _tableViewHelper;
}

- (LXMTableViewGestureRecognizerHelper *)recognizerHelper {

  if (!_recognizerHelper) {
    _recognizerHelper = [LXMTableViewGestureRecognizerHelper new];
  }

  return _recognizerHelper;
}

- (id)delegate {

  return self.tableViewState.viewController;
}

- (id <LXMTableViewOperationState>)operationState {

  if (!_operationState) {
     _operationState = self.operationStateNormal;
  }

  return _operationState;
}

- (id <LXMTableViewOperationState>)operationStateNormal {

  if (!_operationStateNormal) {
    _operationStateNormal = [LXMTableViewOperationState operationStateForOperationStateCode:LXMTableViewOperationStateCodeNormal];
  }

  return _operationStateNormal;
}

- (id <LXMTableViewOperationState>)operationStateModifying {

  if (!_operationStateModifying) {
    _operationStateModifying = [LXMTableViewOperationState operationStateForOperationStateCode:LXMTableViewOperationStateCodeModifying];
  }

  return _operationStateModifying;
}

- (id <LXMTableViewOperationState>)operationStateChecking {

  if (!_operationStateChecking) {
    _operationStateChecking = [LXMTableViewOperationState operationStateForOperationStateCode:LXMTableViewOperationStateCodeChecking];
  }

  return _operationStateChecking;
}

- (id <LXMTableViewOperationState>)operationStateDeleting {

  if (!_operationStateDeleting) {
    _operationStateDeleting = [LXMTableViewOperationState operationStateForOperationStateCode:LXMTableViewOperationStateCodeDeleting];
  }

  return _operationStateDeleting;
}

- (id <LXMTableViewOperationState>)operationStatePinchAdding {

  if (!_operationStatePinchAdding) {
    _operationStatePinchAdding = [LXMTableViewOperationState operationStateForOperationStateCode:LXMTableViewOperationStateCodePinchAdding];
  }

  return _operationStatePinchAdding;
}

- (id <LXMTableViewOperationState>)operationStatePinchTranslating {

  if (!_operationStatePinchTranslating) {
    _operationStatePinchTranslating = [LXMTableViewOperationState operationStateForOperationStateCode:LXMTableViewOperationStateCodePinchTranslating];
  }

  return _operationStatePinchTranslating;
}

- (id <LXMTableViewOperationState>)operationStatePanTranslating {

  if (!_operationStatePanTranslating) {
    _operationStatePanTranslating = [LXMTableViewOperationState operationStateForOperationStateCode:LXMTableViewOperationStateCodePanTranslating];
  }

  return _operationStatePanTranslating;
}

- (id <LXMTableViewOperationState>)operationStatePullAdding {

  if (!_operationStatePullAdding) {
    _operationStatePullAdding = [LXMTableViewOperationState operationStateForOperationStateCode:LXMTableViewOperationStateCodePullAdding];
  }

  return _operationStatePullAdding;
}

- (id <LXMTableViewOperationState>)operationStateRearranging {

  if (!_operationStateRearranging) {
    _operationStateRearranging = [LXMTableViewOperationState operationStateForOperationStateCode:LXMTableViewOperationStateCodeRearranging];
  }

  return _operationStateRearranging;
}

- (id <LXMTableViewOperationState>)operationStateRecovering {

  if (!_operationStateRecovering) {
    _operationStateRecovering = [LXMTableViewOperationState operationStateForOperationStateCode:LXMTableViewOperationStateCodeRecovering];
  }

  return _operationStateRecovering;
}

- (id <LXMTableViewOperationState>)operationStateProcessing {

  if (!_operationStateProcessing) {
    _operationStateProcessing = [LXMTableViewOperationState operationStateForOperationStateCode:LXMTableViewOperationStateCodeProcessing];
  }

  return _operationStateProcessing;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

  if (indexPath == self.tableViewState.addingRowIndexPath) {
    return self.tableViewState.addingRowHeight;
  } else {
    return self.globalSettings.normalRowHeight;
  }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  NSLog(@"end");
  if (decelerate) NSLog(@"will decelerate");
}

#pragma mark - LXMTableViewCellDelegate

- (BOOL)tableViewCellShouldBeginTextEditing:(LXMTableViewCell *)cell {

  return YES;
}

- (void)tableViewCellDidBeginTextEditing:(LXMTableViewCell *)cell {

  self.tableViewState.modifyingRowIndexPath = [self.tableView indexPathForCell:cell];

  [UIView animateWithDuration:LXMTableViewRowAnimationDurationNormal delay:0 options:LXMKeyboardAnimationCurve animations:^{
    [self.tableViewHelper saveContentOffsetAndInset];
    self.tableView.contentOffset = CGPointMake(0, cell.frame.origin.y);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tableView.frame.size.height - self.tableView.rowHeight, 0);
    for (LXMTableViewCell *visibleCell in self.tableView.visibleCells) {
      if (cell != visibleCell) {
        visibleCell.alpha = 0.3f;
      }
    }
  } completion:^(BOOL finished) {
    self.tableView.scrollEnabled = NO;
    [self.operationState switchToOperationState:self.operationStateModifying];
  }];
}

- (BOOL)tableViewCellShouldEndTextEditing:(LXMTableViewCell *)cell {

  return YES;
}

- (void)tableViewCellDidEndTextEditing:(LXMTableViewCell *)cell {

  [UIView animateWithDuration:LXMTableViewRowAnimationDurationNormal delay:0 options:LXMKeyboardAnimationCurve animations:^{
    [self.tableViewHelper recoverContentOffsetAndInset];
    for (LXMTableViewCell *visibleCell in self.tableView.visibleCells) {
      if (cell != visibleCell) {
        visibleCell.alpha = 1.0f;
      }
    }
  } completion:^(BOOL finished) {
    if ([cell.todoItem.text isEqualToString:@""]) {
      [self.tableViewHelper deleteRowAtIndexPath:self.tableViewState.modifyingRowIndexPath];
    } else {
      [self.operationState switchToOperationState:self.operationStateNormal];
      [self.tableView reloadData];
    }
    self.tableView.scrollEnabled = YES;
    self.tableViewState.modifyingRowIndexPath = nil;
  }];
}

@end