//
// Created by FLY.lxm on 2016.9.18.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LXMTodoItemUsage) {
  LXMTodoItemUsageNormal,             ///< 正常的，用来显示在列表中的 todo。
  LXMTodoItemUsagePinchAdded,   ///< 通过 pinch 新增的占位 todo，会在 pinch 新增成功后转为 normal todo。
  LXMTodoItemUsagePullAdded,    ///< 通过下拉新增的占位 todo，会在下拉新增成功后转为 normal todo。
  LXMTodoItemUsageTapAdded,     ///< 通过 tap 新增的占位 todo，会在 tap 新增成功后转为 normal todo。
  LXMTodoItemUsagePlaceholder,  ///< 通过长按进入 todo 重排状态后产生的占位 todo，会在重排状态结束后移除。
//  LXMTodoItemUsageTodoList,         ///< 用来存储 todo list 的名字和其中未完成的 todo 数量
//  LXMTodoItemUsageMenu,             ///< 通过长按进入 todo 重排状态后产生的占位 todo，会在重排状态结束后移除。
//  LXMTodoItemUsageSwitch,         ///< 通过长按进入 todo 重排状态后产生的占位 todo，会在重排状态结束后移除。
//  LXMTodoItemUsageTheme,          ///< 通过长按进入 todo 重排状态后产生的占位 todo，会在重排状态结束后移除。
//  LXMTodoItemUsageTip,            ///< 通过长按进入 todo 重排状态后产生的占位 todo，会在重排状态结束后移除。
//  LXMTodoItemUsageLock,           ///< 通过长按进入 todo 重排状态后产生的占位 todo，会在重排状态结束后移除。
};

@interface LXMTodoItem : NSObject

@property (nonatomic, assign) LXMTodoItemUsage usage;
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, strong) NSString *text;

+ (instancetype)todoItemWithText:(NSString *)text;
+ (instancetype)todoItemWithUsage:(LXMTodoItemUsage)usage;

- (BOOL)toggleCompleted;

@end