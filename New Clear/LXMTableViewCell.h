//
// Created by FLY.lxm on 2016.9.18.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LXMTodoItem;
@class LXMTableViewCell;
@class LXMStrikeThroughText;

@protocol LXMTableViewCellDelegate <NSObject>

- (BOOL)tableViewCellShouldBeginTextEditing:(LXMTableViewCell *)cell;
- (void)tableViewCellDidBeginTextEditing:(LXMTableViewCell *)cell;
- (BOOL)tableViewCellShouldEndTextEditing:(LXMTableViewCell *)cell;
- (void)tableViewCellDidEndTextEditing:(LXMTableViewCell *)cell;

@end

typedef NS_ENUM(NSUInteger, LXMTableViewCellEditingState) {
  LXMTableViewCellEditingStateNormal,
  LXMTableViewCellEditingStateWillCheck,
  LXMTableViewCellEditingStateWillDelete,
  LXMTableViewCellEditingStateNone,
};

@interface LXMTableViewCell : UITableViewCell

@property (nonatomic, strong) LXMTodoItem *todoItem;
@property (nonatomic, strong) UIView *actualContentView;
@property (nonatomic, strong) LXMStrikeThroughText *strikeThroughText;
//@property (nonatomic, strong) UIColor *targetColor;
@property (nonatomic, assign) LXMTableViewCellEditingState editingState;
@property (nonatomic, weak) id <LXMTableViewCellDelegate> delegate;
@property  (nonatomic, assign) BOOL isModifying;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end