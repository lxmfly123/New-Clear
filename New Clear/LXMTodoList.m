//
// Created by FLY.lxm on 2016.9.18.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import "LXMTodoList.h"
#import "LXMTodoItem.h"

@implementation LXMTodoList

+ (instancetype)listWithTodoItems:(LXMTodoItem *)todoItem1, ... NS_REQUIRES_NIL_TERMINATION {

  LXMTodoList *list = [LXMTodoList new];

  if (list) {
    [list.todoItems addObject:todoItem1];

    va_list todoItems;
    va_start(todoItems, todoItem1);
    for (LXMTodoItem *todoItem in va_arg(todoItems, LXMTodoItem *)) {
      [list.todoItems addObject:todoItem];
    }
    va_end(todoItems);
  }

  return list;
}

- (instancetype)init {

  if (self = [super init]) {
    self.todoItems = [NSMutableArray arrayWithCapacity:10];
  }

  return self;
}

#pragma mark - getters

- (NSUInteger)numberOfUncompleted {

  NSUInteger number = 0;
  for (LXMTodoItem *todoItem in self.todoItems) {
    if (!todoItem.isCompleted) {
      number++;
    } else {
      break;
    }
  }

  return number;
}

- (NSUInteger)numberOfCompleted {

  return self.todoItems.count - self.numberOfUncompleted;
}

@end