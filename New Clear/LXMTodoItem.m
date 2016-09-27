//
// Created by FLY.lxm on 2016.9.18.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import "LXMTodoItem.h"


@implementation LXMTodoItem

+ (instancetype)p_todoItemWithText:(NSString *)text usage:(LXMTodoItemUsage)usage{

  LXMTodoItem *todoItem = [LXMTodoItem new];

  if (todoItem) {
    todoItem.usage = usage;
    todoItem.isCompleted = NO;

    switch (usage) {
      case LXMTodoItemUsageNormal:
        todoItem.text = text;
        break;

      case LXMTodoItemUsagePinchAdded:
      case LXMTodoItemUsagePullAdded:
      case LXMTodoItemUsageTapAdded:
      case LXMTodoItemUsagePlaceholder:
        todoItem.text = @"";
        break;
    }
  }

  return todoItem;
}

+ (instancetype)todoItemWithText:(NSString *)text {

  return [self p_todoItemWithText:text usage:LXMTodoItemUsageNormal];
}

+ (instancetype)todoItemWithUsage:(LXMTodoItemUsage)usage {

  return [self p_todoItemWithText:@"" usage:usage];
}

- (BOOL)toggleCompleted {

  return self.isCompleted = !self.isCompleted;
}



@end