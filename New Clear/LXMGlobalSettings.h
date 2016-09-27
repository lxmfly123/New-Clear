//
// Created by FLY.lxm on 2016.9.18.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSTimeInterval const LXMTableViewRowAnimationDurationNormal;
extern NSTimeInterval const LXMTableViewRowAnimationDurationLong;
extern NSTimeInterval const LXMTableViewRowAnimationDurationShort;

extern UIViewAnimationOptions const LXMKeyboardAnimationCurve;

@interface LXMGlobalSettings : NSObject

// size
@property (nonatomic, assign, readonly) CGFloat normalRowHeight;

@property (nonatomic, assign, readonly) CGFloat textFieldLeftPadding;
@property (nonatomic, assign, readonly) CGFloat textFieldLeftMargin;
@property (nonatomic, assign, readonly) CGFloat textFieldRightMargin;
@property (nonatomic, assign, readonly) CGFloat strikeThroughLineThickness;

@property (nonatomic, assign, readonly) CGFloat editCommitTriggerWidth; ///< 当水平拖动 cell 的距离超过该值时，就可认为此时结束手势的话 check 或删除操作可被执行。

// font & type
@property (nonatomic, assign, readonly) CGFloat rowFontSize;
@property (nonatomic, assign, readonly) CGFloat gestureHintFontSize;

// color & transparency
@property (nonatomic, strong, readonly) UIColor *listBaseColor; ///< 当行对应 todo 项被标记为未完成时，todolist 界面的行的基本背景色。
@property (nonatomic, strong, readonly) UIColor *itemBaseColor; ///< 当行对应 todo 项被标记为未完成时，todoitem 界面的行的基本背景色。
@property (nonatomic, assign, readonly) CGFloat rowColorHueOffset; ///< 相邻行背景色之间的 hue 差值，仅用于基本背景色。
@property (nonatomic, strong, readonly) UIColor *editingCompletedColor; ///< 当行对应 todo 项被标记为已完成时，以这种颜色显示。

// behaviors
@property (nonatomic, assign, readonly) CATransform3D addingTransform3DIdentity; ///< 新增 todo 时的对应行的 cell 的 3D 透视转换矩阵，m34 默认 -1/500.0f。


+ (instancetype)sharedInstance;

@end