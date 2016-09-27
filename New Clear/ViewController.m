//
//  ViewController.m
//  New Clear
//
//  Created by FLY.lxm on 2016.9.18.
//  Copyright (c) 2016 FLY. All rights reserved.
//


#import "ViewController.h"
#import "LXMGlobalSettings.h"
#import "LXMTableViewState.h"
#import "LXMTodoItem.h"
#import "LXMTodoList.h"
#import "LXMTableViewCell.h"
#import "LXMTableViewHelper.h"
#import "LXMStrikeThroughText.h"
#import "LXMTableViewGestureRecognizer.h"
#import "LXMTransformableTableViewCell.h"


@interface ViewController () <UITableViewDelegate, UITableViewDataSource, LXMTableViewGestureAddingRowDelegate, LXMTableViewGestureEditingRowDelegate>

@property (nonatomic, weak) LXMGlobalSettings *globalSettings;
@property (nonatomic, weak) LXMTableViewState *tableViewState;
@property (nonatomic, weak) LXMTableViewHelper *tableViewHelper;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) LXMTodoList *todoList;

@end

@implementation ViewController


- (void)viewDidLoad {

  [super viewDidLoad];

  self.todoList = [LXMTodoList new];
  NSArray *array = @[ @"右划完成",
                      @"左划删除",
                      @"Pinch 放大来新建",
                      @"向下拖动新建",
                      @"Tap 空白处来新建",
                      @"Tap 已完成项目来新建",
                      @"长按移动",
                      @"下拉新建",
                      @"编辑文字时也可下拉新建",
                      @"Pinch 缩小来返回上级界面"];
  [array enumerateObjectsUsingBlock:^(NSString * _Nonnull todoText, NSUInteger idx, BOOL * _Nonnull stop) {
    [self.todoList.todoItems addObject:[LXMTodoItem todoItemWithText:todoText]];
  }];

  self.todoList.todoItems[6].isCompleted = YES; // 长按重排
  self.todoList.todoItems[7].isCompleted = YES; // 下拉新建
  self.todoList.todoItems[8].isCompleted = YES; // 编辑时下拉新建
  self.todoList.todoItems[9].isCompleted = YES; // Pinch 缩小来返回上级界面

  self.tableView.backgroundColor = [UIColor blackColor];
  self.tableView.rowHeight = self.globalSettings.normalRowHeight;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

  self.tableViewState.viewController = self;
  self.tableViewState.tableView = self.tableView;
  self.tableViewState.list = self.todoList;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getters

- (LXMGlobalSettings *)globalSettings {

  return [LXMGlobalSettings sharedInstance];
}

- (LXMTableViewState *)tableViewState {

  return [LXMTableViewState sharedInstance];
}

- (UITableView *)tableView {

  return (UITableView *)self.view;
}

- (LXMTableViewHelper *)tableViewHelper {

  return self.tableViewState.tableViewHelper;
}
#pragma mark - data source helper methods

- (LXMTableViewCell *)tableView:(UITableView *)tableView normalCellForRowAtIndexPath:(NSIndexPath *)indexPath {

  NSString *reuseIdentifier = @"Normal";
  LXMTableViewCell *normalCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if (!normalCell) {
    normalCell = [[LXMTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
  }

  normalCell.todoItem = [self.tableViewHelper todoItemForRowAtIndexPath:indexPath];
  normalCell.actualContentView.backgroundColor = [self.tableViewHelper colorForRowAtIndexPath:indexPath];
  normalCell.strikeThroughText.textColor = [self.tableViewHelper textColorForRowAtIndexPath:indexPath];
  normalCell.delegate = self.tableViewState.tableViewGestureRecognizer;

  return normalCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView transformableCellForRowAtIndexPath:(NSIndexPath *)indexPath {

  LXMTodoItem *todoItem = [self.tableViewHelper todoItemForRowAtIndexPath:indexPath];
  LXMTransformableTableViewCell *transformableCell;

  if (indexPath.section == 0) {
    // transformable cells

    LXMTransformableTableViewCellStyle cellStyle;
    NSString *reuseIdentifier;

    switch (todoItem.usage) {
      case LXMTodoItemUsagePinchAdded:
        reuseIdentifier = @"PinchAdded";
        cellStyle = LXMTransformableTableViewCellStyleUnfolding;
        break;


      case LXMTodoItemUsagePullAdded:
        reuseIdentifier = @"PullAdded";
        cellStyle = LXMTransformableTableViewCellStyleBottomFixed;
        break;

      case LXMTodoItemUsageTapAdded: {
        if (self.todoList.numberOfCompleted > 0) {
          reuseIdentifier = @"TapAddedUnfolding";
          cellStyle = LXMTransformableTableViewCellStyleUnfolding;
        } else {
          reuseIdentifier = @"TapAddedFlipping";
          cellStyle = LXMTransformableTableViewCellStyleTopFixed;
        }
      }
        break;

      default:
        NSAssert(NO, @"Wrong Usage. ");
        cellStyle = LXMTransformableTableViewCellStyleUnfolding;
        reuseIdentifier = nil;
        break;
    }

    transformableCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!transformableCell) {
      transformableCell = [LXMTransformableTableViewCell transformableTableViewCellWithStyle:cellStyle reuseIdentifier:reuseIdentifier];
    }
    transformableCell.tintColor = [self.tableViewHelper colorForRowAtIndexPath:indexPath];
  }

  return transformableCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView tailCellForTailRowAtIndexPath:(NSIndexPath *)indexPath {

  NSAssert(indexPath.section == tableView.numberOfSections - 1, @"Not The Index Path for the LAST Row");

  NSString *reuseIdentifier = @"EmptyTail";
  UITableViewCell *tailCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if (!tailCell) {
    tailCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
  }
  tailCell.contentView.backgroundColor = [UIColor blackColor];
  tailCell.selectionStyle =  UITableViewCellSelectionStyleNone;

  return tailCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

  return self.globalSettings.normalRowHeight;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

  return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  NSInteger number;

  switch (section) {
    case 0:
      number = self.todoList.numberOfUncompleted;
      break;

    case 1:
      number = self.todoList.numberOfCompleted;
      break;

    default:
      number = 1;
      break;
  }

  return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  UITableViewCell *cell;

  // tail
  if (indexPath.section == 2) {
    cell = [self tableView:tableView tailCellForTailRowAtIndexPath:indexPath];
    return cell;
  }

  // normal and transformable
  LXMTodoItem *todoItem = [self.tableViewHelper todoItemForRowAtIndexPath:indexPath];

  switch (todoItem.usage) {
    case LXMTodoItemUsagePinchAdded:
    case LXMTodoItemUsagePullAdded:
    case LXMTodoItemUsageTapAdded:
      cell = [self tableView:tableView transformableCellForRowAtIndexPath:indexPath];
      break;

    case LXMTodoItemUsageNormal:
    case LXMTodoItemUsagePlaceholder:
      cell = [self tableView:tableView normalCellForRowAtIndexPath:indexPath];
      break;
  }

  return cell;
}

#pragma mark - LXMTableViewGestureAddingRowDelegate

- (BOOL)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer canAddRowAtIndexPath:(NSIndexPath *)indexPath {

  return indexPath.section == 0 ||
         ([self.tableViewHelper todoItemForRowAtIndexPath:indexPath].usage == LXMTodoItemUsagePlaceholder && indexPath.section < 2);
}

- (void)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer needsAddRowAtIndexPath:(NSIndexPath *)indexPath usage:(LXMTodoItemUsage)usage {

  [self.todoList.todoItems insertObject:[LXMTodoItem todoItemWithUsage:usage]
                                atIndex:[self.tableViewHelper todoItemIndexForIndexPath:indexPath]];
}

- (void)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath {

  [self.todoList.todoItems replaceObjectAtIndex:[self.tableViewHelper todoItemIndexForIndexPath:indexPath]
                                     withObject:[LXMTodoItem todoItemWithText:@""]];
}

- (void)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer needsDiscardRowAtIndexPath:(NSIndexPath *)indexPath {

  [self.todoList.todoItems removeObjectAtIndex:[self.tableViewHelper todoItemIndexForIndexPath:indexPath]];
}

#pragma mark - LXMTableViewGestureEditingRowDelegate

- (BOOL)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {

  BOOL isSectionRight = indexPath.section < 2;
  BOOL isBouncingOrFloating = [self.tableViewState.uneditableRowIndexPaths containsObject:indexPath];

  return isSectionRight && !isBouncingOrFloating;
}

- (void)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer didEnterEditingState:(LXMTableViewCellEditingState)editingState forRowAtIndexPath:(NSIndexPath *)panningRowIndexPath {

  LXMTableViewCell *panningCell = self.tableViewState.panningCell;

  if (panningCell.todoItem.isCompleted) {
    switch (editingState) {
      case LXMTableViewCellEditingStateWillDelete:
      case LXMTableViewCellEditingStateNormal:
        panningCell.actualContentView.backgroundColor = [UIColor blackColor];
        panningCell.strikeThroughText.textColor = [UIColor grayColor];
        break;

      case LXMTableViewCellEditingStateWillCheck:
        panningCell.actualContentView.backgroundColor = [self.tableViewHelper colorForRowAtIndexPath:[self.tableViewHelper movingDestinationIndexPathForCheckedRowAtIndexPath:panningRowIndexPath] ignoreTodoItem:YES];
        panningCell.strikeThroughText.textColor = [UIColor whiteColor];
        break;

      case LXMTableViewCellEditingStateNone:
        break;
    }
  } else {
    switch (editingState) {
      case LXMTableViewCellEditingStateWillDelete:
      case LXMTableViewCellEditingStateNormal:
        panningCell.actualContentView.backgroundColor = [self.tableViewHelper colorForRowAtIndexPath:panningRowIndexPath];
        panningCell.strikeThroughText.textColor = [UIColor whiteColor];
        break;

      case LXMTableViewCellEditingStateWillCheck:
        panningCell.actualContentView.backgroundColor = self.globalSettings.editingCompletedColor;
        panningCell.strikeThroughText.textColor = [UIColor whiteColor];
        break;

      case LXMTableViewCellEditingStateNone:
        break;
    }
  }
}

- (void)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer needsCommitEditingState:(LXMTableViewCellEditingState)editingState forRowAtIndexPath:(NSIndexPath *)indexPath {

  switch (editingState) {
    case LXMTableViewCellEditingStateWillDelete:
      [self.tableViewHelper deleteRowAtIndexPath:indexPath];
      break;

    case LXMTableViewCellEditingStateNormal:
      [self.tableViewHelper bounceRowAtIndexPath:indexPath check:NO];
      break;

    case LXMTableViewCellEditingStateWillCheck:
      [self.tableViewHelper bounceRowAtIndexPath:indexPath check:YES];
      break;

    default:
      break;
  }
}




@end