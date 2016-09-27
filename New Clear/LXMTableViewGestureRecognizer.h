//
// Created by FLY.lxm on 2016.9.19.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LXMTableViewCell.h"
#import "LXMTableViewOperationState.h"
#import "LXMTodoItem.h"

@class LXMTableViewGestureRecognizer;
@class LXMTableViewGestureRecognizerHelper;
@class LXMTableViewHelper;

@protocol LXMTableViewGestureAddingRowDelegate <NSObject>

- (BOOL)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer canAddRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer needsAddRowAtIndexPath:(NSIndexPath *)indexPath usage:(LXMTodoItemUsage)usage;
- (void)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer needsDiscardRowAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (void)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer willCreateRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer isAddingRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer heightForCommitingRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol LXMTableViewGestureEditingRowDelegate <NSObject>

- (BOOL)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer didEnterEditingState:(LXMTableViewCellEditingState)editingState forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer needsCommitEditingState:(LXMTableViewCellEditingState)editingState forRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (BOOL)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer willEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer willCheckRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)gestureRecognizer:(LXMTableViewGestureRecognizer *)recognizer willDeleteRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol LXMTableViewGestureRearrangingRowDelegate <NSObject>
@end


@interface LXMTableViewGestureRecognizer : NSObject <UITableViewDelegate, LXMTableViewCellDelegate>

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) LXMTableViewHelper *tableViewHelper;
@property (nonatomic, strong) LXMTableViewGestureRecognizerHelper *recognizerHelper;

// operation states
@property (nonatomic, strong) id <LXMTableViewOperationState> operationState; ///<  当前 table view 的操作状态。
@property (nonatomic, strong) id <LXMTableViewOperationState> operationStateNormal;
@property (nonatomic, strong) id <LXMTableViewOperationState> operationStateModifying;
@property (nonatomic, strong) id <LXMTableViewOperationState> operationStateChecking;
@property (nonatomic, strong) id <LXMTableViewOperationState> operationStateDeleting;
@property (nonatomic, strong) id <LXMTableViewOperationState> operationStatePinchAdding;
@property (nonatomic, strong) id <LXMTableViewOperationState> operationStatePinchTranslating;
@property (nonatomic, strong) id <LXMTableViewOperationState> operationStatePanTranslating;
@property (nonatomic, strong) id <LXMTableViewOperationState> operationStatePullAdding;
@property (nonatomic, strong) id <LXMTableViewOperationState> operationStateRearranging;
@property (nonatomic, strong) id <LXMTableViewOperationState> operationStateRecovering;
@property (nonatomic, strong) id <LXMTableViewOperationState> operationStateProcessing;

//+ (instancetype)gestureRecognizerWithTableView:(UITableView *)tableView delegate:(id)delegate;

@end