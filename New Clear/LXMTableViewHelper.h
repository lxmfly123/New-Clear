//
// Created by FLY.lxm on 2016.9.19.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LXMTableViewGestureRecognizer;
@class LXMTableViewState;
@class LXMTodoItem;

@interface LXMTableViewHelper : NSObject

// data
- (NSUInteger)todoItemIndexForIndexPath:(NSIndexPath *)indexPath;
- (LXMTodoItem *)todoItemForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)movingDestinationIndexPathForCheckedRowAtIndexPath:(NSIndexPath *)indexPath;

// appearances
- (UIColor *)colorForRowAtIndexPath:(NSIndexPath *)indexPath ignoreTodoItem:(BOOL)shouldIgnore;
- (UIColor *)colorForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIColor *)textColorForRowAtIndexPath:(NSIndexPath *)indexPath;

// animation
- (void)recoverRowAtIndexPath:(NSIndexPath *)indexPath forAdding:(BOOL)shouldAdd;
- (void)bounceRowAtIndexPath:(NSIndexPath *)indexPath check:(BOOL)shouldCheck;
- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)acceptAddingRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)rejectAddingRowAtIndexPath:(NSIndexPath *)indexPath;


// offset and inset
- (void)saveContentOffsetAndInset;
- (void)recoverContentOffsetAndInset;

@end