//
// Created by FLY.lxm on 2016.9.19.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import "LXMTableViewState.h"
#import "LXMTableViewGestureRecognizer.h"
#import "LXMGlobalSettings.h"
#import "LXMTableViewHelper.h"

@interface LXMTableViewState ()

@property (nonatomic, weak) LXMGlobalSettings *globalSettings;

@end

@implementation LXMTableViewState

//@synthesize uneditableRowIndexPaths = _uneditableRowIndexPaths;

+ (instancetype)sharedInstance {

  static LXMTableViewState *singleInstance;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    singleInstance = [LXMTableViewState new];
  });

  return singleInstance;
}

#pragma mark - getters

- (LXMGlobalSettings *)globalSettings {

  return [LXMGlobalSettings sharedInstance];
}

- (LXMTableViewGestureRecognizer *)tableViewGestureRecognizer {

  if (!_tableViewGestureRecognizer) {
    NSAssert(self.tableView, @"No Table View Found...");
    NSAssert(self.viewController, @"No Available Delegate Found...");
    _tableViewGestureRecognizer = [LXMTableViewGestureRecognizer new];
  }

  if (self.tableView.delegate != _tableViewGestureRecognizer) {
    self.tableViewDelegate = self.tableView.delegate;
    self.tableView.delegate = _tableViewGestureRecognizer;
  }

  return _tableViewGestureRecognizer;
}

- (LXMTableViewHelper *)tableViewHelper {

  return self.tableViewGestureRecognizer.tableViewHelper;
}

- (LXMTableViewGestureRecognizerHelper *)recognizerHelper {

  return self.tableViewGestureRecognizer.recognizerHelper;
}

- (CGFloat)addingRowHeight {

  return self.addingProgress * self.globalSettings.normalRowHeight;
}

- (LXMTableViewCell *)panningCell {

  return [self.tableView cellForRowAtIndexPath:self.panningRowIndexPath];
}

- (NSMutableArray<NSIndexPath *> *)bouncingRowIndexPaths {

  if (!_bouncingRowIndexPaths) {
    _bouncingRowIndexPaths = [NSMutableArray arrayWithCapacity:5];
  }

  return _bouncingRowIndexPaths;
}

- (NSMutableArray<NSIndexPath *> *)floatingRowIndexPaths {

  if (!_floatingRowIndexPaths) {
    _floatingRowIndexPaths = [NSMutableArray arrayWithCapacity:5];
  }

  return _floatingRowIndexPaths;
}

- (NSArray<NSIndexPath *> *)uneditableRowIndexPaths {

  return [self.bouncingRowIndexPaths arrayByAddingObjectsFromArray:self.floatingRowIndexPaths];
}

#pragma mark - setters

- (void)setAddingProgress:(CGFloat)addingProgress {

  _addingProgress = addingProgress < 0 ? 0 : addingProgress;
}

@end