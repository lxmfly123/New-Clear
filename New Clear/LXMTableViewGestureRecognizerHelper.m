//
// Created by FLY.lxm on 2016.9.20.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import "LXMTableViewGestureRecognizerHelper.h"
#import "LXMGlobalSettings.h"
#import "LXMTableViewState.h"
#import "LXMTableViewGestureRecognizer.h"
#import "LXMTodoItem.h"
#import "LXMTodoList.h"
#import "LXMTableViewHelper.h"

/// Pinch 时的两个点。
typedef struct {
  CGPoint upper;
  CGPoint lower;
} LXMPinchPoints;

/// 水平拖动时的位移值。
typedef struct {
  CGFloat n;
  CGFloat k;
  CGFloat m;
  CGFloat b;
  CGFloat c;
} LXMHorizontalPanOffsetParameters;

CG_INLINE LXMHorizontalPanOffsetParameters LXMHorizontalPanOffsetParametersMake(CGFloat n, CGFloat k, CGFloat m) {

  CGFloat b = (1 - k * n * logf(m)) / (k * logf(m));
  CGFloat c = k * n - logf(n + b) / logf(m);
  return (LXMHorizontalPanOffsetParameters){n, k, m, b, c};
} ///< Make a offset curve from '(n, k, m)'. see http://lxm9.com/2016/04/19/sliding-damping-in-clear-the-app/

@interface LXMTableViewGestureRecognizerHelper ()

@property (nonatomic, assign) LXMPinchPoints startingPinchPoints;
@property (nonatomic, weak) LXMTableViewState *tableViewState;
@property (nonatomic, weak) LXMGlobalSettings *globalSettings;
@property (nonatomic, weak) LXMTableViewHelper *tableViewHelper;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) LXMTodoList *list;

@end

@implementation LXMTableViewGestureRecognizerHelper

#pragma mark - helper

- (LXMPinchPoints)p_normalizePinchPointsForPinchGestureRecognizer:(UIPinchGestureRecognizer *)recognizer {

  LXMPinchPoints pinchPoints = (LXMPinchPoints){
    [recognizer locationOfTouch:0 inView:self.tableView],
    [recognizer locationOfTouch:1 inView:self.tableView]};
  if (pinchPoints.upper.y > pinchPoints.lower.y) {
    CGPoint tempPoint = pinchPoints.upper;
    pinchPoints.upper = pinchPoints.lower;
    pinchPoints.lower = tempPoint;
  }
  return pinchPoints;
}

- (NSIndexPath *)p_targetIndexPathForPinchPoints:(LXMPinchPoints)pinchPoints {

  NSIndexPath *lower = [self.tableView indexPathForRowAtPoint:pinchPoints.lower];

  if (lower) {
    CGPoint middlePoint = (CGPoint){(pinchPoints.upper.x + pinchPoints.lower.x) / 2, (pinchPoints.upper.y + pinchPoints.lower.y) / 2};
    NSIndexPath *middleIndexPath = [self.tableView indexPathForRowAtPoint:middlePoint];
    UITableViewCell *middleCell = [self.tableView cellForRowAtIndexPath:middleIndexPath];
    if (middlePoint.y > middleCell.frame.origin.y + middleCell.frame.size.height / 2) {
      middleIndexPath = [NSIndexPath indexPathForRow:middleIndexPath.row + 1 inSection:middleIndexPath.section];
    }
    return middleIndexPath;
  } else {
    return [NSIndexPath indexPathForRow:[self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:0] inSection:0];
  }
}

- (CGFloat)p_verticalPinchDistanceOfPinchGestureRecognizer:(UIPinchGestureRecognizer *)recognizer {

  LXMPinchPoints pinchPoints = [self p_normalizePinchPointsForPinchGestureRecognizer:recognizer];
  CGFloat verticalDistance = (self.startingPinchPoints.upper.y - pinchPoints.upper.y) + (pinchPoints.lower.y - self.startingPinchPoints.lower.y);

  return verticalDistance;
}

/// Calculate horizontal pan offset. See http://lxm9.com/2016/04/19/sliding-damping-in-clear-the-app/
- (CGFloat)p_horizontalPanOffsetForParameters:(LXMHorizontalPanOffsetParameters)parameters panRecognizer:(UIPanGestureRecognizer *)recognizer{

  CGFloat horizontalOffset;

  if (ABS([recognizer translationInView:self.tableView].x) < parameters.n) {
    horizontalOffset = parameters.k * [recognizer translationInView:self.tableView].x;
  } else {
    if ([recognizer translationInView:self.tableView].x < 0) {
      horizontalOffset = -((logf(-[recognizer translationInView:self.tableView].x + parameters.b) / logf(parameters.m)) + parameters.c);
    } else {
      horizontalOffset = (logf([recognizer translationInView:self.tableView].x + parameters.b) / logf(parameters.m)) + parameters.c;
    }
  }

  return horizontalOffset;
}

#pragma mark - public

- (NSIndexPath *)addingRowIndexPathForGestureRecognizer:(UIGestureRecognizer *)recognizer {

  if ([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
    // pinch
    self.startingPinchPoints = [self p_normalizePinchPointsForPinchGestureRecognizer:recognizer];
    return [self p_targetIndexPathForPinchPoints:self.startingPinchPoints];
  } else if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
    // pull down
    return self.tableViewState.modifyingRowIndexPath ?
      [NSIndexPath indexPathForRow:self.tableViewState.modifyingRowIndexPath.row inSection:0] :
      [NSIndexPath indexPathForRow:0 inSection:0];
  } else if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
    // tap
    return [NSIndexPath indexPathForRow:self.tableViewState.list.numberOfUncompleted inSection:0];
  } else {
    // error
    NSAssert(NO, @"Gesture Recognizer 有问题");
    return nil;
  }
}

- (void)updateForPinchAdding:(UIPinchGestureRecognizer *)recognizer {

  self.tableViewState.addingProgress = [self p_verticalPinchDistanceOfPinchGestureRecognizer:recognizer] / [LXMGlobalSettings sharedInstance].normalRowHeight;
  LXMPinchPoints currentPinchPoints = [self p_normalizePinchPointsForPinchGestureRecognizer:recognizer];
  CGFloat upperDeltaDistance = self.tableViewState.addingProgress < 0.000001 ? 0 : self.startingPinchPoints.upper.y - currentPinchPoints.upper.y;
  self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + upperDeltaDistance);
}

- (void)commitOrDiscardAddingRowAtIndexPath:(NSIndexPath *)indexPath {

  BOOL shouldCommit = self.tableViewState.addingProgress >= 1;

  if (shouldCommit) {
    [self.tableViewHelper acceptAddingRowAtIndexPath:indexPath];
  } else {
    [self.tableViewHelper rejectAddingRowAtIndexPath:indexPath];
  }
}

- (CGFloat)horizontalPanOffset:(UIPanGestureRecognizer *)recognizer {

  CGFloat horizontalPanOffset;

  if ([recognizer translationInView:self.tableView].x > 0) {
    LXMHorizontalPanOffsetParameters completionParameters = LXMHorizontalPanOffsetParametersMake([LXMGlobalSettings sharedInstance]
    .editCommitTriggerWidth, 0.9f, 1.07f);
    horizontalPanOffset = [self p_horizontalPanOffsetForParameters:completionParameters panRecognizer:recognizer];
  } else {
    LXMHorizontalPanOffsetParameters deletionParameters = LXMHorizontalPanOffsetParametersMake([LXMGlobalSettings sharedInstance]
    .editCommitTriggerWidth, 0.75f, 1.01f);
    horizontalPanOffset = [self p_horizontalPanOffsetForParameters:deletionParameters panRecognizer:recognizer];
  }

  return horizontalPanOffset;
}


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

- (LXMTableViewHelper *)tableViewHelper {

  return self.tableViewState.tableViewHelper;
}

- (LXMTodoList *)list {

  return self.tableViewState.list;
}

@end