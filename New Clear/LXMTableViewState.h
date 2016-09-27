//
// Created by FLY.lxm on 2016.9.19.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LXMTableViewCell;
//@class LXMTransformableTableViewCell;
@class LXMTodoList;
@class LXMTableViewGestureRecognizer;
@class LXMTableViewGestureRecognizerHelper;
@class LXMTableViewHelper;

@interface LXMTableViewState : NSObject

// 以下三个属性必须在 viewDidLoad 中赋值
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) LXMTodoList *list;

@property (nonatomic, strong) LXMTableViewGestureRecognizer *tableViewGestureRecognizer;
@property (nonatomic, weak) LXMTableViewHelper *tableViewHelper;
@property (nonatomic, weak) LXMTableViewGestureRecognizerHelper *recognizerHelper;
@property (nonatomic, weak) id <UITableViewDelegate> tableViewDelegate; ///< Ordinary delegate of table view.

@property (nonatomic, strong) NSIndexPath *addingRowIndexPath;
@property (nonatomic, assign) CGFloat addingProgress; ///< 新增 todo 的动画或手势的执行进度（0 ~ 1）。
@property (nonatomic, assign) CGFloat addingRowHeight; /// 新增 todo 的行的行高，由 addingProgress 计算得到。

@property (nonatomic, strong) NSIndexPath *modifyingRowIndexPath;

@property (nonatomic, strong) NSIndexPath *panningRowIndexPath;
@property (nonatomic, weak, readonly) LXMTableViewCell *panningCell;
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *bouncingRowIndexPaths;
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *floatingRowIndexPaths;
@property (nonatomic, readonly) NSArray<NSIndexPath *> *uneditableRowIndexPaths;

@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, assign) UIEdgeInsets lastContentInset;

+ (instancetype)sharedInstance;

@end